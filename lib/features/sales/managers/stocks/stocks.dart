import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/all_branch_stocks/all_branch_stocks.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/material_arrival.dart';
import 'package:impal_desktop/features/sales/managers/stocks/own_branch_stocks/view/own_branch_stocks.dart';
import 'package:impal_desktop/features/sales/managers/stocks/own_branch_stocks_with_Estimate/view/own_branch_stocks_with_estimate.dart';
import 'package:impal_desktop/features/sales/managers/stocks/surplus_stocks_manager/surplus_stocks_manager.dart';

class Stocks extends StatefulWidget {
  static const String routeName = '/Stocks';
  const Stocks({super.key});

  @override
  _StocksState createState() => _StocksState();
}

class _StocksState extends State<Stocks> {
  int _hoveredIndex = -1;
  final employee = Get.find<LoginController>().employeeModel;
  bool get isManager => employee.isManager ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks Overview',
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
                  _buildReportCard(context, Icons.fiber_new, 'New Arrival',
                      MaterialArrival(), Colors.blue, 0),
                  _buildReportCard(
                      context,
                      Icons.signal_cellular_alt_sharp,
                      'All Branch Stocks',
                      AllBranchStocksPage(),
                      Colors.deepPurple,
                      5),
                  _buildReportCard(context, Icons.receipt, 'Own Branch Stocks',
                      BranchStocksPage(), Colors.green, 1),
                  _buildReportCard(context, Icons.request_quote, 'Own Branch Stocks With Estimate',
                      OwnBranchStocksWithEstimatePage(), Colors.deepPurple, 4),
                  _buildReportCard(context, Icons.receipt, 'Surplus Stocks',
                      SurplusStocksM(), Colors.red, 3),

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
