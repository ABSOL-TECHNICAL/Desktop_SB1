import 'package:flutter/material.dart';
import 'package:impal_desktop/features/global/theme/widgets/suppliersearchdrodown.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/inward/controllers/material_inward_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/inward/model/material_inward_model.dart';

class MaterialInwardPage extends StatefulWidget {
  static const String routeName = '/MaterialInwardPage';

  const MaterialInwardPage({super.key});

  @override
  _MaterialInwardPageState createState() => _MaterialInwardPageState();
}

class _MaterialInwardPageState extends State<MaterialInwardPage> {
  String? selectedRecord;
  bool isLoading = true;
  String chooseDate = '';
  Rx<String?> selectedSupplier = Rx<String?>(null);
  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final MaterialInwardController materialInwardController =
      Get.put(MaterialInwardController());
  TextEditingController partNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController chooseDateController = TextEditingController();
   final ScrollController _scrollController = ScrollController();
  RxList<MaterialInwardDefault> searchedMaterialInward =
      <MaterialInwardDefault>[].obs;
  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());

  Rx<String?> selectedPartNumberId = Rx<String?>(null);
  Rx<String?> selectedDescriptionId = Rx<String?>(null);
  RxBool showPartNumberDropdown = false.obs;
  RxBool showDescriptionDropdown = false.obs;
  List<Map<String, dynamic>> fetchMaterialInwardDetails = [];
  List<MaterialEntry> materialInward = [];
  bool hasSearched = false;
    int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<String> get supplierName {
    return globalSupplierController.globalsupplierController
        .map((item) => item['Supplier'].toString())
        .toList();
  }
   String fromDate = 'Choose From Date';
  String toDate = 'Choose To Date';
  RxString fromdate = ''.obs;
  RxString todate = ''.obs;

  @override
  void initState() {
    super.initState();
    globalSupplierController.fetchSupplier();
    materialInwardController.fetchMaterialInwardDefault();
    materialInwardController.defaultMaterialInward.listen((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    Get.delete<MaterialInwardController>();
    final globalsupplierController = Get.find<GlobalsupplierController>();
    globalsupplierController.selectedSupplierId.value = '';

    super.dispose();
  }

  void _onChooseDatePicked(DateTime pickedDate) {
    setState(() {
      chooseDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      chooseDateController.text = chooseDate;
    });
    print('Choose Date: $chooseDate');
  }

  void fetchPartNumbersByDescription(String description) {
    if (description.isNotEmpty) {
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
        } else {
          showPartNumberDropdown.value = false;
          selectedPartNumberId.value = null;
          partNumberController.clear();
        }
      }).catchError((error) {
        print('Error fetching part numbers: $error');
        showPartNumberDropdown.value = false;
        selectedPartNumberId.value = null;
        partNumberController.clear();
      });
    } else {
      showPartNumberDropdown.value = false;
      selectedPartNumberId.value = null;
      partNumberController.clear();
    }
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
          fetchMaterialInwardDetails.clear();
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showPartNumberDropdown.value = false;
      descriptionController.clear();
      selectedDescriptionId.value = null;
      showDescriptionDropdown.value = false;
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
          fetchMaterialInwardDetails.clear();
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showDescriptionDropdown.value = false;
    }
  }

  void onSelectPartNumber(GlobalitemDetail item) {
    FocusScope.of(context).unfocus();
    partNumberController.text = item.itemName ?? '';
    selectedPartNumberId.value = item.itemId;

    descriptionController.text = item.vehicalApplication ?? '';
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear();
    showPartNumberDropdown.value = false;
    showDescriptionDropdown.value = true;
  }

  void onSelectDescription(GlobalitemDetail item) {
    FocusScope.of(context).unfocus();
    descriptionController.text = item.vehicalApplication ?? '';
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear();

    fetchPartNumbersByDescription(item.vehicalApplication!);

    showDescriptionDropdown.value = false;
  }
  List<MaterialInwardController> _getPaginatedData(List<MaterialInwardController> fullData) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return fullData.sublist(
      startIndex,
      endIndex > fullData.length ? fullData.length : endIndex,
    );
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

void  onSearchPressed() async {
    final selectedSupplierId = globalSupplierController.selectedSupplierId.value;
   
    
    if (selectedSupplierId == null || selectedSupplierId.isEmpty) {
      AppSnackBar.alert(message: "Please select a supplier first");
      return;
    }

   try {
      if (fromDate == 'Choose From Date' && toDate == 'Choose To Date') {
        // Search by supplier only
        await materialInwardController.fetchMaterialInwardDetails(
  selectedSupplierId,
  fromDate == 'Choose From Date' ? '' : fromDate,
  toDate == 'Choose To Date' ? '' : toDate,
  searchedMaterialInward,
);

      } else if (fromDate != 'Choose From Date' && toDate != 'Choose To Date') {
        // Search by supplier + date range
       await materialInwardController.fetchMaterialInwardDetails(
  selectedSupplierId,
  fromDate == 'Choose From Date' ? '' : fromDate,
  toDate == 'Choose To Date' ? '' : toDate,
  searchedMaterialInward,
);

      } else {
        AppSnackBar.alert(message: "Please select both From Date and To Date or none");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching GRN data: ${e.toString()}");
    }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Material Inward',
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
              padding: const EdgeInsets.only(top: 10),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 150.0, left: 150.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isDarkMode
                            ? LinearGradient(
                                colors: [
                                  Colors.blueGrey.shade900,
                                  Colors.blueGrey.shade900
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Color(0xFF6B71FF), Color(0xFF57AEFE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
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
                                          selectedSupplierId?.toString() ?? '';
                                      print('SupplierId:$selectedSupplierId');
                                    },
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                //  Expanded(
                                //   child: _buildTextField(
                                //       label: 'Enter Part No',
                                //       hintText: 'Enter Part No...',
                                //       controller: partNumberController,
                                //       // onChanged: onPartNumberChanged,
                                //       onChanged: (value) {
                                //         final globalsupplierController = Get
                                //             .find<GlobalsupplierController>();
                                //         final selectedSupplierId =
                                //             globalsupplierController
                                //                 .selectedSupplierId.value;

                                //         if (selectedSupplierId == null ||
                                //             selectedSupplierId.isEmpty) {
                                //           AppSnackBar.alert(
                                //               message:
                                //                   "Please select a supplier first.");
                                //           return;
                                //         }
                                //         onPartNumberChanged(value);
                                //       },
                                //       enabled: true,
                                //       onFocusChange: (hasFocus) {
                                //         final globalsupplierController = Get
                                //             .find<GlobalsupplierController>();
                                //         final selectedSupplierId =
                                //             globalsupplierController
                                //                 .selectedSupplierId.value;

                                //         if (hasFocus) {
                                //           toggleFields('desc');
                                //           showDescriptionDropdown.value = false;
                                //         } else {
                                //           if (selectedSupplierId != null &&
                                //               selectedSupplierId.isNotEmpty) {
                                //             showDescriptionDropdown.value =
                                //                 true;
                                //           }
                                //         }
                                //       }),
                                // ),
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
                                const SizedBox(width: 8),
                                // Expanded(
                                //   child: _buildTextField(
                                //     label: 'Enter Vehicle Application',
                                //     hintText: 'Enter Vehicle...',
                                //     controller: descriptionController,
                                //     // onChanged: onDescriptionChanged,
                                //     onChanged: (value) {
                                //       final globalsupplierController =
                                //           Get.find<GlobalsupplierController>();
                                //       final selectedSupplierId =
                                //           globalsupplierController
                                //               .selectedSupplierId.value;

                                //       if (selectedSupplierId == null ||
                                //           selectedSupplierId.isEmpty) {
                                //         AppSnackBar.alert(
                                //             message:
                                //                 "Please select a supplier first.");
                                //         return;
                                //       }
                                //       onDescriptionChanged(value);
                                //     },
                                //     enabled: true,
                                //     onFocusChange: (hasFocus) {
                                //       if (hasFocus) {
                                //         toggleFields('desc');
                                //       } else {
                                //         showDescriptionDropdown.value = true;
                                //       }
                                //     },
                                //   ),
                            
                                // Expanded(
                                //   child: _buildTextField(
                                //     label: 'Enter Part No',
                                //     hintText: 'Enter Part No...',
                                //     controller: partNumberController,
                                //     onChanged: onPartNumberChanged,
                                //     enabled: true,
                                //     onFocusChange: (hasFocus) {
                                //       if (hasFocus) {
                                //         toggleFields('partNo');
                                //         showPartNumberDropdown.value =
                                //             false; // Keep dropdown open when focused
                                //       } else {
                                //         showPartNumberDropdown.value =
                                //             true; // Hide dropdown when losing focus
                                //       }
                                //     },
                                //   ),
                                // ),
                                // const SizedBox(width: 8),
                                // Expanded(
                                //   child: _buildTextField(
                                //     label: 'Enter Description',
                                //     hintText: 'Enter Description...',
                                //     controller: descriptionController,
                                //     onChanged: onDescriptionChanged,
                                //     enabled: true,
                                //     onFocusChange: (hasFocus) {
                                //       if (hasFocus) {
                                //         toggleFields('desc');
                                //       } else {
                                //         showDescriptionDropdown.value = true;
                                //       }
                                //     },
                                //   ),
                                // ),
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
                                const SizedBox(width: 8),
                                // Expanded(
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         'Choose Date'.tr,
                                //         style: theme.textTheme.bodyMedium
                                //             ?.copyWith(
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.white,
                                //         ),
                                //       ),
                                //       const SizedBox(height: 6),
                                //       GestureDetector(
                                //         onTap: () async {
                                //           // Open the date picker and update the chosen date
                                //           DateTime? pickedDate =
                                //               await showDatePicker(
                                //             context: context,
                                //             initialDate: DateTime.now(),
                                //             firstDate: DateTime(2000),
                                //             lastDate: DateTime(2100),
                                //           );
                                //           if (pickedDate != null) {
                                //             _onChooseDatePicked(pickedDate);
                                //           }
                                //         },
                                //         child: Container(
                                //           decoration: BoxDecoration(
                                //             color: isDarkMode
                                //                 ? Colors.blueGrey.shade900
                                //                 : Colors.white,
                                //             borderRadius:
                                //                 BorderRadius.circular(10),
                                //             border: Border.all(
                                //                 color: Colors.grey.shade300),
                                //           ),
                                //           child: Padding(
                                //             padding: const EdgeInsets.symmetric(
                                //                 vertical: 7.0, horizontal: 8.0),
                                //             child: Row(
                                //               children: [
                                //                 const Icon(Icons.calendar_month,
                                //                     color: Color.fromARGB(
                                //                         255, 53, 51, 51)),
                                //                 const SizedBox(width: 4.0),
                                //                 Text(
                                //                   chooseDate.isNotEmpty
                                //                       ? chooseDate
                                //                       : 'Select Date',
                                //                   style: theme.textTheme.bodyLarge?.copyWith(
                                //                       color: chooseDate.isEmpty
                                //                           ? Colors.black
                                //                           : Colors.black),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80, // Fixed width for button
                                  child: ElevatedButton(
                                    onPressed: () {
                                      onSearchPressed();
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
                                      return materialInwardController
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
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Show Part Number Suggestions
                            Obx(() => showPartNumberDropdown.value
                                ? _buildSuggestionsList()
                                : const SizedBox.shrink()),
                            // Show Description Suggestions
                            Obx(() => showDescriptionDropdown.value
                                ? _buildDescriptionSuggestionsList()
                                : const SizedBox.shrink()),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: _buildDynamicTable(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTable(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (materialInwardController.isLoading.value) {
        return _buildShimmerTable();
      }

      if (materialInwardController.alertMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              materialInwardController.alertMessage.value,
              style: theme.textTheme.bodyLarge?.copyWith(
                 color: Colors.black, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      // Check for no data message
      if (materialInwardController.noDataMessage.isNotEmpty) {
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
                  'No results found for the last three days.\nPlease refine your search criteria.',
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

      if (searchedMaterialInward.isNotEmpty) {
        return Column(
          children: [
            _buildSelectedDateWidget(materialInwardController.toDate.value),
            _buildMaterialInwardTable(searchedMaterialInward),
          ],
        );
      } else if (materialInwardController.defaultMaterialInward.isNotEmpty) {
        return Column(
          children: [
            _buildDateRangeWidget(),
            _buildMaterialInwardTable(
                materialInwardController.defaultMaterialInward),
          ],
        );
      } else {
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
                  'Please provide both part number and Choose date',
                  style:theme.textTheme.bodyLarge?.copyWith(
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
    });
  }

  Widget _buildMaterialInwardTable(RxList<MaterialInwardDefault> data) {
   final totalItems = data.length;
  final totalPages = (totalItems / _itemsPerPage).ceil();
  final startIndex = (_currentPage - 1) * _itemsPerPage;
  final endIndex = startIndex + _itemsPerPage;
  final paginatedData = data.sublist(
    startIndex,
    endIndex > totalItems ? totalItems : endIndex,
  );
  return Expanded(
    child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: 1250,
                child: Table(
                  defaultColumnWidth: IntrinsicColumnWidth(),
                  children: [
                    _buildTableRow(
                      ["S.No", "Supplier Name", "Part No", "Desc", "Inward Qty"],
                      context,
                    ),
                    ...paginatedData.map((material) {
                      return _buildTableRow2([
                        (data.indexOf(material) + 1).toString(),
                          material.supplierName,
                  "${material.partNo} ",
                  material.desc.toString(),
                  material.inwardQty.toString(),
                ], context);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (totalPages > 1)
          _buildPaginationControls(totalItems,totalPages),
      ],
    ),
  );
}

 Widget _buildPaginationControls(int totalItems, int totalPages) {
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
  Widget _buildSelectedDateWidget(String selectedDate) {
    final toDate = materialInwardController.toDate.value;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Material Inward for selected date: $toDate',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDateRangeWidget() {
    final startDate = materialInwardController.startDate.value;
    final endDate = materialInwardController.endDate.value;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Material Inward From date: $startDate and To date: $endDate',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
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
                  item.vehicalApplication ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(       fontSize: 14,
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

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.black.withOpacity(0.1), // Light shadow
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 7.0), // Padding between rows
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
                  const SizedBox(width: 16),
                  Container(
                    width: 30, // Width for the "Part No/Desc" column
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

  TableRow _buildTableRow2(List<String> headers, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TableRow(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                colors: [
                  Colors.blueGrey.shade700,
                  Colors.grey,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Color(0xFFEAEFFF),
                  Color(0xFFFAF9FF),
                  Color(0xFFEAEFFF),
                  Color(0xFFFAF9FF),
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTextField({
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
