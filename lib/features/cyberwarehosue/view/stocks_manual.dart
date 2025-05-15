import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/controllers/stocks_manual_controller.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/branch_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/branchitems_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/transferorder_model.dart';

import 'package:impal_desktop/features/cyberwarehosue/widget/dropdown_radius.dart';
import 'package:impal_desktop/features/cyberwarehosue/widget/dropdown_widget.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class StocksManual extends StatefulWidget {
  const StocksManual({super.key});
  static String routeName = '/stocks';

  @override
  _StocksManualState createState() => _StocksManualState();
}

class _StocksManualState extends State<StocksManual> {
  final StocksManualController stocksManualController =
      Get.put(StocksManualController());

  RxList<BranchModel> branch = <BranchModel>[].obs;
  RxList<LocationModel> branchitems = <LocationModel>[].obs;

  final List<int> radiusOptions = [100, 500, 800, 1000, 3000];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int selectedRadius = 100;
  String? selectedItem;
  String? selectedLocationName;
  String? selectedLocationId;
  String? selectedBranch;
  String? selectedBranchId;
  double? selectedLocationLatitude;
  double? selectedLocationLongitude;
  bool isCreatingOrder = false;

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    stocksManualController.fetchLocations();
  }

  @override
  void dispose() {
    stocksManualController.items.clear();
    stocksManualController.clearData();
    super.dispose();
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CustomAlertDialog(
          title: 'Success',
          message: message,
          showOkButton: true,
          onOk: () {
            // Navigator.of(dialogContext).pop(); // Close the dialog
            // Navigate to the Stocks page
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void showCustomDialog(BuildContext context, String message,
      {bool showOkButton = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Error',
          message: message,
          showOkButton: showOkButton,
          onOk: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Confirm Deletion',
          message: 'Are you sure you want to delete this item?',
          onConfirm: () {
            setState(() {
              cartItems.remove(item);

              item['isInCart'] = false; // Set back to false
              item['isFullyAdded'] = false; // Set back to false
              item['transferQuantity'] = ''; // Clear the transfer quantity

              AppSnackBar.success(
                message: '${item['partNo']} has been deleted successfully.',
              );
            });
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Confirm Deletion',
          message: 'Are you sure you want to delete all items in your cart?',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () {
            setState(() {
              cartItems.clear();
              AppSnackBar.success(
                message: 'All items have been cleared from your cart.',
              );
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _updateMapWithNewRadius(int newRadius) async {
    final mapController = Get.find<StocksManualController>();

    if (selectedLocationName != null) {
      final selectedLocationId = stocksManualController.locations
          .firstWhere(
            (location) => location.locationName == selectedLocationName,
          )
          .locationid;

      stocksManualController.branch.clear();
      await mapController.fetchBranch(
          newRadius.toDouble() * 1000, selectedLocationId.toString());
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
    final isDarkMode = theme.brightness == Brightness.dark;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title:  Text(
                'Transfer Surplus Stocks Manual',
                 style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                // style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF161717),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      if (stocksManualController
                                          .locations.isEmpty) {
                                        return DropdownWidget(
                                          label: 'To Location',
                                          value: selectedItem,
                                          items: const [],
                                          onChanged: (newValue) {},
                                        );
                                      }

                                      final locationItems =
                                          stocksManualController.locations
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
                                                stocksManualController.locations
                                                    .firstWhere(
                                              (location) =>
                                                  location.locationName ==
                                                  newValue,
                                            );

                                            if (selectedLocation.latitude !=
                                                    null &&
                                                selectedLocation.longitude !=
                                                    null) {
                                              selectedLocationName =
                                                  selectedLocation.locationName;
                                              selectedLocationLatitude =
                                                  selectedLocation.latitude;
                                              selectedLocationLongitude =
                                                  selectedLocation.longitude;
                                              selectedLocationId =
                                                  selectedLocation.locationid;
                                              final newCenter = LatLng(
                                                selectedLocation.latitude!,
                                                selectedLocation.longitude!,
                                              );

                                              print(
                                                  'Selected Location ID: ${selectedLocation.locationid}');
                                              print(
                                                  'Selected Location Name: $selectedLocationName');

                                              final mapController = Get.find<
                                                  StocksManualController>();
                                              mapController
                                                  .updateMapCenter(newCenter);
                                              mapController.center = newCenter;
                                            }
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
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
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Obx(() {
                                      final branchItemsList =
                                          stocksManualController.branch
                                              .map((branch) => {
                                                    'name':
                                                        branch.locationName ??
                                                            '',
                                                    'id': branch.locationId,
                                                  })
                                              .toList();

                                      return DropdownWidget(
                                        label: 'Branch',
                                        value: selectedBranch,
                                        items: branchItemsList
                                            .map((item) =>
                                                item['name'] as String)
                                            .toList(),
                                        onChanged: (value) {
                                          if (cartItems.isNotEmpty) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomAlertDialog(
                                                  title: 'Clear Cart Items',
                                                  message:
                                                      'If you change the branch, all the items in your cart will be cleared. Are you sure you want to proceed?',
                                                  onCancel: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  onConfirm: () {
                                                    setState(() {
                                                      cartItems
                                                          .clear(); // Clear the cart items
                                                      AppSnackBar.success(
                                                        message:
                                                            'All items have been cleared from your cart.',
                                                      );

                                                      selectedBranch =
                                                          value; // Change selected branch

                                                      final selectedItem =
                                                          branchItemsList.firstWhere(
                                                              (item) =>
                                                                  item[
                                                                      'name'] ==
                                                                  selectedBranch,
                                                              orElse: () =>
                                                                  {'id': null});
                                                      final selectedId =
                                                          selectedItem['id'];
                                                      selectedBranchId =
                                                          selectedId
                                                              ?.toString();

                                                      if (selectedBranchId !=
                                                              null &&
                                                          selectedBranchId!
                                                              .isNotEmpty) {
                                                        stocksManualController
                                                            .fetchItemsLocation(
                                                                selectedBranchId!);
                                                      }

                                                      if (selectedId != null) {
                                                        String idString;

                                                        if (selectedId is int) {
                                                          idString = selectedId
                                                              .toString();
                                                        } else if (selectedId
                                                            is String) {
                                                          idString = selectedId;
                                                          selectedBranchId =
                                                              idString;
                                                        } else {
                                                          idString = '';
                                                        }

                                                        if (idString
                                                            .isNotEmpty) {
                                                          stocksManualController
                                                              .fetchItemsLocation(
                                                                  idString);
                                                        }
                                                      }
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              },
                                            );
                                          } else {
                                            setState(() {
                                              selectedBranch = value;
                                            });

                                            final selectedItem =
                                                branchItemsList.firstWhere(
                                                    (item) =>
                                                        item['name'] ==
                                                        selectedBranch,
                                                    orElse: () => {'id': null});
                                            final selectedId =
                                                selectedItem['id'];
                                            selectedBranchId =
                                                selectedId?.toString();

                                            if (selectedBranchId != null &&
                                                selectedBranchId!.isNotEmpty) {
                                              stocksManualController
                                                  .fetchItemsLocation(
                                                      selectedBranchId!);
                                            }

                                            if (selectedId != null) {
                                              String idString;

                                              if (selectedId is int) {
                                                idString =
                                                    selectedId.toString();
                                              } else if (selectedId is String) {
                                                idString = selectedId;
                                                selectedBranchId = idString;
                                              } else {
                                                idString = '';
                                              }

                                              if (idString.isNotEmpty) {
                                                stocksManualController
                                                    .fetchItemsLocation(
                                                        idString);
                                              }
                                            }
                                          }
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 3),
                                  Obx(() {
                                    bool isLoading =
                                        stocksManualController.isLoading.value;

                                    return ElevatedButton(
                                      onPressed: isLoading
                                          ? null // Disable button while loading
                                          : () async {
                                              setState(() {
                                                isLoading =
                                                    true; // Start the loading state
                                              });

                                              await _updateMapWithNewRadius(
                                                  selectedRadius);

                                              setState(() {
                                                isLoading =
                                                    false; // Stop the loading state
                                              });
                                            },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(100, 40),
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
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Color.fromRGBO(
                                                            255, 255, 255, 1)),
                                              ),
                                            )
                                          :  Text(
                                              'Search',
                                               style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                                              // style: TextStyle(
                                              //   color: Colors.white,
                                              // ),
                                            ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Obx(() {
                                      if (stocksManualController
                                          .isItemsLoading.value) {
                                        return _buildShimmerLoading();
                                      }
                                      if (stocksManualController
                                          .items.isEmpty) {
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
                                                  Icons.search_off,
                                                  size: 80,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Shimmer.fromColors(
                                                baseColor: const Color.fromARGB(
                                                    255, 53, 51, 51),
                                                highlightColor: Colors.white,
                                                child:  Text(
                                                  'No results found.\nPlease select a location and radius to load nearby branches.',
                                                  style: theme.textTheme.bodyLarge?.copyWith(
                                                    fontSize: 17,
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
                                      int totalItemCount =
                                          stocksManualController.items.length;

                                      final int totalRows =
                                          stocksManualController.items.length;
                                      final int startIndex =
                                          _currentPage * _rowsPerPage;
                                      final int endIndex =
                                          (startIndex + _rowsPerPage)
                                              .clamp(0, totalRows);

                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          textTheme:  TextTheme(
                                            bodySmall:
                                             theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
                                                // TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: PaginatedDataTable(
                                              dataRowHeight: 36,
                                              headingRowHeight: 40,
                                              header: Text(
                                                // ignore: unrelated_type_equality_checks
                                                'Total Surplus stocks Count: ${stocksManualController.items.where((item) => item != 0).length}',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              headingRowColor:
                                                  MaterialStateProperty.all(
                                                      const Color.fromARGB(
                                                          255, 215, 210, 210)),
                                              rowsPerPage: _rowsPerPage >
                                                      stocksManualController
                                                          .items.length
                                                  ? stocksManualController
                                                      .items.length
                                                  : _rowsPerPage,
                                              availableRowsPerPage: [
                                                10,
                                                20,
                                                50,
                                                60,
                                                80,
                                                stocksManualController
                                                    .items.length,
                                              ],
                                              onRowsPerPageChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    _rowsPerPage = value;
                                                  });
                                                }
                                              },
                                              onPageChanged: (pageIndex) {
                                                setState(() {
                                                  _currentPage =
                                                      pageIndex ~/ _rowsPerPage;
                                                });
                                              },
                                              columns:  [
                                                DataColumn(
                                                  label: Text(
                                                    "Item ID",
                                                    style: theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Part No",
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "On Hand",
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Purchase Price",
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Transfer Quantity",
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Consigment Number",
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Consignment ID",
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Action",
                                                    style:  theme.textTheme.bodyLarge?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                              // source: _IndentDataTableSource(
                                              //   stocksManualController.items
                                              //       .skip(_currentPage *
                                              //           _rowsPerPage) // Skip items for previous pages
                                              //       .take(
                                              //           _rowsPerPage) // Take the relevant items for the current page
                                              //       .toList(),
                                              //   cartItems,
                                              //   selectedBranch!,
                                              //   context,
                                              // ),
                                              source: _IndentDataTableSource(
                                                stocksManualController.items
                                                    .toList(),
                                                cartItems,
                                                selectedBranch!,
                                                context,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (cartItems.isNotEmpty)
                            SizedBox(
                                width: double.infinity,
                                child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Colors.white,
                                    child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Text(
                                                  'Total Items in Cart: ${cartItems.length}',
                                                  style:   theme.textTheme.bodyLarge?.copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: 200,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: DataTable(
                                                    border: TableBorder.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1,
                                                    ),
                                                    columnSpacing: 70.0,
                                                    horizontalMargin: 16.0,
                                                    headingRowColor:
                                                        MaterialStateProperty
                                                            .all(
                                                      Colors.blue.shade100,
                                                    ),
                                                    headingTextStyle:
                                                        theme.textTheme.bodyLarge?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      const DataColumn(
                                                          label: Text('S. No')),
                                                      const DataColumn(
                                                          label:
                                                              Text('Part No')),
                                                      const DataColumn(
                                                          label:
                                                              Text('Branch')),
                                                      const DataColumn(
                                                          label:
                                                              Text('Quantity')),
                                                      const DataColumn(
                                                          label: Text(
                                                              'Purchase Price')),
                                                      // const DataColumn(
                                                      //     label: Text(
                                                      //         'Consignment ID')),
                                                      DataColumn(
                                                        label: Container(
                                                          alignment: Alignment
                                                              .centerRight, // Right-align the header
                                                          child: const Text(
                                                              'Total Amount'),
                                                        ),
                                                      ),
                                                      const DataColumn(
                                                          label:
                                                              Text('Action')),
                                                    ],
                                                    rows: cartItems
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      final index = entry.key;
                                                      final item = entry.value;
                                                      return DataRow(
                                                        cells: [
                                                          DataCell(Text(
                                                              '${index + 1}')),
                                                          DataCell(Text(
                                                              item['partNo'])),
                                                          DataCell(Text(item[
                                                                  'branchName'] ??
                                                              'N/A')),
                                                          DataCell(Text(
                                                              '${item['transferQuantity']}')),
                                                          DataCell(Text(
                                                              '${item['purchasePrice']}')),
                                                          DataCell(
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                '${item['totalAmount'] != null ? item['totalAmount'].toStringAsFixed(2) : '0.00'}',
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red),
                                                              onPressed: () {
                                                                _showDeleteConfirmationDialog(
                                                                    item);
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width: 200,
                                                      height: 50,
                                                      child: ElevatedButton(
                                                        onPressed:
                                                            _showClearCartDialog,
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                        child: const Text(
                                                            'Clear All Items'),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    SizedBox(
                                                      width: 200,
                                                      height: 50,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          print(
                                                              'Selected Location ID set to: $selectedLocationId');
                                                          print(
                                                              'Selected Branch ID set to: $selectedBranchId');
                                                          print(
                                                              "Cart Items: $cartItems");
                                                          if (selectedLocationId ==
                                                                  null ||
                                                              selectedLocationId!
                                                                  .isEmpty ||
                                                              cartItems
                                                                  .isEmpty) {
                                                            AppSnackBar.alert(
                                                                message:
                                                                    "Please select a location and add items to the cart.");
                                                            return;
                                                          }

                                                          TransferOrderModel
                                                              order =
                                                              TransferOrderModel(
                                                            tolocation:
                                                                int.tryParse(
                                                                    selectedLocationId!),
                                                            subsidiary: 2,
                                                            branchid: int.tryParse(
                                                                selectedBranchId!),
                                                            items: cartItems
                                                                .map((item) {
                                                              print(
                                                                  'Consignment Id: ${item['ConsignmentID'] ?? "N/A"}');
                                                              print(
                                                                  'Item details: ${item.toString()}');
                                                              int consignmentId = item[
                                                                          'ConsignmentID']
                                                                      is String
                                                                  ? int.tryParse(
                                                                          item[
                                                                              'ConsignmentID']) ??
                                                                      0
                                                                  : item['ConsignmentID'] ??
                                                                      0;
                                                              return ItemDetail(
                                                                itemId: item[
                                                                    'itemId'],
                                                                totalAmount:
                                                                    item['totalAmount'] ??
                                                                        0.0,
                                                                quantityAdded:
                                                                    item['transferQuantity'] ??
                                                                        0,
                                                                consignmentId:
                                                                    consignmentId
                                                                        .toString(),
                                                              );
                                                            }).toList(),
                                                          );

                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (dialogContext) {
                                                              return CustomAlertDialog(
                                                                title:
                                                                    'Are you sure?',
                                                                message:
                                                                    'Do you want to create the transfer order?',
                                                                onConfirm:
                                                                    () async {
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop(); // Close dialog
                                                                  // Call the function to send the transaction request
                                                                  setState(() {
                                                                    isCreatingOrder =
                                                                        true; // Start loading
                                                                  });
                                                                  await stocksManualController
                                                                      .sendTransactionManualRequest(
                                                                    order:
                                                                        order,
                                                                  );

                                                                  setState(() {
                                                                    cartItems
                                                                        .clear();
                                                                    stocksManualController
                                                                        .items
                                                                        .clear();
                                                                    isCreatingOrder =
                                                                        false;
                                                                  });
                                                                },
                                                                onCancel: () {
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop(); // Close dialog
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                        ),
                                                        child:
                                                            isCreatingOrder // Modify button with loading state
                                                                ? const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          1)),
                                                                    ),
                                                                  )
                                                                : const Text(
                                                                    'Create Transfer Order'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))))
                        ])))));
  }

  Widget _buildShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final columnSpacing =
            screenWidth * 0.1; // Adjust column spacing based on screen width
        final cellWidth = screenWidth * 0.2; // Adjust cell width dynamically
 final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
        return Column(
          children: List.generate(
            1,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Allow horizontal scrolling
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnSpacing: columnSpacing,
                    horizontalMargin: 16.0,
                    headingRowColor: MaterialStateProperty.all(
                      Colors.blue.shade100,
                    ),
                    headingTextStyle:  theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                      // fontFamily: 'Roboto',
                    ),
                    dataTextStyle:  theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                      // fontFamily: 'Roboto',
                    ),
                    columns:  [
                      DataColumn(
                        label: Text('Item ID', style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text('On Hand', style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text('Part No', style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text('Purchase Price',
                            style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text('Transfer Quantity',
                            style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text('Consignment Number',
                            style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text('Consignment ID',
                            style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text('Action', style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                      ),
                    ],
                    rows: List.generate(5, (index) {
                      return DataRow(cells: [
                        ...List.generate(8, (_) {
                          return DataCell(
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: cellWidth,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IndentDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> cartItems;
  final String selectedBranch;
  final BuildContext context;
  

  _IndentDataTableSource(
      this.items, this.cartItems, this.selectedBranch, this.context);

  @override
  DataRow getRow(int index) {
    final item = items[index];

    // Create a TextEditingController if not already assigned
    TextEditingController controller = item['controller'] ??=
        TextEditingController(text: item['transferQuantity']?.toString() ?? '');
         final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return DataRow(cells: [
      DataCell(Text(item['itemId'].toString())),
      DataCell(Text(item['item'].toString())),
      DataCell(Text(item['onhand']?.toString() ?? '0')),
      DataCell(Text((double.tryParse(item['purchasePrice'].toString())
              ?.toStringAsFixed(2)) ??
          '0.00')),
      DataCell(
        SizedBox(
          width: 100,
          height: 30,
          child: TextField(
            controller: controller,
            decoration:  InputDecoration(
              hintText: 'Enter quantity',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            style:theme.textTheme.bodyLarge?.copyWith(fontSize: 12),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              // Update transfer quantity when changed
              item['transferQuantity'] = value.isEmpty ? '' : value;
            },
          ),
        ),
      ),
      DataCell(Text(item['ConsigmentNumber'] ?? 'N/A')),
      DataCell(Text(item['ConsignmentID'] ?? 'N/A')),
      DataCell(
        SizedBox(
          width: 100,
          height: 30,
          child: ElevatedButton(
            onPressed: () {
              final transferQuantity =
                  int.tryParse(item['transferQuantity']?.toString() ?? '0');
              final onhand = int.tryParse(item['onhand'].toString());

              // Check if item already in cart
              final existingItem = cartItems.firstWhere(
                (cartItem) => cartItem['itemId'] == item['itemId'],
                orElse: () => {},
              );

              if (existingItem.isNotEmpty) {
                AppSnackBar.alert(
                  message:
                      'Item ${item['itemId']} has already been added to the cart!',
                  title: 'Warning',
                );
                return;
              }

              // Check transfer quantity validity
              if (transferQuantity == null || transferQuantity <= 0) {
                showCustomDialog(context, 'Please enter a transfer quantity!',
                    showOkButton: true);
                return;
              } else if (transferQuantity > onhand!) {
                showCustomDialog(context,
                    'You entered more quantity than available on hand!',
                    showOkButton: true);
                return;
              }

              final totalPrice = transferQuantity *
                  double.tryParse(item['purchasePrice'].toString())!;
              cartItems.add({
                'itemId': item['itemId'],
                'partNo': item['item'],
                'transferQuantity': transferQuantity,
                'purchasePrice': item['purchasePrice'],
                'ConsignmentID': item['ConsignmentID'],
                'totalAmount': totalPrice,
                'branchName': selectedBranch,
              });

              item['isInCart'] = true;
              item['isFullyAdded'] = (transferQuantity == onhand);
              item['transferQuantity'] = '';

              AppSnackBar.success(
                message: '${item['item']} added to cart successfully!',
              );

              print('Added to Cart:');
              print('Item ID: ${item['itemId']}');
              print('Part No: ${item['item']}');
              print('Transfer Quantity: $transferQuantity');
              print('Total Amount: $totalPrice');
              print('Consignment Number: ${item['ConsigmentNumber'] ?? "N/A"}');
              print('Branch: $selectedBranch');
              print('Consignment Id: ${item['ConsignmentID'] ?? "N/A"}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  item['isInCart'] && (item['isFullyAdded'] == true)
                      ? Colors.grey
                      : Colors.blue,
              textStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add to Cart'),
          ),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;

  void showCustomDialog(BuildContext context, String message,
      {bool showOkButton = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Error',
          message: message,
          showOkButton: showOkButton,
          onOk: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
