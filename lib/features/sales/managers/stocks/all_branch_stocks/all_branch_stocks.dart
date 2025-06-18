import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';

import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/global/theme/widgets/suppliersearchdrodown.dart';
import 'package:impal_desktop/features/sales/managers/stocks/all_branch_stocks/controllers/all_branch_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/all_branch_stocks/model/all_branch_model.dart';
import 'package:impal_desktop/features/sales/managers/stocks/own_branch_stocks/controllers/own_branch_controller.dart';

class AllBranchStocksPage extends StatefulWidget {
  static const String routeName = '/AllBranchStocksPage';

  const AllBranchStocksPage({super.key});

  @override
  _AllBranchStocksPageState createState() => _AllBranchStocksPageState();
}

class _AllBranchStocksPageState extends State<AllBranchStocksPage> {
  final AllBranchStocksController _controller =
      Get.put(AllBranchStocksController());
  final OwnBranchController ownBranchController =
      Get.put(OwnBranchController());

  String? selectedZone;
  String? selectedState;
  String? selectedStateId;
  final TextEditingController partNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int? selectedIndex;

  Rx<String?> selectedSupplier = Rx<String?>(null);
  Rx<String?> selectedPartNumberId = Rx<String?>(null);
  Rx<String?> selectedDescriptionId = Rx<String?>(null);

  RxBool showPartNumberDropdown = false.obs;
  RxBool showDescriptionDropdown = false.obs;




  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());

  RxBool isLoading = true.obs;
  RxBool isSearchInvalid = false.obs;
  List<Map<String, dynamic>> fetchedStockDetails = [];

  // Added this variable to track loading state for search button
  RxBool isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    ever<List<StateDetail>>(_controller.states, (states) {
      setState(() {});
    });
  }
void resetAllFields() {
  setState(() {
    selectedZone = null;
    selectedState = null;
    selectedStateId = null;
    partNumberController.clear();
    descriptionController.clear();
    selectedIndex = null;
    selectedSupplier.value = null;
    selectedPartNumberId.value = null;
    selectedDescriptionId.value = null;
    showPartNumberDropdown.value = false;
    showDescriptionDropdown.value = false;
    fetchedStockDetails.clear();
    isSearchInvalid.value = false;
  });

  // Properly reset supplier selection
  globalSupplierController.selectedSupplierName.value = '';
  globalSupplierController.selectedSupplierId.value = '';
  globalSupplierController.selectedSupplierId.value = '';
  
  // Clear items
  globalItemsController.globalItems.clear();

  // Reset "All States" checkbox
  _controller.selectAllStates.value = false;

  Get.forceAppUpdate();
}
  void onZoneChanged(String? newValue) async {
    if (newValue != selectedZone) {
      setState(() {
        selectedZone = newValue;
        selectedState = null;
      });

      await _controller.fetchStates(selectedZone!);
      var availableStates =
          _controller.states.map((state) => state.stateName).toSet().toList();

      if (selectedState != null && !availableStates.contains(selectedState)) {
        selectedState = null;
      }
      setState(() {});
    }
  }

  void onStateChanged(String? newValue) {
  StateDetail? selectedStateDetail = _controller.states.firstWhere(
    (state) => state.stateName == newValue,
    orElse: () => StateDetail(stateId: '', stateName: ''),
  );

  setState(() {
    selectedState = newValue;
    selectedStateId = selectedStateDetail.stateId;
    fetchedStockDetails.clear();
    
    // Uncheck "All States" when a specific state is selected
    if (newValue != null) {
      _controller.selectAllStates.value = false;
    }
  });

  if (selectedState != null) {
    print('Selected State: $selectedState, ID: $selectedStateId');
  } else {
    print('Selected state is null; ensure state is in the list.');
  }
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
          fetchedStockDetails.clear();
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
          fetchedStockDetails.clear();
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

 void _fetchStockDetails() {
  String partNo = selectedPartNumberId.value ?? '';
  
  // Pass null as stateId when "All States" is selected
  String? stateIdToSend = _controller.selectAllStates.value ? null : selectedStateId;
  
  _controller.fetchStockDetails(partNo, stateIdToSend)
      .then((List<StockDetail> fetchedItems) {
      setState(() {
        isSearching.value = false; // Stop loading
        if (fetchedItems.isNotEmpty) {
          var item = fetchedItems.first;
          fetchedStockDetails.add({
            'Location': item.location ?? 'N/A',
            'Available Stock': item.availableStock ?? '0.0',
            'Cost Price': item.unitPrice ?? '0.0',
            'MRP': item.list ?? '0.0',
            'Vehicle Application': item.vehicleApplication,
            'Short Description': item.shortDescription,
            'Product Description': item.productDescription,
            'Balance Quantity': (item.balanceQuantity ?? '0.0').toString(),
          });
        } else {
          fetchedStockDetails.clear();
          isSearchInvalid.value = true;
        }
      });
    }).catchError((error) {
      print("Error fetching stock details: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching stock details: $error')),
        );
      }
      isSearching.value = false; // Stop loading in case of error
    });
  }

void onSearchPressed() {
  // Check if neither a state nor "All States" is selected
  if (selectedZone != null && selectedState == null && !_controller.selectAllStates.value) {
    AppSnackBar.alert(message: "Please choose a state or select 'All States'.");
    return;
  }

  // Proceed with the search
  _fetchStockDetails();
}
  void onItemSelected(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = null;
      } else {
        selectedIndex = index;
      }
    });
  }

  @override
  void dispose() {
    partNumberController.dispose();
    descriptionController.dispose();
    if (Get.isRegistered<AllBranchStocksController>()) {
      print("Disposing All Branch Stocks...");
      Get.delete<AllBranchStocksController>();
    }
    super.dispose();
    print("All Branch Stocks disposed.");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Branch Stocks ',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset all fields',
            onPressed: resetAllFields,
          ),
        ],
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
                    const SizedBox(height: 5),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Supplierdropdown(
                                              label: 'Supplier Name',
                                              hintText: 'Select Supplier...',
                                              globalSupplierController:
                                                  globalSupplierController,
                                              onSupplierSelected:
                                                  (selectedSupplierId) {
                                                globalSupplierController
                                                    .selectedSupplierId
                                                    .value = selectedSupplierId
                                                        ?.toString() ??
                                                    '';
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildTextField(
                                              label: 'Enter Part Number',
                                              hintText: 'Enter Part No...',
                                              controller: partNumberController,
                                              onChanged: onPartNumberChanged,
                                              enabled: true,
                                              onFocusChange: (hasFocus) {
                                                if (hasFocus) {
                                                  toggleFields('partNo');
                                                  showPartNumberDropdown.value =
                                                      false;
                                                } else {
                                                  showPartNumberDropdown.value =
                                                      true;
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildTextField(
                                              label: 'Enter Vehicle Application',
                                              hintText: 'Enter  Vehicle Application...',
                                              controller: descriptionController,
                                              onChanged: onDescriptionChanged,
                                              enabled: true,
                                              onFocusChange: (hasFocus) {
                                                if (hasFocus) {
                                                  toggleFields('desc');
                                                } else {
                                                  showDescriptionDropdown
                                                      .value = true;
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Obx(() => showPartNumberDropdown.value
                                ? _buildSuggestionsList()
                                : const SizedBox.shrink()),
                            Obx(() => showDescriptionDropdown.value
                                ? _buildDescriptionSuggestionsList()
                                : const SizedBox.shrink()),
                            const SizedBox(height: 12),
                            Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Expanded(
      child: _buildDropdownField(
        label: 'Choose Zone'.tr,
        hintText: 'Choose Zone'.tr,
        context: context,
        value: selectedZone,
        items: [
          'South Zone',
          'North Zone',
          'East Zone',
          'West Zone'
        ],
        onChanged: onZoneChanged,
      ),
    ),
    const SizedBox(width: 6),
    Expanded(
      child: _buildDropdownField(
        label: 'Choose State'.tr,
        hintText: 'Choose State'.tr,
        context: context,
        value: selectedState,
        items: _controller.states
            .map((state) => state.stateName)
            .toList(),
        onChanged: onStateChanged,
      ),
    ),
    const SizedBox(width: 6),
   Row(
  children: [
    Obx(() => Checkbox(
      value: _controller.selectAllStates.value,
      onChanged: selectedZone != null
          ? (value) {
              _controller.selectAllStates.value = value!;
              if (value) {
                // When "All States" is checked, clear the selected state
                setState(() {
                  selectedState = null;
                  selectedStateId = null;
                });
              }
            }
          : null, // Disable if no zone is selected
    )),
    Tooltip(
      message: selectedZone == null 
          ? "Please select a zone first" 
          : "Check to include all states",
      child: Text(
        'All States',
        style: TextStyle(
          color: selectedZone == null ? Colors.grey : null,
        ),
      ),
    ),
  ],
),
    const SizedBox(width: 6),
    Obx(() => ElevatedButton(
      onPressed: isSearching.value ? null : onSearchPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 251, 134, 45),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90),
        ),
        minimumSize: const Size(50, 45),
      ),
      child: isSearching.value
          ? const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            )
          : const Icon(Icons.search, color: Colors.white),
    )),
  ],
),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      child: Obx(() {
                        if (_controller.isLoading.value) {
                          return _buildShimmerTable();
                        } else if (isSearchInvalid.value ||
                            fetchedStockDetails.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 70),
                                Shimmer.fromColors(
                                  baseColor:
                                      const Color.fromARGB(255, 53, 51, 51),
                                  highlightColor: Colors.white,
                                  child: Icon(
                                    Icons.search_off,
                                    size: 100,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Shimmer.fromColors(
                                  baseColor:
                                      const Color.fromARGB(255, 53, 51, 51),
                                  highlightColor: Colors.white,
                                  child: Text(
                                    'No results found.\nPlease refine your search criteria.',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          const Color.fromARGB(255, 10, 10, 10),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return DisplayedItemsCard(
                            displayedItems: fetchedStockDetails.isNotEmpty
                                ? [fetchedStockDetails.first]
                                : [],
                            selectedIndex: selectedIndex,
                            onItemSelected: onItemSelected,
                          );
                        }
                      }),
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

  Widget _buildSuggestionsList() {
    if (globalItemsController.globalItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: globalItemsController.globalItems.length,
          itemBuilder: (context, index) {
            GlobalitemDetail item = globalItemsController.globalItems[index];
            return GestureDetector(
              onTap: () {
                onSelectPartNumber(item);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 9.0, horizontal: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.itemName ?? '',
                    style: const TextStyle(fontSize: 14.0),
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: globalItemsController.globalItems.length,
          itemBuilder: (context, index) {
            GlobalitemDetail item = globalItemsController.globalItems[index];
            return SizedBox(
              height: 40,
              child: ListTile(
                title: Text(item.vehicalApplication ?? '',
                    style: const TextStyle(fontSize: 14.0)),
                onTap: () {
                  onSelectDescription(item);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String hintText,
    required String? value,
    required String? label,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Log the items and selected value
    print('Dropdown Items: $items');
    print('Dropdown Selected Value: $value');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label.isNotEmpty) ...[
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 1),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade300,
              width: isDarkMode ? 0.8 : 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.contains(value) ? value : null,
              hint: Text(
                hintText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onChanged: onChanged,
              items: items.toSet().map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.blueGrey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              itemHeight: 48.0,
            ),
          ),
        ),
      ],
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
                : Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          12,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
              child: Row(
                children: [
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 20),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 20),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DisplayedItemsCard extends StatelessWidget {
  final List<Map<String, dynamic>> displayedItems;
  final int? selectedIndex;
  final Function(int index) onItemSelected;

  const DisplayedItemsCard({
    super.key,
    required this.displayedItems,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final AllBranchStocksController controller =
        Get.put(AllBranchStocksController());
    final stocks = controller.stocks;

    int totalAvailableStock = 0;
    for (var stock in stocks) {
      totalAvailableStock +=
          (double.tryParse(stock.availableStock ?? '0') ?? 0).toInt();
    }
     

    final stockTableRows = [
      _buildTableHeaderRow(context),
      ...stocks.asMap().entries.map((entry) {
        final index = entry.key;
        final stock = entry.value;
        final isEven = index % 2 == 0;

        return _buildTableDataRow(
          context: context,
          isEven: isEven,
          data: [
            (index + 1).toString(),
            stock.location ?? 'N/A',
            stock.availableStock ?? '0',
            stock.list != null
                ? double.tryParse(stock.list.toString())?.toStringAsFixed(2) ?? '0.0'
                : '0.0',
          ],
        );
      }).toList(),
    ];

    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: displayedItems.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            // resizeToAvoidBottomInset: false,
          children: [
            SizedBox(height: 1,),
            _buildItemDetailsHeader(entry, totalAvailableStock, context),
            // const SizedBox(height: 12),
          SizedBox(
  height: 250, // 👈 Set this to a scrollable height
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          border: TableBorder.all(color: Colors.transparent),
          children: stockTableRows,
        ),
      ),
    ),
  ),
),

            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }
TableRow _buildTableDataRow({
  required BuildContext context,
  required bool isEven,
  required List<String> data,
}) {
  final bgColor = isEven ? Colors.white : Colors.blue.shade50;
  return TableRow(
    decoration: BoxDecoration(color: bgColor),
    children: data
        .map((text) => _buildTableCell(text, isHeader: false, context: context))
        .toList(),
  );
}

  TableRow _buildTableHeaderRow(BuildContext context) {
  return TableRow(
    decoration: BoxDecoration(color: Colors.blue.shade700),
    children: [
      _buildTableCell("S.No.", isHeader: true, context: context),
      _buildTableCell("Location", isHeader: true, context: context),
      _buildTableCell("Available Stock", isHeader: true, context: context),
      _buildTableCell("List Price", isHeader: true, context: context),
    ],
  );
}

 Widget _buildTableCell(
  String text, {
  required bool isHeader,
  required BuildContext context,
}) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
    child: Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: isHeader ? 15 : 14,
        color: isHeader ? Colors.white : Colors.black,
      ),
    ),
  );
}

  TableRow _buildTableRow1(List<String> data, BuildContext context) {
    final theme = Theme.of(context);
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
      ),
      children: data
          .map(
            (value) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
            ),
          )
          .toList(),
    );
  }
}

  Widget _buildItemDetailsHeader(Map<String, dynamic> entry, int totalAvailableStock, BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FA), // Light header background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderColumn("VEHICLE APPLICATION", entry['Vehicle Application']),
          _buildHeaderColumn("SHORT DESCRIPTION", entry['Short Description']),
          _buildHeaderColumn("PRODUCT DESCRIPTION", entry['Product Description']),
          _buildHeaderColumn("BALANCE QUANTITY", totalAvailableStock.toString()),
          _buildHeaderColumn("APPLICATION SENT", entry['Application Segment']),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(String title, dynamic value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }