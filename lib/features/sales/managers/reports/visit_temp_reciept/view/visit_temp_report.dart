// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_temp_reciept/controller/visit_temp_report_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_temp_reciept/widget/visit_temp_report_widgets.dart';

import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';

class VisitTempReceipt extends StatefulWidget {
  static const String routeName = '/VisitTempReceipt';

  const VisitTempReceipt({super.key});

  @override
  _VisitTempReceiptState createState() => _VisitTempReceiptState();
}

class _VisitTempReceiptState extends State<VisitTempReceipt> {
  String? selectedRecord;
  bool isCardExpanded = false; // Variable to manage card expansion
  int? expandedIndex; // Track which card is expanded
  bool isLoading = true;
  final VisitTempController visitTempController =
      Get.put(VisitTempController());
  final LoginController loginController = Get.find<LoginController>();

  final List<List<Color>> _gradients = [
    [const Color(0xFFEDFFFB), const Color(0xFFFFEBF4)], // Gradient 1
    [const Color(0xFFECEFFF), const Color(0xFFFFFAF3)], // Gradient 2
    [const Color(0xFFEDFFFB), const Color(0xFFFFEBF4)], // Gradient 1
    [const Color(0xFFECEFFF), const Color(0xFFFFFAF3)], // Gradient 2
  ];

  final Map<String, dynamic> recordType = {
    'Cash': 1,
    'Cheque': 2,
    'All': [1, 2],
  };

  @override
  void initState() {
    super.initState();
    visitTempController.fetchVisitTempReport();
  }

  void _searchReports() async {
    if (selectedRecord != null) {
      setState(() {
        isLoading = true;
      });

      if (selectedRecord == 'All') {
        visitTempController.modeOfCollection.value = 0;
        visitTempController.recordTypeList.value = [1, 2];
      } else {
        visitTempController.modeOfCollection.value =
            recordType[selectedRecord] ?? 2;
      }

      await visitTempController.fetchVisitTempReport(); // Load data on search
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

  @override
  void dispose() {
    Get.delete<VisitTempController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'View Temporary Receipt Report',
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
                      if (visitTempController.isLoading.value) {
                        return Center(child: _buildShimmerCard());
                      }

                      // Check if there are no reports after a search
                      if (visitTempController.visitTemp.isEmpty) {
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
                                        style: theme.textTheme.bodyLarge?.copyWith(
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
                        itemCount: visitTempController.visitTemp.length,
                        itemBuilder: (context, index) {
                          final report = visitTempController.visitTemp[index];
                          return VisitTempWidgets(
                            gradientColors:
                                _gradients[index % _gradients.length],
                            customerId: report.customerId,
                            // Provide a default value
                            invoiceNo: report.invoiceNo ??
                                'N/A', // Ensure no null error occurs
                            modeOfCollection:
                                report.modeOfCollection, // Handle null case
                            amount: (report.amount.isNotEmpty)
                                ? report.amount
                                : '0.00',
                            remarks:
                                report.remarks, // Handle possible null value
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
