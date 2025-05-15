import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/controllers/planning_indent_controller.dart';
import 'package:impal_desktop/features/cyberwarehosue/controllers/stocks_location_controller.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/planningindent_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/send_planning_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/widget/dropdown_widget.dart';
import 'package:impal_desktop/features/cyberwarehosue/widget/textfield_widget.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:shimmer/shimmer.dart';

class PlanningIndent extends StatefulWidget {
  const PlanningIndent({super.key});

  @override
  _PlanningIndentState createState() => _PlanningIndentState();
}

class _PlanningIndentState extends State<PlanningIndent> {
  int _rowsPerPage = 10;
  int _currentPage = 0;
  final LoginController login = Get.put(LoginController());
  final StocksLocationController stocksLocationController =
      Get.put(StocksLocationController());
  final PlanningIndentController planningIndentController =
      Get.put(PlanningIndentController());

  final RxBool isLoading = false.obs;

  late TextEditingController branchidController;
  late TextEditingController branchnameController;
  final RxString selectedProductGroup = ''.obs;
  final RxString selectedDivision = ''.obs;
  final RxString selectedPurpose = ''.obs;
  int _currentSortColumnIndex = -1;
  bool _isAscending = true;

  void _sort<T>(
    Comparable<T> Function(PlanningindentModel indent) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      planningIndentController.indents.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);

        if (columnIndex == 9) {
          return ascending
              ? Comparable.compare(bValue, aValue)
              : Comparable.compare(aValue, bValue);
        }

        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    branchidController = TextEditingController();
    branchnameController = TextEditingController(
      text: login.employeeModel.locationName ?? 'N/A',
    );
    planningIndentController.indents.clear();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        stocksLocationController.fetchLocations(),
        stocksLocationController.fetchSupplier(),
      ]);
    } catch (e) {
      AppSnackBar.alert(message: "Failed to fetch data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _fetchDataOnSelection() async {
    selectedProductGroup.value = '';
    selectedDivision.value = '';

    final supplierId = planningIndentController.selectedSupplierId.value;
    if (supplierId.isNotEmpty) {
      await planningIndentController.fetchProductgroup(supplierId);
      await planningIndentController.fetchDivision(supplierId);
    }
  }

  @override
  void dispose() {
    branchidController.dispose();
    branchnameController.dispose();
    selectedProductGroup.value = '';
    selectedDivision.value = '';
    planningIndentController.selectedSupplierId.value = '';
    planningIndentController.productGroups.clear();
    planningIndentController.divisions.clear();
    super.dispose();
  }

  final Map<String, int> fms = {
    'F': 1,
    'M': 2,
  };

  Future<bool> _onWillPop(BuildContext context) async {
    selectedProductGroup.value = '';
    selectedDivision.value = '';
    planningIndentController.selectedSupplierId.value = '';
    planningIndentController.productGroups.clear();
    planningIndentController.divisions.clear();

    return await showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Are you sure?',
            message: 'Do you want to leave this page?',
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Planning Indent',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
          // style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF161717),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 242, 246, 248),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                controller: branchnameController,
                                label: 'Branch'.tr,
                                hintText: "Enter Employee Id",
                                readOnly: true,
                              ),
                            ),
                            Expanded(
                              child: Obx(() {
                                if (stocksLocationController.supplier.isEmpty) {
                                  return DropdownWidget(
                                    label: 'Supplier Name',
                                    value: null,
                                    items: const [],
                                    onChanged: (newValue) {},
                                    isRequired:
                                        true, // Now the asterisk will show
                                  );
                                }

                                final supplierItems = stocksLocationController
                                    .supplier
                                    .map((supplier) => supplier.supplier ?? '')
                                    .toList();

                                return DropdownWidget(
                                  label: 'Supplier Name',
                                  value: stocksLocationController
                                      .selectedSupplierId.value,
                                  items: supplierItems,
                                  isRequired: true, // Ensuring required field
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      final selectedSupplierData =
                                          stocksLocationController.supplier
                                              .firstWhere((supplier) =>
                                                  supplier.supplier ==
                                                  newValue);

                                      planningIndentController
                                          .setSelectedSupplierId(
                                        selectedSupplierData.supplierId ?? '',
                                      );
                                      _fetchDataOnSelection();
                                    }
                                  },
                                );
                              }),
                            ),
                            Expanded(
                              child: Obx(() {
                                if (planningIndentController
                                    .divisions.isEmpty) {
                                  return DropdownWidget(
                                    label: 'Division',
                                    value: "Please Select Division",
                                    items: ["Please Select Division"],
                                    onChanged: (newValue) {},
                                  );
                                }

                                final divisionNames = [
                                      'Please Select Division'
                                    ] +
                                    planningIndentController.divisions
                                        .map((e) => e.split('-').first.trim())
                                        .toList();

                                return DropdownWidget(
                                  label: 'Division',
                                  value: selectedDivision.value.isEmpty
                                      ? "Please Select Division"
                                      : selectedDivision.value
                                          .split('-')
                                          .first
                                          .trim(),
                                  items: divisionNames,
                                  onChanged: (newValue) {
                                    if (newValue == null ||
                                        newValue == "Please Select Division") {
                                      selectedDivision.value = "";
                                    } else {
                                      final fullDivision =
                                          planningIndentController.divisions
                                              .firstWhere(
                                        (element) =>
                                            element.startsWith(newValue),
                                        orElse: () => '',
                                      );

                                      selectedDivision.value =
                                          fullDivision.isEmpty
                                              ? ""
                                              : fullDivision;
                                    }
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                if (planningIndentController
                                    .productGroups.isEmpty) {
                                  return DropdownWidget(
                                    label: 'Supplier Product Group',
                                    value: "Please Select Product Group",
                                    items: ["Please Select Product Group"],
                                    onChanged: (newValue) {},
                                  );
                                }

                                final productGroupNames = [
                                      "Please Select Product Group"
                                    ] +
                                    planningIndentController.productGroups
                                        .map((e) => e
                                            .split('-')
                                            .sublist(1)
                                            .join('-')
                                            .trim())
                                        .toList();

                                return DropdownWidget(
                                  label: 'Supplier Product Group',
                                  value: selectedProductGroup.value.isEmpty
                                      ? "Please Select Product Group"
                                      : selectedProductGroup.value
                                          .split('-')
                                          .sublist(1)
                                          .join('-')
                                          .trim(),
                                  items: productGroupNames,
                                  onChanged: (newValue) {
                                    if (newValue == null ||
                                        newValue ==
                                            "Please Select Product Group") {
                                      selectedProductGroup.value = "";
                                    } else {
                                      final productGroup =
                                          planningIndentController.productGroups
                                              .firstWhere(
                                        (element) => element.contains(newValue),
                                        orElse: () => '',
                                      );

                                      if (productGroup.isNotEmpty) {
                                        selectedProductGroup.value =
                                            productGroup;
                                        String productGroupId = productGroup
                                            .split('-')
                                            .first
                                            .trim();
                                        print(
                                            "Selected Product Group ID: $productGroupId");
                                      }
                                    }
                                  },
                                );
                              }),
                            ),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Projection Duration In Months'.tr,
                                hintText: "1",
                                readOnly: true,
                              ),
                            ),
                            Expanded(
                              child: Obx(() {
                                return DropdownWidget(
                                  label: 'F/M',
                                  value: selectedPurpose.value.isEmpty
                                      ? null
                                      : selectedPurpose.value,
                                  items: fms.keys.toList(),
                                  isRequired: true,
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      selectedPurpose.value = newValue;
                                    }
                                  },
                                );
                              }),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (planningIndentController
                                    .selectedSupplierId.value.isEmpty) {
                                  AppSnackBar.alert(
                                      message:
                                          "Please select the supplier name");
                                  return;
                                }

                                if (selectedPurpose.value.isEmpty ||
                                    !fms.containsKey(selectedPurpose.value)) {
                                  AppSnackBar.alert(
                                      message:
                                          "Please select the FM to search the criteria");
                                  return;
                                }

                                final selectedDivisionId = selectedDivision
                                    .value
                                    .split('-')
                                    .last
                                    .trim();
                                final productGroupId = selectedProductGroup
                                    .value
                                    .split('-')
                                    .first
                                    .trim();
                                final supplierId = planningIndentController
                                    .selectedSupplierId.value;
                                final fmsId = fms[selectedPurpose.value] ?? 0;

                                isLoading.value = true;

                                await planningIndentController.submitIndent(
                                  supplierId: supplierId,
                                  fmsId: fmsId,
                                  productGroupId: productGroupId,
                                  divisionId: selectedDivisionId,
                                );

                                isLoading.value = false;
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
                              child: Obx(() => isLoading.value
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
                                    )),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Obx(() {
                            if (planningIndentController.indents.isEmpty) {
                              return Shimmer.fromColors(
                                baseColor: Colors.black,
                                highlightColor: Colors.grey.shade100,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 30),
                                      Shimmer.fromColors(
                                        baseColor: const Color.fromARGB(
                                            255, 53, 51, 51),
                                        highlightColor: Colors.white,
                                        child: Icon(
                                          Icons.search_off,
                                          size: 140,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Shimmer.fromColors(
                                        baseColor: const Color.fromARGB(
                                            255, 53, 51, 51),
                                        highlightColor: Colors.white,
                                        child: Text(
                                          'No planning indent items.\n Available for the searched criteria.',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 10, 10, 10),
                                          ),
                                          // style: TextStyle(
                                          //   fontSize: 16,
                                          //   color:
                                          //       Color.fromARGB(255, 10, 10, 10),
                                          // ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final int totalRows =
                                planningIndentController.indents.length;
                            final int startIndex = _currentPage * _rowsPerPage;
                            final int endIndex =
                                (startIndex + _rowsPerPage).clamp(0, totalRows);

                            final List<PlanningindentModel> paginatedIndents =
                                planningIndentController.indents
                                    .sublist(startIndex, endIndex);

                            return Theme(
                              data: Theme.of(context).copyWith(
                                textTheme: TextTheme(
                                  bodySmall: theme.textTheme.bodyLarge
                                      ?.copyWith(color: Colors.black),
                                  //  TextStyle(color: Colors.black),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(
                                      dragDevices: {
                                        PointerDeviceKind.touch,
                                        PointerDeviceKind.mouse,
                                      },
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: PaginatedDataTable(
                                          dataRowHeight: 36,
                                          headingRowHeight: 40,
                                          header: Text(
                                            'PLANNING INDENT ITEMS (${planningIndentController.indents.length})',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                            // style: const TextStyle(
                                            //   fontSize: 13,
                                            //   fontWeight: FontWeight.bold,
                                            //   color: Colors.black,
                                            // ),
                                          ),
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 215, 210, 210)),
                                          rowsPerPage: _rowsPerPage >
                                                  planningIndentController
                                                      .indents.length
                                              ? planningIndentController
                                                  .indents.length
                                              : _rowsPerPage,
                                          availableRowsPerPage: [
                                            10,
                                            20,
                                            50,
                                            60,
                                            80,
                                            planningIndentController
                                                .indents.length,
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
                                          columns: [
                                            // DataColumn(
                                            //   label: Text(
                                            //     "ITEM",
                                            //     style: TextStyle(
                                            //         fontSize: 12,
                                            //         fontWeight: FontWeight.bold,
                                            //         color: Colors.black),
                                            //   ),
                                            //   onSort:
                                            //       (columnIndex, ascending) =>
                                            //           _sort(
                                            //               (indent) =>
                                            //                   indent.itemName,
                                            //               columnIndex,
                                            //               ascending),
                                            // ),

                                            DataColumn(
                                              label: Row(
                                                children: [
                                                  Text(
                                                    "ITEM",
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    // style: TextStyle(
                                                    //   fontSize: 12,
                                                    //   fontWeight:
                                                    //       FontWeight.bold,
                                                    //   color: Colors.black,
                                                    // ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  // if (_currentSortColumnIndex ==
                                                  //     0) // Column index 0
                                                  Icon(
                                                    _isAscending
                                                        ? Icons.arrow_upward
                                                        : Icons.arrow_downward,
                                                    size: 16,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                              onSort: (columnIndex, ascending) {
                                                setState(() {
                                                  if (_currentSortColumnIndex ==
                                                      columnIndex) {
                                                    _isAscending =
                                                        !_isAscending;
                                                  } else {
                                                    _currentSortColumnIndex =
                                                        columnIndex;
                                                    _isAscending = true;
                                                  }
                                                  _sort(
                                                      (indent) =>
                                                          indent.itemName,
                                                      columnIndex,
                                                      _isAscending);
                                                });
                                              },
                                            ),

                                            DataColumn(
                                              label: Text(
                                                "NAME",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) =>
                                                          indent.displayName,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "VEH APPLN",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) => indent
                                                          .vehicleApplication,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "AVL. QTY",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) =>
                                                          indent.availableQty,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "ON ORD",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      _sort(
                                                          (indent) =>
                                                              indent.onOrderQty,
                                                          columnIndex,
                                                          ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "AVG/MONTH",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) => indent
                                                          .avgSaleQtyPerMonth,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "SUG.QTY",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) =>
                                                          indent.suggestedQty,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "TO ORDER QTY",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      _sort(
                                                          (indent) =>
                                                              indent.orderQty,
                                                          columnIndex,
                                                          ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "SUP NO",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) =>
                                                          indent.supersededNo,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "MOQ",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort((indent) => indent.moq,
                                                      columnIndex, ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "LAST 3 MONTHS SALE",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) => indent
                                                          .lastThreeMonthsSequentialSale,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "CURRENT MONTH SALE",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      _sort(
                                                          (indent) => indent
                                                              .currentMonthSale,
                                                          columnIndex,
                                                          ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "STOCK > 6 MONTHS",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) => indent
                                                          .greaterThan6MonthStock,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "GRN1 QTY",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      _sort(
                                                          (indent) =>
                                                              indent.grn1Qty,
                                                          columnIndex,
                                                          ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "STDN QTY",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      _sort(
                                                          (indent) =>
                                                              indent.stdnQty,
                                                          columnIndex,
                                                          ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "LOSS OF SALE QTY",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) =>
                                                          indent.lossOfSaleQty,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "BACKORDER QTY",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) =>
                                                          indent.backorderQty,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "LAST RECEIPT DATE",
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onSort: (columnIndex,
                                                      ascending) =>
                                                  _sort(
                                                      (indent) => indent
                                                          .lastDateOfReceipt,
                                                      columnIndex,
                                                      ascending),
                                            ),
                                          ],
                                          source: _IndentDataTableSource(
                                              planningIndentController.indents),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                return planningIndentController.indents.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            planningIndentController.indents
                                                .clear();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 237, 171, 27),
                                            elevation: 6,
                                            shadowColor:
                                                Colors.black.withOpacity(0.15),
                                          ),
                                          child: Text(
                                            'Clear Items',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                            // style: TextStyle(
                                            //   color: Colors.white,
                                            //   fontWeight: FontWeight.w600,
                                            //   letterSpacing: 0.5,
                                            // ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 140,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (planningIndentController
                                                .indents.isEmpty) {
                                              AppSnackBar.alert(
                                                  message:
                                                      "No items to submit!");
                                              return;
                                            }

                                            isLoading.value = true;

                                            bool canSubmit =
                                                await planningIndentController
                                                    .beforeSubmitPlanning(
                                              planningindent:
                                                  SentPlanningIndentModel(
                                                supplier: int.tryParse(
                                                    planningIndentController
                                                        .selectedSupplierId
                                                        .value),
                                                location: int.tryParse(
                                                    planningIndentController
                                                        .selectedLocationId
                                                        .value),
                                                fms: fms[selectedPurpose
                                                        .value] ??
                                                    0,
                                                supplierprogro: int.tryParse(
                                                    selectedProductGroup.value
                                                        .split('-')
                                                        .first
                                                        .trim()),
                                                supplierprodiv: int.tryParse(
                                                    selectedDivision.value
                                                        .split('-')
                                                        .last
                                                        .trim()),
                                                items: planningIndentController
                                                    .indents
                                                    .map((indent) {
                                                  return ItemDetail(
                                                    itemId: indent.itemId,
                                                    availableQty:
                                                        indent.availableQty,
                                                    onHandQty: indent.onHandQty,
                                                    moq: indent.moq,
                                                    onOrderQty:
                                                        indent.onOrderQty,
                                                    avgSaleQtyPerMonth: indent
                                                        .avgSaleQtyPerMonth,
                                                    proAvgSalesQty:
                                                        indent.projAvgSaleQty,
                                                    orderQty: indent.orderQty,
                                                    suggestedQty:
                                                        indent.suggestedQty,
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                            print("Can Submit: $canSubmit");
                                            if (canSubmit) {
                                              bool success =
                                                  await planningIndentController
                                                      .sendPlanningIndent(
                                                planningindent:
                                                    SentPlanningIndentModel(
                                                  supplier: int.tryParse(
                                                      planningIndentController
                                                          .selectedSupplierId
                                                          .value),
                                                  location: int.tryParse(
                                                      planningIndentController
                                                          .selectedLocationId
                                                          .value),
                                                  fms: fms[selectedPurpose
                                                          .value] ??
                                                      0,
                                                  supplierprogro: int.tryParse(
                                                      selectedProductGroup.value
                                                          .split('-')
                                                          .first
                                                          .trim()),
                                                  supplierprodiv: int.tryParse(
                                                      selectedDivision.value
                                                          .split('-')
                                                          .last
                                                          .trim()),
                                                  items:
                                                      planningIndentController
                                                          .indents
                                                          .map((indent) {
                                                    return ItemDetail(
                                                      itemId: indent.itemId,
                                                      availableQty:
                                                          indent.availableQty,
                                                      onHandQty:
                                                          indent.onHandQty,
                                                      moq: indent.moq,
                                                      onOrderQty:
                                                          indent.onOrderQty,
                                                      avgSaleQtyPerMonth: indent
                                                          .avgSaleQtyPerMonth,
                                                      proAvgSalesQty:
                                                          indent.projAvgSaleQty,
                                                      orderQty: indent.orderQty,
                                                      suggestedQty:
                                                          indent.suggestedQty,
                                                    );
                                                  }).toList(),
                                                ),
                                              );

                                              if (success) {
                                                planningIndentController.indents
                                                    .clear();
                                              }
                                            }

                                            isLoading.value = false;
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            backgroundColor:
                                                Colors.green.shade600,
                                            elevation: 6,
                                            shadowColor:
                                                Colors.black.withOpacity(0.15),
                                          ),
                                          child: Obx(() => isLoading.value
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5,
                                                  ),
                                                )
                                              : Text('Submit',
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox();
              })
            ],
          ),
        ),
      ),
    );
  }
}

class _IndentDataTableSource extends DataTableSource {
  final List<PlanningindentModel> filteredIndents;
  final Map<int, TextEditingController> _controllers = {};

  _IndentDataTableSource(List<PlanningindentModel> indents)
      : filteredIndents = indents.toList() {
    for (var i = 0; i < filteredIndents.length; i++) {
      _controllers[i] =
          TextEditingController(text: filteredIndents[i].orderQty.toString());
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredIndents.length) return null;
    final indent = filteredIndents[index];

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return index.isEven ? Colors.blueGrey[50] : Colors.white;
        },
      ),
      cells: [
        _buildDataCell(indent.itemName, FontWeight.w400, Colors.black),
        _buildDataCell(indent.displayName, FontWeight.w400, Colors.black),
        _buildDataCell(
            indent.vehicleApplication, FontWeight.w400, Colors.black),
        _buildDataCell(
            indent.availableQty.toString(), FontWeight.w400, Colors.black),
        _buildDataCell(
            indent.onOrderQty.toString(), FontWeight.w400, Colors.black),
        _buildDataCell(indent.avgSaleQtyPerMonth.toString(), FontWeight.w400,
            Colors.black),
        _buildDataCell(
            indent.suggestedQty.toString(), FontWeight.w400, Colors.black),
        DataCell(
          SizedBox(
            width: 70,
            height: 30,
            child: TextField(
                controller: _controllers[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 218, 214, 214),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 167, 160, 160)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                onChanged: (value) {
                  int? newValue = int.tryParse(value);

                  int maxQty = (indent.avgSaleQtyPerMonth * 2) -
                      indent.onOrderQty -
                      indent.availableQty;
                  maxQty = maxQty < 0 ? 0 : maxQty;

                  if (newValue == null || newValue < 0) {
                    _controllers[index]!.text = indent.orderQty.toString();
                  } else if (newValue > maxQty) {
                    _controllers[index]!.text = maxQty.toString();
                    indent.orderQty = maxQty;
                    AppSnackBar.alert(
                        message: "Quantity cannot exceed $maxQty");

                    print("Input exceeded. New value set: $maxQty");
                  } else {
                    indent.orderQty = newValue;
                    print("Accepted value: $newValue");
                  }
                }),
          ),
        ),
        _buildDataCell(indent.supersededNo, FontWeight.w400, Colors.black),
        _buildDataCell(indent.moq.toString(), FontWeight.w400, Colors.black),
        _buildDataCell(indent.lastThreeMonthsSequentialSale, FontWeight.w400,
            Colors.black),
        _buildDataCell(indent.currentMonthSale, FontWeight.w400, Colors.black),
        _buildDataCell(
            indent.greaterThan6MonthStock, FontWeight.w400, Colors.black),
        _buildDataCell(indent.grn1Qty, FontWeight.w400, Colors.black),
        _buildDataCell(indent.stdnQty, FontWeight.w400, Colors.black),
        _buildDataCell(indent.lossOfSaleQty, FontWeight.w400, Colors.black),
        _buildDataCell(indent.backorderQty, FontWeight.w400, Colors.black),
        _buildDataCell(indent.lastDateOfReceipt, FontWeight.w400, Colors.black),
      ],
    );
  }

  DataCell _buildDataCell(String text, FontWeight weight, Color textColor) {
    // final theme = Theme.of(context);
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
        child: Text(
          text,
          // style:theme.textTheme.bodyLarge?.copyWith( fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  @override
  int get rowCount => filteredIndents.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
