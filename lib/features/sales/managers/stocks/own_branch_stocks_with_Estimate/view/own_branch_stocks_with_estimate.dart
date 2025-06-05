import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/customerdropdown.dart';
import 'package:impal_desktop/features/global/theme/widgets/customerdropdownestimate.dart';

import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/controllers/customer_details_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/controllers/sales_order_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/model/saleorderslb_model.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/widget/sales_order_ownbranchstocks_widget.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/widget/sales_order_widget.dart';
import 'package:impal_desktop/version_controller.dart';

import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/own_branch_stocks/controllers/own_branch_controller.dart';

class OwnBranchStocksWithEstimatePage extends StatefulWidget {
  static const String routeName = '/OwnBranchStocksWithEstimatePage';

  const OwnBranchStocksWithEstimatePage({super.key});

  @override
  _OwnBranchStocksWithEstimatePageState createState() => _OwnBranchStocksWithEstimatePageState();
}

class _OwnBranchStocksWithEstimatePageState extends State<OwnBranchStocksWithEstimatePage> {

    bool _isLoading = false;

  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final OwnBranchController ownBranchController =
      Get.put(OwnBranchController());
  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());
  final LoginController loginController = Get.find<LoginController>();

  final TextEditingController partNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  TextEditingController slbvalueController = TextEditingController();
  TextEditingController slbtownlocationController = TextEditingController();
  TextEditingController slbtownlocationIdController = TextEditingController();
  TextEditingController availableQuantityController = TextEditingController();
  TextEditingController requiredQuantityController = TextEditingController();

  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final GlobalcustomerController globalcustomerController =
      Get.put(GlobalcustomerController());

  final CustomerDetailsController customerDetailsController =
      Get.put(CustomerDetailsController());

  final SalesOrderController salesOrderController =
      Get.put(SalesOrderController());

    final VersionController versionController = Get.put(VersionController());

  int? selectedCustomerId;
  bool isDisabledDropdown = false;
  int? selectedSalesId; // Store selected ID
  bool isDropdownDisabled = false;
  int? selectedSupplierIds;
  String? sbbl;
  String? slbname;

  String? ordertypeId;
  bool isLoadingorder = true;
  final List<Map<String, dynamic>> salesOptions = [
    {"name": "Cash Sales", "id": 1},
    {"name": "Credit Sales", "id": 2},
    {"name": "Advance Sales", "id": 5}
    // {"name": "Distress Sale", "id": 4},
  ];

  Rx<String?> selectedSupplier = Rx<String?>(null);
  Rx<String?> selectedPartNumberId = Rx<String?>(null);
  Rx<String?> selectedDescriptionId = Rx<String?>(null);

  RxBool showPartNumberDropdown = false.obs;
  RxBool showDescriptionDropdown = false.obs;

  RxBool isLoading = true.obs;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
    selectedSalesId = 2; // Default to "Credit Sales"
    ordertypeId = selectedSalesId.toString();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoadingorder = false;
      });
    });
  }

  Future<void> _fetchSuppliers() async {
    await globalSupplierController.fetchSupplier();
    isLoading.value = false;
  }

  void onPartNumberChanged(String value) {
    if (value.isNotEmpty) {
      final globalsupplierController = Get.find<GlobalsupplierController>();

      final selectedSupplierId =
          globalsupplierController.selectedSupplierId.value;

      globalItemsController
          .fetchGlobalItems(value, "", selectedSupplierId)
          .then((_) {
        setState(() {
          showPartNumberDropdown.value = true;
        });
      });
    } else {
      clearFieldsAndData(); // Clear fields and data if part number is empty
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  void onDescriptionChanged(String value) {
    if (value.isNotEmpty) {
      final globalsupplierController = Get.find<GlobalsupplierController>();

      final selectedSupplierId =
          globalsupplierController.selectedSupplierId.value;

      globalItemsController
          .fetchGlobalItems("", value, selectedSupplierId)
          .then((_) {
        setState(() {
          showDescriptionDropdown.value = true;
        });
      });
    } else {
      clearFieldsAndData(); // Clear fields and data if description is empty
    }
  }

  void onSelectPartNumber(GlobalitemDetail item) {
    FocusScope.of(context).unfocus();
    partNumberController.text = item.itemName ?? '';
    selectedPartNumberId.value = item.itemId;

    descriptionController.text = item.desc ?? '';
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear();
    showPartNumberDropdown.value = false;
    showDescriptionDropdown.value = true;
  }

  void onSelectDescription(GlobalitemDetail item) {
    FocusScope.of(context).unfocus();
    descriptionController.text = item.desc ?? '';
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear();
    fetchPartNumbersByDescription(item.desc!);
    showDescriptionDropdown.value = false;
  }

  void fetchPartNumbersByDescription(String description) {
    final globalsupplierController = Get.find<GlobalsupplierController>();

    final selectedSupplierId =
        globalsupplierController.selectedSupplierId.value;

    globalItemsController
        .fetchGlobalItems("", description, selectedSupplierId)
        .then((_) {
      if (globalItemsController.globalItems.isNotEmpty) {
        selectedPartNumberId.value =
            globalItemsController.globalItems.first.itemId;
        partNumberController.text =
            globalItemsController.globalItems.first.itemName ?? '';
        showPartNumberDropdown.value = true;
      }
    });
  }

  void toggleFields(String field) {
    if (field == 'partNo') {
      descriptionController.clear();
      selectedDescriptionId.value = null;
      partNumberController.text = '';
      showDescriptionDropdown.value = false;
    } else {
      partNumberController.clear();
      selectedPartNumberId.value = null;
      descriptionController.text = '';
      showPartNumberDropdown.value = false;
    }
  }

  void _onSearchPressed(String partNumber, String supplierId) {
    String? branchId = loginController.location;
    String selectedSupplierId =
        globalSupplierController.selectedSupplierId.value;

    if (selectedSupplierId.isEmpty) {
      AppSnackBar.alert(message: "Please select a supplier");
      return;
    }

    ownBranchController.isLoading.value = true;

    ownBranchController
        .fetchOwnBranchDetails(partNumber, selectedSupplierId, branchId!)
        .then((_) {
      ownBranchController.isLoading.value = false;
      setState(() {});
    }).catchError((error) {
      AppSnackBar.alert(
          message: "An error occurred while fetching details: $error");
      ownBranchController.isLoading.value = false;
    });
  }

  void clearFieldsAndData() {
    partNumberController.clear();
    descriptionController.clear();
    selectedPartNumberId.value = null;
    selectedDescriptionId.value = null;
    ownBranchController.ownDetails
        .clear(); // Clear existing data in the data table
    showPartNumberDropdown.value = false;
    showDescriptionDropdown.value = false;
  }

  @override
  void dispose() {
    partNumberController.dispose();
    descriptionController.dispose();

    globalItemsController.globalItems.clear();

    final globalsupplierController = Get.find<GlobalsupplierController>();
    globalsupplierController.selectedSupplierId.value = '';

    if (Get.isRegistered<OwnBranchController>()) {
      Get.delete<OwnBranchController>();
    }

    super.dispose();
  }

  RxInt currentPage = 1.obs;
  final int itemsPerPage = 50;
  final ScrollController scrollController = ScrollController();

//   List<GlobalitemDetail> get filteredData {
//   if (searchQuery.isEmpty) {
//     return globalItemsController.GlobalitemDetail;
//   }
//   return globalItemsController.GlobalitemDetail.where((item) {
//     return (item.partno?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
//            (item.desc?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
//   }).toList();
// }

  List<GlobalitemDetail> get filteredData {
    if (searchQuery.isEmpty) {
      return globalItemsController.globalItems;
    }
    return globalItemsController.globalItems.where((item) {
      return (item.itemName
                  ?.toLowerCase()
                  .contains(searchQuery.toLowerCase()) ??
              false) ||
          (item.desc?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false);
    }).toList();
  }

// Update your getPaginatedData method to use filteredData
  List<GlobalitemDetail> getPaginatedData() {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredData.sublist(
      startIndex,
      endIndex > filteredData.length ? filteredData.length : endIndex,
    );
  }

    Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: "Exit Confirmation",
            message: "Are you sure you want to leave this page?",
            onCancel: () {
              Navigator.of(context).pop(false);
            },
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
          ),
        ) ??
        false;
  }

String _getSalesTypeName(int? id) {
  if (id == null) return 'Not Selected';
  final option = salesOptions.firstWhere(
    (option) => option['id'] == id,
    orElse: () => {'name': 'Unknown'},
  );
  return option['name'];
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    final totalPages = (filteredData.length / itemsPerPage).ceil();

    return WillPopScope(
        onWillPop: () async {
          bool shouldExit = await _showExitConfirmationDialog(context);
          return shouldExit;
        },
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Own Branch Stocks',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth,
              padding: const EdgeInsets.only(top: 10, bottom: 0),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 150.0, left: 150.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: Theme.of(context).brightness ==
                                Brightness.dark
                            ? LinearGradient(
                                colors: [
                                  Colors.blueGrey.shade900,
                                  Colors.blueGrey.shade900,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF6B71FF), Color(0xFF57AEFE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                   child:
                                                                AbsorbPointer(
                                                              absorbing:
                                                                  isDisabledDropdown,
                                  child: CustomerDropdownestimate(
                                    label: "Customer",
                                    hintText: "Select Customer",
                                    controller: _customerController,
                                    globalcustomerController:
                                        globalcustomerController,
                                    onCustomerSelected: (selectedId) {
                                      setState(() {
                                        selectedCustomerId = selectedId;
                                        isDisabledDropdown = true;
                                      });
                                      final String id = selectedId.toString();
                                      // Fetch outstanding details based on selected customer ID
                                      customerDetailsController
                                          .fetchOutstandingDetailsCustomer(id);
                                    },
                                  ),
                                                                ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SalesorderSupplierEstimatedropdown(
                                    label: 'Supplier Name'.tr,
                                    hintText: 'Choose Supplier Name...'.tr,
                                    controller: _supplierController,
                                    globalSupplierController:
                                        globalSupplierController,
                                    onSupplierSelected: (selectedId) {
                                      setState(() {
                                        globalSupplierController
                                                .selectedSupplierId.value =
                                            selectedId?.toString() ?? '';
                                        selectedSupplierIds = selectedId;
                                        print('SupplierId:$selectedId');
                                      });
                                    },
                                  ),
                                  // Supplierdropdown(
                                  //   label: 'Supplier Name',
                                  //   hintText: 'Select Supplier...',
                                  //    controller:
                                  //                               _supplierController,
                                  //   globalSupplierController:
                                  //       globalSupplierController,
                                  //   onSupplierSelected: (selectedSupplierId) {
                                  //     globalSupplierController
                                  //             .selectedSupplierId.value =
                                  //         selectedSupplierId?.toString() ?? '';
                                  //         selectedSupplierIds =
                                  //                                   selectedSupplierId;
                                  //     print('SupplierId:$selectedSupplierId');
                                  //   },
                                  // ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSalesTypeDropdownField(
                                    label: 'Select Sales Type',
                                    hintText: 'Choose Sales Type...',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const SizedBox(width: 5),
                                ElevatedButton(
  onPressed: salesOrderController.isLoadingslbpartnumber.value
      ? null // Disable button while loading
      : () async {
          if (selectedCustomerId == null) {
            AppSnackBar.alert(message: "Please Select Customer");
            return;
          }

          if (selectedSupplierIds == null) {
            AppSnackBar.alert(message: "Please Select Supplier Name");
            return;
          }

          String partNumber = selectedPartNumberId.value ??
              partNumberController.text.trim();

          String supplierId = selectedSupplierIds.toString();
          String customerId = selectedCustomerId.toString();

          globalItemsController.globalItems.clear();

          // Start loading
          salesOrderController.isLoadingslbpartnumber.value = true;

          try {
            await salesOrderController
                .fetchslbpartnumbervalue(supplierId, customerId);

            if (salesOrderController.isSlbPartNumberVisible.value) {
              await globalItemsController
                  .fetchGlobalItems("", "", supplierId);
            } else {
              globalItemsController.globalItems.clear();
            }
          } finally {
            // Stop loading
            salesOrderController.isLoadingslbpartnumber.value = false;
          }
        },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 251, 134, 45),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(90),
    ),
    minimumSize: const Size(50, 45),
  ),
  child: Obx(() {
    return salesOrderController.isLoadingslbpartnumber.value
        ? const SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.0,
            ),
          )
        : const Icon(
            Icons.search,
            color: Colors.white,
          );
  }),
)

    //                             ElevatedButton(
    //                               onPressed: () async {
    //                                   if (selectedCustomerId == null) {
    //   AppSnackBar.alert(message: "Please Select Customer");
    //   return;
    // }
                                      
    // if (selectedSupplierIds == null) {
    //   AppSnackBar.alert(message: "Please Select Supplier Name");
    //   return;
    // }
    //                                 String partNumber =
    //                                     selectedPartNumberId.value ??
    //                                         partNumberController.text.trim();


    //                                 String supplierId =
    //                                     selectedSupplierIds.toString();
                              
    //                                 String customerId =
    //                                     selectedCustomerId.toString();
                                    
    //                                 globalItemsController.globalItems.clear();

    //                                 await salesOrderController
    //                                     .fetchslbpartnumbervalue(
    //                                         supplierId, customerId);

    //                                 if (salesOrderController
    //                                     .isSlbPartNumberVisible.value) {
    //                                   await globalItemsController
    //                                       .fetchGlobalItems("", "", supplierId);
    //                                 } else {
    //                                   globalItemsController.globalItems.clear();
    //                                 }

    //                                 //  _onSearchPressed(partNumber, supplierId);
    //                               },
    //                               style: ElevatedButton.styleFrom(
    //                                 backgroundColor:
    //                                     const Color.fromARGB(255, 251, 134, 45),
    //                                 shape: RoundedRectangleBorder(
    //                                   borderRadius: BorderRadius.circular(90),
    //                                 ),
    //                                 minimumSize: const Size(50, 45),
    //                               ),
    //                               child: Obx(() {
    //                                 return salesOrderController.isLoadingslbpartnumber.value
    //                                     ? const SizedBox(
    //                                         width: 24.0,
    //                                         height: 24.0,
    //                                         child: CircularProgressIndicator(
    //                                           color: Colors.white,
    //                                           strokeWidth: 2.0,
    //                                         ),
    //                                       )
    //                                     : const Icon(
    //                                         Icons.search,
    //                                         color: Colors.white,
    //                                       );
    //                               }),
    //                             ),
                              ],
                            ),
                            // const SizedBox(height: 8),
                            // Obx(() => showPartNumberDropdown.value
                            //     ? _buildSuggestionsList()
                            //     : const SizedBox.shrink()),
                            // Obx(() => showDescriptionDropdown.value
                            //     ? _buildDescriptionSuggestionsList()
                            //     : const SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlobalSearchField(
                      hintText: 'Search Supplier...'.tr,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 15),
                    Obx(() {
                      return globalItemsController.isLoading.value
                          ? _buildShimmerTable()
                          : _buildDataTable();
                    }),
                    Obx(() {
                      if (globalItemsController.globalItems.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildPaginationControls();
                    }),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(140, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                _showCartSummaryDialog(context);
              },
              child:  _isLoading
                                                                  ? const SizedBox(
                                                                      width: 24,
                                                                      height:
                                                                          24,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2.5,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )
                                                                  :  Text('Submit Order'),
            ),
          ),
          //  const SizedBox(width: 50,),
          //    Column(
          //               mainAxisAlignment: MainAxisAlignment.end,
          //               children: [
          //                 Row(
          //                  mainAxisAlignment: MainAxisAlignment.end,
          //                     children: [
          //                   ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.green,
          //       foregroundColor: Colors.white,
          //       minimumSize: const Size(120, 40),
          //     ),
          //     onPressed: () {
          //     _showCartSummaryDialog(context);
          //     },

          //     child: const Text('Submit Order'),
          //   ),
          //             ]),
          //               ]),
          //               const SizedBox(width: 50,),
        ],
      ),
        ),
    );
  }

// Update your _buildPaginationControls method
  Widget _buildPaginationControls() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final totalPages = (filteredData.length / itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage.value > 1
                ? () {
                    currentPage.value = 1;
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage.value > 1
                ? () {
                    currentPage.value--;
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),
          Container(
            width: 80,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: TextField(
              controller:
                  TextEditingController(text: currentPage.value.toString()),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value) ?? currentPage.value;
                if (page >= 1 && page <= totalPages) {
                  currentPage.value = page;
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
            ),
          ),
          Text(
            'of $totalPages',
            style: theme.textTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage.value < totalPages
                ? () {
                    currentPage.value++;
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage.value < totalPages
                ? () {
                    currentPage.value = totalPages;
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Total: ${filteredData.length} items',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          8,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                      width: 30,
                      height: 20,
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]),
                  const SizedBox(width: 16),
                  Container(
                      width: 60,
                      height: 20,
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]),
                  const SizedBox(width: 16),
                  Container(
                      width: 190,
                      height: 20,
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      if (globalItemsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (filteredData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Icon(
                  Icons.search_off,
                  size: 100,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Text(
                  'No results found.\nPlease refine your search criteria.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 10, 10, 10),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      List<DataRow> dataRows = getPaginatedData().map((detail) {
        int index = filteredData.indexOf(detail) + 1;

        return DataRow(
          color: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              return (index % 2 == 0)
                  ? const Color(0xFFEAEFFF)
                  : const Color(0xFFFAF9FF);
            },
          ),
          cells: <DataCell>[
            DataCell(Text(index.toString())),
            DataCell(Text(detail.itemName ?? '-')),
            // DataCell(Text(detail.itemId ?? '-')),
            DataCell(Text(detail.desc ?? '-')),
            DataCell(Text(detail.vehicalApplication ?? '-')),
            DataCell(
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  _showAddToCartDialog(context, detail);
                },
              ),
            ),
          ],
        );
      }).toList();

      return Expanded(
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Container(
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    gradient: isDarkMode
                        ? LinearGradient(
                            colors: [
                              Colors.redAccent.shade400,
                              Colors.pink.shade900,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xFF57AEFE),
                              Color(0xFF6B71FF),
                              Color(0xFF6B71FF),
                              Color(0xFF57AEFE),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  ),
                  child: DataTable(
                    columnSpacing: 16.0,
                    headingRowHeight: 40.0,
                    columns: <DataColumn>[
                      DataColumn(
                        label: Center(
                          child: Text('S.No',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text('Part No',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text('Desc',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      // DataColumn(
                      //   label: Center(
                      //     child: Text('Available Stock',
                      //         style: theme.textTheme.bodyLarge?.copyWith(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold,
                      //         )),
                      //   ),
                      // ),
                      DataColumn(
                        label: Center(
                          child: Text('Vehicle No',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text('Action',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                    rows: dataRows,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

// Add this method to your _BranchStockPageState class
  void _showAddToCartDialog(BuildContext context, GlobalitemDetail item) {
    
   setState(() {
    isDropdownDisabled = true;
  });
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    salesOrderController.selectedSlbName.value = '';
    salesOrderController.slbValue.value = '';
    slbvalueController.clear();
    requiredQuantityController.clear();

    TextEditingController quantityController = TextEditingController();
    TextEditingController discountController = TextEditingController();
    final GlobalKey slbDropdownKey =
        GlobalKey(); // Add this key for the dropdown

    salesOrderController.fetchslbtownlocation(selectedCustomerId.toString());

    // final int? supplierId = selectedSupplierIds;
    final String id = selectedSupplierIds.toString();
    final String itemID = item.itemId!;
    salesOrderController.fetchslb(id, selectedCustomerId.toString(), itemID);
    globalItemsController.selectPartNumber(item.itemId!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add to Cart',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display customer and supplier info
                if (selectedCustomerId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Customer: ${_customerController.text}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Supplier: ${_supplierController.text}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 16.0),
                //   child: Text(
                //     'OrderType: $ordertypeId',
                //     style: theme.textTheme.bodyMedium?.copyWith(
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                Padding(
  padding: const EdgeInsets.only(bottom: 16.0),
  child: Text(
    'Order Type: ${_getSalesTypeName(selectedSalesId)}', // Shows "Cash Sales" instead of "1"
    style: theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
    ),
  ),
),
                // Item details
                Text(
                  '${item.itemId} - ${item.itemName} - ${item.desc}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Input fields
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Text(
                          'Select SLB',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Obx(() {
                          if (salesOrderController.isLoadingslbname.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return GestureDetector(
                            key: slbDropdownKey, // Use the key here
                            onTap: () {
                              if (salesOrderController.saleorderslb.isEmpty) {
                                AppSnackBar.alert(
                                    message:
                                        "The Selected SLB doesn't have value please contact Head office.");
                                return;
                              }

                              final RenderBox renderBox = slbDropdownKey
                                  .currentContext!
                                  .findRenderObject() as RenderBox;
                              final Offset offset =
                                  renderBox.localToGlobal(Offset.zero);
                              final Size size = renderBox.size;

                              showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  offset.dx,
                                  offset.dy + size.height,
                                  offset.dx + size.width,
                                  offset.dy + size.height + 200,
                                ),
                                items: salesOrderController.saleorderslb
                                    .map((item) {
                                  return PopupMenuItem<String>(
                                    value: item.id.toString(),
                                    child: SizedBox(
                                      width: size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(item.name ?? 'N/A'),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ).then((selectedValue) {
                                if (selectedValue != null) {
                                  final selectedSlb = salesOrderController
                                      .saleorderslb
                                      .firstWhere(
                                    (item) =>
                                        item.id.toString() == selectedValue,
                                    orElse: () => Dataslb(id: 0, name: ""),
                                  );
                                  final String loc =
                                      salesOrderController.slbtownid.value;
                                  final String? itemid = item.itemId;
                                  final String slb = selectedValue;
                                  print(
                                      "location: $loc - ITemId: $itemid - SlbId: $slb");

                                  salesOrderController.fetchslbvalue(
                                      loc, itemid!, slb);
                                  salesOrderController.selectedSlbName.value =
                                      selectedValue;
                                  salesOrderController.slbName.value =
                                      selectedSlb.name ?? '';
                                  FocusScope.of(context).unfocus();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      salesOrderController
                                              .selectedSlbName.value.isEmpty
                                          ? "Select SLB Name"
                                          : salesOrderController.saleorderslb
                                              .firstWhere(
                                                (item) =>
                                                    item.id.toString() ==
                                                    salesOrderController
                                                        .selectedSlbName.value,
                                                orElse: () =>
                                                    Dataslb(id: 0, name: ""),
                                              )
                                              .name!,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.black),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          if (salesOrderController.isLoadingslbvalue.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final slbvalue = salesOrderController.slbValue;

                          if (slbvalue.isNotEmpty) {
                            slbvalueController.text = slbvalue.value;
                          }

                          return _buildTextFieldua(
                            label: 'SLB Value'.tr,
                            hintText: '',
                            controller: slbvalueController,
                          );
                        }),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (salesOrderController
                            .isLoadingslbtownlocation.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final slbtownlocation =
                            salesOrderController.slbtownlocation;

                        if (slbtownlocation.isNotEmpty) {
                          slbtownlocationIdController.text =
                              salesOrderController.slbtownid.value;
                          slbtownlocationController.text =
                              slbtownlocation.value;
                        }

                        return _buildTextFieldua(
                          label: 'SLB Town / Location'.tr,
                          hintText: '',
                          controller: slbtownlocationController,
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final availableQuantity = globalItemsController
                                    .globalItemStocks.isNotEmpty
                                ? globalItemsController.globalItemStocks.first
                                        .availableQuantity
                                        ?.toInt()
                                        .toString() ??
                                    '0'
                                : 'N/A';

                            if (availableQuantity != 'N/A') {
                              availableQuantityController.text =
                                  availableQuantity;
                            }

                            return _buildTextFieldua(
                              label: 'Available Qty'.tr,
                              hintText: '',
                              controller: availableQuantityController,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Required Qty',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final availableQuantity = globalItemsController
                                    .globalItemStocks.isNotEmpty
                                ? globalItemsController.globalItemStocks.first
                                        .availableQuantity ??
                                    0
                                : 0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 500, // Set the desired width
                                  height: 50,
                                  child: TextField(
                                      controller: requiredQuantityController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(
                                              r'^[0-9]*$'), // Allows only digits (0-9) and prevents decimals
                                        ),
                                      ],
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'Enter required quantity',
                                        hintStyle:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[
                                                  600], // Adjusted hint color
                                        ),
                                        filled: true,
                                        fillColor: isDarkMode
                                            ? Colors.grey[850]
                                            : Colors
                                                .white, // Dark mode background color
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.blueAccent.shade700
                                                : Colors.grey
                                                    .shade400, // Border color
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: const Color.fromARGB(
                                                255,
                                                62,
                                                162,
                                                233), // Focused border color
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 12),
                                        constraints: const BoxConstraints(
                                            maxHeight:
                                                46), // Keep height reasonable
                                      ),
                                      onChanged: (value) {}),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (requiredQuantityController.text.isEmpty) {
                        AppSnackBar.alert(message: "Please enter quantity");
                        return;
                      }
                      if (slbvalueController.text == "No Data") {
                        AppSnackBar.alert(
                            message:
                                'SLB value is required. Please contact the head office!');
                        return;
                      }

                      bool isDuplicate = cartItems
                          .any((cartItem) => cartItem['partNo'] == item.itemId);

                      if (isDuplicate) {
                        AppSnackBar.alert(
                            message: "This item is already in your cart");
                        return;
                      }

                      sbbl = salesOrderController.selectedSlbName.value;
                      if (sbbl == null || sbbl!.isEmpty) {
                        AppSnackBar.alert(
                            message: 'Please select an SLB Field!');
                        return;
                      }

                      slbname = salesOrderController.slbName.value;
                      final String? slb = sbbl;
                      final String? slbnames = slbname;
                      print("good  $slb");
                      print("Bad $slbnames");
                      final String slbvalue = slbvalueController.text;

                      cartItems.add({
                        'partNo': item.itemId,
                        'partNumber': item.itemName,
                        'description': item.desc,
                        'requiredQty': requiredQuantityController.text,
                        'quantity': int.tryParse(quantityController.text) ?? 1,
                        'discount':
                            double.tryParse(discountController.text) ?? 0.0,
                        'customer': _customerController.text,
                        'customerId': selectedCustomerId,
                        'supplier': _supplierController.text,
                        'supplierId':
                            globalSupplierController.selectedSupplierId.value,
                        'selectedSlbName': slb, // Add selected SLB name
                        'slbname': slbnames,
                        'slbvalue': slbvalue
                      });
                      Navigator.of(context).pop();
                      AppSnackBar.success(message: "Item added to cart");
                    },
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showCartSummaryDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (cartItems.isEmpty) {
      AppSnackBar.alert(message: "Cart is empty");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Order Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: SizedBox(
            // width: double.maxFinite,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Customer and Supplier info
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer: ${_customerController.text}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Supplier: ${_supplierController.text}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cart items table
                    Obx(() {
                      if (cartItems.isEmpty) {
                        return const Text('No items in cart');
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Part No')),
                            DataColumn(label: Text('SLB Name')),
                            DataColumn(label: Text('SLB Value')),
                            DataColumn(label: Text('Qty')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: cartItems.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['partNumber'] ?? '')),
                                DataCell(Text(item['slbname'] ?? '')),
                                DataCell(Text(item['slbvalue'] ?? '')),
                                DataCell(Text(item['requiredQty'].toString())),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: Get.context!,
                                        builder: (BuildContext context) {
                                          return CustomAlertDialog(
                                            title: "Delete Item",
                                            message:
                                                "Are you sure you want to delete this item?",
                                            onConfirm: () {
                                              cartItems.remove(item);
                                              Get.back();
                                              Get.back();
                                              AppSnackBar.success(
                                                  message:
                                                      'Item removed from cart!');
                                            },
                                            onCancel: () {
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      minimumSize: Size(120, 40),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(120, 40),
                    ),
                    onPressed:   _isLoading
                                                                  ? null // Disables button when loading
                                                                  : () {
                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return CustomAlertDialog(
                                                                            title:
                                                                                'Confirm ',
                                                                            message:
                                                                                'Are you sure you want to submit this order?',
                                                                            onConfirm:
                                                                                () async {
                                                                              Navigator.of(context).pop();
                                                                              Get.back();

                                                                              if (cartItems.isEmpty) {
                                                                                AppSnackBar.alert(message: 'Cart is empty!');
                                                                                return;
                                                                              }

                                                                              setState(() {
                                                                                _isLoading = true;
                                                                              });

                                                                              final String customerId = customerDetailsController.outstandingDetails[0]['CustomerID'].toString();

                                                                              final String version = versionController.version.toString();

                                                                              Map<String, dynamic> requestBody = {
                                                                                "CustomerId": customerId,
                                                                                "OrderType": ordertypeId,
                                                                                "Version": version,
                                                                                "item": {
                                                                                  "items": cartItems.map((item) {
                                                                                    return {
                                                                                      "Supplier": item['supplierId'],
                                                                                      "itemId": item['partNo'],
                                                                                      "Unitprice": "",
                                                                                      "itemQuantity": item['requiredQty'],
                                                                                      "slbid": item['selectedSlbName'],
                                                                                      "slbValue": item['slbvalue'],
                                                                                      "Source": "Desktop App",
                                                                                    };
                                                                                  }).toList(),
                                                                                }
                                                                              };

                                                                              await salesOrderController.sendCartDataToApi(requestBody);

                                                                              setState(() {
                                                                                _isLoading = false; // Re-enable button after request completes
                                                                              });
                                                                            },
                                                                            onCancel:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          );
                                                                        },
                                                                      );
                      // print('Submitting order: ${cartItems.toList()}');
                      // AppSnackBar.success(
                      //     message: "Order submitted successfully");
                      // cartItems.clear();
                      // Navigator.of(context).pop();
                    },
                    child: const Text('Confirm Order'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextFieldua({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 500,
          height: 50,
          child: TextField(
            readOnly: true, // Read-only mode
            maxLines: maxLines,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              filled: true,
              fillColor: (true) // Check if the field is read-only
                  ? const Color.fromARGB(
                      255, 242, 241, 241) // Gray background when read-only
                  // ignore: dead_code
                  : (isDarkMode ? Colors.grey[850] : Colors.white), // Default
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.blueAccent.shade700
                      : Colors.grey.shade400,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 62, 162, 233),
                  width: 1.5,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: const BoxConstraints(maxHeight: 46),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextEditingController? controller,
    bool enabled = true,
    required ValueChanged<bool> onFocusChange,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Focus(
      onFocusChange: (hasFocus) => onFocusChange(hasFocus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: enabled ? onChanged : (value) {},
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white : Colors.grey.shade100,
                  width: isDarkMode ? 0.8 : 0.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.black : Colors.white,
                  width: 0.2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: const BoxConstraints(maxHeight: 46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTypeDropdownField({
    required String label,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? Colors.grey : Colors.grey,
              width: 1.2,
            ),
          ),
          constraints: const BoxConstraints(
            maxHeight: 46,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedSalesId, // Default to "Credit Sales"
              hint: Text(
                hintText,
                style: theme.textTheme.bodyLarge,
              ),
              onChanged: isDropdownDisabled
                  ? null
                  : (int? newValue) {
                      setState(() {
                        selectedSalesId = newValue;
                        ordertypeId = selectedSalesId.toString();
                        print("Selected Sales Type ID: $selectedSalesId");
                        print("ordertypeId: $ordertypeId");
                        isDropdownDisabled = true; // Disable after selection
                      });
                    },
              items: salesOptions.map<DropdownMenuItem<int>>((option) {
                return DropdownMenuItem<int>(
                  value: option["id"],
                  child: Text(
                    option["name"],
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.grey[900]! : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }
}
