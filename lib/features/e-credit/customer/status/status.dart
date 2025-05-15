import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/header.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/controller/approver_controller.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/controller/creditlimit_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/status/controller/statuscontroller.dart';

class Status extends StatefulWidget {
  static const String routeName = '/Status';

  const Status({super.key});

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> with SingleTickerProviderStateMixin {
  final CreditlimitController creditController =
      Get.put(CreditlimitController());
  final ApproverController approverController = Get.put(ApproverController());
  final StatusController statusController = Get.put(StatusController());

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchStatus();
  }

  void _fetchStatus() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await statusController.fetchApplicationStatus();

    if (!mounted) return;
    _sortFilteredList();

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _sortFilteredList() {
    statusController.applicationstatus.sort((a, b) {
      if (a.applicationDate == null && b.applicationDate == null) return 0;
      if (a.applicationDate == null) return 1;
      if (b.applicationDate == null) return -1;
      return b.applicationDate!.compareTo(a.applicationDate!);
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: GlobalAppBar(title: 'Application Status'),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  _fetchStatus();
                  AppSnackBar.success(
                    message: "Application details refreshed successfully.",
                  );
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        const Color.fromARGB(255, 45, 5, 248).withOpacity(0.9),
                    border: Border.all(
                      color: const Color.fromARGB(255, 231, 230, 223),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(2, 2),
                      ),
                      BoxShadow(
                        color: const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.7),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.refresh, color: Colors.white, size: 15),
                ),
              ),
            ],
          ),
          // Custom Tab Bar
          _buildCustomTabBar(),
          // Horizontal scroll buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _scrollLeft,
                icon: const Icon(Icons.arrow_circle_left, size: 30),
              ),
              IconButton(
                onPressed: _scrollRight,
                icon: const Icon(Icons.arrow_circle_right, size: 30),
              ),
            ],
          ),
          // Tab view for tables
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatusTable('1'),
                _buildStatusTable('2'),
                _buildStatusTable('3'),
                _buildStatusTable('All'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Column(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(3),
            child: Obx(() {
              int pendingCount = statusController.applicationstatus
                  .where((app) => app.approvalStatusId == '1')
                  .length;
              int approvedCount = statusController.applicationstatus
                  .where((app) => app.approvalStatusId == '2')
                  .length;
              int rejectedCount = statusController.applicationstatus
                  .where((app) => app.approvalStatusId == '3')
                  .length;
              int allCount = statusController.applicationstatus.length;

              return TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF6B71FF),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                tabs: [
                  _buildFixedWidthTab('Pending ($pendingCount)'),
                  _buildFixedWidthTab('Approved ($approvedCount)'),
                  _buildFixedWidthTab('Rejected ($rejectedCount)'),
                  _buildFixedWidthTab('All ($allCount)'),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFixedWidthTab(String text) {
    return Tab(
      child: SizedBox(
        width: 100,
        child: Center(child: Text(text)),
      ),
    );
  }

  Widget _buildStatusTable(String filter) {
    return Obx(() {
      var filteredList = filter == 'All'
          ? statusController.applicationstatus
          : statusController.applicationstatus
              .where((app) => app.approvalStatusId == filter)
              .toList();

      return _isLoading
          ? _buildShimmerEffect()
          : Container(
              padding:
                  const EdgeInsets.all(12.0), // Padding inside the container
              margin: const EdgeInsets.symmetric(
                  horizontal: 10), // Margin outside the container
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Soft shadow effect
                  ),
                ],
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: DataTableTheme(
                      data: DataTableThemeData(
                        dataRowHeight: 40,
                        headingRowHeight: 45,
                      ),
                      child: DataTable(
                        headingRowHeight: 40,
                        dataRowHeight: 40,
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => const Color(0xFF6B71FF),
                        ),
                        columns: _buildColumns(filter),
                        rows: filteredList.isNotEmpty
                            ? filteredList
                                .map((app) => _buildDataRow(app, filter))
                                .toList()
                            : [_buildEmptyRow()],
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  List<DataColumn> _buildColumns(String filter) {
    return [
      DataColumn(label: _buildColumnText('Customer Code')),
      DataColumn(label: _buildColumnText('Customer')),
      DataColumn(label: _buildColumnText('Branch')),
      DataColumn(label: _buildColumnText('Application Date')),
      DataColumn(label: _buildColumnText('Validity Indicator')),
      DataColumn(label: _buildColumnText('Existing Credit Limit')),
      DataColumn(label: _buildColumnText('Enhance Credit')),
      DataColumn(label: _buildColumnText('Old Limit')),
      DataColumn(label: _buildColumnText('Approver')),
      DataColumn(label: _buildColumnText('Reject Reason')),
      DataColumn(label: _buildColumnText('Mode of Payment')),
    ];
  }

  DataRow _buildDataRow(app, String filter) {
    return DataRow(cells: [
      DataCell(Text(app.customercode ?? 'N/A')),
      DataCell(Text(app.customername ?? 'N/A')),
      DataCell(Text(app.branchTxt ?? 'N/A')),
      DataCell(Text(app.applicationDate ?? 'N/A')),
      DataCell(Text(app.vaidateIndicatortxt ?? 'N/A')),
      DataCell(Text(app.existingCreditLimit?.toStringAsFixed(2) ?? '0.00')),
      DataCell(Text(app.enhanceCredit?.toString() ?? '0')),
      DataCell(Text(app.oldLimit?.toString() ?? '0')),
      DataCell(Text(app.employeeID ?? 'N/A')),
      DataCell(Text(app.reason ?? 'N/A')),
      DataCell(Text(app.modeOfCredit ?? 'N/A')),
    ]);
  }

  DataRow _buildEmptyRow() {
    return const DataRow(cells: [
      DataCell(Text('No data available')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('')),
    ]);
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: List.generate(
                  9,
                  (colIndex) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Container(
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColumnText(String text) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        // style: const TextStyle(
        //     fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
      ),
    );
  }
}
