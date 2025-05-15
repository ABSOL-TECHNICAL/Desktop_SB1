import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/target_vs_actual_sales_report/controllers/target_vs_actual_controller.dart';

class TargetVsActualPie extends StatefulWidget {
  const TargetVsActualPie({super.key});

  @override
  _TargetVsActualPieState createState() => _TargetVsActualPieState();
}

class _TargetVsActualPieState extends State<TargetVsActualPie> {
  final TargetVsActualController targetVsActualController =
      Get.put(TargetVsActualController());

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, String> reportData) {
    double target = double.tryParse(reportData['Target'] ?? '0.0') ?? 0.0;
    double daySales = double.tryParse(reportData['DaySales'] ?? '0.0') ?? 0.0;
    double cumulativeSales =
        double.tryParse(reportData['CumulativeSales'] ?? '0.0') ?? 0.0;
    double achSales = double.tryParse(reportData['AchSales'] ?? '0.0') ?? 0.0;
    double billToDo = double.tryParse(reportData['BillToDo'] ?? '0.0') ?? 0.0;

    // Avoid zero values by setting a minimum threshold
    double minValue = 1.0; // Adjust this as needed

    return [
      if (target > 0)
        PieChartSectionData(
          color: Colors.blue,
          value: target < minValue ? minValue : target,
          radius: 50,
          title: target.toStringAsFixed(1),
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (daySales > 0)
        PieChartSectionData(
          color: Colors.green,
          value: daySales < minValue ? minValue : daySales,
          radius: 50,
          title: daySales.toStringAsFixed(1),
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (cumulativeSales > 0)
        PieChartSectionData(
          color: Colors.orange,
          value: cumulativeSales < minValue ? minValue : cumulativeSales,
          radius: 50,
          title: cumulativeSales.toStringAsFixed(1),
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      if (achSales > 0)
        PieChartSectionData(
          color: Colors.purple,
          value: achSales < minValue ? minValue : achSales,
          radius: 50,
          title: achSales.toStringAsFixed(1),
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (billToDo > 0)
        PieChartSectionData(
          color: Colors.red,
          value: billToDo < minValue ? minValue : billToDo,
          radius: 50,
          title: billToDo.toStringAsFixed(1),
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final reportData = targetVsActualController.reportData;
      final reportDataString =
          reportData.map((key, value) => MapEntry(key, value.toString()));

      // Check if data is zero, show "No Data Available" message
      if (reportDataString['Target'] == '0.0' &&
          reportDataString['DaySales'] == '0.0' &&
          reportDataString['CumulativeSales'] == '0.0' &&
          reportDataString['AchSales'] == '0.0' &&
          reportDataString['BillToDo'] == '0.0') {
        return Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 16), // Reduced margin
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Reduced padding
            child: Column(
              children: [
                 Text(
                  'Target vs Actual Sales Report For Current Month',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12), // Reduced space between text
                 Text(
                  'No Data Available',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 16), // Reduced margin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced padding
          child: Column(
            children: [
               Text(
                'Target vs Actual Sales Report For Current Month',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(reportDataString),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(Colors.blue,
                          'Target: ${reportDataString['Target'] ?? '-'}'),
                      _buildLegendItem(Colors.green,
                          'Day Sales: ${reportDataString['DaySales'] ?? '-'}'),
                      _buildLegendItem(Colors.orange,
                          'Cumulative: ${reportDataString['CumulativeSales'] ?? '-'}'),
                      _buildLegendItem(Colors.purple,
                          'Ach Sales %: ${reportDataString['AchSales'] ?? '-'}'),
                      _buildLegendItem(Colors.red,
                          'Balance To Do: ${reportDataString['BillToDo'] ?? '-'}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLegendItem(Color color, String data) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 10),
        Text(data,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
