import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/sales/managers/stocks/liquidation%20of%20surplus%20stocks/controllers/liquidation_stocks_controller.dart';
import 'dart:math';

class LiquidationSurplusStocks extends StatefulWidget {
  const LiquidationSurplusStocks({super.key});

  @override
  _LiquidationSurplusStocksState createState() =>
      _LiquidationSurplusStocksState();
}

class _LiquidationSurplusStocksState extends State<LiquidationSurplusStocks>
    with SingleTickerProviderStateMixin {
  final LiquidationStocksController liquidationStocksController =
      Get.put(LiquidationStocksController());
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
    if (Get.isRegistered<LiquidationSurplusStocks>()) {
      Get.delete<LiquidationSurplusStocks>();
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
    final theme = Theme.of(context);
    return Obx(() {
      final reportData = liquidationStocksController.reportData;
      double screenWidth = MediaQuery.of(context).size.width;

      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Liquidation of Surplus Stocks',
                style: theme.textTheme.bodyLarge?.copyWith(
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
                    title: 'Monthly Target',
                    value: reportData['Target'] ?? '0.0',
                    icon: Icons.flag,
                  ),
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 5),
                Expanded(
                  child: _buildDashboardCard(
                    title: 'Day Sales',
                    value: reportData['DaySales'] ?? '0.0',
                    icon: Icons.calendar_today,
                  ),
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 5),
                Expanded(
                  child: _buildDashboardCard(
                    title: 'Cumulative',
                    value: reportData['CumulativeSales'] ?? '0.0',
                    icon: Icons.bar_chart,
                  ),
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 5),
                Expanded(
                  child: _buildDashboardCard(
                    title: 'Ach Sales %',
                    value: reportData['AchSales'] ?? '0.0',
                    icon: Icons.percent,
                  ),
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 5),
                Expanded(
                  child: _buildDashboardCard(
                    title: 'Balance To Do',
                    value: reportData['BalanceToDo'] ?? '0.0',
                    icon: Icons.receipt,
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
