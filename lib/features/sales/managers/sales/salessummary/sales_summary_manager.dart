import 'package:flutter/material.dart';
import 'package:impal_desktop/features/sales/managers/sales/salessummary/controller/sales_summary_manager_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';

class SalesSummaryManager extends StatefulWidget {
  static const String routeName = '/sales_summary';

  const SalesSummaryManager({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SalesSummaryManagerState createState() => _SalesSummaryManagerState();
}

class _SalesSummaryManagerState extends State<SalesSummaryManager> {
  bool isLoading = true;
  final SalesSummaryManagerController salessummaryController =
      Get.put(SalesSummaryManagerController());
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize the controller and fetch data
    print("Initializing New product sales manager ...");
    salessummaryController.fetchSalessummaryManager();

    // Listen for changes in the search text field
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the controller and the search controller
    if (Get.isRegistered<SalesSummaryManagerController>()) {
      print("Disposing SalesSummaryManagerController...");
      Get.delete<SalesSummaryManagerController>();
    }
    searchController.dispose(); // Dispose of the search controller

    super.dispose();
    print("New Product sales Manager disposed.");
  }

  // Filtering method for search functionality
  List<Map<String, dynamic>> _filterData() {
    if (searchQuery.isEmpty) {
      return salessummaryController.reportData;
    } else {
      return salessummaryController.reportData.where((entry) {
        // Check if either SalesExecutiveName or Monthlytarget contains the search query
        return (entry['SalesExecutiveName']
                    ?.toLowerCase()
                    .contains(searchQuery) ??
                false) ||
            (entry['Monthlytarget']?.toString().contains(searchQuery) ??
                false) ||
            (entry['DaySales']?.toString().contains(searchQuery) ?? false) ||
            (entry['CumulativeSales']?.toString().contains(searchQuery) ??
                false) ||
            (entry['AchSales']?.toString().contains(searchQuery) ?? false);
      }).toList();
    }
  }

  double _calculateCumulativeTotal() {
  final filteredData = _filterData(); // Apply search filter if any
  double total = 0.0;

  for (var entry in filteredData) {
    final value = double.tryParse(entry['CumulativeSales']?.toString() ?? '0') ?? 0.0;
    total += value;
  }

  return total;
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sales Summary',
          style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
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
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 5, bottom: 0),
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: GlobalSearchField(
                          hintText: 'Search Sales Executive...'.tr,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value; // Update the search query
                            });
                          },
                        ),
                      ),
                    ),
                                        const SizedBox(height: 20),
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 201, 199, 199),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          'Cumulative Total: ${_calculateCumulativeTotal().toStringAsFixed(2)}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );
    }),
  ],
),
const SizedBox(height: 20),
                    Expanded(
                      child: Obx(
                        () {
                          return salessummaryController
                                  .isLoading.value // Check for loading state
                              ? _buildShimmerTable()
                              : _filterData().isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 160),
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 53, 51, 51),
                                            highlightColor: Colors.white,
                                            child: Icon(
                                              Icons.search_off,
                                              size: 70,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 53, 51, 51),
                                            highlightColor: Colors.white,
                                            child:  Text(
                                              'No Sales Summary is Found.',
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontSize: 20,
                                                color: Color.fromARGB(
                                                    255, 10, 10, 10),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      // Center the entire table container
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Container(
                                          padding: const EdgeInsets.all(3.0),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Table(
                                              defaultColumnWidth:
                                                  IntrinsicColumnWidth(),
                                              border: TableBorder.all(
                                                color:
                                                    Colors.grey, // Border color
                                                width: 1, // Border width
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5), // Border radius
                                              ),
                                              children: [
                                                _buildTableRow(
                                                  [
                                                    "Sales Executive Name".tr,
                                                    "Monthly Target".tr,
                                                    "Day Sales".tr,
                                                    "Cumulative Sales".tr,
                                                    "Ach Sales %".tr,
                                                    "Balance to do".tr,
                                                  ],
                                                  context,
                                                ),
                                                // Build table rows for each filtered entry in reportData
                                                ..._filterData()
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  int index = entry
                                                      .key; // Get the index
                                                  var data = entry.value;

                                                  return _buildTableRow1(
                                                    [
                                                      data['SalesExecutiveName'] ??
                                                          "N/A",
                                                      data['Monthlytarget']
                                                              ?.toString() ??
                                                          "0",
                                                      data['DaySales']
                                                              ?.toString() ??
                                                          "0",
                                                      data['CumulativeSales']
                                                              ?.toString() ??
                                                          "0",
                                                      data['AchSales']
                                                              ?.toString() ??
                                                          "0",
                                                      data['BalanceToDo']
                                                              ?.toString() ??
                                                          "0",
                                                    ],
                                                    context,
                                                    index,
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                        },
                      ),
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

  TableRow _buildTableRow(List<String> headers, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return TableRow(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                colors: [Colors.redAccent.shade400, Colors.pink.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF57AEFE), Color(0xFF6B71FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: Colors.pink.withOpacity(0.1), // Reduced opacity for the border
          width: 1, // Border width
        ),
      ),
      children: headers
          .map(
            (header) => Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
              child: SizedBox(
                width: 200, // Adjusted width of each cell
                child: Text(
                  header,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.pink.withOpacity(0.1), // Low opacity border
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  highlightColor:
                      isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  highlightColor:
                      isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow1(
      List<String> headers, BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine the background color based on the index
    Color bgColor;
    if (index % 2 == 0) {
      // Even index
      bgColor = isDarkMode ? Colors.blueGrey : Color(0xFFEAEFFF); // Light color
    } else {
      // Odd index
      bgColor = isDarkMode
          ? Colors.grey[900]!
          : Color.fromARGB(255, 255, 249, 252); // Dark color
    }

    return TableRow(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      children: headers
          .map(
            (header) => Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 14.0), // Reduced vertical padding
              child: SizedBox(
                width: 200, // Increased width of each cell
                child: Text(
                  header,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
