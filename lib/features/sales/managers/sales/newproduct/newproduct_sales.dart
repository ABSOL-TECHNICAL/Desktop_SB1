import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/sales/managers/sales/newproduct/controller/newproduct_sales_controller.dart';

class ProductSalesSummary extends StatefulWidget {
  static const String routeName = '/product_summary';

  const ProductSalesSummary({super.key});

  @override
  _ProductSalesSummaryState createState() => _ProductSalesSummaryState();
}

class _ProductSalesSummaryState extends State<ProductSalesSummary> {
  final NewproductManagerController salesController =
      Get.put(NewproductManagerController());
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    salesController.fetchNewProductManager();
  }

  @override
  void dispose() {
    if (Get.isRegistered<NewproductManagerController>()) {
      Get.delete<NewproductManagerController>();
    }
    super.dispose();
  }

  List<Map<String, dynamic>> _filterData() {
    return searchQuery.isEmpty
        ? salesController.reportData
        : salesController.reportData
            .where((entry) => (entry['SalesExecutiveName']
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false))
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Product Sales',
          style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: constraints.maxWidth > 600
                        ? 400
                        : constraints.maxWidth * 0.8,
                    child: GlobalSearchField(
                      hintText: 'Search Sales Executive...'.tr,
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Obx(() {
                    if (salesController.isLoading.value) {
                      return _buildShimmerTable();
                    } else if (_filterData().isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 150),
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
                              child:  Text(
                                'No results found \nPlease refine your search criteria.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 23,
                                  color: Color.fromARGB(255, 10, 10, 10),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: constraints.maxWidth * 0.9),
                            child: Table(
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                              children: [
                                _buildTableHeader(),
                                ..._buildTableRows(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Color(0xFF57AEFE),
      ),
      children: [
        _buildTableCell("Sales Executive Name".tr, isHeader: true),
        _buildTableCell("Monthly Target".tr, isHeader: true),
        _buildTableCell("Day Sales".tr, isHeader: true),
        _buildTableCell("Cumulative Sales".tr, isHeader: true),
        _buildTableCell("Ach Sales %".tr, isHeader: true),
        _buildTableCell("Balance to do".tr, isHeader: true),
      ],
    );
  }

  TableCell _buildTableCell(String text, {bool isHeader = false}) {
    final theme = Theme.of(context);
    return TableCell(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 12.0, horizontal: 8.0), // Increased vertical padding
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    return _filterData().asMap().entries.map((entry) {
      int index = entry.key;
      var data = entry.value;
      return TableRow(
        decoration: BoxDecoration(
          color: index % 2 == 0
              ? const Color(0xFFEDFFFB)
              : const Color.fromARGB(255, 222, 236, 247),
        ),
        children: [
          _buildTableCell(data['SalesExecutiveName'] ?? "N/A"),
          _buildTableCell(data['Monthlytarget']?.toString() ?? "0"),
          _buildTableCell(data['DaySales']?.toString() ?? "0"),
          _buildTableCell(data['CumulativeSales']?.toString() ?? "0"),
          _buildTableCell(data['AchSales']?.toString() ?? "0"),
          _buildTableCell(data['BalanceToDo']?.toString() ?? "0"),
        ],
      );
    }).toList();
  }

  Widget _buildShimmerTable() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
