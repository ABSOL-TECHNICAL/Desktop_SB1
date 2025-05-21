import 'package:flutter/material.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/global/theme/widgets/suppliersearchdrodown.dart';
import 'package:intl/intl.dart';

import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/branch_transfers/controller/branch_transfers_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/branch_transfers/model/branch_transfers_model.dart';

class BranchTransfersPage extends StatefulWidget {
  static const String routeName = '/BranchTransfersPage';

  const BranchTransfersPage({super.key});

  @override
  _BranchTransfersPageState createState() => _BranchTransfersPageState();
}

class _BranchTransfersPageState extends State<BranchTransfersPage> {
  bool isLoading = true;
  bool isSearchPerformed = false; // Track if search is performed
  String? selectedLocation;
  String lrDate = '';
  TextEditingController partNumberController = TextEditingController();
  TextEditingController lrDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Rx<String?> selectedSupplier = Rx<String?>(null);

  Rx<String?> selectedPartNumberId = Rx<String?>(null);
  Rx<String?> selectedDescriptionId = Rx<String?>(null);
  RxBool showPartNumberDropdown = false.obs;
  RxBool showDescriptionDropdown = false.obs;
  List<Map<String, dynamic>> fetchBranchTransferDetails = [];
  String searchQuery = '';
  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());
  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final BranchTransfersController branchTransfersController =
      Get.put(BranchTransfersController());
  RxList<DefaulBranchstock> searchedBranchTransfer = <DefaulBranchstock>[].obs;
  final BranchTransfersController locationController = Get.find();
  RxList<DefaulBranchstock> searchedBranch = <DefaulBranchstock>[].obs;

  String fromDate = 'Choose From Date';
  String toDate = 'Choose To Date';

  RxString fromdate = ''.obs;
  RxString todate = ''.obs;


  Future<String?> getSupplierId(String supplierName) async {
    final selectedSupplierDetails = globalSupplierController
        .globalsupplierController
        .firstWhere((item) => item['Supplier'] == supplierName,
            orElse: () => null);

    return selectedSupplierDetails?['SupplierId'];
  }

  List<String> get supplierName {
    return globalSupplierController.globalsupplierController
        .map((item) => item['Supplier'].toString())
        .toList();
  }

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch default data when the page is initialized
    locationController.fetchLocations();
    globalSupplierController.fetchSupplier();
    branchTransfersController.fetchBranchStockDefault();

    // Listen for changes in the defaultBranchStocks for loading state
    branchTransfersController.defaultBranchStocks.listen((_) {
      setState(() {
        isLoading = false;
        // Set the searchedBranchTransfer to the default stocks initially
        searchedBranchTransfer.value =
            branchTransfersController.defaultBranchStocks;
      });
    });

    branchTransfersController.supplierDetails.listen((data) {
      setState(() {
        searchedBranchTransfer.value = data
            .map((d) => DefaulBranchstock.fromJson(d as Map<String, dynamic>))
            .toList();
      });
    });
  }

  Future<void> _pickFromDate() async {
    DateTime pickedDate;
    if (fromDate != 'Choose From Date') {
      pickedDate = DateFormat('dd/MM/yyyy').parse(fromDate);
    } else {
      pickedDate = DateTime.now();
    }

    DateTime? newPickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (newPickedDate != null) {
      _onFromDatePicked(newPickedDate);
    }
  }

  Future<void> _pickToDate() async {
    DateTime pickedDate;
    if (toDate != 'Choose To Date') {
      pickedDate = DateFormat('dd/MM/yyyy').parse(toDate);
    } else {
      pickedDate = DateTime.now();
    }

    DateTime? newPickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(2000), // Ensure a valid date
      lastDate: DateTime(2100),
    );

    if (newPickedDate != null) {
      _onToDatePicked(newPickedDate);
    }
  }

  void _onFromDatePicked(DateTime pickedDate) {
    if (toDate != 'Choose To Date' &&
        pickedDate.isAfter(DateFormat('dd/MM/yyyy').parse(toDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("From Date cannot be later than To Date.")),
      );
      return;
    }

    setState(() {
      fromDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void _onToDatePicked(DateTime pickedDate) {
    if (fromDate != 'Choose From Date' &&
        pickedDate.isBefore(DateFormat('dd/MM/yyyy').parse(fromDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("To Date cannot be earlier than From Date.")),
      );
      return;
    }

    setState(() {
      toDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<BranchTransfersController>()) {
      print("Disposing Branch Transfers...");
      Get.delete<BranchTransfersController>();
    } else {
      print("Branch Transfers is not registered, no need to dispose.");
    }
    super.dispose();
    print("Branch Transfers disposed.");
    final globalsupplierController = Get.find<GlobalsupplierController>();
    globalsupplierController.selectedSupplierId.value = '';
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
      showDescriptionDropdown.value = false; // Hide the description dropdown
    } else {
      partNumberController.clear();
      selectedPartNumberId.value = null;
      descriptionController.text = '';
      showPartNumberDropdown.value = false; // Hide the part number dropdown
    }
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
          fetchBranchTransferDetails.clear(); // Clear displayed items data
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showPartNumberDropdown.value = false;
      descriptionController.clear();
      selectedDescriptionId.value = null;
      showDescriptionDropdown.value = false; // Hide description dropdown
    }
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
          fetchBranchTransferDetails.clear(); // Clear displayed items data
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showDescriptionDropdown.value = false;
    }
  }

  void onSelectPartNumber(GlobalitemDetail item) {
    FocusScope.of(context).unfocus(); // Close the keyboard
    partNumberController.text = item.itemName ?? '';
    selectedPartNumberId.value = item.itemId;

    // Set the description based on the selected part number
    descriptionController.text = item.desc ?? '';
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear();
    showPartNumberDropdown.value = false; // Hide dropdown after selection
    showDescriptionDropdown.value = true; // Show the description dropdown
  }

  void onSelectDescription(GlobalitemDetail item) {
    FocusScope.of(context).unfocus(); // Close the keyboard
    descriptionController.text =
        item.desc ?? ''; // Set selected description in the field
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear(); // Clear current items

    // Fetch related part numbers based on the selected description
    fetchPartNumbersByDescription(item.desc!);

    showDescriptionDropdown.value = false;
  }

  List<DefaulBranchstock> _filterData() {
    if (searchQuery.isEmpty) {
      return branchTransfersController.defaultBranchStocks;
    } else {
      return branchTransfersController.defaultBranchStocks.where((detail) {
        return "${detail.supplierName} - ${detail.toNumber}"
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  List<DefaulBranchstock> _getPaginatedData(List<DefaulBranchstock> allData) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= allData.length) {
      return [];
    }
    return allData.sublist(
      startIndex,
      startIndex + _itemsPerPage > allData.length
          ? allData.length
          : startIndex + _itemsPerPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Branch Transfers',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: screenWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 0),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, right: 150.0, left: 150.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isDarkMode
                              ? LinearGradient(
                                  colors: [
                                    Colors.blueGrey.shade900,
                                    Colors.blueGrey.shade900,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF6B71FF),
                                    Color(0xFF57AEFE)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Supplierdropdown(
                                      label: 'Supplier Name',
                                      hintText: 'Select Supplier...',
                                      globalSupplierController:
                                          globalSupplierController,
                                      onSupplierSelected: (selectedSupplierId) {
                                        globalSupplierController
                                                .selectedSupplierId.value =
                                            selectedSupplierId?.toString() ??
                                                '';
                                        print('SupplierId:$selectedSupplierId');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildTextField1(
                                      label: 'Enter Part No',
                                      hintText: 'Enter Part No...',
                                      controller: partNumberController,
                                      onChanged: onPartNumberChanged,
                                      enabled: true,
                                      onFocusChange: (hasFocus) {
                                        if (hasFocus) {
                                          toggleFields('partNo');
                                          showPartNumberDropdown.value =
                                              false; // Keep dropdown open when focused
                                        } else {
                                          showPartNumberDropdown.value =
                                              true; // Hide dropdown when losing focus
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildTextField1(
                                      label: 'Enter Description',
                                      hintText: 'Enter Desc No...',
                                      controller: descriptionController,
                                      onChanged: onDescriptionChanged,
                                      enabled: true,
                                      onFocusChange: (hasFocus) {
                                        if (hasFocus) {
                                          toggleFields('desc');
                                        } else {
                                          showDescriptionDropdown.value =
                                              true; // Hide on losing focus
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton(
                                    // onPressed: () {
                                    //   String partNumber =
                                    //       selectedPartNumberId.value ??
                                    //           partNumberController.text.trim();
                                    //   print('Part Number: $partNumber');

                                    //   if (partNumber.isNotEmpty) {
                                    //     branchTransfersController
                                    //         .supplierDetails
                                    //         .clear();

                                    //     branchTransfersController
                                    //         .fetchBranchTransferDetails(
                                    //       partNumber,
                                    //       branchTransfersController
                                    //           .defaultBranchStocks,
                                    //     );

                                    //     setState(() {
                                    //       isSearchPerformed =
                                    //           true; // Flag to display selected date widget
                                    //     });

                                    //     branchTransfersController
                                    //         .defaultBranchStocks
                                    //         .listen((data) {
                                    //       searchedBranchTransfer.value =
                                    //           data; // Update the UI observable
                                    //     });
                                    //   } else {
                                    //     AppSnackBar.alert(
                                    //       message: "Please Select All fields.",
                                    //     );
                                    //   }
                                    // },

                               onPressed: () {
  final String partNumber = selectedPartNumberId.value?.trim().isNotEmpty == true
      ? selectedPartNumberId.value!.trim()
      : partNumberController.text.trim();

  final bool isPartNumberEmpty = partNumber.isEmpty;
  final bool isFromDateEmpty = fromDate.isEmpty || fromDate == 'Choose From Date';
  final bool isToDateEmpty = toDate.isEmpty || toDate == 'Choose To Date';

  if (!isPartNumberEmpty && !isFromDateEmpty && !isToDateEmpty) {
    // Clear previous results
    branchTransfersController.supplierDetails.clear();

    // Make API call
    branchTransfersController.fetchBranchTransferDetails(
      partNumber,
      branchTransfersController.defaultBranchStocks,
      fromDate: fromDate,
      toDate: toDate,
    );

    // Mark search performed
    setState(() {
      isSearchPerformed = true;
    });

    // Update UI with fetched data
    branchTransfersController.defaultBranchStocks.listen((data) {
      searchedBranchTransfer.value = data;
    });
  } else {
    // Build an error message showing exactly which field is missing
    String errorMessage = 'Please fill all the fields';
    

    AppSnackBar.alert(message: errorMessage.trim());
  }
},


                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 251, 134, 45),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(90),
                                      ),
                                      minimumSize: const Size(50, 45),
                                    ),
                                    child: Obx(() {
                                      return branchTransfersController
                                              .isLoading.value
                                          ? SizedBox(
                                              width: 24.0,
                                              height: 24.0,
                                              child:
                                                  const CircularProgressIndicator(
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
                                ],
                              ),
                              const SizedBox(height: 15),
                              Obx(() => showPartNumberDropdown.value
                                  ? _buildSuggestionsList()
                                  : const SizedBox.shrink()),
                              Obx(() => showDescriptionDropdown.value
                                  ? _buildDescriptionSuggestionsList()
                                  : const SizedBox.shrink()),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('From Date',
                                            style: theme.textTheme.bodySmall),
                                        const SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: _pickFromDate,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.blueGrey.shade900
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.calendar_today,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4.0),
                                                  Text(fromDate,
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('To Date',
                                            style: theme.textTheme.bodySmall),
                                        const SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: _pickToDate,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.blueGrey.shade900
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.calendar_today,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4.0),
                                                  Text(toDate,
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: _buildDynamicBranchTransferTable(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBranchTransferTable(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (branchTransfersController.isLoading.value) {
        return _buildShimmerTable(); // Show your shimmer effect
      }

      if (branchTransfersController
          .branchTransferErrorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Icon(
                  Icons.search_off,
                  size: 100,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Text(
                  'No results found for Past 4 Days.\nPlease refine your search criteria.',
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

      if (searchedBranchTransfer.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Icon(
                  Icons.search_off,
                  size: 120,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 20),
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

      return Column(
        children: [
          if (!isSearchPerformed) _buildDateRangeWidget(),
          Expanded(child: _buildBranchTransferTable(searchedBranchTransfer)),
        ],
      );
    });
  }

  Widget _buildBranchTransferTable(RxList<DefaulBranchstock> data) {
    List<DefaulBranchstock> filteredData = _filterData();
    final theme = Theme.of(context);
    final paginatedData = _getPaginatedData(filteredData);
    final totalPages = (filteredData.length / _itemsPerPage).ceil();

    // Check if there is no filtered data
    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 70),
            Shimmer.fromColors(
              baseColor: const Color.fromARGB(255, 53, 51, 51),
              highlightColor: Colors.white,
              child: Icon(
                Icons.search_off,
                size: 100,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            'Total: ${data.length} items',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: 1250,
                child: Table(
                  defaultColumnWidth: IntrinsicColumnWidth(),
                  children: [
                    _buildTableRow(
                      [
                        "S.NO",
                        "Transfer Order Number",
                        "Supplier Name",
                        "Item Name",
                        "Quantity",
                        "LR Date",
                        "Location"
                      ],
                      context,
                    ),
                    ...paginatedData.map((branchStock) {
                      return _buildTableRow1(
                        [
                          ((_currentPage - 1) * _itemsPerPage +
                                  paginatedData.indexOf(branchStock) +
                                  1)
                              .toString(),
                          branchStock.toNumber,
                          branchStock.supplierName,
                          branchStock.itemName,
                          branchStock.quantity.toString(),
                          branchStock.lRDate,
                          branchStock.location,
                        ],
                        isHeader: false,
                        context: context,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage = 1;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),

          // Page number input
          Container(
            width: 80,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: TextField(
              // controller: _pageController,
              controller: TextEditingController(text: _currentPage.toString()),
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
                final page = int.tryParse(value) ?? _currentPage;
                if (page >= 1 && page <= totalPages) {
                  setState(() {
                    _currentPage = page;
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
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
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage = totalPages;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),

          const SizedBox(width: 16),
          Text(
            'Total: $totalPages pages',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeWidget() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Branch Transfer From date: ${branchTransfersController.startDate.value} and To date: ${branchTransfersController.endDate.value}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: GlobalSearchField(
                hintText: 'Search Tranfser Order or Supplier Name...'.tr,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity, // Full width of the screen
      padding: const EdgeInsets.all(16.0), // Padding around the card
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[850]!
            : Colors.grey[300]!, // Background color for the card
        borderRadius: BorderRadius.circular(16), // Rounded corners for the card
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.black.withOpacity(0.1), // Light shadow
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(2, 2), // Shadow offset
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          7, // Adjust the number of rows based on your requirement
          (index) => Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4.0), // Padding between rows
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: 30, // Width for the "#" column
                    height: 20, // Adjust height as needed
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 16), // Spacing between columns
                  Container(
                    width: 60, // Width for the "Line" column
                    height: 20, // Adjust height as needed
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 60, // Width for the "Part No/Desc" column
                    height: 20, // Adjust height as needed
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (globalItemsController.globalItems.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: globalItemsController.globalItems.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade300,
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            final item = globalItemsController.globalItems[index];
            return GestureDetector(
              onTap: () => onSelectPartNumber(item),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Text(
                  item.itemName ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionSuggestionsList() {
    if (globalItemsController.globalItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: globalItemsController.globalItems.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade300,
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            GlobalitemDetail item = globalItemsController.globalItems[index];
            return InkWell(
              onTap: () => onSelectDescription(item),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  item.desc ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> headers, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return TableRow(
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
      children: headers
          .map(
            (header) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                header,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _buildTableRow1(List<String> data,
      {required bool isHeader, required BuildContext context}) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TableRow(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                colors: [
                  Colors.blueGrey,
                  Colors.grey[900]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFFEDFFFB), // Starting color (EDFFFB)
                  Color(0xFFFAF9FF), // Ending color (FAF9FF)
                  Color(0xFFEDFFFB), // Starting color (EDFFFB)
                  Color(0xFFFAF9FF), // Ending color (FAF9FF)
                ],
                begin: Alignment.topLeft, // Gradient starting point
                end: Alignment.bottomRight, // Gradient ending point
              ),
      ),
      children: data
          .map(
            (header) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                header,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTextField1({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    required void Function(String) onChanged,
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
              color: isDarkMode ? Colors.white : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: maxLines,
            controller: controller,
            onChanged: onChanged,
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
                  color: Colors.grey.shade100,
                  width: isDarkMode ? 0.8 : 0.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.white,
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
}
