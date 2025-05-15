import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/controllers/stocks_location_controller.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/branch_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/transferorder_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/widget/dropdown_radius.dart';
import 'package:impal_desktop/features/cyberwarehosue/widget/dropdown_widget.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:latlong2/latlong.dart';

import 'package:shimmer/shimmer.dart';

class Worksheet extends StatefulWidget {
  const Worksheet({super.key});
  static String routeName = '/Worksheet';

  @override
  _WorksheetState createState() => _WorksheetState();
}

class _WorksheetState extends State<Worksheet> {
  final StocksLocationController stocksLocationController =
      Get.put(StocksLocationController());

  final RxList<String> highlightedItemNames = <String>[].obs;
  final ScrollController _scrollController = ScrollController();
  final double scrollAmount = 100.0;

  final StocksLocationController controller =
      Get.find<StocksLocationController>();

  final List<int> radiusOptions = [100, 500, 800, 1000, 3000];
  int selectedRadius = 100;
  int visibleRowsCount = 10;
  int sNo = 1;

  String? selectedItem;
  String? selectedLocationName;
  String? selectedFileName = 'No file selected';
  bool shouldDisplayButton = false;

  double? selectedLocationLatitude;
  double? selectedLocationLongitude;

  bool isLoading = false;
  bool isCartReady = false;
  int? _expandedTileIndex;
  String? location;
  int? selectedLocationId;
  final int subsidiary = 2;
  Set<String> processedBranches = {};

  Map<String, int> balanceRequiredQuantities = {};
  Map<String, int> balanceitems = {};

  RxList<Map<String, dynamic>> balanceRequiredQuantitiesList =
      RxList<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();

    fetchData();
  }

 void restartPage() {

 Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => Worksheet()),
  );

}
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    await stocksLocationController.fetchLocations();
    await stocksLocationController.fetchSupplier();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
     controller.fetchedItems.clear();
    _scrollController.dispose();
     stocksLocationController.clearData();
    super.dispose();
  }

  void _fetchDataOnSelection() async {
    final supplierId = stocksLocationController.selectedSupplierId.value;
    final locationId = selectedLocationId;

    if (supplierId.isNotEmpty &&
        (locationId != null && locationId.toString().isNotEmpty)) {
      print('Selected Supplier ID: $supplierId');
      print('Selected Location ID: $locationId');

      await stocksLocationController.fetchWorkSheetstocks(
          supplierId, locationId.toString());
    }
  }

  void _triggerMinusButtonAction() {
    setState(() {
      balanceitems.clear();

      for (var item in controller.fetchedItems) {
        var balanceItem = balanceRequiredQuantitiesList.firstWhere(
          (entry) =>
              entry['item'].toString().trim().toLowerCase() ==
              item['PartName'].toString().trim().toLowerCase(),
          orElse: () => {'balanceRequiredQty': item['RequiredQty']},
        );

        item['RequiredQty'] = balanceItem['balanceRequiredQty'];

        int updatedQty = int.tryParse(item['RequiredQty'].toString()) ?? 0;

        if (updatedQty != 0) {
          String key = "${item['PartNoID']} - ${item['PlanningID']}";

          balanceitems[key] = updatedQty;
        }
      }

      final StocksLocationController stockController =
          Get.find<StocksLocationController>();
      stockController.updateBalanceItems(balanceitems);
    });
  }

  // Future<void> fetchItemsSequentially() async {
  //   for (var location in stocksLocationController.branch) {
  //     await stocksLocationController
  //         .fetchItemsFromBranch(location.locationId.toString());
  //   }

  Future<void> fetchItemsSequentially() async {
    var branches = List.from(stocksLocationController.branch);
    for (var location in branches) {
      await stocksLocationController
          .fetchItemsFromBranch(location.locationId.toString());
    }

    AppSnackBar.success(
      message:
          "All available branches within the selected radius have been fetched successfully.",
    );
  }

  int calculateRemainingQty(
      String itemId, int currentRequiredQty, Map<String, int> itemBalances) {
    if (itemBalances.containsKey(itemId)) {
      return itemBalances[itemId]!;
    }

    itemBalances[itemId] = currentRequiredQty;
    return currentRequiredQty;
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

    List<String> partNoIDs = [];
    Set<String> printedPartNoIDs = {};
    Set<String> processedItems = {};

    List<List<dynamic>> tableData = controller.fetchedItems.map((item) {
      String partNoID = item['PartNoID'].toString();

      if (partNoID != "0" && !printedPartNoIDs.contains(partNoID)) {
        partNoIDs.add(partNoID);
        printedPartNoIDs.add(partNoID);
      }

      return [
        item['PartName'].toString(),
        item['SupplierText'].toString(),
        item['SupplierText'].toString(),
        partNoID,
        item['PlanningID'].toString(),
        item['RequiredQty'].toString(),
      ];
    }).toList();

    String formattedItemIds = partNoIDs.join(',');
    print('Formatted Item IDs: $formattedItemIds');

    controller.updateItemIds(formattedItemIds);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('WorkSheet Planning Indent',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
          // style: TextStyle(color: Colors.white)),
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
                              child: Obx(() {
                                final suppliers =
                                    stocksLocationController.supplier;

                                final supplierItems = suppliers
                                    .map((supplier) => supplier.supplier ?? '')
                                    .toList();

                                return DropdownWidget(
                                  label: 'Supplier Name',
                                  value: suppliers.isEmpty
                                      ? null
                                      : stocksLocationController
                                          .selectedSupplierId.value,
                                  items: supplierItems,
                                  isRequired: true,
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      final selectedSupplierData =
                                          suppliers.firstWhere((supplier) =>
                                              supplier.supplier == newValue);

                                      stocksLocationController
                                              .selectedSupplierId.value =
                                          selectedSupplierData.supplierId ?? '';

                                      print(
                                          'Selected Supplier ID: ${selectedSupplierData.supplierId}');
                                      _fetchDataOnSelection();
                                    }
                                  },
                                );
                              }),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() {
                                final locations =
                                    stocksLocationController.locations;

                                // Sort locations alphabetically
                                final locationItems = locations
                                    .map((location) =>
                                        location.locationName ?? '')
                                    .toList()
                                  ..sort((a, b) => a.compareTo(b));

                                return DropdownWidget(
                                  label: 'To Location',
                                  isRequired: true,
                                  value: (location?.isNotEmpty ?? false)
                                      ? location
                                      : selectedItem,
                                  items: locationItems,
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      final selectedLocation =
                                          locations.firstWhere((loc) =>
                                              loc.locationName == newValue);

                                      selectedItem = newValue;
                                      selectedLocationName =
                                          selectedLocation.locationName;
                                      selectedLocationLatitude =
                                          selectedLocation.latitude;
                                      selectedLocationLongitude =
                                          selectedLocation.longitude;

                                      final newCenter = LatLng(
                                        selectedLocation.latitude ?? 0.0,
                                        selectedLocation.longitude ?? 0.0,
                                      );

                                      final mapController =
                                          Get.find<StocksLocationController>();
                                      mapController.updateMapCenter(newCenter);
                                      mapController.center = newCenter;

                                      final locationId = int.tryParse(
                                          selectedLocation.locationid
                                              .toString());

                                      if (locationId != null) {
                                        selectedLocationId = locationId;

                                        print(
                                            'Selected Location: ${selectedLocation.locationName}');
                                        print(
                                            'Latitude: ${selectedLocation.latitude}');
                                        print(
                                            'Longitude: ${selectedLocation.longitude}');
                                        print('Location ID: $locationId');

                                        _fetchDataOnSelection();
                                      } else {
                                        print('Error: Invalid location ID');
                                      }
                                    }
                                  },
                                );
                              }),
                            ),
                            Expanded(
                              child: DropdownRadius(
                                label: 'Radius (KM)',
                                value: selectedRadius,
                                isRequired: true,
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
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                if ((selectedItem?.isEmpty ?? true)) {
                                  AppSnackBar.alert(
                                    message:
                                        "Please select the location and upload the file to Proceed",
                                  );
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
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
                              Obx(() {
                                if (controller.fetchedItems.isNotEmpty) {
                                  return Text(
                                    'Total Requested Items: (${controller.fetchedItems.length})',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: Obx(() {
                                  if (controller.fetchedItems.isEmpty &&
                                      controller.isLoading.value) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: DataTable(
                                        border: TableBorder.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        columnSpacing: 70.0,
                                        horizontalMargin: 16.0,
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                          Colors.blue.shade100,
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
                                          // fontFamily: 'Roboto',
                                        ),
                                        columns: [
                                          DataColumn(
                                              label: Text('Branch',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                          fontSize: 12))),
                                          DataColumn(
                                              label: Text('Supplier',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                          fontSize: 14))),
                                          DataColumn(
                                              label: Text('Item',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                          fontSize: 14))),
                                          DataColumn(
                                              label: Text('Required Qty',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                          fontSize: 14))),
                                        ],
                                        rows: List.generate(5, (index) {
                                          return DataRow(cells: [
                                            DataCell(Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                  width: 100,
                                                  height: 20,
                                                  color: Colors.white),
                                            )),
                                            DataCell(Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                  width: 100,
                                                  height: 20,
                                                  color: Colors.white),
                                            )),
                                            DataCell(Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                  width: 100,
                                                  height: 20,
                                                  color: Colors.white),
                                            )),
                                            DataCell(Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                  width: 100,
                                                  height: 20,
                                                  color: Colors.white),
                                            )),
                                          ]);
                                        }),
                                      ),
                                    );
                                  } else if (controller.fetchedItems.isEmpty) {
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 240, 230, 230),
                                            highlightColor: Colors.red,
                                            child: const Icon(
                                              Icons.warning,
                                              color: Color.fromARGB(
                                                  255, 253, 5, 5),
                                              size: 50,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 126, 121, 121),
                                            highlightColor: Colors.black,
                                            child: Text(
                                              'No Item found',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 197, 196, 196),
                                            highlightColor: Colors.black,
                                            child: Text(
                                              'Please check back later or try adjusting your search.',
                                              textAlign: TextAlign.left,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        DataTable(
                                          border: TableBorder.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          columnSpacing: 60.0,
                                          horizontalMargin: 16.0,
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                            Colors.blue.shade100,
                                          ),
                                          headingTextStyle: theme
                                              .textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                          ),
                                          dataTextStyle: theme
                                              .textTheme.bodyLarge
                                              ?.copyWith(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontFamily: 'Roboto',
                                          ),
                                          columns: [
                                            DataColumn(
                                                label: Text('Planning Id',
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            fontSize: 14))),
                                            DataColumn(
                                                label: Text('Branch',
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            fontSize: 14))),
                                            DataColumn(
                                                label: Text('Supplier',
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            fontSize: 14))),
                                            DataColumn(
                                                label: Text('Item',
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            fontSize: 14))),
                                            DataColumn(
                                                label: Text('Required Qty',
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            fontSize: 14))),
                                          ],
                                          rows: controller.fetchedItems
                                              .map((item) {
                                            int requiredQty = int.tryParse(
                                                    item['RequiredQty']
                                                        .toString()) ??
                                                0;

                                            if (requiredQty != 0) {
                                              balanceitems[item['PartNoID']
                                                  .toString()] = requiredQty;
                                            }

                                            return DataRow(
                                              color: requiredQty == 0
                                                  ? MaterialStateProperty.all(
                                                      const Color.fromARGB(
                                                          255, 143, 226, 144))
                                                  : null,
                                              cells: [
                                                DataCell(Text(
                                                  item['IndentNo'] != null
                                                      ? item['IndentNo']
                                                          .toString()
                                                      : 'N/A',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(fontSize: 12),
                                                )),
                                                DataCell(Text(
                                                  item['LocationName']
                                                      .toString(),
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(fontSize: 12),
                                                )),
                                                DataCell(Text(
                                                  item['SupplierText']
                                                      .toString(),
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(fontSize: 12),
                                                )),
                                                DataCell(Text(
                                                  item['PartName'].toString(),
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(fontSize: 12),
                                                )),
                                                DataCell(
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      requiredQty.toString(),
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                              fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _triggerMinusButtonAction();
                                                  final StocksLocationController
                                                      stockController =
                                                      Get.find<
                                                          StocksLocationController>();
                                                  stockController
                                                      .sendBalanceDetails();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(150, 45),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(0.15),
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
                                                        'Generate PO',
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                          // fontFamily: 'Roboto',
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // controller.fetchedItems
                                                  //     .clear();
                                                    restartPage() ;
                                                   
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(150, 45),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 237, 171, 27),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(0.15),
                                                ),
                                                child: Text(
                                                  'Reset',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    // fontFamily: 'Roboto',
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  }
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
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
                                              size: 100,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 53, 51, 51),
                                            highlightColor: Colors.white,
                                            child: Text(
                                              'No results found.\nPlease select supplier and Tolocation and set the radius to load nearby branches.',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 13,
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

                                    if (highlightedItemCount == 0) {
                                      return const SizedBox();
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
                                                color: Colors.blue, width: 1),
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
                                                        fontSize: 12,
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
                                                              child: Text(
                                                                'Fetching item please wait',
                                                                style: theme
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.copyWith(
                                                                  fontSize: 13,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          10,
                                                                          10,
                                                                          10),
                                                                ),
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
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
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
                                                return Center(
                                                  child: Text(
                                                    "No items available for this location.",
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            color: Colors.black,
                                                            fontSize: 12),
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
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          ))),
                                                      DataCell(Text(
                                                          item['ConsigmentNumber']
                                                              .toString(),
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          ))),
                                                      DataCell(Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              item['onhand']
                                                                  .toString(),
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black)))),
                                                      DataCell(Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              item['purchasePrice']
                                                                  .toString(),
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              )))),
                                                      DataCell(Text(planningId,
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          ))),
                                                    ],
                                                    color: MaterialStateProperty
                                                        .all(const Color(
                                                            0xFFFFF9C4)),
                                                  ));
                                                }
                                              }

                                              if (highlightedRows.isEmpty) {
                                                return Center(
                                                  child: Text(
                                                    "No highlighted items available.",
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            color:
                                                                Colors.black),
                                                    // style: TextStyle(
                                                    //     color: Colors.black),
                                                  ),
                                                );
                                              }

                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DataTable(
                                                  columns: [
                                                    DataColumn(
                                                        label: Text('Item',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ))),
                                                    DataColumn(
                                                        label: Text(
                                                            'Item Con No',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ))),
                                                    DataColumn(
                                                        label: Text('On Hand',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ))),
                                                    DataColumn(
                                                        label: Text(
                                                            'Purchase Price',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ))),
                                                    DataColumn(
                                                        label: Text(
                                                            'Planning ID',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ))),
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
                                      String planningId = "";

                                      for (var row in tableData) {
                                        if (row[0].toString() == itemName) {
                                          requiredQty =
                                              int.tryParse(row[5].toString()) ??
                                                  0;
                                          planningId = row[4].toString();
                                          break;
                                        }
                                      }

                                      if (requiredQty > 0) {
                                        int accumulatedQty = 0;
                                        List<int> highlightedRows = [];
                                        List<String> takenQuantitiesMessages =
                                            [];

                                        for (int index = 0;
                                            index < items.length;
                                            index++) {
                                          var branchItem = items[index];
                                          if (branchItem['item'] == itemName) {
                                            int onhandQty = int.tryParse(
                                                    branchItem['onhand']
                                                        .toString()) ??
                                                0;
                                            accumulatedQty += onhandQty;

                                            if (accumulatedQty <= requiredQty) {
                                              highlightedRows.add(index);
                                              takenQuantitiesMessages.add(
                                                  'Added $onhandQty from consignment ${branchItem['ConsigmentNumber']}');
                                            } else {
                                              int takenQty = requiredQty -
                                                  (accumulatedQty - onhandQty);
                                              if (takenQty > 0) {
                                                highlightedRows.add(index);
                                                takenQuantitiesMessages.add(
                                                    'Added $takenQty from consignment ${branchItem['ConsigmentNumber']}');
                                              }
                                              break;
                                            }
                                          }
                                        }

                                        if (highlightedRows
                                            .contains(items.indexOf(item))) {
                                          highlightedItemsByBranch.putIfAbsent(
                                            location.locationName ??
                                                'Unknown Location',
                                            () => [],
                                          );

                                          highlightedItemsByBranch[
                                                  location.locationName]!
                                              .add({
                                            'item': item,
                                            'requiredQty': requiredQty,
                                            'takenQuantitiesMessages':
                                                takenQuantitiesMessages,
                                            'planningId': planningId,
                                          });
                                        }
                                      }
                                    }
                                  }
                                }

                                // Sort branches by total amount in descending order
                                final sortedBranches = highlightedItemsByBranch
                                    .keys
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
                                          double purchasePrice =
                                              double.tryParse(
                                                      item['purchasePrice']
                                                          .toString()) ??
                                                  0.0;
                                          double itemAmount =
                                              takenQuantitiesMessages.fold(
                                            0.0,
                                            (innerSum, message) {
                                              final quantityMatch =
                                                  RegExp(r'Added (\d+)')
                                                      .firstMatch(
                                                          message.toString());
                                              final quantity = quantityMatch !=
                                                      null
                                                  ? int.tryParse(
                                                      quantityMatch.group(1) ??
                                                          '0')
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
                                          double purchasePrice =
                                              double.tryParse(
                                                      item['purchasePrice']
                                                          .toString()) ??
                                                  0.0;
                                          double itemAmount =
                                              takenQuantitiesMessages.fold(
                                            0.0,
                                            (innerSum, message) {
                                              final quantityMatch =
                                                  RegExp(r'Added (\d+)')
                                                      .firstMatch(
                                                          message.toString());
                                              final quantity = quantityMatch !=
                                                      null
                                                  ? int.tryParse(
                                                      quantityMatch.group(1) ??
                                                          '0')
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
                                return Column(
                                  children: [
                                    Text(
                                      'The item has been added to the cart. Total branches: ${sortedBranches.length}',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Obx(() {
                                      var highlightedItemsByBranch = <String,
                                          List<Map<String, dynamic>>>{};

                                      for (var location
                                          in stocksLocationController.branch) {
                                        var items = stocksLocationController
                                                .fetchedItemsPerLocation[
                                            location.locationId.toString()];
                                        if (items != null) {
                                          for (var item in items) {
                                            String itemName =
                                                item['item'].toString();
                                            int requiredQty = 0;
                                            String planningId = "";

                                            for (var row in tableData) {
                                              if (row[0].toString() ==
                                                  itemName) {
                                                requiredQty = int.tryParse(
                                                        row[5].toString()) ??
                                                    0;
                                                planningId = row[4].toString();

                                                break;
                                              }
                                            }

                                            if (requiredQty > 0) {
                                              int accumulatedQty = 0;
                                              List<int> highlightedRows = [];
                                              List<String>
                                                  takenQuantitiesMessages = [];

                                              for (int index = 0;
                                                  index < items.length;
                                                  index++) {
                                                var branchItem = items[index];
                                                if (branchItem['item'] ==
                                                    itemName) {
                                                  int onhandQty = int.tryParse(
                                                          branchItem['onhand']
                                                              .toString()) ??
                                                      0;

                                                  // debugPrint(
                                                  //     "\x1B[38;2;255;165;0mAccumulating for item $itemName: Adding onhandQty $onhandQty (Accumulated: $accumulatedQty)\x1B[0m");

                                                  accumulatedQty += onhandQty;

                                                  if (accumulatedQty <=
                                                      requiredQty) {
                                                    highlightedRows.add(index);
                                                    takenQuantitiesMessages.add(
                                                        'Added $onhandQty from consignment ${branchItem['ConsigmentNumber']}');
                                                    //   debugPrint(
                                                    //       "\x1B[33mAdded $onhandQty from consignment ${branchItem['ConsigmentNumber']} to accumulate. Total accumulated: $accumulatedQty\x1B[0m");
                                                    //
                                                  } else {
                                                    int takenQty = requiredQty -
                                                        (accumulatedQty -
                                                            onhandQty);
                                                    if (takenQty > 0) {
                                                      highlightedRows
                                                          .add(index);
                                                      takenQuantitiesMessages.add(
                                                          'Added $takenQty from consignment ${branchItem['ConsigmentNumber']}');
                                                      debugPrint(
                                                          "\x1B[33mAdded $takenQty from consignment ${branchItem['ConsigmentNumber']} to reach the required quantity. Total accumulated: $accumulatedQty\x1B[0m");
                                                    }
                                                    debugPrint(
                                                        "\x1B[32mRequired quantity reached! Stopping accumulation for $itemName.\x1B[0m");
                                                    break;
                                                  }
                                                }
                                              }

                                              if (highlightedRows.contains(
                                                  items.indexOf(item))) {
                                                highlightedItemsByBranch
                                                    .putIfAbsent(
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
                                                  'planningId': planningId,
                                                });
                                              }
                                            }
                                          }
                                        }
                                      }

                                      //'No Surplus items have been added to the cart yet.',
                                      if (highlightedItemsByBranch.isEmpty) {
                                        return Center(
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
                                                  Icons.remove_shopping_cart,
                                                  size: 70,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Shimmer.fromColors(
                                                baseColor: const Color.fromARGB(
                                                    255, 53, 51, 51),
                                                highlightColor: Colors.white,
                                                child: Text(
                                                  'No Surplus items have been added to the cart yet.',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    fontSize: 15,
                                                    color: Color.fromARGB(
                                                        255, 10, 10, 10),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // Sort branches by total amount in descending order
                                      final sortedBranches =
                                          highlightedItemsByBranch.keys.toList()
                                            ..sort(
                                              (a, b) {
                                                double totalAmountA =
                                                    highlightedItemsByBranch[a]!
                                                        .fold(
                                                  0.0,
                                                  (sum, highlightedItem) {
                                                    var takenQuantitiesMessages =
                                                        highlightedItem[
                                                            'takenQuantitiesMessages'];
                                                    var item =
                                                        highlightedItem['item'];
                                                    double purchasePrice =
                                                        double.tryParse(item[
                                                                    'purchasePrice']
                                                                .toString()) ??
                                                            0.0;
                                                    double itemAmount =
                                                        takenQuantitiesMessages
                                                            .fold(
                                                      0.0,
                                                      (innerSum, message) {
                                                        final quantityMatch = RegExp(
                                                                r'Added (\d+)')
                                                            .firstMatch(message
                                                                .toString());
                                                        final quantity =
                                                            quantityMatch !=
                                                                    null
                                                                ? int.tryParse(
                                                                    quantityMatch
                                                                            .group(1) ??
                                                                        '0')
                                                                : 0;
                                                        return innerSum +
                                                            (quantity! *
                                                                purchasePrice);
                                                      },
                                                    );
                                                    return sum + itemAmount;
                                                  },
                                                );

                                                double totalAmountB =
                                                    highlightedItemsByBranch[b]!
                                                        .fold(
                                                  0.0,
                                                  (sum, highlightedItem) {
                                                    var takenQuantitiesMessages =
                                                        highlightedItem[
                                                            'takenQuantitiesMessages'];
                                                    var item =
                                                        highlightedItem['item'];
                                                    double purchasePrice =
                                                        double.tryParse(item[
                                                                    'purchasePrice']
                                                                .toString()) ??
                                                            0.0;
                                                    double itemAmount =
                                                        takenQuantitiesMessages
                                                            .fold(
                                                      0.0,
                                                      (innerSum, message) {
                                                        final quantityMatch = RegExp(
                                                                r'Added (\d+)')
                                                            .firstMatch(message
                                                                .toString());
                                                        final quantity =
                                                            quantityMatch !=
                                                                    null
                                                                ? int.tryParse(
                                                                    quantityMatch
                                                                            .group(1) ??
                                                                        '0')
                                                                : 0;
                                                        return innerSum +
                                                            (quantity! *
                                                                purchasePrice);
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
                                            tabs: sortedBranches
                                                .map((branchName) {
                                              final processedItems = <String>{};

                                              double totalAmount = 0.0;
                                              final branchItems =
                                                  highlightedItemsByBranch[
                                                          branchName] ??
                                                      [];

                                              // final processedItems = <String>{};
                                              // double totalAmount =
                                              //     highlightedItemsByBranch[
                                              //             branchName]!
                                              //         .fold<double>(
                                              //   0.0,
                                              //   (sum, highlightedItem) {
                                              //     var item =
                                              //         highlightedItem['item'];
                                              //     var itemName =
                                              //         item['item'].toString();
                                              //     var takenQuantitiesMessages =
                                              //         highlightedItem[
                                              //             'takenQuantitiesMessages'];

                                              //     double purchasePrice =
                                              //         double.tryParse(item[
                                              //                     'purchasePrice']
                                              //                 .toString()) ??
                                              //             0.0;
                                              //     double itemAmount =
                                              //         takenQuantitiesMessages
                                              //             .fold(
                                              //       0.0,
                                              //       (innerSum, message)
                                              //       //   {
                                              //       //     final quantityMatch =
                                              //       //         RegExp(r'Added (\d+)')
                                              //       //             .firstMatch(message
                                              //       //                 .toString());
                                              //       //     final quantity =
                                              //       //         quantityMatch != null
                                              //       //             ? int.tryParse(
                                              //       //                 quantityMatch
                                              //       //                         .group(
                                              //       //                             1) ??
                                              //       //                     '0')
                                              //       //             : 0;
                                              //       //     return innerSum +
                                              //       //         (quantity! *
                                              //       //             purchasePrice);
                                              //       //   },
                                              //       // );
                                              //       {
                                              //         final quantityMatch =
                                              //             RegExp(r'Added (\d+)')
                                              //                 .firstMatch(message
                                              //                     .toString());
                                              //         if (quantityMatch !=
                                              //             null) {
                                              //           final quantity = int.tryParse(
                                              //                   quantityMatch
                                              //                           .group(
                                              //                               1) ??
                                              //                       '0') ??
                                              //               0;

                                              //           double amount =
                                              //               quantity *
                                              //                   purchasePrice;

                                              //           // Print detailed calculation for each message
                                              //           debugPrint(
                                              //               'Branch: $branchName | '
                                              //               'Item: $itemName | '
                                              //               'Consignment: ${item['ConsigmentNumber']} | '
                                              //               'Quantity: $quantity | '
                                              //               'Price: $purchasePrice | '
                                              //               'Amount: $amount');
                                              //           // return innerSum +
                                              //           //     (quantity *
                                              //           //         purchasePrice);

                                              //           return innerSum +
                                              //               amount;
                                              //         }

                                              //         return innerSum;
                                              //       },
                                              //     );

                                              //     debugPrint(
                                              //         'Branch: $branchName | '
                                              //         'Item: $itemName | '
                                              //         'Subtotal: $itemAmount');

                                              //     return sum + itemAmount;
                                              //   },
                                              // );

                                              // // debugPrint(
                                              // //     'Tab for $branchName - Total Amount: $totalAmount');
                                              // // Print total for the branch
                                              // debugPrint(
                                              //     'Branch: $branchName | '
                                              //     'TOTAL AMOUNT: $totalAmount');
                                              final itemsByName = <String,
                                                  List<Map<String, dynamic>>>{};
                                              for (final itemData
                                                  in branchItems) {
                                                final item = itemData['item']
                                                    as Map<String, dynamic>;
                                                final itemName =
                                                    item['item'].toString();
                                                itemsByName
                                                    .putIfAbsent(
                                                        itemName, () => [])
                                                    .add(itemData);
                                              }

                                              // Calculate amount for each unique item
                                              for (final entry
                                                  in itemsByName.entries) {
                                                final itemName = entry.key;
                                                final itemDatas = entry.value;

                                                // Get price from first item (assuming same price across consignments)
                                                final firstItem =
                                                    itemDatas.first['item']
                                                        as Map<String, dynamic>;
                                                final purchasePrice =
                                                    double.tryParse(firstItem[
                                                                'purchasePrice']
                                                            .toString()) ??
                                                        0.0;

                                                // Sum quantities across all consignments for this item
                                                final seenConsignments =
                                                    <String>{};
                                                int totalQuantity = 0;
                                                for (final itemData
                                                    in itemDatas) {
                                                  final item = itemData['item']
                                                      as Map<String, dynamic>;
                                                  final consignmentNumber =
                                                      item['ConsigmentNumber']
                                                              ?.toString() ??
                                                          'N/A';

                                                  if (seenConsignments.contains(
                                                      consignmentNumber)) {
                                                    continue; // Skip duplicate consignment
                                                  }

                                                  seenConsignments
                                                      .add(consignmentNumber);
                                                  final messages = itemData[
                                                          'takenQuantitiesMessages']
                                                      as List<dynamic>;
                                                  for (final message
                                                      in messages) {
                                                    if (message
                                                        .toString()
                                                        .contains(
                                                            consignmentNumber)) {
                                                      final match = RegExp(
                                                              r'Added (\d+)')
                                                          .firstMatch(message
                                                              .toString());
                                                      if (match != null) {
                                                        totalQuantity +=
                                                            int.tryParse(
                                                                    match.group(
                                                                            1) ??
                                                                        '0') ??
                                                                0;
                                                      }
                                                    }
                                                  }
                                                }

                                                // Calculate amount for this item
                                                final itemAmount =
                                                    totalQuantity *
                                                        purchasePrice;
                                                totalAmount += itemAmount;

                                                debugPrint('Item: $itemName | '
                                                    'Total Qty: $totalQuantity | '
                                                    'Price: $purchasePrice | '
                                                    'Amount: $itemAmount');
                                              }

                                              debugPrint(
                                                  'TOTAL for $branchName: $totalAmount');
                                              final isProcessed =
                                                  processedBranches
                                                      .contains(branchName);
                                              return Tab(
                                                text:
                                                    null, // Remove the text parameter as we use Text.rich
                                                icon: AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  transitionBuilder:
                                                      (Widget child,
                                                          Animation<double>
                                                              animation) {
                                                    return ScaleTransition(
                                                      scale: animation,
                                                      child: child,
                                                    );
                                                  },
                                                  child: isProcessed
                                                      ? const Icon(
                                                          Icons.check_circle,
                                                          key:
                                                              ValueKey('check'),
                                                          color: Colors.green,
                                                        )
                                                      : const Icon(
                                                          Icons.location_on,
                                                          key: ValueKey(
                                                              'location'),
                                                        ),
                                                ),
                                                iconMargin:
                                                    const EdgeInsets.only(
                                                        right: 8.0),
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '$branchName \n (',
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .black),
                                                        // style: const TextStyle(
                                                        //     color: Colors
                                                        //         .black), // Default color
                                                      ),
                                                      TextSpan(
                                                        text: totalAmount
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .red), // Red color for totalAmount
                                                      ),
                                                      TextSpan(
                                                        text: ')',
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .black),
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
                                            labelStyle: theme
                                                .textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                            indicatorSize:
                                                TabBarIndicatorSize.label,
                                            indicatorWeight: 3.0,
                                            indicatorPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20.0),
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    Colors.transparent),
                                            splashFactory:
                                                NoSplash.splashFactory,
                                            onTap: (index) {
                                              final branchName =
                                                  highlightedItemsByBranch.keys
                                                      .elementAt(index);
                                              if (processedBranches
                                                  .contains(branchName)) {}
                                            },
                                          ),
                                          SizedBox(
                                            height: 500,
                                            child: TabBarView(
                                              children: sortedBranches
                                                  .map((branchName) {
                                                var branchItems =
                                                    highlightedItemsByBranch[
                                                        branchName]!;

                                                Map<String,
                                                        Map<String, dynamic>>
                                                    consolidatedItems = {};

                                                for (var highlightedItem
                                                    in branchItems) {
                                                  var item =
                                                      highlightedItem['item'];
                                                  var itemName =
                                                      item['item'].toString();
                                                  var consignmentNumber = item[
                                                          'ConsigmentNumber'] ??
                                                      'N/A';
                                                  var onHand = int.tryParse(
                                                          item['onhand']
                                                                  ?.toString() ??
                                                              '0') ??
                                                      0;
                                                  var purchasePrice = double.tryParse(
                                                          item['purchasePrice']
                                                                  ?.toString() ??
                                                              '0.0') ??
                                                      0.0;
                                                  var requiredQty =
                                                      highlightedItem[
                                                          'requiredQty'];
                                                  var takenQuantitiesMessages =
                                                      highlightedItem[
                                                          'takenQuantitiesMessages'];

                                                  int totalQuantityAdded = 0;
                                                  double totalAmount = 0.0;

                                                  for (var message
                                                      in takenQuantitiesMessages) {
                                                    if (message
                                                        .toString()
                                                        .contains(
                                                            consignmentNumber)) {
                                                      final quantityMatch =
                                                          RegExp(r'Added (\d+)')
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
                                                        totalQuantityAdded +=
                                                            quantity;
                                                        totalAmount +=
                                                            quantity *
                                                                purchasePrice;
                                                      }
                                                    }
                                                  }

                                                  if (!consolidatedItems
                                                      .containsKey(itemName)) {
                                                    consolidatedItems[
                                                        itemName] = {
                                                      'onHand': 0,
                                                      'purchasePrice':
                                                          purchasePrice,
                                                      'requiredQty':
                                                          requiredQty,
                                                      'totalQuantityAdded':
                                                          totalQuantityAdded,
                                                      'totalAmount':
                                                          totalAmount,
                                                      'consignmentNumbers': [],
                                                    };
                                                  }

                                                  consolidatedItems[itemName]![
                                                      'onHand'] += onHand;

                                                  if (!consolidatedItems[
                                                              itemName]![
                                                          'consignmentNumbers']
                                                      .contains(
                                                          consignmentNumber)) {
                                                    consolidatedItems[
                                                                itemName]![
                                                            'consignmentNumbers']
                                                        .add(consignmentNumber);
                                                  }
                                                }

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // RichText(
                                                          //   text: TextSpan(
                                                          //     children: [
                                                          //       TextSpan(
                                                          //         text: "Total Amount: ",
                                                          //         style: theme
                                                          //             .textTheme.bodyMedium
                                                          //             ?.copyWith(
                                                          //           fontWeight:
                                                          //               FontWeight.bold,
                                                          //           color: Colors.black,
                                                          //           fontSize: 12,
                                                          //         ),
                                                          //       ),
                                                          //       TextSpan(
                                                          //         text: branchItems
                                                          //             .fold(0.0, (sum,
                                                          //                 highlightedItem) {
                                                          //           var takenQuantitiesMessages =
                                                          //               highlightedItem[
                                                          //                   'takenQuantitiesMessages'];
                                                          //           var item =
                                                          //               highlightedItem[
                                                          //                   'item'];
                                                          //           double purchasePrice =
                                                          //               double.tryParse(item[
                                                          //                           'purchasePrice']
                                                          //                       .toString()) ??
                                                          //                   0.0;
                                                          //           double itemAmount =
                                                          //               takenQuantitiesMessages
                                                          //                   .fold(0.0,
                                                          //                       (innerSum,
                                                          //                           message) {
                                                          //             final quantityMatch = RegExp(
                                                          //                     r'Added (\d+)')
                                                          //                 .firstMatch(message
                                                          //                     .toString());
                                                          //             final quantity =
                                                          //                 quantityMatch !=
                                                          //                         null
                                                          //                     ? int.tryParse(
                                                          //                             quantityMatch.group(1) ??
                                                          //                                 '0') ??
                                                          //                         0
                                                          //                     : 0;
                                                          //             return innerSum +
                                                          //                 (quantity *
                                                          //                     purchasePrice);
                                                          //           });
                                                          //           return sum + itemAmount;
                                                          //         }).toStringAsFixed(2),
                                                          //         style: theme
                                                          //             .textTheme.bodyMedium
                                                          //             ?.copyWith(
                                                          //           fontWeight:
                                                          //               FontWeight.bold,
                                                          //           fontSize: 12,
                                                          //           color: Colors.red,
                                                          //         ),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Total Matched Items Count: ",
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: consolidatedItems
                                                                      .length
                                                                      .toString(), // Count the number of items
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .red,
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
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              if (processedBranches
                                                                  .contains(
                                                                      branchName))
                                                                Obx(() {
                                                                  final controller =
                                                                      Get.find<
                                                                          StocksLocationController>();
                                                                  final branchTO =
                                                                      controller
                                                                          .branch
                                                                          .firstWhere(
                                                                            (location) =>
                                                                                location.locationName ==
                                                                                branchName,
                                                                            orElse: () =>
                                                                                BranchModel(locationId: -1, locationName: ''),
                                                                          )
                                                                          .locationName;

                                                                  return Text(
                                                                    branchTO == branchName &&
                                                                            controller
                                                                                .transferOrderNumber.value.isNotEmpty
                                                                        ? controller
                                                                            .transferOrderNumber
                                                                            .value
                                                                        : 'N/A',
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  );
                                                                }),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: DataTable(
                                                            border:
                                                                TableBorder.all(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              width: 1,
                                                            ),
                                                            columnSpacing: 20.0,
                                                            horizontalMargin:
                                                                16.0,
                                                            headingRowColor:
                                                                MaterialStateProperty
                                                                    .all(
                                                              processedBranches
                                                                      .contains(
                                                                          branchName)
                                                                  ? const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      143,
                                                                      226,
                                                                      144)
                                                                  : Colors.blue
                                                                      .shade100,
                                                            ),
                                                            columns: [
                                                              DataColumn(
                                                                  label: Text(
                                                                      'S.No',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Item',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'On Hand',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Purchase Price',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Required Qty',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Quantity Pegged',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Amount',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Consignment Numbers',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge
                                                                          ?.copyWith(
                                                                              fontSize: 14))),
                                                              if (!processedBranches
                                                                  .contains(
                                                                      branchName))
                                                                DataColumn(
                                                                    label: Text(
                                                                        'Balance Required Qty',
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(fontSize: 14))),
                                                            ],
                                                            rows: () {
                                                              Map<
                                                                      String,
                                                                      Map<String,
                                                                          dynamic>>
                                                                  consolidatedItems =
                                                                  {};
                                                              var groupedItems =
                                                                  <String,
                                                                      List<
                                                                          Map<String,
                                                                              dynamic>>>{};

                                                              // Step 1: Group items by itemName
                                                              for (var highlightedItem
                                                                  in branchItems) {
                                                                var item =
                                                                    highlightedItem[
                                                                        'item'];
                                                                var itemName =
                                                                    item['item']
                                                                        .toString();
                                                                groupedItems
                                                                    .putIfAbsent(
                                                                        itemName,
                                                                        () =>
                                                                            []);
                                                                groupedItems[
                                                                        itemName]!
                                                                    .add(
                                                                        highlightedItem);
                                                              }

                                                              // Step 2: Process each group
                                                              for (var entry
                                                                  in groupedItems
                                                                      .entries) {
                                                                var itemName =
                                                                    entry.key;
                                                                var items =
                                                                    entry.value;

                                                                int totalOnHand =
                                                                    0;
                                                                double
                                                                    purchasePrice =
                                                                    0.0;
                                                                int requiredQty =
                                                                    items.first[
                                                                        'requiredQty'];
                                                                List
                                                                    takenMessages =
                                                                    items.first[
                                                                        'takenQuantitiesMessages'];
                                                                int totalQuantityAdded =
                                                                    0;
                                                                double
                                                                    totalAmount =
                                                                    0.0;
                                                                List<String>
                                                                    consignmentNumbers =
                                                                    [];

                                                                for (var itemEntry
                                                                    in items) {
                                                                  var item =
                                                                      itemEntry[
                                                                          'item'];
                                                                  var consignmentNumber =
                                                                      item['ConsigmentNumber'] ??
                                                                          'N/A';
                                                                  var onHand =
                                                                      int.tryParse(item['onhand']?.toString() ??
                                                                              '0') ??
                                                                          0;
                                                                  purchasePrice =
                                                                      double.tryParse(item['purchasePrice']?.toString() ??
                                                                              '0.0') ??
                                                                          0.0;

                                                                  totalOnHand +=
                                                                      onHand;

                                                                  for (var message
                                                                      in takenMessages) {
                                                                    if (message
                                                                        .toString()
                                                                        .contains(
                                                                            consignmentNumber)) {
                                                                      final quantityMatch = RegExp(
                                                                              r'Added (\d+)')
                                                                          .firstMatch(
                                                                              message.toString());
                                                                      if (quantityMatch !=
                                                                          null) {
                                                                        final quantity =
                                                                            int.tryParse(quantityMatch.group(1) ?? '0') ??
                                                                                0;
                                                                        int remaining =
                                                                            requiredQty -
                                                                                totalQuantityAdded;

                                                                        if (remaining >
                                                                            0) {
                                                                          int qtyToAdd = quantity > remaining
                                                                              ? remaining
                                                                              : quantity;
                                                                          totalQuantityAdded +=
                                                                              qtyToAdd;
                                                                          totalAmount +=
                                                                              qtyToAdd * purchasePrice;

                                                                          if (!consignmentNumbers
                                                                              .contains(consignmentNumber)) {
                                                                            consignmentNumbers.add(consignmentNumber);
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }

                                                                  if (totalQuantityAdded >=
                                                                      requiredQty) {
                                                                    break;
                                                                  }
                                                                }
                                                                consolidatedItems[
                                                                    itemName] = {
                                                                  'onHand':
                                                                      totalOnHand,
                                                                  'purchasePrice':
                                                                      purchasePrice,
                                                                  'requiredQty':
                                                                      requiredQty,
                                                                  'totalQuantityAdded':
                                                                      totalQuantityAdded,
                                                                  'totalAmount':
                                                                      totalAmount,
                                                                  'consignmentNumbers':
                                                                      consignmentNumbers,
                                                                };
                                                              }
                                                              int sNo = 1;
                                                              return consolidatedItems
                                                                  .entries
                                                                  .map((entry) {
                                                                var itemName =
                                                                    entry.key;
                                                                var data =
                                                                    entry.value;
                                                                int balanceRequiredQty =
                                                                    data['requiredQty'] -
                                                                        data[
                                                                            'totalQuantityAdded'];
                                                                bool
                                                                    isProcessedBranch =
                                                                    processedBranches
                                                                        .contains(
                                                                            branchName);

                                                                return DataRow(
                                                                  cells: [
                                                                    DataCell(
                                                                      Text(
                                                                        (sNo++)
                                                                            .toString(),
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(fontSize: 12),
                                                                      ),
                                                                    ),
                                                                    DataCell(Text(
                                                                        itemName,
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(fontSize: 12))),
                                                                    DataCell(Text(
                                                                        data['onHand']
                                                                            .toString(),
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(fontSize: 12))),
                                                                    DataCell(
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child:
                                                                            Text(
                                                                          data['purchasePrice']
                                                                              .toStringAsFixed(2),
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          style: theme
                                                                              .textTheme
                                                                              .bodyLarge
                                                                              ?.copyWith(fontSize: 12),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(Text(
                                                                        data['requiredQty']
                                                                            .toString(),
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(fontSize: 12))),
                                                                    DataCell(Text(
                                                                        data['totalQuantityAdded']
                                                                            .toString(),
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(fontSize: 12))),
                                                                    DataCell(
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child:
                                                                            Text(
                                                                          data['totalAmount']
                                                                              .toStringAsFixed(2),
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          style: theme
                                                                              .textTheme
                                                                              .bodyLarge
                                                                              ?.copyWith(fontSize: 12),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(Text(
                                                                        data['consignmentNumbers'].join(
                                                                            ', '),
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(fontSize: 12))),
                                                                    if (!isProcessedBranch)
                                                                      DataCell(
                                                                        Text(
                                                                          balanceRequiredQty
                                                                              .toString(),
                                                                          style: theme
                                                                              .textTheme
                                                                              .bodyLarge
                                                                              ?.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: balanceRequiredQty < 0
                                                                                ? Colors.purple
                                                                                : balanceRequiredQty > 1
                                                                                    ? Colors.red
                                                                                    : Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                );
                                                              }).toList();
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Obx(
                                                        () => ElevatedButton(
                                                          onPressed: stocksLocationController
                                                                      .isLoading
                                                                      .value ||
                                                                  processedBranches
                                                                      .contains(
                                                                          branchName)
                                                              ? null
                                                              : () async {
                                                                  balanceRequiredQuantitiesList
                                                                      .clear();
                                                                  Map<String,
                                                                          int>
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
                                                                              message.toString());
                                                                      if (quantityMatch !=
                                                                          null) {
                                                                        totalQuantityAdded +=
                                                                            int.tryParse(quantityMatch.group(1) ?? '0') ??
                                                                                0;
                                                                      }
                                                                    }
                                                                    int balanceRequiredQty =
                                                                        originalRequiredQty -
                                                                            totalQuantityAdded;
                                                                    balanceRequiredQuantities[
                                                                        item[
                                                                            'item']] = (balanceRequiredQuantities[
                                                                                item['item']] ??
                                                                            0) +
                                                                        balanceRequiredQty;
                                                                    if (!balanceRequiredQuantitiesList.any((entry) =>
                                                                        entry[
                                                                            'item'] ==
                                                                        item[
                                                                            'item'])) {
                                                                      balanceRequiredQuantitiesList
                                                                          .add({
                                                                        'item':
                                                                            item['item'],
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
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            Text(
                                                                              'Confirmation',
                                                                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                                                            ),
                                                                            Icon(
                                                                              Icons.warning,
                                                                              color: Color.fromARGB(255, 218, 202, 61),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        content:
                                                                            const SizedBox(
                                                                          width:
                                                                              400,
                                                                          child:
                                                                              Text(
                                                                            'Are you sure you want to create a transfer order?',
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ),
                                                                        actions: <Widget>[
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                TextButton.styleFrom(
                                                                              foregroundColor: Colors.red,
                                                                              side: const BorderSide(color: Colors.red),
                                                                            ),
                                                                            child:
                                                                                const Text('No'),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              Navigator.of(context).pop();
                                                                              stocksLocationController.isLoading.value = true;

                                                                              var branchId = stocksLocationController.branch
                                                                                  .firstWhere(
                                                                                    (location) => location.locationName == branchName,
                                                                                    orElse: () => BranchModel(locationId: -1, locationName: branchName),
                                                                                  )
                                                                                  .locationId;

                                                                              List<Map<String, dynamic>> allItems = [];

                                                                              for (var highlightedItem in branchItems) {
                                                                                var item = highlightedItem['item'];
                                                                                var takenQuantitiesMessages = highlightedItem['takenQuantitiesMessages'];

                                                                                String consignmentNumber = item['ConsigmentNumber'] ?? 'N/A';
                                                                                String consignmentId = item['ConsignmentID']?.toString() ?? 'N/A';
                                                                                String itemId = item['itemId']?.toString() ?? 'N/A';
                                                                                String planningId = highlightedItem['planningId'];

                                                                                final filteredMessages = takenQuantitiesMessages.where((message) => message.toString().contains(consignmentNumber)).toList();

                                                                                double totalQuantity = 0;
                                                                                double totalAmount = 0.0;

                                                                                for (var message in filteredMessages) {
                                                                                  final quantityMatch = RegExp(r'Added (\d+)').firstMatch(message.toString());
                                                                                  if (quantityMatch != null) {
                                                                                    final quantity = int.tryParse(quantityMatch.group(1) ?? '0') ?? 0;
                                                                                    final double purchasePrice = double.tryParse(item['purchasePrice'].toString()) ?? 0.0;
                                                                                    final double amount = quantity * purchasePrice;
                                                                                    totalQuantity += quantity;
                                                                                    totalAmount += amount;
                                                                                  }
                                                                                }

                                                                                totalAmount = totalAmount.toInt().toDouble();

                                                                                allItems.add({
                                                                                  'itemId': itemId,
                                                                                  'totalAmount': totalAmount,
                                                                                  'quantityAdded': totalQuantity,
                                                                                  'consignmentId': consignmentId,
                                                                                  'planningId': planningId,
                                                                                });
                                                                              }

                                                                              TransferOrderModel order = TransferOrderModel(
                                                                                tolocation: selectedLocationId,
                                                                                subsidiary: subsidiary,
                                                                                branchid: branchId,
                                                                                items: allItems.map((entry) {
                                                                                  return ItemDetail(
                                                                                    itemId: int.tryParse(entry['itemId']),
                                                                                    totalAmount: entry['totalAmount'],
                                                                                    quantityAdded: entry['quantityAdded']?.toInt(),
                                                                                    consignmentId: entry['consignmentId'],
                                                                                    planningId: entry['planningId'],
                                                                                  );
                                                                                }).toList(),
                                                                              );

                                                                              bool success = await stocksLocationController.sendWorkIndentTransaction(order: order);

                                                                              if (success) {
                                                                                _triggerMinusButtonAction();
                                                                                processedBranches.add(branchName);
                                                                              }
                                                                            },
                                                                            style:
                                                                                TextButton.styleFrom(
                                                                              foregroundColor: Colors.green,
                                                                              side: const BorderSide(color: Colors.green),
                                                                            ),
                                                                            child: stocksLocationController.isLoading.value
                                                                                ? const CircularProgressIndicator()
                                                                                : const Text('Yes'),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            minimumSize:
                                                                const Size(
                                                                    80, 40),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            backgroundColor:
                                                                Colors.green,
                                                          ),
                                                          child: stocksLocationController
                                                                  .isLoading
                                                                  .value
                                                              ? const SizedBox(
                                                                  width: 24,
                                                                  height: 24,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: Colors
                                                                        .black,
                                                                    strokeWidth:
                                                                        3,
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
                                );
                              }),
                            ])))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
