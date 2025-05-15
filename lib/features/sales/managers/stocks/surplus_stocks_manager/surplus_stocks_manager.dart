import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/sales/managers/stocks/surplus_stocks_manager/controller/surplus_stocks_manager_controller.dart';

class SurplusStocksM extends StatefulWidget {
  const SurplusStocksM({super.key});

  @override
  _SurplusStocksMState createState() => _SurplusStocksMState();
}

class _SurplusStocksMState extends State<SurplusStocksM> {
  // late TextEditingController _pageController;
  final SurplusStocksMController surplusstockmanager =
      Get.put(SurplusStocksMController());
  String searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    //  _pageController = TextEditingController(text: _currentPage.toString());
    print("Initializing Surplus Stocks Manager...");
    surplusstockmanager.fetchSurplusstockManager();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (Get.isRegistered<SurplusStocksMController>()) {
      print("Disposing Surplus Stock Manager controller...");
      Get.delete<SurplusStocksMController>();
    }
    super.dispose();
    print("Surplus Stock Manager disposed.");
  }

  List<Map<String, dynamic>> _filterData() {
    if (searchQuery.isEmpty) {
      return surplusstockmanager.reportData;
    } else {
      return surplusstockmanager.reportData.where((entry) {
        return (entry['Supplier']
                ?.toLowerCase()
                .contains(searchQuery.toLowerCase()) ??
            false);
      }).toList();
    }
  }

  List<Map<String, dynamic>> _getPaginatedData(List<Map<String, dynamic>> data) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= data.length) {
      return [];
    }
    final endIndex = startIndex + _itemsPerPage;
    return data.sublist(
        startIndex, endIndex > data.length ? data.length : endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surplus Stocks',
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
              padding: const EdgeInsets.only(top: 10, bottom: 0),
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: GlobalSearchField(
                          hintText: 'Search Supplier...'.tr,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              _currentPage = 1; // Reset to first page when searching
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),Expanded(
  child: Obx(() {
    final filteredData = _filterData();
    final paginatedData = _getPaginatedData(filteredData);
    final totalPages = (filteredData.length / _itemsPerPage).ceil();

    return surplusstockmanager.isLoading.value
        ? _buildShimmerTable()
        : filteredData.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),
                    Shimmer.fromColors(
                      baseColor: const Color.fromARGB(255, 53, 51, 51),
                      highlightColor: Colors.white,
                      child: Icon(
                        Icons.search_off,
                        size: 140,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Shimmer.fromColors(
                      baseColor: const Color.fromARGB(255, 53, 51, 51),
                      highlightColor: Colors.white,
                      child: Text(
                        'No surplus stocks are available right now.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          color: Color.fromARGB(255, 10, 10, 10),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            : 
            Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Total: ${filteredData.length} items',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      child: Container(
                        alignment: Alignment.center,
                        width: 1000,
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1000,
                            child: Table(
                              defaultColumnWidth: const FlexColumnWidth(),
                              columnWidths: const {
                                0: FixedColumnWidth(80),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                                4: FlexColumnWidth(1),
                                5: FlexColumnWidth(1),
                              },
                              children: [
                                _buildTableRow(
                                  [
                                    "S.No".tr,
                                    "Supplier".tr,
                                    "Part No".tr,
                                    "Qty".tr,
                                    "No Of Month".tr,
                                    "Value".tr,
                                    "Aging".tr,
                                    "Cost Price".tr,
                                  ],
                                  context,
                                ),
                                ...paginatedData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  var data = entry.value;
                                  double value;
                                  String valueString = data['Value'] ?? "0.0";

                                  try {
                                    value = double.parse(valueString);
                                  } catch (e) {
                                    value = 0.0;
                                  }
                                  return _buildTableRow1(
                                    [
                                      ((_currentPage - 1) * _itemsPerPage + index + 1).toString(),
                                      data['Supplier'] ?? "N/A",
                                      data['Item'] ?? "N/A",
                                      data['Qty']?.toString() ?? "0.0",
                                      data['NoOfMonth']?.toString() ?? "0.0",
                                      value.toStringAsFixed(2),
                                      data['Aging']?.toString() ?? "0.0",
                                      data['Cost']?.toString() ?? "0.0",
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
                    ),
                  ),
                  // Total items count above pagination controls
                 
                  _buildPaginationControls(totalPages),
            
                ],
              );
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

 // Add this new method to your _SurplusStocksMState class
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
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
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

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SizedBox(
        width: 780,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
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
                  highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
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
                  highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
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
                  highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
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

  TableRow _buildTableRow1(List<String> headers, BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color bgColor;
    if (index % 2 == 0) {
      bgColor = isDarkMode ? Colors.blueGrey : Color(0xFFEAEFFF);
    } else {
      bgColor = isDarkMode ? Colors.grey[900]! : Color(0xFFFAF9FF);
    }

    return TableRow(
      decoration: BoxDecoration(
        color: bgColor,
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
}