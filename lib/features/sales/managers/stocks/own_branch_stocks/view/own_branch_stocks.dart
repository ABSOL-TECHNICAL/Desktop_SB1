import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/global/theme/widgets/suppliersearchdrodown.dart';
import 'package:impal_desktop/features/sales/managers/stocks/own_branch_stocks/model/own_branch_model.dart';

import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/own_branch_stocks/controllers/own_branch_controller.dart';

class BranchStocksPage extends StatefulWidget {
  static const String routeName = '/BranchStocksPage';

  const BranchStocksPage({super.key});

  @override
  _BranchStockPageState createState() => _BranchStockPageState();
}

class _BranchStockPageState extends State<BranchStocksPage> {
  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final OwnBranchController ownBranchController =
      Get.put(OwnBranchController());
  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());
  final LoginController loginController = Get.find<LoginController>();

  final TextEditingController partNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

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
final int itemsPerPage = 10;
final ScrollController scrollController = ScrollController();

  List<Ownbranch> get filteredData {
  if (searchQuery.isEmpty) {
    return ownBranchController.ownDetails;
  }
  return ownBranchController.ownDetails.where((item) {
    return (item.partno?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
           (item.desc?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
  }).toList();
}

// Update your getPaginatedData method to use filteredData
List<Ownbranch> getPaginatedData() {
  final startIndex = (currentPage.value - 1) * itemsPerPage;
  final endIndex = startIndex + itemsPerPage;
  return filteredData.sublist(
    startIndex,
    endIndex > filteredData.length ? filteredData.length : endIndex,
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
      final totalPages = (filteredData.length / itemsPerPage).ceil();

    return Scaffold(
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Enter Part No',
                                    hintText: 'Enter Part No...',
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
                                  child: _buildTextField(
                                    label: 'Enter Description',
                                    hintText: 'Enter Description',
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
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: () {
                                    String partNumber =
                                        selectedPartNumberId.value ??
                                            partNumberController.text.trim();
                                    String supplierId =
                                        selectedSupplier.value ?? "";

                                    _onSearchPressed(partNumber, supplierId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 251, 134, 45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(90),
                                    ),
                                    minimumSize: const Size(50, 45),
                                  ),
                                  child: Obx(() {
                                    return ownBranchController.isLoading.value
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
                            const SizedBox(height: 8),
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
                    const SizedBox(height: 12),
                    GlobalSearchField(
                      hintText: 'Search Supplier...'.tr,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 15),
                    Obx(() {
                      return ownBranchController.isLoading.value
                          ? _buildShimmerTable()
                          : _buildDataTable();
                    }),
                     Obx(() {
                      if (ownBranchController.ownDetails.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildPaginationControls();
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
            controller: TextEditingController(text: currentPage.value.toString()),
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
    if (ownBranchController.isLoading.value) {
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
    } else {
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
            DataCell(Text(detail.partno?.toString() ?? '0')),
            DataCell(Text(detail.desc?.toString() ?? '0')),
            DataCell(Text(detail.availableStock?.toString() ?? '0')),
            DataCell(Text(detail.unitPrice?.toStringAsFixed(2) ?? '0.00')),
            DataCell(Text(detail.mRP?.toStringAsFixed(2) ?? '0.00')),
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
                          child: Text(
                            'S.No',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Part No',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Desc',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Available Stock',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Unit Price',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'MRP',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    }
  });
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
}
