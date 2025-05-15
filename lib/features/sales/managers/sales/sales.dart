import 'package:flutter/material.dart';
import 'package:impal_desktop/features/sales/managers/sales/newproduct/newproduct_sales.dart';
import 'package:impal_desktop/features/sales/managers/sales/salessummary/sales_summary_manager.dart';

class Sales extends StatefulWidget {
  static const String routeName = '/Sales';
  const Sales({super.key});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  bool _isHoveredCreateReport = false;
  bool _isHoveredVisitReport = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title:
             Text('Sales Overview', style:theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              _buildReportCard(
                context,
                Icons.analytics,
                'Sales Summary',
                SalesSummaryManager(),
                Colors.blue,
                0,
              ),
              _buildReportCard(
                context,
                Icons.add_box,
                'New Product Sales',
                ProductSalesSummary(),
                Colors.green,
                1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget destination,
    Color iconColor,
    int cardIndex,
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
        onEnter: (_) {
          setState(() {
            if (cardIndex == 0) _isHoveredCreateReport = true;
            if (cardIndex == 1) _isHoveredVisitReport = true;
          });
        },
        onExit: (_) {
          setState(() {
            if (cardIndex == 0) _isHoveredCreateReport = false;
            if (cardIndex == 1) _isHoveredVisitReport = false;
          });
        },
        child: AnimatedScale(
          scale: _getScale(cardIndex),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              width: 250,
              height: 150,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(0, 5),
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

  double _getScale(int cardIndex) {
    if (cardIndex == 0) return _isHoveredCreateReport ? 1.1 : 1.0;
    if (cardIndex == 1) return _isHoveredVisitReport ? 1.1 : 1.0;

    return 1.0;
  }
}
