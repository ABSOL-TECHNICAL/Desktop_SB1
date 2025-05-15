import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/billed_customer/non-billed/controller/nonbilled_controller.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';

class NonBilledScreen extends StatefulWidget {
  static const String routeName = '/NonBilledScreen';

  const NonBilledScreen({super.key});

  @override
  _NonBilledScreenState createState() => _NonBilledScreenState();
}

class _NonBilledScreenState extends State<NonBilledScreen> {
  NonbilledController _controller = Get.put(NonbilledController());
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    print("Initializing NonbilledController...");
    _controller = Get.put(NonbilledController());

    // Simulate loading
    print("Simulating loading state...");
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        print("Loading complete, isLoading set to false.");
      });
    });
    _controller.fetchNonBilled();
  }

  @override
  void dispose() {
    // Dispose of the controller
    if (Get.isRegistered<NonbilledController>()) {
      print("Disposing NonbilledController...");
      Get.delete<NonbilledController>();
    } else {
      print("NonbilledController is not registered, no need to dispose.");
    }

    super.dispose();
    print("NonBilledScreen disposed.");
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  List<dynamic> _filteredCustomers() {
    if (searchQuery.isEmpty) return _controller.nonbilledCustomer;
    return _controller.nonbilledCustomer.where((customer) {
      return customer["DealoreCode"]
              ?.toLowerCase()
              ?.contains(searchQuery.toLowerCase()) ??
          false ||
              customer["Address"]
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
            'UnBilled Details',
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
                  padding:
                      const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      isLoading
                          ? ShimmerCard(
                              height: 100,
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
                                                "Total Unbilled Customers".tr,
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
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            _controller.nonbilledCustomer.length
                                                .toString(),
                                            style: theme.textTheme.headlineLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      )
                                    ]),
                              ),
                            ),
                      const SizedBox(height: 15),
                      Text(
                        'Current data is From : ${DateFormat('MMMM').format(DateTime.now())} Month',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      GlobalSearchField(
                        hintText: 'Search Customers...'.tr,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 10),
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
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Table(
                                  defaultColumnWidth:
                                      const IntrinsicColumnWidth(),
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        gradient: isDarkMode
                                            ? LinearGradient(
                                                colors: [
                                                  Colors.redAccent.shade400,
                                                  Colors.pink.shade900
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFF57AEFE),
                                                  Color(0xFF6B71FF)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                      ),
                                      children: [
                                        _buildHeaderCell(
                                            "S.No", context), // SNo header
                                        _buildHeaderCell(
                                            "Dealer code / Name", context),
                                        _buildHeaderCell("Address", context),
                                        _buildHeaderCell("Location", context),
                                        _buildHeaderCell(
                                            "Last Billed Date", context),
                                        _buildHeaderCell(
                                            "Credit Limit", context),
                                      ],
                                    ),
                                    // Populate the table rows dynamically
                                    ..._filteredCustomers()
                                        .asMap()
                                        .entries
                                        .map<TableRow>((entry) {
                                      int index = entry.key; // Get index
                                      Map<String, dynamic> customer =
                                          entry.value; // Get customer data
                                      return _buildTableRow1(
                                        [
                                          (index + 1)
                                              .toString(), // Serial number
                                          customer["DealoreCode"] ?? "",
                                          customer["Address"] ?? "",
                                          customer["Location"] ?? "",
                                          customer["LastBillDate"] ?? "",
                                          customer["CreditAmount"] ?? "",
                                        ],
                                        isHeader: false,
                                        context: context,
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
        ));
  }

  Widget _buildHeaderCell(String text, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
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
