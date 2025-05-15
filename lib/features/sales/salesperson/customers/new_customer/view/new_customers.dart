import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/new_customer/controller/new_customers_controller.dart';

class NewCustomers extends StatefulWidget {
  static const String routeName = '/NewCustomers';

  const NewCustomers({super.key});

  @override
  _NewCustomersState createState() => _NewCustomersState();
}

class _NewCustomersState extends State<NewCustomers> {
  bool isLoading = true;
  final NewCustomerController newCustomerController =
      Get.put(NewCustomerController());

  @override
  void initState() {
    super.initState();
    newCustomerController.fetchNewCustomerDetails();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<NewCustomerController>()) {
      print("Disposing New Customer...");
      Get.delete<NewCustomerController>();
    } else {
      print("New Customer is not registered, no need to dispose.");
    }
    super.dispose();
    print("Customer disposed.");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customers',
          style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (newCustomerController.isLoading.value) {
            return _buildShimmerLoading();
          } else if (newCustomerController.customerData.isEmpty) {
            return _buildNoDataWidget();
          } else {
            return _buildCustomerTables(context, theme);
          }
        }),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 20),
          Text(
            'No new customers have been added this month.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTables(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
            color: const Color.fromARGB(
                255, 250, 248, 248), // Set card color to grey
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month\'s Customers (${newCustomerController.customerData[0].customerMonth?.length ?? 0})', // Add count in the header
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCustomerDataTable(
                    newCustomerController.customerData[0].customerMonth ?? [],
                    context,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
            color: const Color.fromARGB(
                255, 250, 248, 248), // Set card color to grey
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Year\'s Customers (${newCustomerController.customerData[0].customerYear?.length ?? 0})', // Add count in the header
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCustomerDataTable(
                    newCustomerController.customerData[0].customerYear ?? [],
                    context,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerDataTable(
      List<dynamic> customerList, BuildContext context) {
        final theme = Theme.of(context);
    if (customerList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Center(
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
                child:  Text(
                  'No Customer found.',
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 20, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Table(
              defaultColumnWidth: const FixedColumnWidth(140),
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
                borderRadius: BorderRadius.circular(8),
              ),
              children: [
                _buildTableRow(
                  ["S.No", "Customer Code", "Customer Name", "Sales"],
                  context,
                  isHeader: true,
                ),
                ...List.generate(
                  customerList.length,
                  (index) {
                    final customer = customerList[index];
                    return _buildTableRow(
                      [
                        (index + 1).toString(),
                        customer.customerCode ?? "- None -",
                        customer.customerName ?? "- None -",
                        customer.sales?.toString() ?? "0.00",
                      ],
                      context,
                      isHeader: false,
                      rowColor:
                          index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    List<String> data,
    BuildContext context, {
    bool isHeader = false,
    Color? rowColor,
  }) {
    final theme = Theme.of(context);
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? const Color.fromARGB(255, 59, 128, 219) : rowColor,
        borderRadius: BorderRadius.circular(8),
      ),
      children: data
          .map(
            (value) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  fontSize: isHeader ? 16 : 14,
                  color: isHeader ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.grey.shade300, // Set card color to grey
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color.fromARGB(
                  255, 242, 237, 237), // Set card color to grey
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.white,
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
}
