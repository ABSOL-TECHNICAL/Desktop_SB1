import 'package:flutter/material.dart';
import 'package:impal_desktop/features/cyberwarehosue/view/planning_indent.dart';
// import 'package:impal_desktop/features/cyberwarehosue/view/planning_indent.dart';
// import 'package:impal_desktop/features/cyberwarehosue/view/stocks_csv.dart';
import 'package:impal_desktop/features/cyberwarehosue/view/stocks_manual.dart';
import 'package:impal_desktop/features/cyberwarehosue/view/worksheet.dart';
import 'package:impal_desktop/features/cyberwarehosue/view/to_history.dart';

import 'package:impal_desktop/features/global/theme/widgets/header.dart';

class CyberStocks extends StatelessWidget {
  const CyberStocks({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlobalAppBar(title: 'Cyber Warehouse'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildOptionCard(
                  context,
                  icon: Icons.broadcast_on_home_rounded,
                  iconColor: Colors.blue,
                  title: 'Manual Adjustment',
                  description:
                      'Manually adjust surplus stock from Branch to Branch.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StocksManual(),
                      ),
                    );
                  },
                ),
                // _buildOptionCard(
                //   context,
                //   icon: Icons.file_upload,
                //   iconColor: Colors.green,
                //   title: 'CSV Upload',
                //   description: 'Upload surplus stock data via CSV files.',
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const StockCsvReports(),
                //       ),
                //     );
                //   },
                // ),
                _buildOptionCard(
                  context,
                  icon: Icons.table_chart,
                  iconColor: Colors.orange,
                  title: 'Worksheet',
                  description: 'View and manage surplus stock worksheets.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Worksheet(),
                      ),
                    );
                  },
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.storage,
                  iconColor: Colors.purple,
                  title: 'Planning Indent Screen',
                  description:
                      'Initiate and manage planning indents for Cyber Warehouse efficiently.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlanningIndent(),
                      ),
                    );
                  },
                ),
                // _buildOptionCard(
                //   context,
                //   icon: Icons.history,
                //   iconColor: Colors.red,
                //   title: 'Gst',
                //   description: 'View the history surplus stock.',
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const NewCustomerApplication(),
                //       ),
                //     );
                //   },
                // ),
                _buildOptionCard(
                  context,
                  icon: Icons.history,
                  iconColor: Colors.red,
                  title: 'History',
                  description: 'View the history surplus stock.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransferOrder(),
                      ),
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

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 300,
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
