import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/new_customer/view/new_customers.dart';
import 'package:shimmer/shimmer.dart';

class CustomerStatsPieChart extends StatelessWidget {
  final int monthlyCount;
  final int yearlyCount;

  const CustomerStatsPieChart({
    super.key,
    required this.monthlyCount,
    required this.yearlyCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasData = monthlyCount > 0 || yearlyCount > 0;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Stats',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 90,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewCustomers()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'View',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pie chart or empty state
          Expanded(
            child: hasData
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 6,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                      sections: [
                        PieChartSectionData(
                          value: monthlyCount.toDouble(),
                          color: Colors.blueAccent,
                          title: monthlyCount.toString(),
                          radius: 50,
                          titleStyle: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: yearlyCount.toDouble(),
                          color: Colors.redAccent,
                          title: yearlyCount.toString(),
                          radius: 50,
                          titleStyle: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Shimmer.fromColors(
                            baseColor: const Color.fromARGB(255, 53, 51, 51),
                            highlightColor: Colors.white,
                            child: Icon(
                              Icons.search_off,
                              size: 110,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Shimmer.fromColors(
                            baseColor: const Color.fromARGB(255, 53, 51, 51),
                            highlightColor: Colors.white,
                            child: Text(
                              'Currently, there are no new customers.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: Color.fromARGB(255, 10, 10, 10),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Legend (only if there's data)
          if (hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(
                    label: 'New Customer This Month',
                    count: monthlyCount,
                    color: Colors.blueAccent,
                  ),
                  _legendItem(
                    label: 'New Customer This Year',
                    count: yearlyCount,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required String label,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
