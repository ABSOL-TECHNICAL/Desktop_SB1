import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/status/controller/approver_status_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/header.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ApprovalStatus extends StatefulWidget {
  static const String routeName = '/ApprovalStatus';

  const ApprovalStatus({super.key});

  @override
  _ApprovalStatusState createState() => _ApprovalStatusState();
}

class _ApprovalStatusState extends State<ApprovalStatus>
    with SingleTickerProviderStateMixin {
  final ApprovalStatusController approvalstatusController =
      Get.put(ApprovalStatusController());

  late TabController _tabController;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchApprovalStatus();
  }

  @override
  void dispose() {
    approvalstatusController.fetchApproverBranch();
    approvalstatusController.fetchApproverStatusData();
    super.dispose();
  }

  void _fetchApprovalStatus() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await approvalstatusController.fetchApproverStatusData();
_debugCheckStatusData();
    if (!mounted) return;
    _sortFilteredList();

    setState(() => _isLoading = false);
  }
  void _debugCheckStatusData() {
  if (approvalstatusController.statusData.isNotEmpty) {
    print('First item status ID: ${approvalstatusController.statusData.first.approvalStatusid}');
    print('First item status type: ${approvalstatusController.statusData.first.approvalStatusid.runtimeType}');
    
    // Count each status type
    int pending = approvalstatusController.statusData.where((e) => e.approvalStatusid == '1').length;
    int approved = approvalstatusController.statusData.where((e) => e.approvalStatusid == '2').length;
    int rejected = approvalstatusController.statusData.where((e) => e.approvalStatusid == '3').length;
    
    print('Actual counts - Pending: $pending, Approved: $approved, Rejected: $rejected');
  }
}

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      // Try parsing as ISO format first (e.g., "2023-12-31T12:00:00Z")
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        // Try parsing with common date formats
        List<String> possibleFormats = [
          "dd-MM-yyyy HH:mm:ss",
          "dd/MM/yyyy HH:mm:ss",
          "yyyy-MM-dd HH:mm:ss",
          "dd-MM-yyyy",
          "dd/MM/yyyy",
          "yyyy-MM-dd"
        ];

        for (var format in possibleFormats) {
          try {
            return DateFormat(format).parse(dateString);
          } catch (e) {
            continue;
          }
        }
        return null;
      } catch (e) {
        return null;
      }
    }
  }

  void _sortFilteredList() {
    DateTime today = DateTime.now();

    approvalstatusController.statusData.sort((a, b) {
      DateTime? dateA = _parseDate(a.applicationdate);
      DateTime? dateB = _parseDate(b.applicationdate);

      // Handle null cases
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // Move null dates to bottom
      if (dateB == null) return -1; // Move null dates to bottom

      // Check if dates are today
      bool isTodayA = _isSameDay(dateA, today);
      bool isTodayB = _isSameDay(dateB, today);

      if (isTodayA && isTodayB) {
        // Both are today - sort by time (newest first)
        return dateB.compareTo(dateA);
      } else if (isTodayA) {
        return -1; // Only A is today - put first
      } else if (isTodayB) {
        return 1; // Only B is today - put first
      } else {
        // Neither is today - sort by date (newest first)
        return dateB.compareTo(dateA);
      }
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
// Replace your current search-related methods with these:

// Update your search-related methods:

  String searchQuery = '';

  List<dynamic> _filteredApplications(String filter) {
  var baseList = filter == 'All'
      ? approvalstatusController.statusData
      : approvalstatusController.statusData
          .where((app) => app.approvalStatusid?.toString().trim() == filter.trim())
          .toList();

  if (searchQuery.isEmpty) return baseList;

  return baseList.where((app) {
    return (app.customercode?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
        (app.customername?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
        (app.branchTxt?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
        (app.branch?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
  }).toList();
}

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
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
      resizeToAvoidBottomInset: false,
      appBar: GlobalAppBar(title: 'Approval Status'),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  _fetchApprovalStatus();
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
                        width: 1.5),
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
          _buildCustomTabBar(),
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
        // Search field above the tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: GlobalSearchField(
              hintText: 'Search Customers...'.tr,
              onChanged: _onSearchChanged,
            ),
          ),
        ),
        const SizedBox(height: 5),

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
              final statusData = approvalstatusController.statusData.value;
            
            int pendingCount = _filteredApplications('1').length;
            int approvedCount = _filteredApplications('2').length;
            int rejectedCount = _filteredApplications('3').length;
            int allCount = statusData.length;
 print('Counts - Pending: $pendingCount, Approved: $approvedCount, Rejected: $rejectedCount');
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
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Tab(
      child: SizedBox(
        width: 150,
        child: Center(
          child: Text(
            text,
              // style:theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            // style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTable(String filter) {
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
  return Container(
     width: MediaQuery.of(context).size.width * 0.7,
          height: 450,
    padding: const EdgeInsets.all(5),
       decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Obx(() {
      var filteredList = _filteredApplications(filter); // Apply search filter
 
      return _isLoading
          ? _buildShimmerEffect()
          : Column(
              children: [
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
                SizedBox(
                  height: 400, // Adjust the height to fit within the container
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width * 0.9, // Adjust width dynamically
                        ),
                        child: DataTable(
                          headingRowHeight: 40,
                          dataRowHeight: 40,
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFF6B71FF)),
                          columns: _buildColumns(),
                          rows: filteredList.isNotEmpty
                              ? filteredList.map((app) => _buildDataRow(app)).toList()
                              : [_buildEmptyRow()],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
    }),
  );
}

  Widget _buildShimmerEffect() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 40,
            color: Colors.white,
            child: Row(
              children: List.generate(9, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: 40,
                  color: Colors.white,
                  child: Row(
                    children: List.generate(9, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 20,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(label: _buildColumnText('Customer Code')),
      DataColumn(label: _buildColumnText('Customer')),
      DataColumn(label: _buildColumnText('Branch')),
      DataColumn(label: _buildColumnText('Application Date')),
      DataColumn(label: _buildColumnText('Validity Indicator')),
      DataColumn(label: _buildColumnText('Existing Credit Limit')),
      DataColumn(label: _buildColumnText('Enhance Credit')),
      DataColumn(label: _buildColumnText('Employee')),
      DataColumn(label: _buildColumnText('Reject Reason')),
      DataColumn(label: _buildColumnText('Mode')),
    ];
  }

  DataRow _buildDataRow(app) {
    return DataRow(cells: [
      DataCell(Text(app.customercode ?? 'N/A')),
      DataCell(Text((app.customername ?? 'N/A').toUpperCase())),
      DataCell(Text(app.branchTxt ?? 'N/A')),
      DataCell(Text(app.applicationdate ?? 'N/A')),
      DataCell(Text(app.validateIndicatortxt ?? 'N/A')),
      DataCell(Text(app.creditLimit ?? 'N/A')),
      DataCell(Text(app.enhanceCredit.toString())),
      DataCell(Text(app.eDPName ?? 'N/A')),
      DataCell(Text(app.reason ?? 'N/A')),
      DataCell(Text(app.modeofcredit ?? 'N/A')),
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
    ]);
  }

  Widget _buildColumnText(String text) {
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Text(
        text,
         style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
        // style: const TextStyle(
        //     fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
      ),
    );
  }
}
