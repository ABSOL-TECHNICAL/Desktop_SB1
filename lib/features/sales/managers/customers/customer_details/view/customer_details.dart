import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:impal_desktop/features/global/theme/theme.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/controllers/customer_details_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/outstanding_page/view/outstanding_page.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/view/sales_order.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/view_order/view_order.dart';

class CustomerDetails extends StatefulWidget {
  static const String routeName = '/Customer';

  const CustomerDetails({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<CustomerDetails> {
  int? _expandedCardIndex;
  String _searchQuery = '';
  bool isLoading = true;
  final CustomerDetailsController _controller =
      Get.put(CustomerDetailsController());

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  void _fetchData() async {
    await _controller.fetchCustomerdetails();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<CustomerDetailsController>()) {
      print("Disposing Customer Details...");
      Get.delete<CustomerDetailsController>();
    } else {
      print("Customer details is not registered, no need to dispose.");
    }

    super.dispose();
    print("Customer details disposed.");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final filteredCustomers = _controller.customerdetails.where((customer) {
      final searchLowerCase = _searchQuery.toLowerCase();
      return customer['Customer'] != null &&
              customer['Customer'].toLowerCase().contains(searchLowerCase) ||
          customer['CustomerId'] != null &&
              customer['CustomerId'].toLowerCase().contains(searchLowerCase) ||
          customer['Address'] != null &&
              customer['Address'].toLowerCase().contains(searchLowerCase);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Details',
          style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: isDarkMode
          ? AppTheme.darkTheme(context).scaffoldBackgroundColor
          : AppTheme.lightTheme(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 5),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 200.0, left: 200.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: GlobalSearchField(
                          hintText: 'Search Customers...'.tr,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value; // Update the search query
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' Total Customers : ${filteredCustomers.length} ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isLoading
                          ? _buildShimmerCard(context)
                          : filteredCustomers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 100),
                                      Shimmer.fromColors(
                                        baseColor: const Color.fromARGB(
                                            255, 53, 51, 51),
                                        highlightColor: Colors.white,
                                        child: Icon(
                                          Icons
                                              .person_off, // More suitable icon for "No Customers"
                                          size: 110,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Shimmer.fromColors(
                                        baseColor: const Color.fromARGB(
                                            255, 53, 51, 51),
                                        highlightColor: Colors.white,
                                        child:  Text(
                                          'No customers found. Please refine your search.',
                                          style: theme.textTheme.bodyLarge?.copyWith(      
                    fontSize: 15,
                                            color:
                                                Color.fromARGB(255, 10, 10, 10),
                ),
                                          
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount:
                                      (filteredCustomers.length / 2).ceil(),
                                  itemBuilder: (context, index) {
                                    // final customer = filteredCustomers[index];
                                    final customer1 =
                                        filteredCustomers[index * 2];
                                    final customer2 = (index * 2 + 1 <
                                            filteredCustomers.length)
                                        ? filteredCustomers[index * 2 + 1]
                                        : null;
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              _buildCustomerCard(
                                                context,
                                                theme,
                                                index * 2,
                                                customer1['Customer'] ?? '',
                                                customer1['CustomerCode'] ?? '',
                                                customer1['Address'] ?? '',
                                                customer1['Phone'] ?? '',
                                                filteredCustomers,
                                              ),
                                              const SizedBox(height: 15),
                                            ],
                                          ),
                                        ),
                                        if (customer2 != null) ...[
                                          // Only add second card if it exists
                                          const SizedBox(
                                              width: 10), // Space between cards
                                          Expanded(
                                            child: Column(
                                              children: [
                                                _buildCustomerCard(
                                                  context,
                                                  theme,
                                                  index * 2 + 1,
                                                  customer2['Customer'] ?? '',
                                                  customer2['CustomerCode'] ??
                                                      '',
                                                  customer2['Address'] ?? '',
                                                  customer2['Phone'] ?? '',
                                                  filteredCustomers,
                                                ),
                                                const SizedBox(height: 15),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
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

  Widget _buildCustomerCard(
    BuildContext context,
    ThemeData theme,
    int cardIndex,
    String name,
    String code,
    String address,
    String phoneNumber,
    List<dynamic> filteredCustomers,
  ) {
    final isExpanded = _expandedCardIndex == cardIndex;
    final bool isDarkMode = theme.brightness == Brightness.dark;
    double cardWidth =
        MediaQuery.of(context).size.width * 0.8; // Increased width to 80%

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? LinearGradient(
                        colors: [
                          Colors.blueGrey.shade900,
                          Colors.blueGrey.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [
                          Color(0xFFEAEFFF),
                          Color(0xFFFAF9FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.blueGrey.shade900.withOpacity(0.8)
                        : Colors.black.withOpacity(0.12),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    20.0), // Added more padding for better spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerInfo(
                        context, theme, name, code, address, phoneNumber),
                    const SizedBox(height: 20),
                    _buildActionButton(
                        context, theme, cardIndex, filteredCustomers),
                    if (isExpanded) ...[
                      const SizedBox(height: 30),
                      _buildAdditionalInfo(
                          theme, name, code, filteredCustomers, cardIndex),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, ThemeData theme, String name,
      String code, String address, String phoneNumber) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                phoneNumber,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: theme.textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    int cardIndex,
    List<dynamic> filteredCustomers,
  ) {
    final isExpanded = _expandedCardIndex == cardIndex;
    final isDarkMode = theme.brightness == Brightness.dark;

    final darkModeColor = Colors.blueAccent.shade700;

    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: isExpanded ? Alignment.center : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            width: isExpanded ? 200 : 120,
            height: 35,
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (isExpanded) {
                  _expandedCardIndex = null;
                } else {
                  _expandedCardIndex = cardIndex;
                }
              });

              final selectedCustomer = filteredCustomers[cardIndex];

              if (selectedCustomer != null) {
                if (kDebugMode) {
                  print(
                      "Selected Customer ID: ${selectedCustomer['CustomerId']}");
                }

                _controller.selectedCustomer.value = {
                  'CustomerId': selectedCustomer['CustomerId'],
                  'Customer': selectedCustomer['Customer'],
                };
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.zero,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Transactions'.tr,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(ThemeData theme, String name, String code,
      List<dynamic> filteredCustomers, int cardIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Content for $name:'.tr,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _buildActionButtons(filteredCustomers, cardIndex)
      ],
    );
  }

  Widget _buildActionButtons(List<dynamic> filteredCustomers, int cardIndex) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? const Color(0xFF064071)
                      : const Color(0xFFDEFFA9),
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  'Outstandings'.tr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesOrderPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? const Color(0xFF17A2B8)
                      : const Color(0xFFF4E3FF),
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  'Create Estimate'.tr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final selectedCustomer = filteredCustomers[cardIndex];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewOrderPage(
                            customerName: selectedCustomer['Customer'])),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 227, 144, 144),
                  backgroundColor: isDarkMode
                      ? const Color(0xFF17A2B8)
                      : const Color.fromRGBO(246, 227, 166, 0.822),
                ),
                child: Text(
                  'View Orders'.tr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.grey[850]!, Colors.white60]
                    : [Colors.grey[300]!, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(16), // Match the border radius
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.grey[800]!.withOpacity(0.3)
                      : const Color.fromARGB(255, 214, 213, 213)
                          .withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(2, 2), // Match the shadow settings
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // Match the padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adjust shimmer widgets to match the actual content layout
                  _buildShimmerRow(width: 200, height: 20),
                  _buildShimmerRow(width: 50, height: 15),
                  _buildShimmerRow(width: 280, height: 15),
                  // Add more shimmer rows as needed
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerRow({
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      child: ShimmerCard(
        height: height,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
