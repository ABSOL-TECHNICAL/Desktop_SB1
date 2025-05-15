import 'dart:io';

import 'package:excel/excel.dart' as excel;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/controllers/stocks_location_controller.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/branch_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/to_location_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/transferorder_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/widget/dropdown_radius.dart';
import 'package:impal_desktop/features/cyberwarehosue/widget/dropdown_widget.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:latlong2/latlong.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';

class StockCsvReports extends StatefulWidget {
  const StockCsvReports({super.key});
  static String routeName = '/stocks';

  @override
  _StockCsvReportsState createState() => _StockCsvReportsState();
}

class _StockCsvReportsState extends State<StockCsvReports> {
  final StocksLocationController stocksLocationController =
      Get.put(StocksLocationController());
  final RxList<String> highlightedItemNames = <String>[].obs;
  final ScrollController _scrollController = ScrollController();
  final double scrollAmount = 100.0;

  final List<int> radiusOptions = [100, 500, 800, 1000, 3000];
  int selectedRadius = 100;
  int visibleRowsCount = 10;

  String? selectedItem;
  String? selectedLocationName;
  String? selectedFileName = 'No file selected';
  bool shouldDisplayButton = false;
  int? _expandedTileIndex;
  double? selectedLocationLatitude;
  double? selectedLocationLongitude;
  List<List<dynamic>> tableData = [];
  bool isLoading = false;
  bool isCartReady = false;
  String? location;
  int? selectedLocationId;
  final int subsidiary = 2;
  Set<String> processedBranches = {};
  Map<String, int> balanceRequiredQuantities = {};

  RxList<Map<String, dynamic>> balanceRequiredQuantitiesList =
      RxList<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    stocksLocationController.fetchLocations();
  }

  @override
  void dispose() {
    stocksLocationController.clearData();
    _scrollController.dispose();
    stocksLocationController.transferOrderNumber.value = '';
    super.dispose();
  }

  int calculateRemainingQty(
      String itemId, int currentRequiredQty, Map<String, int> itemBalances) {
    if (itemBalances.containsKey(itemId)) {
      return itemBalances[itemId]!;
    }

    itemBalances[itemId] = currentRequiredQty;
    return currentRequiredQty;
  }

  Future<void> downloadExcel(List<List<dynamic>> tableData) async {
    try {
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Sheet1'];

      List<String> headers = [
        'Branch',
        'Supplier',
        'Item',
        'From Date',
        'To Date',
        'Request Required Qty'
      ];
      sheet.appendRow(headers.map((e) => excel.TextCellValue(e)).toList());

      for (var row in tableData) {
        sheet.appendRow(
            row.map((e) => excel.TextCellValue(e.toString())).toList());
      }

      String directoryPath;
      if (Platform.isWindows) {
        directoryPath = 'C:/Downloads';
      } else if (Platform.isLinux || Platform.isMacOS) {
        directoryPath = '${Directory.current.path}/Downloads';
      } else if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        directoryPath = directory.path;
      } else {
        throw Exception("Unsupported platform");
      }

      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final path = '$directoryPath/table_data.xlsx';
      final file = File(path);

      await file.writeAsBytes(excelFile.encode()!);

      AppSnackBar.success(message: "Excel file downloaded to $path");
    } catch (e) {
      AppSnackBar.alert(message: "Failed to download Excel: $e");
    }
  }

  void _triggerMinusButtonAction() {
    setState(() {
      for (var i = 0; i < tableData.length; i++) {
        var row = tableData[i];
        var balanceItem = balanceRequiredQuantitiesList.firstWhere(
          (entry) => entry['item'] == row[0].toString(),
          orElse: () => {'item': '', 'balanceRequiredQty': 0},
        );

        if (balanceItem['balanceRequiredQty'] != 0) {
          row[5] = balanceItem['balanceRequiredQty'].toString();
        }
      }
    });
  }

  Future<void> fetchItemsSequentially() async {
    for (var location in stocksLocationController.branch) {
      await stocksLocationController
          .fetchItemsFromBranch(location.locationId.toString());
    }
  }

  Future<void> _updateMapWithNewRadius(int newRadius) async {
    final mapController = Get.find<StocksLocationController>();

    if (selectedLocationName != null &&
        selectedLocationLatitude != null &&
        selectedLocationLongitude != null) {
      final selectedLocationId = stocksLocationController.locations
          .firstWhere(
            (location) => location.locationName == selectedLocationName,
          )
          .locationid;

      stocksLocationController.branch.clear();
      await mapController.fetchBranch(
          newRadius.toDouble() * 1000, selectedLocationId.toString());

      print('Updated radius to: $newRadius km');
      print('Location ID: $selectedLocationId');
    } else {
      print('No location selected.');
    }
  }

  Future<void> _pickXlsxFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = await file.readAsBytes();

      try {
        var myExcel = excel.Excel.decodeBytes(bytes);
        List<List<dynamic>> extractedData = [];
        List<String> row8Values = [];

        for (var table in myExcel.tables.keys) {
          for (var row in myExcel.tables[table]!.rows.skip(1)) {
            extractedData
                .add(row.map((cell) => cell?.value.toString() ?? '').toList());
          }
        }

        setState(() {
          selectedFileName = result.files.single.name;
          tableData = extractedData.skip(1).map((row) {
            row8Values.add(row[8]);
            return [row[4], row[1], row[0], row[2], row[3], row[7], row[8]];
          }).toList();

          location = extractedData.isNotEmpty ? extractedData[1][3] : '';
        });

        debugPrint('Row[8]: "${row8Values.join(",")}"');
        debugPrint('Location: $location');
        debugPrint('Filtered XLSX Data: $extractedData');

        final StocksLocationController stocksLocationController =
            Get.find<StocksLocationController>();
        stocksLocationController.updateRow8Values(row8Values);
      } catch (e) {
        AppSnackBar.alert(message: "Error reading XLSX: $e");
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Are you sure?',
            message: 'Do you want to leave this page?',
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
            onCancel: () {
              Navigator.of(context).pop(false);
            },
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title:  Text(
            'Transfer surplus stocks',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)
            // style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF161717),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 242, 246, 248),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickXlsxFile,
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'Upload File',
                                    hintText:
                                        (selectedFileName?.isEmpty ?? true)
                                            ? 'No file chosen'
                                            : selectedFileName,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                    labelStyle:   theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() {
                                if (location?.isNotEmpty ?? false) {
                                  selectedItem = location!;
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    for (var location
                                        in stocksLocationController.locations) {
                                      if (location.locationName ==
                                          selectedItem) {
                                        _handleLocationChange(location);
                                      }
                                    }
                                  });
                                }

                                if (stocksLocationController
                                    .locations.isEmpty) {
                                  return DropdownWidget(
                                    label: 'To Location',
                                    value: selectedItem,
                                    items: const [],
                                    onChanged: (newValue) {},
                                  );
                                }

                                final locationItems = stocksLocationController
                                    .locations
                                    .map((location) =>
                                        location.locationName ?? '')
                                    .toList();

                                return DropdownWidget(
                                  label: 'To Location',
                                  value: selectedItem,
                                  items: locationItems,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedItem = newValue;
                                      final selectedLocation =
                                          stocksLocationController.locations
                                              .firstWhere(
                                        (location) =>
                                            location.locationName == newValue,
                                      );
                                      _handleLocationChange(selectedLocation);
                                    });
                                  },
                                );
                              }),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownRadius(
                                label: 'Radius (KM)',
                                value: selectedRadius,
                                items: radiusOptions,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedRadius = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if ((selectedItem?.isEmpty ?? true)) {
                                  AppSnackBar.alert(
                                      message:
                                          "Please select the location and upload the file to Proceed");
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await _updateMapWithNewRadius(selectedRadius);
                                  setState(() {
                                    isLoading = false;
                                  });
                                  fetchItemsSequentially();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 50),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 6,
                                shadowColor: Colors.black.withOpacity(0.1),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Search',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (tableData.isNotEmpty)
                      Obx(() {
                        return Expanded(
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Stock Uploaded (${tableData.length} items)',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        // style: const TextStyle(
                                        //   fontWeight: FontWeight.bold,
                                        //   fontSize: 16,
                                        //   color: Colors.black,
                                        // ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _scrollController.animateTo(
                                                _scrollController.offset -
                                                    scrollAmount,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade300,
                                                    Colors.blue.shade700
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.chevron_left_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              _scrollController.animateTo(
                                                _scrollController.offset +
                                                    scrollAmount,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade300,
                                                    Colors.blue.shade700
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.chevron_right_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _scrollController,
                                    child: MouseRegion(
                                      child: DataTable(
                                        border: TableBorder.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        columnSpacing: 20.0,
                                        horizontalMargin: 16.0,
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                                Colors.blue.shade100),
                                        headingTextStyle:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                          // fontFamily: 'Roboto',
                                        ),

                                        //  TextStyle(
                                        //   fontWeight: FontWeight.bold,
                                        //   fontSize: 16,
                                        //   color: Colors.black,
                                        //   fontFamily: 'Roboto',
                                        // ),
                                        dataTextStyle:
                                            theme.textTheme.bodyLarge?.copyWith(
                                                // fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black87),
                                        //  const TextStyle(
                                        //   fontSize: 14,
                                        //   color: Colors.black87,
                                        //   fontFamily: 'Roboto',
                                        // ),
                                        columns: [
                                          DataColumn(
                                              label: Text(
                                            'Branch',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            //  TextStyle(
                                            //     fontWeight:
                                            //         FontWeight.bold)
                                          )),
                                          DataColumn(
                                              label: Text('Supplier',
                                              style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                                  // style: TextStyle(
                                                  //     fontWeight:
                                                  //         FontWeight.bold)
                                                          )),
                                          DataColumn(
                                              label: Text('Item',
                                                  style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                                  // TextStyle(
                                                  //     fontWeight:
                                                  //         FontWeight.bold)
                                                          )),
                                          DataColumn(
                                              label: Text('From Date',
                                                  style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                                  // TextStyle(
                                                  //     fontWeight:
                                                  //         FontWeight.bold)
                                                          )),
                                          DataColumn(
                                              label: Text('To Date',
                                                  style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),)),
                                          DataColumn(
                                              label: Text('Item ID',
                                                 style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),)),
                                          DataColumn(
                                              label: Text(
                                                  'Request Required Qty',
                                                 style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),)),
                                        ],
                                        rows: tableData
                                            .take(visibleRowsCount)
                                            .map((row) {
                                          var balanceItem =
                                              balanceRequiredQuantitiesList
                                                  .firstWhere(
                                            (entry) =>
                                                entry['item'] ==
                                                row[0].toString(),
                                            orElse: () => {
                                              'item': '',
                                              'balanceRequiredQty': 0
                                            },
                                          );

                                          return DataRow(
                                            cells: [
                                              DataCell(Text(row[4].toString())),
                                              DataCell(Text(row[2].toString())),
                                              DataCell(Text(row[0].toString())),
                                              DataCell(Text(row[1].toString())),
                                              DataCell(Text(row[3].toString())),
                                              DataCell(Text(row[6].toString())),
                                              DataCell(
                                                Text(
                                                  balanceItem['balanceRequiredQty'] ==
                                                          0
                                                      ? row[5].toString()
                                                      : balanceItem[
                                                              'balanceRequiredQty']
                                                          .toString(),
                                                 style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 100,
                                        child: shouldDisplayButton
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    for (var i = 0;
                                                        i < tableData.length;
                                                        i++) {
                                                      var row = tableData[i];
                                                      var balanceItem =
                                                          balanceRequiredQuantitiesList
                                                              .firstWhere(
                                                        (entry) =>
                                                            entry['item'] ==
                                                            row[0].toString(),
                                                        orElse: () => {
                                                          'item': '',
                                                          'balanceRequiredQty':
                                                              0
                                                        },
                                                      );

                                                      if (balanceItem[
                                                              'balanceRequiredQty'] !=
                                                          0) {
                                                        row[5] = balanceItem[
                                                                'balanceRequiredQty']
                                                            .toString();
                                                      }
                                                    }
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(100, 40),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: isLoading
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    :  Text(
                                                        'Minus',
                                                        style: theme.textTheme.bodyLarge
                                                ?.copyWith( color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                                        // style: TextStyle(
                                                        //   color: Colors.white,
                                                        //   fontWeight:
                                                        //       FontWeight.bold,
                                                        // ),
                                                      ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 150,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await downloadExcel(tableData);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(100, 40),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child:  Text(
                                            'Download CSV',
                                           style: theme.textTheme.bodyLarge
                                                ?.copyWith( color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 100,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              tableData.clear();
                                              highlightedItemNames.clear();
                                              visibleRowsCount = 10;
                                              isCartReady = false;

                                              stocksLocationController.branch
                                                  .clear();

                                              selectedFileName = '';
                                            });

                                            AppSnackBar.alert(
                                              message:
                                                  "CSV data and cart have been cleared.",
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(100, 40),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              :  Text(
                                                  'Clear CSV',
                                                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white,fontWeight: FontWeight.bold,)
                                                  // style: TextStyle(
                                                  //   color: Colors.white,
                                                  //   fontWeight: FontWeight.bold,
                                                  // ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      if (tableData.length > 10)
                                        SizedBox(
                                          width: 100,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                visibleRowsCount =
                                                    (visibleRowsCount == 10)
                                                        ? tableData.length
                                                        : 10;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(100, 40),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    visibleRowsCount == 10
                                                        ? 'Load More'
                                                        : 'Show Less',
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    const VerticalDivider(
                      color: Colors.grey,
                      thickness: 1,
                      width: 10,
                    ),
                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                final branchCount =
                                    stocksLocationController.branch.length;
                                return Text(
                                  'Available Branches Nearby ($branchCount)',
                                  style:  theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),
                              Obx(() {
                                if (stocksLocationController.branch.isEmpty) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.black,
                                    highlightColor: Colors.grey.shade100,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 53, 51, 51),
                                            highlightColor: Colors.white,
                                            child: Icon(
                                              Icons.search_off,
                                              size: 120,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 53, 51, 51),
                                            highlightColor: Colors.white,
                                            child:  Text(
                                              'No results found.\nPlease upload a file and set the radius to load nearby branches.',
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                    255, 10, 10, 10),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (stocksLocationController
                                        .branch.isNotEmpty &&
                                    stocksLocationController
                                        .fetchedItemsPerLocation.isEmpty) {
                                  fetchItemsSequentially();
                                }

                                List<Widget> locationCards =
                                    stocksLocationController.branch
                                        .map<Widget>((location) {
                                  int index = stocksLocationController.branch
                                      .indexOf(location);
                                  String locationId =
                                      location.locationId.toString();

                                  return Obx(() {
                                    var items = stocksLocationController
                                        .fetchedItemsPerLocation[locationId];

                                    int highlightedItemCount = 0;
                                    Set<String> highlightedItems = {};

                                    if (items != null) {
                                      for (var item in items) {
                                        tableData.any((row) {
                                          if (!highlightedItems.contains(
                                                  row[0].toString()) &&
                                              row[0].toString() ==
                                                  item['item'].toString()) {
                                            highlightedItems
                                                .add(row[0].toString());
                                            highlightedItemCount++;
                                            return true;
                                          }
                                          return false;
                                        });
                                      }
                                    }

                                    // If no highlighted items, return an empty container (hide the card)
                                    if (highlightedItemCount == 0) {
                                      return const SizedBox(); // This will remove the card
                                    }

                                    return AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: ExpansionTile(
                                        title: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blue, width: 1.5),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      location.locationName ??
                                                          'Unknown Location',
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    if (items == null)
                                                      Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                                height: 10),
                                                            Shimmer.fromColors(
                                                              baseColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      53,
                                                                      51,
                                                                      51),
                                                              highlightColor:
                                                                  Colors.white,
                                                              child:  Text(
                                                                'Fetching item please wait',
                                                                style: theme.textTheme.bodyLarge
                                                ?.copyWith(  fontSize: 13,
                                                                   color: Color
                                                                       .fromARGB(
                                                                           255,
                                                                           10,
                                                                           10,
                                                                           10),
                                            ),
                                                                // style:
                                                                //     TextStyle(
                                                                //   fontSize: 13,
                                                                //   color: Color
                                                                //       .fromARGB(
                                                                //           255,
                                                                //           10,
                                                                //           10,
                                                                //           10),
                                                                // ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    else ...[
                                                      RichText(
                                                        text: TextSpan(
                                                          style: theme.textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),
                                                          children: [
                                                            const TextSpan(
                                                                text:
                                                                    'Available Item Matched: '),
                                                            TextSpan(
                                                              text:
                                                                  '$highlightedItemCount',
                                                                    style: theme.textTheme.bodyLarge
                                                ?.copyWith( fontWeight: FontWeight.bold),
                                                              // style: const TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.refresh,
                                                    color: Colors.blue),
                                                onPressed: () async {
                                                  await stocksLocationController
                                                      .fetchItemsFromBranch(
                                                          locationId);
                                                  AppSnackBar.success(
                                                    message:
                                                        "Data reloaded for location: ${location.locationName ?? 'Unknown Location'}",
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        onExpansionChanged: (expanded) {
                                          if (expanded) {
                                            setState(() {
                                              _expandedTileIndex = index;
                                            });
                                            debugPrint(
                                                "Selected branch: ${location.locationName ?? 'Unknown Location'}");
                                          } else {
                                            setState(() {
                                              _expandedTileIndex = null;
                                            });
                                          }
                                        },
                                        children: [
                                          if (_expandedTileIndex == index) ...[
                                            Obx(() {
                                              var items = stocksLocationController
                                                      .fetchedItemsPerLocation[
                                                  locationId];

                                              if (items == null ||
                                                  items.isEmpty) {
                                                return  Center(
                                                  child: Text(
                                                    "No items available for this location.",
                                                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black)
                                                    // style: TextStyle(
                                                    //     color: Colors.black),
                                                  ),
                                                );
                                              }

                                              List<DataRow> highlightedRows =
                                                  [];

                                              for (var item in items) {
                                                String itemName =
                                                    item['item'].toString();
                                                int requiredQty = 0;
                                                String planningId = "";

                                                for (var row in tableData) {
                                                  if (row[0].toString() ==
                                                      itemName) {
                                                    requiredQty = int.tryParse(
                                                            row[5]
                                                                .toString()) ??
                                                        0;
                                                    planningId =
                                                        row[4].toString();
                                                    break;
                                                  }
                                                }

                                                if (requiredQty <= 0) continue;

                                                int accumulatedQty = 0;
                                                List<int>
                                                    highlightedItemIndexes = [];

                                                for (int index = 0;
                                                    index < items.length;
                                                    index++) {
                                                  var branchItem = items[index];
                                                  if (branchItem['item'] ==
                                                      itemName) {
                                                    int onhandQty =
                                                        int.tryParse(branchItem[
                                                                    'onhand']
                                                                .toString()) ??
                                                            0;
                                                    accumulatedQty += onhandQty;

                                                    if (accumulatedQty <=
                                                        requiredQty) {
                                                      highlightedItemIndexes
                                                          .add(index);
                                                    } else {
                                                      int remainingQty =
                                                          requiredQty -
                                                              (accumulatedQty -
                                                                  onhandQty);
                                                      if (remainingQty > 0) {
                                                        highlightedItemIndexes
                                                            .add(index);
                                                      }
                                                      break;
                                                    }
                                                  }
                                                }

                                                bool shouldHighlightRow =
                                                    highlightedItemIndexes
                                                        .contains(items
                                                            .indexOf(item));

                                                if (shouldHighlightRow) {
                                                  highlightedRows.add(DataRow(
                                                    cells: [
                                                      DataCell(Text(
                                                          item['item']
                                                              .toString(),
                                                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                          // style:
                                                          //     const TextStyle(
                                                          //         color: Colors
                                                          //             .black))),
                                                      DataCell(Text(
                                                          item['ConsigmentNumber']
                                                              .toString(),
                                                               style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                          // style:
                                                          //     const TextStyle(
                                                          //         color: Colors
                                                          //             .black))),
                                                      DataCell(Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              item['onhand']
                                                                  .toString(),
                                                                   style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black)))),
                                                              // style: const TextStyle(
                                                              //     color: Colors
                                                              //         .black)))),
                                                      DataCell(Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              item['purchasePrice']
                                                                  .toString(),
                                                                   style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black)))),
                                                              // style: const TextStyle(
                                                              //     color: Colors
                                                              //         .black)))),
                                                      DataCell(Text(planningId,
                                                       style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                          // style:
                                                          //     const TextStyle(
                                                          //         color: Colors
                                                          //             .black))),
                                                    ],
                                                    color: MaterialStateProperty
                                                        .all(const Color(
                                                            0xFFFFF9C4)),
                                                  ));
                                                }
                                              }

                                              if (highlightedRows.isEmpty) {
                                                return  Center(
                                                  child: Text(
                                                    "No highlighted items available.",
                                                     style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
                                                    // style: TextStyle(
                                                    //     color: Colors.black),
                                                  ),
                                                );
                                              }

                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DataTable(
                                                  columns:  [
                                                    DataColumn(
                                                        label: Text('Item',
                                                         style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                            // style: TextStyle(
                                                            //     color: Colors
                                                            //         .black))),
                                                    DataColumn(
                                                        label: Text(
                                                            'Item Con No',
                                                             style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                            // style: TextStyle(
                                                            //     color: Colors
                                                            //         .black))),
                                                    DataColumn(
                                                        label: Text('On Hand',
                                                         style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                            // style: TextStyle(
                                                            //     color: Colors
                                                            //         .black))),
                                                    DataColumn(
                                                        label: Text(
                                                            'Purchase Price',
                                                             style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                            // style: TextStyle(
                                                            //     color: Colors
                                                            //         .black))),
                                                    DataColumn(
                                                        label: Text(
                                                            'Planning ID',
                                                             style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black))),
                                                            // style: TextStyle(
                                                            //     color: Colors
                                                            //         .black))),
                                                  ],
                                                  rows: highlightedRows,
                                                ),
                                              );
                                            }),
                                          ],
                                        ],
                                      ),
                                    );
                                  });
                                }).toList();

                                return ListView(
                                    shrinkWrap: true, children: locationCards);
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The item has been added to the cart',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          var highlightedItemsByBranch =
                              <String, List<Map<String, dynamic>>>{};

                          for (var location
                              in stocksLocationController.branch) {
                            var items = stocksLocationController
                                    .fetchedItemsPerLocation[
                                location.locationId.toString()];
                            if (items != null) {
                              for (var item in items) {
                                String itemName = item['item'].toString();
                                int requiredQty = 0;

                                for (var row in tableData) {
                                  if (row[0].toString() == itemName) {
                                    requiredQty =
                                        int.tryParse(row[5].toString()) ?? 0;
                                    break;
                                  }
                                }

                                if (requiredQty > 0) {
                                  int accumulatedQty = 0;
                                  List<int> highlightedRows = [];
                                  List<String> takenQuantitiesMessages = [];

                                  for (int index = 0;
                                      index < items.length;
                                      index++) {
                                    var branchItem = items[index];
                                    if (branchItem['item'] == itemName) {
                                      int onhandQty = int.tryParse(
                                              branchItem['onhand']
                                                  .toString()) ??
                                          0;

                                      // debugPrint(
                                      //     "\x1B[38;2;255;165;0mAccumulating for item $itemName: Adding onhandQty $onhandQty (Accumulated: $accumulatedQty)\x1B[0m");

                                      accumulatedQty += onhandQty;

                                      // debugPrint(
                                      //     "\x1B[38;2;255;165;0mAfter adding $onhandQty, accumulated quantity: $accumulatedQty\x1B[0m");

                                      if (accumulatedQty <= requiredQty) {
                                        highlightedRows.add(index);
                                        takenQuantitiesMessages.add(
                                            'Added $onhandQty from consignment ${branchItem['ConsigmentNumber']}');
                                        // debugPrint(
                                        //     "\x1B[33mAdded $onhandQty from consignment ${branchItem['ConsigmentNumber']} to accumulate. Total accumulated: $accumulatedQty\x1B[0m");
                                      } else {
                                        int takenQty = requiredQty -
                                            (accumulatedQty - onhandQty);
                                        if (takenQty > 0) {
                                          highlightedRows.add(index);
                                          takenQuantitiesMessages.add(
                                              'Added $takenQty from consignment ${branchItem['ConsigmentNumber']}');
                                          // debugPrint(
                                          //     "\x1B[33mAdded $takenQty from consignment ${branchItem['ConsigmentNumber']} to reach the required quantity. Total accumulated: $accumulatedQty\x1B[0m");
                                        }
                                        debugPrint(
                                            "\x1B[32mRequired quantity reached! Stopping accumulation for $itemName.\x1B[0m");
                                        break;
                                      }
                                    }
                                  }

                                  if (highlightedRows
                                      .contains(items.indexOf(item))) {
                                    highlightedItemsByBranch.putIfAbsent(
                                        location.locationName ??
                                            'Unknown Location',
                                        () => []);

                                    highlightedItemsByBranch[
                                            location.locationName]!
                                        .add({
                                      'item': item,
                                      'requiredQty': requiredQty,
                                      'takenQuantitiesMessages':
                                          takenQuantitiesMessages,
                                    });
                                  }
                                }
                              }
                            }
                          }

                          if (highlightedItemsByBranch.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Shimmer.fromColors(
                                    baseColor:
                                        const Color.fromARGB(255, 53, 51, 51),
                                    highlightColor: Colors.white,
                                    child: Icon(
                                      Icons.remove_shopping_cart,
                                      size: 70,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Shimmer.fromColors(
                                    baseColor:
                                        const Color.fromARGB(255, 53, 51, 51),
                                    highlightColor: Colors.white,
                                    child:  Text(
                                      'No Surplus items have been added to the cart yet.',
                                      style:  theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 10, 10, 10),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Sort branches by total amount in descending order
                          final sortedBranches = highlightedItemsByBranch.keys
                              .toList()
                            ..sort(
                              (a, b) {
                                double totalAmountA =
                                    highlightedItemsByBranch[a]!.fold(
                                  0.0,
                                  (sum, highlightedItem) {
                                    var takenQuantitiesMessages =
                                        highlightedItem[
                                            'takenQuantitiesMessages'];
                                    var item = highlightedItem['item'];
                                    double purchasePrice = double.tryParse(
                                            item['purchasePrice'].toString()) ??
                                        0.0;
                                    double itemAmount =
                                        takenQuantitiesMessages.fold(
                                      0.0,
                                      (innerSum, message) {
                                        final quantityMatch =
                                            RegExp(r'Added (\d+)')
                                                .firstMatch(message.toString());
                                        final quantity = quantityMatch != null
                                            ? int.tryParse(
                                                quantityMatch.group(1) ?? '0')
                                            : 0;
                                        return innerSum +
                                            (quantity! * purchasePrice);
                                      },
                                    );
                                    return sum + itemAmount;
                                  },
                                );

                                double totalAmountB =
                                    highlightedItemsByBranch[b]!.fold(
                                  0.0,
                                  (sum, highlightedItem) {
                                    var takenQuantitiesMessages =
                                        highlightedItem[
                                            'takenQuantitiesMessages'];
                                    var item = highlightedItem['item'];
                                    double purchasePrice = double.tryParse(
                                            item['purchasePrice'].toString()) ??
                                        0.0;
                                    double itemAmount =
                                        takenQuantitiesMessages.fold(
                                      0.0,
                                      (innerSum, message) {
                                        final quantityMatch =
                                            RegExp(r'Added (\d+)')
                                                .firstMatch(message.toString());
                                        final quantity = quantityMatch != null
                                            ? int.tryParse(
                                                quantityMatch.group(1) ?? '0')
                                            : 0;
                                        return innerSum +
                                            (quantity! * purchasePrice);
                                      },
                                    );
                                    return sum + itemAmount;
                                  },
                                );

                                return totalAmountB.compareTo(
                                    totalAmountA); // Descending order
                              },
                            );

                          return DefaultTabController(
                            length: sortedBranches.length,
                            child: Column(children: [
                              TabBar(
                                isScrollable: true,
                                tabs: sortedBranches.map((branchName) {
                                  double totalAmount =
                                      highlightedItemsByBranch[branchName]!
                                          .fold(
                                    0.0,
                                    (sum, highlightedItem) {
                                      var takenQuantitiesMessages =
                                          highlightedItem[
                                              'takenQuantitiesMessages'];
                                      var item = highlightedItem['item'];
                                      double purchasePrice = double.tryParse(
                                              item['purchasePrice']
                                                  .toString()) ??
                                          0.0;
                                      double itemAmount =
                                          takenQuantitiesMessages.fold(
                                        0.0,
                                        (innerSum, message) {
                                          final quantityMatch =
                                              RegExp(r'Added (\d+)').firstMatch(
                                                  message.toString());
                                          final quantity = quantityMatch != null
                                              ? int.tryParse(
                                                  quantityMatch.group(1) ?? '0')
                                              : 0;
                                          return innerSum +
                                              (quantity! * purchasePrice);
                                        },
                                      );
                                      return sum + itemAmount;
                                    },
                                  );
                                  final isProcessed =
                                      processedBranches.contains(branchName);

                                  stocksLocationController.branch.firstWhere(
                                    (location) =>
                                        location.locationName == branchName,
                                    orElse: () => BranchModel(
                                      locationId: -1,
                                      locationName: branchName,
                                    ),
                                  );

                                  return Tab(
                                    text:
                                        null, // Remove the text parameter as we use Text.rich
                                    icon: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: isProcessed
                                          ? const Icon(
                                              Icons.check_circle,
                                              key: ValueKey('check'),
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              Icons.location_on,
                                              key: ValueKey('location'),
                                            ),
                                    ),
                                    iconMargin:
                                        const EdgeInsets.only(right: 8.0),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '$branchName \n (',
                                             style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
                                            // style: const TextStyle(
                                            //     color: Colors
                                            //         .black), // Default color
                                          ),
                                          TextSpan(
                                            text:
                                                totalAmount.toStringAsFixed(2),
                                                 style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                                            // style: const TextStyle(
                                            //     color: Colors
                                            //         .red), // Red color for totalAmount
                                          ),
                                           TextSpan(
                                            text: ')',
                                             style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
                                            // style: TextStyle(
                                            //     color: Colors
                                            //         .black), // Default color
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.black,
                                indicatorColor: Colors.blue,
                                labelStyle: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                indicatorSize: TabBarIndicatorSize.label,
                                indicatorWeight: 3.0,
                                indicatorPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                overlayColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                splashFactory: NoSplash.splashFactory,
                                onTap: (index) {
                                  final branchName = highlightedItemsByBranch
                                      .keys
                                      .elementAt(index);
                                  if (processedBranches.contains(branchName)) {}
                                },
                              ),
                              SizedBox(
                                height: 400,
                                child: TabBarView(
                                  children: sortedBranches.map((branchName) {
                                    var branchItems =
                                        highlightedItemsByBranch[branchName]!;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Total Amount: ",
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: branchItems
                                                          .fold(0.0, (sum,
                                                              highlightedItem) {
                                                        var takenQuantitiesMessages =
                                                            highlightedItem[
                                                                'takenQuantitiesMessages'];
                                                        var item =
                                                            highlightedItem[
                                                                'item'];
                                                        double purchasePrice =
                                                            double.tryParse(item[
                                                                        'purchasePrice']
                                                                    .toString()) ??
                                                                0.0;
                                                        double itemAmount =
                                                            takenQuantitiesMessages
                                                                .fold(0.0,
                                                                    (innerSum,
                                                                        message) {
                                                          final quantityMatch = RegExp(
                                                                  r'Added (\d+)')
                                                              .firstMatch(message
                                                                  .toString());
                                                          final quantity =
                                                              quantityMatch !=
                                                                      null
                                                                  ? int.tryParse(
                                                                          quantityMatch.group(1) ??
                                                                              '0') ??
                                                                      0
                                                                  : 0;
                                                          return innerSum +
                                                              (quantity *
                                                                  purchasePrice);
                                                        });
                                                        return sum + itemAmount;
                                                      }).toStringAsFixed(2),
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Transfer Order Number: ",
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  if (processedBranches
                                                      .contains(branchName))
                                                    Obx(() {
                                                      final controller = Get.find<
                                                          StocksLocationController>();
                                                      final branchTO =
                                                          controller.branch
                                                              .firstWhere(
                                                                (location) =>
                                                                    location
                                                                        .locationName ==
                                                                    branchName,
                                                                orElse: () =>
                                                                    BranchModel(
                                                                        locationId:
                                                                            -1,
                                                                        locationName:
                                                                            ''),
                                                              )
                                                              .locationName;

                                                      return Text(
                                                        branchTO == branchName &&
                                                                controller
                                                                    .transferOrderNumber
                                                                    .value
                                                                    .isNotEmpty
                                                            ? controller
                                                                .transferOrderNumber
                                                                .value
                                                            : 'N/A',
                                                        style: theme.textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                        ),
                                                      );
                                                    }),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              height: 400,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: DataTable(
                                                  border: TableBorder.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1,
                                                  ),
                                                  columnSpacing: 20.0,
                                                  horizontalMargin: 16.0,
                                                  headingRowColor:
                                                      MaterialStateProperty.all(
                                                    processedBranches.contains(
                                                            branchName)
                                                        ? const Color.fromARGB(
                                                            255, 143, 226, 144)
                                                        : Colors.blue.shade100,
                                                  ),
                                                  headingTextStyle:
                                                     theme.textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    // fontFamily: 'Roboto',
                                                  ),
                                                  dataTextStyle:
                                                      theme.textTheme.bodyLarge?.copyWith(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                  columns: [
                                                    const DataColumn(
                                                        label: Text('Item')),
                                                    const DataColumn(
                                                        label: Text('On hand')),
                                                    const DataColumn(
                                                        label: Text(
                                                            'Purchase Price')),
                                                    const DataColumn(
                                                        label: Text(
                                                            'Required Qty')),
                                                    const DataColumn(
                                                        label: Text(
                                                            'Quantity Added')),
                                                    const DataColumn(
                                                        label: Text('Amount')),
                                                    const DataColumn(
                                                        label: Text(
                                                            'Consignment Number')),
                                                    const DataColumn(
                                                        label: Text(
                                                            'Consignment ID')),
                                                    if (!processedBranches
                                                        .contains(branchName))
                                                      const DataColumn(
                                                          label: Text(
                                                              'Balance Required Qty')),
                                                  ],
                                                  rows: branchItems
                                                      .map((highlightedItem) {
                                                    var item =
                                                        highlightedItem['item'];
                                                    var originalRequiredQty =
                                                        highlightedItem[
                                                            'requiredQty'];
                                                    var takenQuantitiesMessages =
                                                        highlightedItem[
                                                            'takenQuantitiesMessages'];

                                                    int totalQuantityAdded = 0;
                                                    double totalAmount = 0.0;
                                                    String? consignmentNumber;
                                                    String? consignmentId =
                                                        item['ConsignmentID']
                                                            ?.toString();

                                                    for (var message
                                                        in takenQuantitiesMessages) {
                                                      if (message
                                                          .toString()
                                                          .contains(item[
                                                              'ConsigmentNumber'])) {
                                                        final quantityMatch = RegExp(
                                                                r'Added (\d+)')
                                                            .firstMatch(message
                                                                .toString());
                                                        if (quantityMatch !=
                                                            null) {
                                                          final quantity = int.tryParse(
                                                                  quantityMatch
                                                                          .group(
                                                                              1) ??
                                                                      '0') ??
                                                              0;
                                                          final purchasePrice =
                                                              double.tryParse(item[
                                                                          'purchasePrice']
                                                                      .toString()) ??
                                                                  0.0;
                                                          totalQuantityAdded +=
                                                              quantity;
                                                          totalAmount +=
                                                              quantity *
                                                                  purchasePrice;
                                                          consignmentNumber =
                                                              item['ConsigmentNumber'] ??
                                                                  'N/A';
                                                        }
                                                      }
                                                    }

                                                    int adjustedRequiredQty =
                                                        calculateRemainingQty(
                                                      item['item'].toString(),
                                                      originalRequiredQty,
                                                      {},
                                                    );
                                                    int balanceRequiredQty =
                                                        adjustedRequiredQty -
                                                            totalQuantityAdded;

                                                    bool isProcessedBranch =
                                                        processedBranches
                                                            .contains(
                                                                branchName);

                                                    return DataRow(
                                                      cells: [
                                                        DataCell(Text(
                                                            item['item']
                                                                .toString())),
                                                        DataCell(Text(
                                                            item['onhand']
                                                                .toString())),
                                                        DataCell(Text(item[
                                                                'purchasePrice']
                                                            .toString())),
                                                        DataCell(Text(
                                                            adjustedRequiredQty
                                                                .toString())),
                                                        DataCell(Text(
                                                            totalQuantityAdded
                                                                .toString())),
                                                        DataCell(Text(totalAmount
                                                            .toStringAsFixed(
                                                                2))),
                                                        DataCell(Text(
                                                            consignmentNumber ??
                                                                'N/A')),
                                                        DataCell(Text(
                                                            consignmentId ??
                                                                'N/A')),
                                                        if (!isProcessedBranch)
                                                          DataCell(
                                                            Text(
                                                              balanceRequiredQty
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: highlightedItem ==
                                                                        branchItems.lastWhere(
                                                                          (row) =>
                                                                              row['item']['item'] ==
                                                                              item['item'],
                                                                        )
                                                                    ? Colors.red
                                                                    : Colors.black,
                                                                fontWeight:
                                                                    highlightedItem ==
                                                                            branchItems
                                                                                .lastWhere(
                                                                              (row) => row['item']['item'] == item['item'],
                                                                            )
                                                                        ? FontWeight
                                                                            .bold
                                                                        : FontWeight
                                                                            .normal,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                      color: MaterialStateProperty
                                                          .resolveWith<
                                                              Color>((Set<
                                                                  MaterialState>
                                                              states) {
                                                        return isProcessedBranch
                                                            ? Colors
                                                                .grey.shade200
                                                            : Colors.white;
                                                      }),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Obx(
                                            () => ElevatedButton(
                                              onPressed:
                                                  stocksLocationController
                                                              .isLoading
                                                              .value ||
                                                          processedBranches
                                                              .contains(
                                                                  branchName)
                                                      ? null
                                                      : () async {
                                                          balanceRequiredQuantitiesList
                                                              .clear();
                                                          Map<String, int>
                                                              balanceRequiredQuantities =
                                                              {};

                                                          for (var highlightedItem
                                                              in branchItems) {
                                                            var item =
                                                                highlightedItem[
                                                                    'item'];
                                                            var originalRequiredQty =
                                                                highlightedItem[
                                                                    'requiredQty'];
                                                            var takenQuantitiesMessages =
                                                                highlightedItem[
                                                                    'takenQuantitiesMessages'];
                                                            int totalQuantityAdded =
                                                                0;
                                                            for (var message
                                                                in takenQuantitiesMessages) {
                                                              final quantityMatch = RegExp(
                                                                      r'Added (\d+)')
                                                                  .firstMatch(
                                                                      message
                                                                          .toString());
                                                              if (quantityMatch !=
                                                                  null) {
                                                                totalQuantityAdded +=
                                                                    int.tryParse(quantityMatch.group(1) ??
                                                                            '0') ??
                                                                        0;
                                                              }
                                                            }
                                                            int balanceRequiredQty =
                                                                originalRequiredQty -
                                                                    totalQuantityAdded;
                                                            balanceRequiredQuantities[
                                                                    item[
                                                                        'item']] =
                                                                (balanceRequiredQuantities[
                                                                            item['item']] ??
                                                                        0) +
                                                                    balanceRequiredQty;
                                                            if (!balanceRequiredQuantitiesList
                                                                .any((entry) =>
                                                                    entry[
                                                                        'item'] ==
                                                                    item[
                                                                        'item'])) {
                                                              balanceRequiredQuantitiesList
                                                                  .add({
                                                                'item': item[
                                                                    'item'],
                                                                'balanceRequiredQty':
                                                                    balanceRequiredQty,
                                                              });
                                                            }
                                                            print(
                                                                'Item: ${item['item']}, Original Required Qty: $originalRequiredQty, Balance Required Qty: $balanceRequiredQty');
                                                          }

                                                          print(
                                                              'Final Balance Required Quantities: $balanceRequiredQuantitiesList');

                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title:
                                                                     Row(
                                                                  children: [
                                                                    Text(
                                                                      'Confirmation',
                                                                      style:  theme.textTheme.bodyLarge?.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .warning,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          218,
                                                                          202,
                                                                          61),
                                                                    ),
                                                                  ],
                                                                ),
                                                                content:
                                                                    const SizedBox(
                                                                  width: 400,
                                                                  child: Text(
                                                                    'Are you sure you want to create a transfer order?',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      foregroundColor:
                                                                          Colors
                                                                              .red,
                                                                      side: const BorderSide(
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                            'No'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      stocksLocationController
                                                                          .isLoading
                                                                          .value = true;

                                                                      var branchId = stocksLocationController
                                                                          .branch
                                                                          .firstWhere(
                                                                            (location) =>
                                                                                location.locationName ==
                                                                                branchName,
                                                                            orElse: () =>
                                                                                BranchModel(locationId: -1, locationName: branchName),
                                                                          )
                                                                          .locationId;

                                                                      List<Map<String, dynamic>>
                                                                          allItems =
                                                                          [];

                                                                      for (var highlightedItem
                                                                          in branchItems) {
                                                                        var item =
                                                                            highlightedItem['item'];
                                                                        var takenQuantitiesMessages =
                                                                            highlightedItem['takenQuantitiesMessages'];
                                                                        String
                                                                            consignmentNumber =
                                                                            item['ConsigmentNumber'] ??
                                                                                'N/A';
                                                                        String
                                                                            consignmentId =
                                                                            item['ConsignmentID']?.toString() ??
                                                                                'N/A';
                                                                        String
                                                                            itemId =
                                                                            item['itemId']?.toString() ??
                                                                                'N/A';

                                                                        final filteredMessages = takenQuantitiesMessages
                                                                            .where((message) =>
                                                                                message.toString().contains(consignmentNumber))
                                                                            .toList();

                                                                        double
                                                                            totalQuantity =
                                                                            0;
                                                                        double
                                                                            totalAmount =
                                                                            0.0;

                                                                        for (var message
                                                                            in filteredMessages) {
                                                                          final quantityMatch =
                                                                              RegExp(r'Added (\d+)').firstMatch(message.toString());
                                                                          if (quantityMatch !=
                                                                              null) {
                                                                            final quantity =
                                                                                int.tryParse(quantityMatch.group(1) ?? '0') ?? 0;
                                                                            final double
                                                                                purchasePrice =
                                                                                double.tryParse(item['purchasePrice'].toString()) ?? 0.0;
                                                                            final double
                                                                                amount =
                                                                                quantity * purchasePrice;
                                                                            totalQuantity +=
                                                                                quantity;
                                                                            totalAmount +=
                                                                                amount;
                                                                          }
                                                                        }

                                                                        totalAmount = totalAmount
                                                                            .toInt()
                                                                            .toDouble();

                                                                        allItems
                                                                            .add({
                                                                          'itemId':
                                                                              itemId,
                                                                          'totalAmount':
                                                                              totalAmount,
                                                                          'quantityAdded':
                                                                              totalQuantity,
                                                                          'consignmentId':
                                                                              consignmentId,
                                                                        });
                                                                      }

                                                                      TransferOrderModel
                                                                          order =
                                                                          TransferOrderModel(
                                                                        tolocation:
                                                                            selectedLocationId,
                                                                        subsidiary:
                                                                            subsidiary,
                                                                        branchid:
                                                                            branchId,
                                                                        items: allItems
                                                                            .map((entry) {
                                                                          return ItemDetail(
                                                                            itemId:
                                                                                int.tryParse(entry['itemId']),
                                                                            totalAmount:
                                                                                entry['totalAmount'],
                                                                            quantityAdded:
                                                                                entry['quantityAdded']?.toInt(),
                                                                            consignmentId:
                                                                                entry['consignmentId'],
                                                                          );
                                                                        }).toList(),
                                                                      );

                                                                      await stocksLocationController.sendTransactionRequest(
                                                                          order:
                                                                              order);
                                                                      _triggerMinusButtonAction();
                                                                      processedBranches
                                                                          .add(
                                                                              branchName);
                                                                    },
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      foregroundColor:
                                                                          Colors
                                                                              .green,
                                                                      side: const BorderSide(
                                                                          color:
                                                                              Colors.green),
                                                                    ),
                                                                    child: stocksLocationController
                                                                            .isLoading
                                                                            .value
                                                                        ? const CircularProgressIndicator()
                                                                        : const Text(
                                                                            'Yes'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(80, 40),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                backgroundColor: Colors.green,
                                              ),
                                              child: stocksLocationController
                                                      .isLoading.value
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.black,
                                                        strokeWidth: 3,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Create Transfer Order'),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ]),
                          );
                        }),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLocationChange(FromCyberLocation selectedLocation) {
    if (selectedLocation.latitude != null &&
        selectedLocation.longitude != null) {
      selectedLocationName = selectedLocation.locationName;
      selectedLocationLatitude = selectedLocation.latitude;
      selectedLocationLongitude = selectedLocation.longitude;
      final newCenter = LatLng(
        selectedLocation.latitude!,
        selectedLocation.longitude!,
      );

      final mapController = Get.find<StocksLocationController>();
      mapController.updateMapCenter(newCenter);
      mapController.center = newCenter;

      final locationId = int.tryParse(selectedLocation.locationid.toString());

      if (locationId != null) {
        selectedLocationId = locationId;

        // print('Selected Location: ${selectedLocation.locationName}');
        // print('Latitude: ${selectedLocation.latitude}');
        // print('Longitude: ${selectedLocation.longitude}');
        // print('Location ID: $locationId');
      } else {
        print('Error: Invalid location ID');
      }
    }
  }
}
