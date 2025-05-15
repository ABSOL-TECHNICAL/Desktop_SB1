import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:impal_desktop/features/sales/salesperson/customers/new_product_sales_report/controller/new_product_sales_controller.dart';

class ECreditCustomerCount extends StatefulWidget {
  const ECreditCustomerCount({super.key});

  @override
  _ECreditCustomerCountState createState() => _ECreditCustomerCountState();
}

class _ECreditCustomerCountState extends State<ECreditCustomerCount>
    with SingleTickerProviderStateMixin {
  final NewProductSalesController newProductSalesController =
      Get.put(NewProductSalesController());
  String hoveredCard = '';
  late AnimationController _controller;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });

    _wiggleAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (Get.isRegistered<NewProductSalesController>()) {
      Get.delete<NewProductSalesController>();
    }
    super.dispose();
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: SizedBox(
        width: 210,
        height: 100,
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              hoveredCard = title;
              _controller.forward(from: 0);
            });
          },
          onExit: (_) {
            setState(() {
              hoveredCard = '';
              _controller.reverse();
            });
          },
          child: Transform.rotate(
            angle: hoveredCard == title
                ? sin(_wiggleAnimation.value * pi / 180) * 0.1
                : 0,
            child: Card(
              color: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontSize: hoveredCard == title ? 22 : 18,
                            fontWeight: hoveredCard == title
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          child: Text(value),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 18,
                        color: Colors.white,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reportData = newProductSalesController.salesreportData;
      double screenWidth = MediaQuery.of(context).size.width;

      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: const Text(
                'Application Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: screenWidth > 600
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    title: 'Approved',
                    value: reportData['MonthlyTarget'] ?? '0.0',
                    icon: Icons.verified,
                  ),
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 5),
                Expanded(
                  child: _buildDashboardCard(
                    title: 'Pending',
                    value: reportData['DaySales'] ?? '0.0',
                    icon: Icons.pending_actions,
                  ),
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 5),
                Expanded(
                  child: _buildDashboardCard(
                    title: 'Rejected',
                    value: reportData['CumulativeSales'] ?? '0.0',
                    icon: Icons.highlight_off,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
