import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/view/standalone_sales_order.dart';

import 'package:impal_desktop/features/sales/salesperson/customers/new_customer/view/new_customers.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/view_billed_details/view/view_billed_details.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/billed_customer/billed/view/billed_viewpage.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/billed_customer/non-billed/view/non_billed_viewpage.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/view/customer_details.dart';

class CustomerSummary extends StatefulWidget {
  static const String routeName = '/Salessummary';
  const CustomerSummary({super.key});

  @override
  _CustomerSummaryState createState() => _CustomerSummaryState();
}

class _CustomerSummaryState extends State<CustomerSummary> {
  int _hoveredIndex = -1;
  final employee = Get.find<LoginController>().employeeModel;
  bool get isManager => employee.isManager ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Overview',
            style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildReportCard(context, Icons.people, 'Customer Details',
                      CustomerDetails(), Colors.blue, 0),
                  _buildReportCard(
                      context,
                      Icons.request_quote,
                      'Create Estimate',
                      StandaloneSalesOrderPage(),
                      Colors.deepPurple,
                      5),
                  _buildReportCard(context, Icons.receipt,
                      'View Billed Details', BilledDetails(), Colors.green, 1),
                  _buildReportCard(context, Icons.diversity_3,
                      'View New Customers', NewCustomers(), Colors.red, 2),
                  _buildReportCard(context, Icons.how_to_reg_rounded,
                      'Billed Customers', BilledScreen(), Colors.orange, 3),
                  _buildReportCard(context, Icons.person, 'UnBilled Customers',
                      NonBilledScreen(), Colors.purple, 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget destination,
    Color iconColor,
    int index,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: AnimatedScale(
          scale: _hoveredIndex == index ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
              height: 150,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50, color: iconColor),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
