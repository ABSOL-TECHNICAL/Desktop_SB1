import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/sales_executive_controller.dart';
import 'package:impal_desktop/features/global/theme/model/sales_executive_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report_manager/controller/visit_report_m_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report_manager/widget/visit_report_m_widgets.dart';

class VisitReportM extends StatefulWidget {
  static const String routeName = '/VisitReportM';

  const VisitReportM({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VisitReportMState createState() => _VisitReportMState();
}

class _VisitReportMState extends State<VisitReportM> {
  bool isLoading = true;
  bool isSearchLoading = false;
  String fromDate = '';
  String toDate = '';
  String? selectedRecord;
  int? expandedIndex;
  // String? selectedSE;
  Rx<String?> selectedSE = Rx<String?>(null);
  RxList<SalesExecutiveModel> salesExecutives = <SalesExecutiveModel>[].obs;
  final LoginController login = Get.find<LoginController>();
  final LoginController loginController = Get.find<LoginController>();

  final SalesExecutiveController seController =
      Get.put(SalesExecutiveController());
  final VisitReportMController visitReportMController =
      Get.put(VisitReportMController());

  List<String> get salesExecutiveName {
    return seController.salesExecutiveController
        .map((item) => item['SalesManName'].toString())
        .toList();
  }

  Future<String?> salesExecutiveId(String salesExecutiveName) async {
    final selectedSEDetails = seController.salesExecutiveController.firstWhere(
        (item) => item['SalesManName'] == salesExecutiveName,
        orElse: () => null);

    return selectedSEDetails?['SalesManID'];
  }

  @override
  void initState() {
    super.initState();

    visitReportMController.fetchVisitReportsdefault();
    seController.fetchSalesExecutives();
    DateTime currentDate = DateTime.now();
    toDate = DateFormat('dd/MM/yyyy').format(currentDate);
    DateTime firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    fromDate = DateFormat('dd/MM/yyyy').format(firstDayOfMonth);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _onSearchButtonPressed() {
    setState(() {
      isSearchLoading = true;
    });

    // Get the selected values and fetch visit reports
    visitReportMController.fromDate.value = fromDate;
    visitReportMController.toDate.value = toDate;

    salesExecutiveId(selectedSE.value ?? '').then((salesExecId) {
      // Check if salesExecId is null, then default to 0 or handle accordingly
      if (salesExecId != null) {
        visitReportMController.salesExecutiveId.value =
            int.tryParse(salesExecId) ?? 0;
      } else {
        visitReportMController.salesExecutiveId.value =
            0; // or any default value
      }

      // String salesRepId = loginController.employeeModel.salesRepId ?? '';
      // visitReportMController.salesRepId.value = int.tryParse(salesRepId) ?? 0;

      // Ensure the record type value is fetched correctly
      visitReportMController.recordType.value = recordType[selectedRecord] ?? 0;

      // Retrieve the location from the login model
      String location = login.employeeModel.location!.toString();

      // Fetch visit reports using the updated parameters
      visitReportMController.fetchVisitReports(location).whenComplete(() {
        setState(() {
          isSearchLoading = false; // Stop the loading indicator
        });
      });
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _pickFromDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('dd/MM/yyyy').parse(fromDate),
      firstDate: DateTime(2000),
      lastDate: DateFormat('dd/MM/yyyy').parse(toDate),
    );

    if (pickedDate != null) {
      _onFromDatePicked(pickedDate);
    }
  }

  Future<void> _pickToDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('dd/MM/yyyy').parse(toDate),
      firstDate: DateFormat('dd/MM/yyyy').parse(fromDate),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _onToDatePicked(pickedDate);
    }
  }

  void _onFromDatePicked(DateTime pickedDate) {
    DateTime toDateTime = DateFormat('dd/MM/yyyy').parse(toDate);

    if (pickedDate.isAfter(toDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("From Date cannot be later than To Date.")),
      );
      return;
    }

    setState(() {
      fromDate = formatDate(pickedDate);
    });
  }

  void _onToDatePicked(DateTime pickedDate) {
    DateTime fromDateTime = DateFormat('dd/MM/yyyy').parse(fromDate);

    if (pickedDate.isBefore(fromDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("To Date cannot be earlier than From Date.")),
      );
      return;
    }

    setState(() {
      toDate = formatDate(pickedDate);
    });
  }

  @override
  void dispose() {
    Get.delete<VisitReportMController>();
    super.dispose();
  }

  final Map<String, int> recordType = {
    'Payment Collection': 1,
    'General': 2,
    'Others': 3,
  };

  final List<List<Color>> _gradients = [
    [const Color(0xFFEDFFFB), const Color(0xFFFFEBF4)], // Gradient 1
    [const Color(0xFFECEFFF), const Color(0xFFFFFAF3)], // Gradient 2
    [const Color(0xFFEDFFFB), const Color(0xFFFFEBF4)], // Gradient 1
    [const Color(0xFFECEFFF), const Color(0xFFFFFAF3)], // Gradient 2
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'View Visit Report',
          style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      body: Material(
          child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: screenWidth,
                padding: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 150, right: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 45),

                      const SizedBox(height: 5),
                      isLoading
                          ? ShimmerCard(
                              height: 150,
                              borderRadius: BorderRadius.circular(16),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: isDarkMode
                                    ? LinearGradient(
                                        colors: [
                                          Colors.blueGrey.withOpacity(0.3),
                                          Colors.blueGrey.withOpacity(0.3)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF6B71FF),
                                          Color(0xFF57AEFE)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() {
                                          final salesExecutivesNames =
                                              salesExecutiveName; // Extract names
                                          return _buildDropdownField1(
                                            label: 'Choose',
                                            hintText:
                                                'Select Sales Executive Name...',
                                            value: selectedSE.value,
                                            items:
                                                salesExecutivesNames, // Pass the names to dropdown
                                            onChanged: (String? newValue) {
                                              selectedSE.value = newValue;
                                              debugPrint(
                                                  "Selected Sales Executive: $selectedSE");
                                            },
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildDropdownField(
                                          label: 'Report Type',
                                          hintText: 'Select Report...',
                                          value: selectedRecord,
                                          items: recordType.keys.toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              selectedRecord =
                                                  newValue; // Update the selected record

                                              // Get the corresponding ID from the map
                                              final selectedRecordId =
                                                  recordType[newValue];
                                              debugPrint(
                                                  "Selected Report Type: $selectedRecord");
                                              debugPrint(
                                                  "Selected Report ID: $selectedRecordId");
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('From Date'.tr,
                                                style:
                                                    theme.textTheme.bodySmall),
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
                                                      color:
                                                          Colors.grey.shade300),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.calendar_month,
                                                          color: Colors.grey),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      Text(
                                                          fromDate.isEmpty
                                                              ? 'Choose Date'
                                                              : fromDate,
                                                          style: theme.textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                  color: isDarkMode
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                  fontSize:
                                                                      13)),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('To Date'.tr,
                                                style:
                                                    theme.textTheme.bodySmall),
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
                                                      color:
                                                          Colors.grey.shade300),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.calendar_month,
                                                          color: Colors.grey),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      Text(
                                                          fromDate.isEmpty
                                                              ? 'Choose Date'
                                                              : toDate,
                                                          style: theme.textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                  color: isDarkMode
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                  fontSize:
                                                                      13)),
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
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _onSearchButtonPressed,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 251, 134, 45),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                90), // Smaller border radius
                                          ),
                                          minimumSize: const Size(50, 40),
                                        ),
                                        child: const Icon(Icons.search,
                                            color: Colors.white),
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                            ),
                      // const SizedBox(height: 30),
                      // isLoading
                      //     ? _buildShimmerTable()
                      //     : _buildDynamicTable(context,viewController.defaultViewOrder),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Obx(() {
                          if (visitReportMController.isLoading.value) {
                            return Center(child: _buildShimmerCard());
                          }

                          // Check if there are no reports after a search
                          if (visitReportMController.visitReports.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Replace with your asset image path
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Shimmer.fromColors(
                                          baseColor: const Color.fromARGB(
                                              255, 53, 51, 51),
                                          highlightColor: Colors.white,
                                          child: Icon(
                                            Icons.search_off,
                                            size: 90,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Shimmer.fromColors(
                                          baseColor: const Color.fromARGB(
                                              255, 53, 51, 51),
                                          highlightColor: Colors.white,
                                          child:  Text(
                                            'No results found.\nPlease refine your search criteria.',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontSize: 19,
                                             
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
                            itemCount:
                                visitReportMController.visitReports.length,
                            itemBuilder: (context, index) {
                              final report =
                                  visitReportMController.visitReports[index];
                              return VisitReportMWidget(
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
            )
          ],
        ),
      )),
    );
  }

  Widget _buildDropdownField1({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white,
              width: isDarkMode ? 0.8 : 0.2,
            ),
          ),
          constraints: const BoxConstraints(maxHeight: 50),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hintText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.blueGrey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white,
              width: isDarkMode ? 0.8 : 0.2,
            ),
          ),
          constraints: const BoxConstraints(maxHeight: 50),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hintText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.blueGrey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
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
