import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/sales/salesperson/collection_summary/controller/collection_summary_controller.dart';

import 'package:shimmer/shimmer.dart';

class CollectionSummary extends StatefulWidget {
  const CollectionSummary({super.key});

  @override
  _CollectionSummaryState createState() => _CollectionSummaryState();
}

class _CollectionSummaryState extends State<CollectionSummary> {
  final CollectionsummaryController _controller =
      Get.put(CollectionsummaryController());

  @override
  void initState() {
    super.initState();
    _controller.fetchCollectionsummaryData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Collection Summary',
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
          double padding = constraints.maxWidth > 1200
              ? 32
              : 16; // Increase padding for large screens
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
            child: Obx(() {
              if (_controller.isLoading.value) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Shimmer effect for the header
                        Row(
                          children: [
                            Expanded(
                              child: buildShimmerContainer(),
                            ),
                            SizedBox(width: 32),
                            Expanded(
                              child: buildShimmerContainer(),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        // Shimmer effect for table rows
                        Row(
                          children: [
                            Expanded(
                              child: buildShimmerContainer(),
                            ),
                            SizedBox(width: 32),
                            Expanded(
                              child: buildShimmerContainer(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              final reportData = _controller.reportData;
              final tableData = [
                {
                  '< 90': reportData['TotalOutstandingabove90days'] ?? '0',
                  '> 90': reportData['Totalout91to180day'] ?? '0',
                  '> 180': reportData['Totalout180daysabove'] ?? '0',
                },
                {
                  '< 90': reportData['DayCollectionabove90days'] ?? '0',
                  '> 90': reportData['Daycollection91to180day'] ?? '0',
                  '> 180': reportData['Daycollection180daysabove'] ?? '0',
                },
                {
                  '< 90': reportData['CumulativeSalesabove90days'] ?? '0',
                  '> 90': reportData['CumulativeSales91to180days'] ?? '0',
                  '> 180': reportData['CumulativeSales180daysabove'] ?? '0',
                },
                {
                  '< 90': reportData['Achcollectionsabove90days'] ?? '0',
                  '> 90': reportData['Achcollection91to180day'] ?? '0',
                  '> 180': reportData['Achcollection180daysabove'] ?? '0',
                },
              ];

              final totalData = tableData.map((row) {
                double total = row.values
                    .map((value) => double.tryParse(value) ?? 0)
                    .reduce((a, b) => a + b);
                return {...row, 'Total': total.toString()};
              }).toList();

              double totalOutstanding =
                  double.tryParse(totalData[0]['Total'] ?? '0') ?? 0;
              double cumulativeTotal =
                  double.tryParse(totalData[2]['Total'] ?? '0') ?? 0;

              double divisionResult = cumulativeTotal != 0
                  ? (totalOutstanding / cumulativeTotal) * 100
                  : 0;

              totalData[3]['Total'] = divisionResult.toStringAsFixed(2);

              return SingleChildScrollView(
                // Make the entire content scrollable
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: buildTable(
                                theme, 'Total Outstanding', totalData[0])),
                        SizedBox(width: 32),
                        Expanded(
                            child: buildTable(
                                theme, 'Day Collections', totalData[1])),
                      ],
                    ),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                            child:
                                buildTable(theme, 'Cumulative', totalData[2])),
                        SizedBox(width: 32),
                        Expanded(
                            child: buildTable(
                                theme, 'Ach Collections %', totalData[3])),
                      ],
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget buildShimmerContainer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
    );
  }

  Widget buildTable(ThemeData theme, String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Larger font for desktop UI
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Table(
          border: TableBorder.all(color: Colors.grey[300]!, width: 1),
          columnWidths: const {
            0: FixedColumnWidth(120), // Adjust column widths for better spacing
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(120),
            3: FixedColumnWidth(120),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B71FF), Color(0xFF57AEFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              children: ['≤ 90', '91 - 180', '≥ 180', 'Total']
                  .map((text) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14, // Larger font size for headings
                          ),
                        ),
                      ))
                  .toList(),
            ),
            TableRow(
              children: data.values
                  .map((value) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14, // Larger font for table data
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}
