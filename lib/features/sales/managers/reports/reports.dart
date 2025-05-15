import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/view/planning_indent.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/create_report/create_report.dart';
import 'package:impal_desktop/features/sales/managers/reports/temp_receipt/temp_receipt.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report/view/visit_report.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report_manager/view/visit_report_m.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_temp_reciept/view/visit_temp_report.dart';

class Reports extends StatefulWidget {
  static const String routeName = '/Reports';
  const Reports({super.key});

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  int _hoveredIndex = -1;
  final employee = Get.find<LoginController>().employeeModel;
  bool get isManager => employee.isManager ?? false;
  bool get isEDP => employee.isEdp ?? false;
  bool get isSalesman => employee.isSalesman ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text('Reports', style: theme.textTheme.bodyLarge?.copyWith(      
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
                  _buildReportCard(context, Icons.add_box_outlined,
                      'Generate Report', CreateReport(), Colors.blue, 0),
                  if (isManager)
                    _buildReportCard(context, Icons.storage, 'Planning Indent',
                        PlanningIndent(), Colors.purple, 7),
                  if (!isManager)
                    _buildReportCard(context, Icons.insert_chart_outlined,
                        'Visit Summary', VisitReport(), Colors.green, 2),
                  _buildReportCard(
                      context,
                      Icons.receipt_long,
                      'Generate Temporary Receipt',
                      TempReceipt(),
                      Colors.orange,
                      3),
                  _buildReportCard(
                      context,
                      Icons.business,
                      "Temporary Receipt Summary",
                      VisitTempReceipt(),
                      Colors.green,
                      4),
                  if (isManager)
                    _buildReportCard(context, Icons.summarize,
                        'View Visit Summary', VisitReportM(), Colors.red, 5),
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
                    )
                   
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
