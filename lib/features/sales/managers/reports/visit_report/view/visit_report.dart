// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report/controller/visit_report_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report/widget/visit_report_widgets.dart';

class VisitReport extends StatefulWidget {
  static const String routeName = '/VisitReport';

  const VisitReport({super.key});

  @override
  _VisitReportState createState() => _VisitReportState();
}

class _VisitReportState extends State<VisitReport> {
  String? selectedRecord;
  bool isCardExpanded = false; // Variable to manage card expansion
  int? expandedIndex; // Track which card is expanded
  bool isLoading = true;
  final VisitReportController visitReportController =
      Get.put(VisitReportController());
  final LoginController loginController = Get.find<LoginController>();
  String fromDate = 'Choose From Date';
  String toDate = 'Choose To Date';

  final List<List<Color>> _gradients = [
    [const Color(0xFFEDFFFB), const Color(0xFFFFEBF4)], // Gradient 1
    [const Color(0xFFECEFFF), const Color(0xFFFFFAF3)], // Gradient 2
    [const Color(0xFFEDFFFB), const Color(0xFFFFEBF4)], // Gradient 1
    [const Color(0xFFECEFFF), const Color(0xFFFFFAF3)], // Gradient 2
  ];

  final Map<String, dynamic> recordType = {
    'Payment Collection': 1,
    'General': 2,
    'Others': 3,
    'Sales Order': 4,
    'All': [1, 2, 3, 4],
  };

  @override
  void initState() {
    super.initState();
    visitReportController.fetchVisitReportsdefault();
  }

  void _searchReports() async {
    if (selectedRecord != null) {
      setState(() {
        isLoading = true;
      });

      if (selectedRecord == 'All') {
        visitReportController.recordType.value = 0;
        visitReportController.recordTypeList.value = [1, 2, 3, 4];
      } else {
        visitReportController.recordType.value =
            recordType[selectedRecord] ?? 2;
      }

      String salesRepId = loginController.employeeModel.salesRepId ?? '';
      visitReportController.salesRepId.value = int.tryParse(salesRepId) ?? 0;

      if (fromDate != 'Choose Date' && toDate != 'Choose Date') {
        visitReportController.fromDate.value = fromDate;
        visitReportController.toDate.value = toDate;
      } else {
        AppSnackBar.alert(
          message: "Please select both From Date and To Date.",
        );
        setState(() {
          isLoading = false; // Stop loading if failed
        });
        return; // Exit the method early to prevent errors
      }

      await visitReportController.fetchVisitReports(); // Load data on search
      setState(() {
        isLoading = false; // Stop loading
      });
    } else {
      // Handle case when no record type is selected
      AppSnackBar.alert(
        message: "Please select a Record Type.",
      );
    }
  }

  Future<void> _pickFromDate() async {
    DateTime pickedDate;
    if (fromDate != 'Choose From Date') {
      pickedDate = DateFormat('dd/MM/yyyy').parse(fromDate);
    } else {
      pickedDate = DateTime.now();
    }

    DateTime? newPickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (newPickedDate != null) {
      _onFromDatePicked(newPickedDate);
    }
  }

  Future<void> _pickToDate() async {
    DateTime pickedDate;
    if (toDate != 'Choose To Date') {
      pickedDate = DateFormat('dd/MM/yyyy').parse(toDate);
    } else {
      pickedDate = DateTime.now();
    }

    DateTime? newPickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(2000), // Ensure a valid date
      lastDate: DateTime(2100),
    );

    if (newPickedDate != null) {
      _onToDatePicked(newPickedDate);
    }
  }

  void _onFromDatePicked(DateTime pickedDate) {
    if (toDate != 'Choose To Date' &&
        pickedDate.isAfter(DateFormat('dd/MM/yyyy').parse(toDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("From Date cannot be later than To Date.")),
      );
      return;
    }

    setState(() {
      fromDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void _onToDatePicked(DateTime pickedDate) {
    if (fromDate != 'Choose From Date' &&
        pickedDate.isBefore(DateFormat('dd/MM/yyyy').parse(fromDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("To Date cannot be earlier than From Date.")),
      );
      return;
    }

    setState(() {
      toDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  @override
  void dispose() {
    Get.delete<VisitReportController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Visit Report',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: screenWidth,
            padding: const EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.only(left: 200, right: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isDarkMode
                          ? LinearGradient(
                              colors: [
                                  Colors.blueGrey.withOpacity(0.3),
                                  Colors.blueGrey.withOpacity(0.3)
                                ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : const LinearGradient(
                              colors: [Color(0xFF6B71FF), Color(0xFF57AEFE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Record Type',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 0),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.blueGrey.shade900
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: isDarkMode ? 0.8 : 0.2,
                                        ),
                                      ),
                                      constraints:
                                          const BoxConstraints(maxHeight: 50),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: selectedRecord,
                                          hint: Text(
                                            'Select Record Type', // You can change this to your desired hint
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontSize: 14,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedRecord = newValue;
                                            });
                                          },
                                          items: recordType.keys
                                              .map<DropdownMenuItem<String>>(
                                                  (String key) {
                                            return DropdownMenuItem<String>(
                                              value: key,
                                              child: Text(
                                                key,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontSize: 14,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          dropdownColor: isDarkMode
                                              ? Colors.blueGrey.shade900
                                              : Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('From Date',
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: _pickFromDate,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.blueGrey.shade900
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  color: Colors.grey),
                                              const SizedBox(width: 4.0),
                                              Text(fromDate,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('To Date',
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: _pickToDate,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.blueGrey.shade900
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  color: Colors.grey),
                                              const SizedBox(width: 4.0),
                                              Text(toDate,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: _searchReports,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 251, 134, 45),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(90)),
                                  minimumSize: const Size(50, 40),
                                ),
                                child: const Icon(Icons.search,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      if (visitReportController.isLoading.value) {
                        return Center(child: _buildShimmerCard());
                      }

                      // Check if there are no reports after a search
                      if (visitReportController.visitReports.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Replace with your asset image path
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Shimmer.fromColors(
                                      baseColor:
                                          const Color.fromARGB(255, 53, 51, 51),
                                      highlightColor: Colors.white,
                                      child: Icon(
                                        Icons.error_outline,
                                        size: 130,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Shimmer.fromColors(
                                      baseColor:
                                          const Color.fromARGB(255, 53, 51, 51),
                                      highlightColor: Colors.white,
                                      child: Text(
                                        'Please search for the record type, and view the details',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: visitReportController.visitReports.length,
                        itemBuilder: (context, index) {
                          final report =
                              visitReportController.visitReports[index];
                          return VisitReportWidget(
                            gradientColors:
                                _gradients[index % _gradients.length],
                            personMet: report.personMet,
                            customer: report.customer,
                            paymentMethod: report.paymentMethod,
                            amount: report.amount.isNotEmpty
                                ? report.amount
                                : '0.00',
                            reportedOn: report.reportedOn,
                            nextVisitOn: report.nextVisitDate,
                            remarks: report.remarks,
                            isExpanded: expandedIndex == index,
                            onTap: () {
                              setState(() {
                                expandedIndex =
                                    expandedIndex == index ? null : index;
                              });
                            },
                          );
                        },
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildShimmerCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.grey[700]!, Colors.grey[700]!]
                    : [Colors.grey[300]!, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.grey[700]!
                      : const Color.fromARGB(255, 214, 213, 213)
                          .withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 150,
                    child: ShimmerCard(height: 20, borderRadius: null),
                  ),
                  const SizedBox(
                    width: 180,
                    child: ShimmerCard(height: 15, borderRadius: null),
                  ),
                  _buildShimmerRow(),
                  _buildShimmerRow(),
                  _buildShimmerRow(),
                  _buildShimmerRow(),
                  _buildShimmerRow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerRow() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 150,
                    height: 20,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                const SizedBox(width: 40),
                Container(
                    width: 110,
                    height: 20,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                    width: 80,
                    height: 10,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                const SizedBox(width: 110),
                Container(
                    width: 50,
                    height: 10,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
