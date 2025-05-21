import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:impal_desktop/features/global/theme/widgets/customer_search_dropdown.dart';

import 'package:intl/intl.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';

import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/reports/create_report/controller/create_report_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/temp_receipt/controllers/temp_receipt_comtroller.dart';

class CreateReport extends StatefulWidget {
  static const String routeName = '/CreateReport';

  const CreateReport({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CreateReportState createState() => _CreateReportState();
}

class _CreateReportState extends State<CreateReport> {
  final RxBool isLoading = false.obs;
  String reportedDate = '';
  final TextEditingController fileNameController = TextEditingController();
  final CreateReportController createReportController =
      Get.put(CreateReportController());
  TextEditingController nextVisitController = TextEditingController();
  TextEditingController personMetController = TextEditingController();
  TextEditingController reportedDateController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  final TempReceiptController tempreceiptController =
      Get.put(TempReceiptController());

  // Form fields data
  int? selectedCustomerId;
  String? selectedCustomerName;
  String? selectedPersonMet;
  String? selectedPaymentMethod;
  int? selectedPurposevisit;
  String? nextVisitDate;
  String? reportedOnDate;
  String? remarks;

  @override
  void initState() {
    super.initState();
    // Set the reported date to the current date
    reportedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  // Payment methods and their corresponding IDs
  final Map<String, int> paymentMethods = {
    'Cash': 1,
    'Cheque': 2,
  };

  final Map<String, int> purposeoftheVisit = {
    'Payment Collection': 1,
    'General': 2,
    'Others': 3,
    'Sales Order': 4,
  };

  String chooseDate = '';
  TextEditingController chooseDateController = TextEditingController();

  String chooseDate1 = '';
  TextEditingController chooseDateController1 = TextEditingController();
  // Date pickers for the "Next Visit Date" and "Reported Date"
  void _onChooseDatePicked(DateTime pickedDate) {
    setState(() {
      chooseDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      chooseDateController.text = chooseDate;
      nextVisitDate = chooseDate;
    });
    print('Choose Date: $chooseDate');
    print(nextVisitDate);
  }

  void _selectDate() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    // Ensure initialDate is either today or yesterday
    DateTime initialDate = today; // Default to today
    if (now.isBefore(yesterday) || now.isAfter(today)) {
      initialDate = today;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate, // Must be in the selectable range
      firstDate: yesterday,
      lastDate: today,
      selectableDayPredicate: (DateTime date) {
        return date == yesterday || date == today;
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        reportedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  String? filen;
  String? filet;
  String? files;

  void _submitForm() async {
    if (selectedPaymentMethod == "2") {
      if (tempreceiptController.FileName.isEmpty) {
        AppSnackBar.alert(message: "Please choose the Image");
        return;
      }
    }
    if (remarksController.text.isNotEmpty &&
        personMetController.text.isNotEmpty &&
        selectedCustomerId != null &&
        nextVisitDate != null) {
      // Start loading
      isLoading.value = true;

      // Capture form inputs
      remarks = remarksController.text;
      selectedPersonMet = personMetController.text;
      reportedOnDate = reportedDate;

      filen = tempreceiptController.FileName;
      filet = tempreceiptController.FileType;
      files = tempreceiptController.encodedData;

      print("name  -> $filen");
      print("type  -> $filet");
      print("file  -> $files");
      print("Submitting with selected payment method: $selectedPaymentMethod");
      print("Selected Customer ID: $selectedCustomerId");
      print("Person Met: $selectedPersonMet");
      print("Next Visit Date: $nextVisitDate");
      print("Reported Date: $reportedOnDate");
      print("Remarks: $remarks");

      try {
        // Create the report using the controller
        await createReportController.createReport(
          customerId: selectedCustomerId!,
          personMet: selectedPersonMet ?? "Unknown",
          paymentMethod: selectedPaymentMethod ?? "",
          nextVisitDate: nextVisitDate!,
          reportedOnDate: reportedOnDate!,
          purposeOfTheVisit: selectedPurposevisit!,
          remarks: remarks ?? "No remarks",
          filename: filen ?? '',
          filetype: filet ?? '',
          image: files ?? '',
        );

        // Check if the report was created successfully
        if (createReportController.reportStatus.value ==
            'Report Created Successfully') {
          final reportId = createReportController.reportId.value;

          // Show success dialog
          showDialog(
            context: Get.context!, // Use Get.context instead of currentContext

            barrierDismissible: true, // Allow dismiss by tapping outside
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async {
                  // Dispose controller and navigate back on back button or outside tap
                  Get.delete<CreateReportController>();
                  Get.back(); // Close dialog
                  Get.back(); // Navigate back
                  return true;
                },
                child: CustomAlertDialog(
                  title: "Report Created",
                  message:
                      "Report created successfully with Report ID: $reportId",
                  showOkButton: true,
                  onOk: () {
                    // Dispose controller and navigate back when OK is clicked
                    Get.delete<CreateReportController>();
                    Get.back(); // Close dialog
                    Get.back(); // Navigate back
                  },
                ),
              );
            },
          );

          _clearFormData(); // Clear form inputs
        }
      } catch (e) {
        print("Error while submitting the form: $e");
        AppSnackBar.alert(message: "Submission failed. Please try again.");
      } finally {
        // Stop loading
        isLoading.value = false;
      }
    } else {
      AppSnackBar.alert(message: "Please fill out all the required fields.");
    }
  }

  void _clearFormData() {
    remarksController.clear();
    personMetController.clear();
    selectedPaymentMethod = null;
    selectedCustomerId = null;
    nextVisitDate = null;
    reportedOnDate = null;
    selectedPurposevisit = null;
    tempreceiptController.FileName = "";
    tempreceiptController.FileType = "";
    tempreceiptController.encodedData = "";
  }

  File? galleryFile;
  final picker = ImagePicker();

  final GlobalcustomerController globalcustomerController =
      Get.put(GlobalcustomerController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Create Report',
      //     style: theme.textTheme.bodyLarge?.copyWith(      
      //             color: Colors.white,
      //           ),
      //   ),
      //   backgroundColor: const Color(0xFF161717),
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      body: Stack(children: [
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                width: screenWidth,
                padding: const EdgeInsets.only(top: 10, bottom: 0),
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, right: 15.0, left: 15.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Card(
                                    margin: const EdgeInsets.all(12.0),
                                    elevation: 5,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child:
                                                    //   CustomerDropdown(
                                                    //     label: "Customer",
                                                    //     hintText: "Select Customer",
                                                    //     globalcustomerController:
                                                    //         globalcustomerController,
                                                    //     onCustomerSelected:
                                                    //         (selectedId) {
                                                    //       setState(() {
                                                    //         selectedCustomerId =
                                                    //             selectedId;
                                                    //       });
                                                    //     },
                                                    //   ),
                                                    // ),
                                                    CustomerSearchDropdown(
                                                  label: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "Customer",
                                                          style: theme.textTheme.bodyLarge?.copyWith(
                                                                 fontWeight:
                                                                  FontWeight
                                                                      .bold
                                                          )
                                                          
                                                        ),
                                                        TextSpan(
                                                          text: " *",
                                                          style: theme.textTheme.bodyLarge?.copyWith(
                                                            color: Colors.red,
                                                                 fontWeight:
                                                                  FontWeight
                                                                      .bold
                                                          )
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  hintText: "Select Customer",
                                                  globalcustomerController:
                                                      globalcustomerController,
                                                  onCustomerSelected: (int?
                                                          customerId,
                                                      String? customerName) {
                                                    setState(() {
                                                      selectedCustomerId =
                                                          customerId;
                                                      selectedCustomerName =
                                                          customerName;
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _buildTextField(
                                                  label: 'Person Met*',
                                                  hintText:
                                                      'Enter Person Met...',
                                                  controller:
                                                      personMetController,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _buildVisitDropdownField(
                                                  label:
                                                      'Purpose of the Visit*',
                                                  hintText:
                                                      'Purpose of the Visit',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Payment Method Column
                                              Expanded(
                                                flex:
                                                    2, // Flex value to control the width proportion
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (selectedPurposevisit ==
                                                        1)
                                                      _buildPaymentDropdownField(
                                                        label:
                                                            'Payment Method*',
                                                        hintText:
                                                            'Payment Method',
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      12), // Added space between the widgets
                                              // Reported Date Column
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Reported Date',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isDarkMode
                                                                ? Colors
                                                                    .grey[300]
                                                                : Colors.black,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    GestureDetector(
                                                      onTap: _selectDate,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isDarkMode
                                                              ? Colors.grey[850]
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: isDarkMode
                                                                ? Colors
                                                                    .blueAccent
                                                                    .shade400
                                                                : Colors.blue
                                                                    .shade300,
                                                            width: 1.2,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color: Colors
                                                                    .grey),
                                                            const SizedBox(
                                                                width: 4.0),
                                                            Text(
                                                              reportedDate,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      12), // Space between widgets
                                              // Next Visit Date Column
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text.rich(
                                                      TextSpan(
                                                        text:
                                                            'Next Visit Date', // Main label text
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDarkMode
                                                              ? Colors.grey[300]
                                                              : Colors.black,
                                                        ),
                                                        children: [
                                                          const TextSpan(
                                                            text:
                                                                ' *', // Red-colored asterisk
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        DateTime? pickedDate1 =
                                                            await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              DateTime.now(),
                                                          firstDate:
                                                              DateTime(2000),
                                                          lastDate:
                                                              DateTime(2100),
                                                        );
                                                        if (pickedDate1 !=
                                                            null) {
                                                          if (pickedDate1
                                                              .isBefore(DateTime
                                                                  .now())) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Please select a future date')),
                                                            );
                                                          } else {
                                                            _onChooseDatePicked(
                                                                pickedDate1);
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isDarkMode
                                                              ? Colors.grey[850]
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: isDarkMode
                                                                ? Colors
                                                                    .blueAccent
                                                                    .shade400
                                                                : Colors.blue
                                                                    .shade300,
                                                            width: 1.2,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color: Colors
                                                                    .grey),
                                                            const SizedBox(
                                                                width: 4.0),
                                                            Text(
                                                              chooseDate
                                                                      .isNotEmpty
                                                                  ? chooseDate
                                                                  : 'Select Date',
                                                              style: TextStyle(
                                                                color: chooseDate
                                                                        .isEmpty
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          if (selectedPaymentMethod == "2")
                                            GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    25)),
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Container(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        25)),
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.white,
                                                            Colors.grey[100]!
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: <Widget>[
                                                          // Header
                                                          Text(
                                                            'Choose an Action',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                          SizedBox(height: 15),

                                                          // Upload Card
                                                          Card(
                                                            elevation: 6,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            color: Colors.white,
                                                            shadowColor: Colors
                                                                .black
                                                                .withOpacity(
                                                                    0.1),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                await tempreceiptController
                                                                    .handleDocumentSelection(
                                                                        context);
                                                                fileNameController
                                                                        .text =
                                                                    tempreceiptController
                                                                        .FileName;
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        15),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .file_upload,
                                                                      size: 30,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            15),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <Widget>[
                                                                        Text(
                                                                          'Upload Image',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                5),
                                                                        Text(
                                                                          'Tap to upload an image file',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.grey[600],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: AbsorbPointer(
                                                absorbing: true,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Text(
                                                    //   "Upload",
                                                    //   style: theme
                                                    //       .textTheme.bodyLarge
                                                    //       ?.copyWith(
                                                    //     fontWeight:
                                                    //         FontWeight.bold,
                                                    //     color: isDarkMode
                                                    //         ? Colors.grey[300]
                                                    //         : Colors.black,
                                                    //   ),
                                                    // ),
                                                    Text.rich(
                                                      TextSpan(
                                                        text:
                                                            'Upload', // Main label text
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDarkMode
                                                              ? Colors.grey[300]
                                                              : Colors.black,
                                                        ),
                                                        children: [
                                                          const TextSpan(
                                                            text:
                                                                ' *', // Red-colored asterisk
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Stack(
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              fileNameController, // Persistent controller
                                                          decoration:
                                                              InputDecoration(
                                                            hintText: fileNameController
                                                                    .text
                                                                    .isEmpty
                                                                ? 'Choose a file'
                                                                : fileNameController
                                                                    .text,
                                                            hintStyle: theme
                                                                .textTheme
                                                                .bodyLarge,
                                                            filled: true,
                                                            fillColor: isDarkMode
                                                                ? Colors
                                                                    .grey[850]
                                                                : Colors
                                                                    .white, // Darker gray for dark mode
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                color:
                                                                    isDarkMode
                                                                        ? Colors
                                                                            .blueAccent
                                                                            .shade400 // Softer blue for dark mode
                                                                        : Colors
                                                                            .blue
                                                                            .shade300, // Lighter blue for light mode
                                                                width:
                                                                    isDarkMode
                                                                        ? 0.8
                                                                        : 0.2,
                                                              ),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  width: 0.2),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        12),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 9,
                                                          right: 8,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isDarkMode
                                                                  ? Colors
                                                                      .blueAccent
                                                                      .shade700
                                                                  : Colors.blue
                                                                      .shade600,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          8)),
                                                            ),
                                                            child: Text(
                                                              "Choose File",
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 16),
                                          _buildTextArea(
                                            label: 'Remarks',
                                            hintText:
                                                'Maximum 100 Characters...',
                                            controller:
                                                remarksController, // Pass the controller
                                          ),
                                          const SizedBox(height: 24),
                                          Center(
                                            child: Obx(() => Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: isLoading.value
                                                          ? null
                                                          : _submitForm,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                251, 134, 45),
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 32,
                                                                vertical: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        minimumSize:
                                                            const Size(200, 50),
                                                      ),
                                                      child: isLoading.value
                                                          ? const SizedBox(
                                                              width: 24,
                                                              height: 24,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                strokeWidth: 2,
                                                              ),
                                                            )
                                                          : const Text(
                                                              'Submit'),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]))))
      ]),
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: theme.textTheme.bodyLarge?.copyWith(
        //     fontWeight: FontWeight.bold,
        //     color: isDarkMode
        //         ? Colors.white
        //         : Colors.black, // Adjusted text color for dark mode
        //   ),
        // ),
        Text.rich(
          TextSpan(
            text: label.replaceAll('*', ''),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black, // Color adjusted for dark mode
            ),
            children: [
               TextSpan(
                text: ' *', // Add * separately with red color
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                )
                
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // Bind the controller here
          maxLines: maxLines,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600], // Adjusted hint color
            ),
            filled: true,
            fillColor: isDarkMode
                ? Colors.grey[850]
                : Colors.white, // Dark mode background color
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  10), // Rounded corners for a smoother look
              borderSide: BorderSide(
                color: isDarkMode
                    ? Colors.blueAccent.shade700
                    : Colors.grey.shade400, // Border color
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade600,
                width: 0.2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required String hintText,
    int maxLines = 4,
    required TextEditingController controller, // Pass the controller
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final customBlue =
        isDarkMode ? Colors.blueAccent.shade700 : Colors.blue.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[300] : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // Bind the controller to the TextField
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDarkMode ? customBlue : Colors.grey.shade400,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey
                    .shade600, // Set the border color for the focused state
                width: 0.2, // Set the border width
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitDropdownField({
    required String label,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label.replaceAll('*', ''),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black, // Color adjusted for dark mode
            ),
            children: [
               TextSpan(
                text: ' *', // Add * separately with red color
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                )
               
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[850]
                : Colors.white, // Darker gray for dark mode
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(
              color: isDarkMode
                  ? Colors.blueAccent.shade400 // Softer blue for dark mode
                  : Colors.blue.shade300, // Lighter blue for light mode
              width: 1.2, // Slightly thicker border
            ),
          ),
          constraints: const BoxConstraints(
            maxHeight: 46,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedPurposevisit == null
                  ? null
                  : purposeoftheVisit.keys.firstWhere(
                      (key) => purposeoftheVisit[key] == selectedPurposevisit),
              hint: Text(
                hintText,
                style: theme.textTheme.bodyLarge,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPurposevisit = purposeoftheVisit[newValue!];
                  print(
                      "Selected Purpose of the Visit ID: $selectedPurposevisit");
                });
              },
              items: purposeoftheVisit.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                   
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.grey[900]! : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        )
      ],
    );
  }

  // Payment Method Dropdown Field
  Widget _buildPaymentDropdownField({
    required String label,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label.replaceAll('*', ''),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black, // Color adjusted for dark mode
            ),
            children: [
               TextSpan(
                text: ' *', // Add * separately with red color
                style: theme.textTheme.bodyLarge?.copyWith(
                   color: Colors.red,
                  fontWeight: FontWeight.bold,
                )
                
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[850]
                : Colors.white, // Darker gray for dark mode
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(
              color: isDarkMode
                  ? Colors.blueAccent.shade400 // Softer blue for dark mode
                  : Colors.blue.shade300, // Lighter blue for light mode
              width: 1.2, // Slightly thicker border
            ),
          ),
          constraints: const BoxConstraints(
            maxHeight: 46,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: paymentMethods
                      .containsValue(int.tryParse(selectedPaymentMethod ?? ""))
                  ? paymentMethods.keys.firstWhere((key) =>
                      paymentMethods[key]?.toString() == selectedPaymentMethod)
                  : null,
              hint: Text(
                hintText,
                style: theme.textTheme.bodyLarge,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedPaymentMethod =
                        paymentMethods[newValue]?.toString();
                    print("Selected Payment Method ID: $selectedPaymentMethod");
                  });
                }
              },
              items: paymentMethods.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.grey[900]! : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }
}
