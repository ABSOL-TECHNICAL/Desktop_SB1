import 'package:flutter/material.dart';
import 'package:impal_desktop/features/sales/managers/reports/create_report/create_report.dart';
import 'package:impal_desktop/features/sales/managers/reports/temp_receipt/temp_receipt.dart';

class MergeReportsPage extends StatelessWidget {
  const MergeReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Temp Receipt & Create Report',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF161717),
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarHeight: 40,
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(kToolbarHeight + 5), // extra 10 for spacing
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //SizedBox(height: 10), // space between AppBar and TabBar
                Container(
                  color: const Color.fromARGB(255, 85, 94, 255),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        const Color.fromRGBO(158, 158, 158, 1),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                          width: 5.0,
                          color: const Color.fromARGB(255, 239, 187, 45)),
                      insets: EdgeInsets.symmetric(horizontal: 120.0),
                    ),
                    tabs: const [
                      Tab(text: 'Temp Receipt'),
                      Tab(text: 'Create Report'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            TempReceipt(), // Your existing TempReceipt widget
            CreateReport(), // Your existing CreateReport widget
          ],
        ),
      ),
    );
  }
}
