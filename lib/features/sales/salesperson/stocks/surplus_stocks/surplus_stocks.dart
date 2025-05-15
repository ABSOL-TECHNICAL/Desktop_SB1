import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_textfield.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/global/theme/widgets/suppliersearchdrodown.dart';
import 'package:impal_desktop/features/sales/salesperson/stocks/surplus_stocks/controllers/surplus_stocks_controller.dart';

class SurplusStocks extends StatefulWidget {
  static const String routeName = '/SurplusStocks';

  const SurplusStocks({super.key});

  @override
  _SurplusStocksState createState() => _SurplusStocksState();
}

class _SurplusStocksState extends State<SurplusStocks> {
  bool isLoading = true;

  TextEditingController partNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Rx<String?> selectedPartNumberId = Rx<String?>(null);
  Rx<String?> selectedDescriptionId = Rx<String?>(null);

  RxBool showPartNumberDropdown = false.obs;
  RxBool showDescriptionDropdown = false.obs;

  RxBool isSearchInvalid = false.obs;

  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final SurplusStocksControllers surplusStocksController =
      Get.put(SurplusStocksControllers());
  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());

  @override
  void initState() {
    super.initState();
    globalSupplierController.fetchSupplier();
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
      globalItemsController.globalItems.clear();
      showPartNumberDropdown.value = false;
      descriptionController.clear();
      selectedDescriptionId.value = null;
      showDescriptionDropdown.value = false;
      surplusStocksController.supplierStocks.clear();
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
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showDescriptionDropdown.value = false;
      surplusStocksController.supplierStocks.clear();
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

    // Automatically close the description dropdown
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
    surplusStocksController.supplierStocks.clear();
  }

  void onSearch() {
    isSearchInvalid.value = false;
    surplusStocksController.supplierStocks.clear();

    final partNumber = partNumberController.text.trim();
    final description = descriptionController.text.trim();

    String itemId = '';

    if (selectedPartNumberId.value != null) {
      itemId = selectedPartNumberId.value!;
    } else {
      itemId = partNumber;
    }

    bool partNumberValid = selectedPartNumberId.value != null;
    bool descriptionValid = selectedDescriptionId.value != null;

    if (itemId.isNotEmpty && partNumberValid && descriptionValid) {
      surplusStocksController.isLoading.value = true;

      surplusStocksController
          .fetchSurplusStockDetails(itemId, description)
          .then((_) {
        if (surplusStocksController.supplierStocks.isEmpty) {
          isSearchInvalid.value = true;
          showPartNumberDropdown.value = true; // Allow re-selection if no data
        }
      }).catchError((error) {
        AppSnackBar.alert(message: "Error fetching data: $error");
        isSearchInvalid.value = true;
      }).whenComplete(() {
        surplusStocksController.isLoading.value = false;
      });
    } else {
      isSearchInvalid.value = true;
      AppSnackBar.alert(message: "Please Select all fields");
      showPartNumberDropdown.value =
          true; // Keep dropdown open for re-selection
    }
  }

  @override
  void dispose() {
    partNumberController.dispose();
    descriptionController.dispose();

    globalItemsController.globalItems.clear();

    if (Get.isRegistered<SurplusStocksControllers>()) {
      Get.delete<SurplusStocksControllers>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Surplus Stocks',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth,
              padding: const EdgeInsets.only(top: 10),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 370.0, left: 370.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isDarkMode
                            ? LinearGradient(colors: [
                                Colors.blueGrey.shade900,
                                Colors.blueGrey.shade900
                              ])
                            : const LinearGradient(
                                colors: [Color(0xFF6B71FF), Color(0xFF57AEFE)]),
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Enter Part No',
                                    hintText: 'Enter...',
                                    controller: partNumberController,
                                    onChanged: onPartNumberChanged,
                                    enabled: true,
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        toggleFields('partNo');
                                        showPartNumberDropdown.value = false;
                                      } else {
                                        showPartNumberDropdown.value = true;
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Enter Description',
                                    hintText: 'Enter...',
                                    controller: descriptionController,
                                    onChanged: onDescriptionChanged,
                                    enabled: true,
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        toggleFields('desc');
                                      } else {
                                        showDescriptionDropdown.value = true;
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  onPressed: onSearch,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 251, 134, 45),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(90),
                                    ),
                                    minimumSize: const Size(50, 45),
                                  ),
                                  child: Obx(() {
                                    return surplusStocksController
                                            .isLoading.value
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
                                ),
                              ],
                            ),
                            Obx(() => showPartNumberDropdown.value
                                ? _buildSuggestionsList()
                                : const SizedBox.shrink()),
                            Obx(() => showDescriptionDropdown.value
                                ? _buildDescriptionSuggestionsList()
                                : const SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      if (surplusStocksController.isLoading.value) {
                        return _buildShimmerTable();
                      } else if (isSearchInvalid.value ||
                          surplusStocksController.supplierStocks.isEmpty) {
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
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              padding: const EdgeInsets.all(3.0),
                              child: Table(
                                defaultColumnWidth:
                                    const IntrinsicColumnWidth(),
                                children: [
                                  _buildTableRow([
                                    "S.No",
                                    "Supplier Name",
                                    "Qty",
                                    "Value",
                                    "Aging"
                                  ], context),
                                  ...surplusStocksController.supplierStocks
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    var supplierDetail = entry.value;

                                    return TableRow(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child:
                                                Text((index + 1).toString())),
                                        Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child:
                                                Text(supplierDetail.supplier)),
                                        Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Text(supplierDetail.qty)),
                                        Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Text(
                                              double.tryParse(
                                                          supplierDetail.value)
                                                      ?.toStringAsFixed(2) ??
                                                  '0.00',
                                              style: const TextStyle(
                                                  fontSize: 14.0),
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Text(
                                              double.tryParse(
                                                          supplierDetail.aging)
                                                      ?.toStringAsFixed(2) ??
                                                  '0.00',
                                              style: const TextStyle(
                                                  fontSize: 14.0),
                                            )),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }),
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
                  style: const TextStyle(
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
                  style: const TextStyle(
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 14.0), // Increased horizontal padding
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
}
