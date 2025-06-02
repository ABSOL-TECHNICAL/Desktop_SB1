import 'package:flutter/material.dart';
import 'package:impal_desktop/features/global/theme/widgets/suppliersearchdrodown.dart';

import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';

import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/grn1/controller/grn_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/grn1/model/grn_model.dart';

class Grn1Page extends StatefulWidget {
  static const String routeName = '/Grn1Page';

  const Grn1Page({super.key});

  @override
  _Grn1PageState createState() => _Grn1PageState();
}

class _Grn1PageState extends State<Grn1Page> {
  bool isLoading = true;
  TextEditingController partNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Rx<String?> selectedSupplier = Rx<String?>(null);

  // partno and desc
  Rx<String?> selectedPartNumberId = Rx<String?>(null);
  Rx<String?> selectedDescriptionId = Rx<String?>(null);
  RxBool showPartNumberDropdown = false.obs;
  RxBool showDescriptionDropdown = false.obs;
  List<Map<String, dynamic>> fetchGrn1 = [];

  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());

  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final Grn1Controller grn1controller = Get.put(Grn1Controller());
  RxList<Grn1Model> searchedGrn = <Grn1Model>[].obs;
  void fetchPartNumbersByDescription(String description) {
    final globalsupplierController = Get.find<GlobalsupplierController>();
    final selectedSupplierId =
        globalsupplierController.selectedSupplierId.value;

    globalItemsController
        .fetchGlobalItems("", description, selectedSupplierId)
        .then((_) {
      if (globalItemsController.globalItems.isNotEmpty) {
        selectedPartNumberId.value = globalItemsController
            .globalItems.first.itemId; // Auto-select first part number
        partNumberController.text =
            globalItemsController.globalItems.first.itemName ??
                ''; // Auto-fill part number
        showPartNumberDropdown.value = true; // Show dropdown for part numbers
      }
    });
  }

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

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
          fetchGrn1.clear(); // Clear displayed items data
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showPartNumberDropdown.value = false;
      descriptionController
          .clear(); // Clear the description when part number is empty
      selectedDescriptionId.value = null; // Reset the selected description ID
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
          fetchGrn1.clear(); // Clear displayed items data
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
    descriptionController.text = item.vehicalApplication ?? '';
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
    fetchPartNumbersByDescription(item.vehicalApplication!);

    // Automatically close the description dropdown
    showDescriptionDropdown.value = false;
  }

  List<String> get supplierName {
    return globalSupplierController.globalsupplierController
        .map((item) => item['Supplier'].toString())
        .toList();
  }

  @override
  void initState() {
    super.initState();
    globalSupplierController.fetchSupplier();
    grn1controller.fetchGrnDefault();
    grn1controller.isLoading.listen((loading) {
      setState(() {
        isLoading = loading;
      });
    });
  }

  Future<String?> getSupplierId(String supplierName) async {
    final selectedSupplierDetails = globalSupplierController
        .globalsupplierController
        .firstWhere((item) => item['Supplier'] == supplierName,
            orElse: () => null);

    return selectedSupplierDetails?['SupplierId'];
  }

  @override
  void dispose() {
    if (Get.isRegistered<Grn1Controller>()) {
      print("Disposing GRN1...");
      Get.delete<Grn1Controller>();
    } else {
      print("GRN1 is not registered, no need to dispose.");
    }
    super.dispose();
    print("GRN1 disposed.");
  }

  List<Grn1Model> _getPaginatedData(List<Grn1Model> fullData) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return fullData.sublist(
      startIndex,
      endIndex > fullData.length ? fullData.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GRN1',
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
                                      // onChanged: onPartNumberChanged,
                                      onChanged: (value) {
                                        final globalsupplierController = Get
                                            .find<GlobalsupplierController>();
                                        final selectedSupplierId =
                                            globalsupplierController
                                                .selectedSupplierId.value;

                                        if (selectedSupplierId == null ||
                                            selectedSupplierId.isEmpty) {
                                          AppSnackBar.alert(
                                              message:
                                                  "Please select a supplier first.");
                                          return;
                                        }
                                        onPartNumberChanged(value);
                                      },
                                      enabled: true,
                                      onFocusChange: (hasFocus) {
                                        final globalsupplierController = Get
                                            .find<GlobalsupplierController>();
                                        final selectedSupplierId =
                                            globalsupplierController
                                                .selectedSupplierId.value;

                                        if (hasFocus) {
                                          toggleFields('desc');
                                          showDescriptionDropdown.value = false;
                                        } else {
                                          if (selectedSupplierId != null &&
                                              selectedSupplierId.isNotEmpty) {
                                            showDescriptionDropdown.value =
                                                true;
                                          }
                                        }
                                      }),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Enter Vehicle Application No',
                                    hintText: 'Enter Vehicle...',
                                    controller: descriptionController,
                                    // onChanged: onDescriptionChanged,
                                    onChanged: (value) {
                                      final globalsupplierController =
                                          Get.find<GlobalsupplierController>();
                                      final selectedSupplierId =
                                          globalsupplierController
                                              .selectedSupplierId.value;

                                      if (selectedSupplierId == null ||
                                          selectedSupplierId.isEmpty) {
                                        AppSnackBar.alert(
                                            message:
                                                "Please select a supplier first.");
                                        return;
                                      }
                                      onDescriptionChanged(value);
                                    },
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
                                  onPressed: () async {
                                    String partNumber =
                                        selectedPartNumberId.value ??
                                            partNumberController.text.trim();

                                    print('Part Number: $partNumber');

                                    if (partNumber.isNotEmpty) {
                                      grn1controller.grnDetails.clear();
                                      await grn1controller
                                          .fetchGrn1(partNumber);
                                    } else {
                                      AppSnackBar.alert(
                                          message:
                                              "Please enter a Part Number");
                                    }
                                  },
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
                                    return grn1controller.isLoading.value
                                        ? SizedBox(
                                            width: 24.0,
                                            height: 24.0,
                                            child:
                                                const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.0),
                                          )
                                        : const Icon(Icons.search,
                                            color: Colors.white);
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
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
                    SizedBox(height: 20),
                    Expanded(
                        child: isLoading
                            ? _buildShimmerTable()
                            : _buildGrnTable(
                                context, grn1controller.grnDetails))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrnTable(BuildContext context, RxList<Grn1Model> data) {
    return Obx(() {
      if (grn1controller.isLoading.value) {
        return _buildShimmerTable();
      }

      final int startIndex = (_currentPage - 1) * _itemsPerPage;
      final paginatedData = _getPaginatedData(data);
      final totalPages = (data.length / _itemsPerPage).ceil();
      final theme = Theme.of(context);

      if (paginatedData.isNotEmpty) {
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
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1250,
                    child: Table(
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        _buildTableRow(
                          [
                            "S.No",
                            "GRN Number",
                            "Supplier Name",
                            "Item Name",
                            "Quantity",
                            "LR Date",
                            "LR Number"
                          ],
                          context,
                        ),
                        ...paginatedData.asMap().entries.map((entry) {
                          int index = entry.key;
                          Grn1Model grn = entry.value;
                          return _buildTableRow1(
                            [
                              (startIndex + index + 1).toString(),
                              grn.grnNumber ?? "N/A",
                              grn.supplierName ?? "N/A",
                              grn.itemName ?? "N/A",
                              grn.quantity ?? "N/A",
                              grn.lrdate ?? "N/A",
                              grn.lrnumber ?? "N/A",
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
      } else {
        return Center(
          child: Text(
            'No results found.',
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        );
      }
    });
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
                  Color(0xFFEDFFFB),
                  Color(0xFFFAF9FF),
                  Color(0xFFEDFFFB),
                  Color(0xFFFAF9FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
          10,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: 600,
                    height: 20,
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 300,
                    height: 20,
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 16),
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
