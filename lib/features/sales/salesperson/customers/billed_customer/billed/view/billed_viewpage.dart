import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/billed_customer/billed/controller/billed_controller.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';

class BilledScreen extends StatefulWidget {
  static const String routeName = '/BilledScreen';

  const BilledScreen({super.key});

  @override
  _BilledScreenState createState() => _BilledScreenState();
}

class _BilledScreenState extends State<BilledScreen> {
  BilledController _controller = Get.put(BilledController());
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    print("Initializing BilledController...");
    _controller = Get.put(BilledController());

    // Simulate loading
    print("Simulating loading state...");
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
    _controller.fetchBilled();
  }

  @override
  void dispose() {
    // Dispose of the controller
    if (Get.isRegistered<BilledController>()) {
      print("Disposing BilledController...");
      Get.delete<BilledController>();
    } else {
      print("BilledController is not registered, no need to dispose.");
    }

    super.dispose();
    print("BilledScreen disposed.");
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  List<dynamic> _filteredCustomers() {
    if (searchQuery.isEmpty) return _controller.billedCustomer;
    return _controller.billedCustomer.where((customer) {
      return customer["DealoreCode"]
              ?.toLowerCase()
              ?.contains(searchQuery.toLowerCase()) ??
          false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Billed Details',
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
                  padding: const EdgeInsets.only(
                      top: 10.0, right: 150.0, left: 150.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 25),
                      isLoading
                          ? ShimmerCard(
                              height: 60,
                              borderRadius: BorderRadius.circular(16),
                            )
                          : Container(
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
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF6B71FF),
                                          Color(0xFF57AEFE)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Total Billed Amount".tr,
                                                style: theme
                                                    .textTheme.headlineLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Obx(() {
                                        return Row(
                                          children: [
                                            Text(
                                              _controller.totalAmount.value
                                                  .toStringAsFixed(2),
                                              style: theme
                                                  .textTheme.headlineLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        );
                                      })
                                    ]),
                              ),
                            ),
                      const SizedBox(height: 25),
                      Text(
                        'Current data is From : ${DateFormat('MMMM').format(DateTime.now())} Month',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      GlobalSearchField(
                        hintText: 'Search Customers...'.tr,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 15),
                      Obx(() {
                        if (_controller.isLoading.value) {
                          return _buildShimmerTable();
                        } else if (_filteredCustomers().isEmpty) {
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
                                    style: theme.textTheme.bodyLarge?.copyWith(
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
                          return Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(3.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Table(
                                    defaultColumnWidth:
                                        const IntrinsicColumnWidth(),
                                    children: [
                                      // Removed sticky header
                                      _buildTableRow(
                                        [
                                          "S.No", // Add SNo to the header
                                          "Dealer code/name",
                                          "Address",
                                          "Location",
                                          "Credit Limit",
                                          "Last Billed Date",
                                          "Total Amount"
                                        ],
                                        isHeader: true,
                                        context: context,
                                      ),
                                      ..._filteredCustomers()
                                          .asMap()
                                          .entries
                                          .map<TableRow>((entry) {
                                        int index = entry.key; // Get the index
                                        Map<String, dynamic> customer = entry
                                            .value; // Get the customer data
                                        return _buildTableRow1(
                                          [
                                            (index + 1)
                                                .toString(), // Add serial number (starting from 1)
                                            customer["DealoreCode"] ?? "",
                                            customer["Address"] ?? "",
                                            customer["Location"] ?? "",
                                            customer["CreditAmount"] ?? "",
                                            customer["LastBillDate"] ?? "",
                                            customer["Amount"] ?? "",
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
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  TableRow _buildTableRow1(List<String> data,
      {required bool isHeader, required BuildContext context}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                  Color(0xFFEDFFFB), // Starting color (EDFFFB)
                  Color(0xFFFAF9FF), // Ending color (FAF9FF)
                  Color(0xFFEDFFFB), // Starting color (EDFFFB)
                  Color(0xFFFAF9FF), // Ending color (FAF9FF)
                ],
                begin: Alignment.topLeft, // Gradient starting point
                end: Alignment.bottomRight, // Gradient ending point
              ),
      ),
      children: data
          .map(
            (dataItem) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                dataItem,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _buildTableRow(List<String> data,
      {required bool isHeader, required BuildContext context}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TableRow(
      decoration: isHeader
          ? BoxDecoration(
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
            )
          : null,
      children: data
          .map(
            (cell) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell,
                style: isHeader
                    ? theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      )
                    : theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: isDarkMode ? Colors.white : Colors.black,
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
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
        ),
      ),
    );
  }
}
