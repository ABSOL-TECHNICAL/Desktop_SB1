import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/card_customer_dropdown.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/controllers/customer_details_controller.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';

import 'package:impal_desktop/features/sales/salesperson/customers/view_billed_details/controllers/view_billed_controller.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/view_billed_details/widgets/view_billed_widget.dart';

class BilledDetails extends StatefulWidget {
  static const String routeName = '/BilledDetails';

  const BilledDetails({super.key});

  @override
  _BilledDetailsState createState() => _BilledDetailsState();
}

class _BilledDetailsState extends State<BilledDetails> {
  final uniqueCustomerNames = <String>[].obs;
  var selectedCustomer = ''.obs;
  bool isLoading = true;
  String fromDate = 'Choose Date';
  String toDate = 'Choose Date';
  // RxString selectedCustomer = ''.obs;
  String? selectedCustomerID;
  final LoginController loginController = Get.find<LoginController>();
  final ViewBilledDetailsController viewBilledController =
      Get.put(ViewBilledDetailsController());
  final CustomerDetailsController customerDetailsController =
      Get.put(CustomerDetailsController());
  final GlobalcustomerController globalCustomerController =
      Get.put(GlobalcustomerController());

  // Step 1: Create the customerName list
  List<String> get customerName {
    return globalCustomerController.globalcustomerController
        .map((item) => item['Customer'].toString())
        .toSet() // Ensure uniqueness
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // customerDetailsController.fetchCustomerdetails();
    globalCustomerController.fetchCustomer().then((_) {
      final customers = globalCustomerController.globalcustomerController
          .map((item) => item['Customer'].toString())
          .toSet()
          .toList();

      uniqueCustomerNames.assignAll(customers);
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the controller
    if (Get.isRegistered<ViewBilledDetailsController>()) {
      print("Disposing CutomerDetails...");
      Get.delete<ViewBilledDetailsController>();
    } else {
      print("CutomerDetails is not registered, no need to dispose.");
    }
    // globalCustomerController.fetchCustomer();
    super.dispose();
    print("CustomerDetails disposed.");
  }

  void _searchReports() async {
    if (selectedCustomer.value.isEmpty) {
      AppSnackBar.alert(message: "Please select the customer name.");
      return;
    }

    if (fromDate != 'Choose From Date' && toDate != 'Choose Date') {
      setState(() {
        isLoading = true; // Start loading
      });

      viewBilledController.fromDate.value = fromDate;
      viewBilledController.toDate.value = toDate;

      selectedCustomerID =
          globalCustomerController.globalcustomerController.firstWhere(
        (item) => item['Customer'].toString() == selectedCustomer.value,
        orElse: () => {},
      )?['CustomerId'];

      if (selectedCustomerID != null) {
        try {
          await viewBilledController.fetchViewBilledSearchDetails(
              fromDate, toDate);
        } catch (e) {
          AppSnackBar.alert(message: "Error fetching data.");
        } finally {
          setState(() {
            isLoading = false; // Stop loading
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        AppSnackBar.alert(message: "Selected customer ID is invalid.");
      }
    } else {
      AppSnackBar.alert(message: "Please select both From Date and To Date.");
    }
  }

  Future<void> _pickFromDate() async {
    DateTime pickedDate;
    if (fromDate != 'Choose Date') {
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
    if (toDate != 'Choose Date') {
      pickedDate = DateFormat('dd/MM/yyyy').parse(toDate);
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
      _onToDatePicked(newPickedDate);
    }
  }

  void _onFromDatePicked(DateTime pickedDate) {
    if (toDate != 'Choose Date' &&
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
  Widget build(BuildContext context) {
    uniqueCustomerNames.assignAll(customerName.toSet().toList());
    final theme = Theme.of(context);
    // double screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'View Billed Details',
            style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF161717),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 10, bottom: 0),
              child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                    colors: [
                                        Color(0xFF6B71FF),
                                        Color(0xFF57AEFE)
                                      ],
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          CardCustomerDropdown(
                                            label: 'Customer',
                                            hintText:
                                                'Search for a customer...',
                                            globalcustomerController:
                                                globalCustomerController,
                                            onCustomerSelected: (customerId) {
                                              if (customerId != null) {
                                                selectedCustomer.value =
                                                    globalCustomerController
                                                            .globalcustomerController
                                                            .firstWhere(
                                                          (item) =>
                                                              item[
                                                                  'CustomerId'] ==
                                                              customerId
                                                                  .toString(),
                                                          orElse: () => {},
                                                        )['Customer'] ??
                                                        '';
                                                selectedCustomerID =
                                                    customerId.toString();
                                                viewBilledController
                                                        .selectedCustomerID =
                                                    selectedCustomerID;
                                              }
                                            },
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
                                          Text(
                                            'From Date',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          GestureDetector(
                                            onTap: _pickFromDate,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Colors.black
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_today,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      fromDate,
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                              fontSize:
                                                                  16, // Adjust size if needed
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                    ),
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
                                          Text(
                                            'To Date',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_today,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      toDate,
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                              fontSize: 16,
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                    ),
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
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _searchReports,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 251, 134, 45),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(90)),
                                        minimumSize: const Size(50, 40),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Icon(Icons.search,
                                              color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                isLoading
                                    ? _buildShimmerTable()
                                    : Column(
                                        children: [
                                          Obx(() {
                                            if (viewBilledController
                                                .viewBilledDetails.isEmpty) {
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 70),
                                                    Shimmer.fromColors(
                                                      baseColor:
                                                          const Color.fromARGB(
                                                              255, 53, 51, 51),
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        Icons.search_off,
                                                        size: 100,
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Shimmer.fromColors(
                                                      baseColor:
                                                          const Color.fromARGB(
                                                              255, 53, 51, 51),
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Text(
                                                        'No results found.\nPlease refine your search criteria.',
                                                        style: theme.textTheme.bodyLarge?.copyWith(
                                                          fontSize: 20,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 10, 10, 10),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              print(viewBilledController
                                                  .viewBilledDetails.length);
                                              return ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    // maxHeight: MediaQuery.of(context).size.height * 0.45,
                                                    ),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  itemCount: (viewBilledController
                                                              .viewBilledDetails
                                                              .length /
                                                          2)
                                                      .ceil(), // divide by 2 to pair data
                                                  itemBuilder:
                                                      (context, index) {
                                                    final detail1 =
                                                        viewBilledController
                                                                .viewBilledDetails[
                                                            index *
                                                                2]; // first item
                                                    final detail2 = (index * 2 +
                                                                1) <
                                                            viewBilledController
                                                                .viewBilledDetails
                                                                .length
                                                        ? viewBilledController
                                                            .viewBilledDetails[index *
                                                                2 +
                                                            1] // second item (if available)
                                                        : null;

                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // Card 1
                                                          Expanded(
                                                            child:
                                                                ViewBilledWidget(
                                                              title:
                                                                  '${detail1.customerName}\n${detail1.docNo}',
                                                              subtitle:
                                                                  'Date: ${detail1.docDate}',
                                                              viewBilledDetails: [
                                                                detail1
                                                              ],
                                                            ),
                                                          ),
                                                          // Add space between cards
                                                          const SizedBox(
                                                              width: 10),
                                                          // Card 2 (if exists)
                                                          if (detail2 != null)
                                                            Expanded(
                                                              child:
                                                                  ViewBilledWidget(
                                                                title:
                                                                    '${detail2.customerName}\n${detail2.docNo}',
                                                                subtitle:
                                                                    'Date: ${detail2.docDate}',
                                                                viewBilledDetails: [
                                                                  detail2
                                                                ],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          }),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ])),
            ),
          ),
        ]));
  }

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[850]!, Colors.white60]
              : [Colors.grey[300]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          10,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 20,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 250,
                    height: 20,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
