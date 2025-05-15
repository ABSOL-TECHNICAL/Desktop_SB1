import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:impal_desktop/features/dashboard/controllers/dashboard_controller.dart';

class CombinedBilledReport extends StatefulWidget {
  const CombinedBilledReport({super.key});

  @override
  _CombinedBilledReportState createState() => _CombinedBilledReportState();
}

class _CombinedBilledReportState extends State<CombinedBilledReport> {
  int touchedIndex = -1;

  final DashboardController dashboardController =
      Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'New Product Sales Report For Current Month',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 50),
          // Wrap only the parts that need to reactively update
          Obx(() {
            int billedCount = dashboardController.billCustomer.length;
            int nonBilledCount = dashboardController.nonbillCustomer.length;

            return SizedBox(
              height: 90,
              width: 60,
              child: _buildDonutChart(billedCount, nonBilledCount),
            );
          }),
          const SizedBox(height: 10),
          // Wrap only the legend in Obx
          Obx(() {
            return _buildLegend();
          }),
        ],
      ),
    );
  }

  Widget _buildDonutChart(int billedCount, int nonBilledCount) {
    if (billedCount == 0 && nonBilledCount == 0) {
      return Center(child: Text('No data available'));
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 30,
        sections: showingSections(billedCount, nonBilledCount),
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      int billedCount, int nonBilledCount) {
        final theme = Theme.of(context);
    return [
      PieChartSectionData(
        value: billedCount.toDouble(),
        title: billedCount.toString(),
        color: Colors.green,
        radius: touchedIndex == 0 ? 60 : 50,
        titleStyle: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: nonBilledCount.toDouble(),
        title: nonBilledCount.toString(),
        color: Colors.red,
        radius: touchedIndex == 1 ? 60 : 50,
        titleStyle: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Billed Customers', Colors.green),
        const SizedBox(width: 20),
        _buildLegendItem('Non-Billed Customers', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text,
            style:theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
