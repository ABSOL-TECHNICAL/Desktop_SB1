import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/customer_search_dropdown.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/reports/temp_receipt/controllers/temp_receipt_comtroller.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

class TempReceipt extends StatefulWidget {
  static const String routeName = '/TempReceipt';

  const TempReceipt({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TempReceiptState createState() => _TempReceiptState();
}

class _TempReceiptState extends State<TempReceipt> {
  final RxBool isLoading = false.obs;
  final TextEditingController fileNameController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController amountInwordsController = TextEditingController();
  TextEditingController invoiceNoController = TextEditingController();
  TextEditingController checkNoController = TextEditingController();

  final GlobalcustomerController globalcustomerController =
      Get.put(GlobalcustomerController());
  final TempReceiptController tempreceiptController =
      Get.put(TempReceiptController());
  int? selectedPaymentMethod;
  int? selectedCustomerId;
  String? selectedCustomerName;

  String chooseDate = '';
  TextEditingController chooseDateController = TextEditingController();
  String? checkDatevalue;

  void _onChooseDatePicked(DateTime pickedDate) {
    setState(() {
      chooseDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      chooseDateController.text = chooseDate;
      checkDatevalue = chooseDate;
    });
    print('Choose Date: $chooseDate');
    print(checkDatevalue);
  }

  final Map<String, int> paymentMethods = {
    'Cash': 1,
    'Cheque': 2,
  };

  String? remarks;
  String? checkno;
  String? checkdate;

  String? amount;
  String? amountinwards;
  String? invoiceno;
  String? filen;
  String? filet;
  String? files;

  RxString filenamefield = ''.obs;

  void _submitForm(BuildContext currentContext) async {
    if (selectedPaymentMethod == 2) {
      if (tempreceiptController.FileName.isEmpty) {
        AppSnackBar.alert(message: "Please choose the Image");
        return;
      }
    }
    if (selectedPaymentMethod != null &&
        selectedCustomerId != null &&
        amountController.text.isNotEmpty &&
        invoiceNoController.text.isNotEmpty) {
      // Start loading
      isLoading.value = true;

      remarks = remarksController.text;
      amount = amountController.text;
      amountinwards = amountInwordsController.text;
      print(amountinwards);
      invoiceno = invoiceNoController.text;

      if (selectedPaymentMethod == 1) {
        filen = '';
        filet = '';
        files = '';
      } else {
        filen = tempreceiptController.FileName;
        filet = tempreceiptController.FileType;
        files = tempreceiptController.encodedData;
      }
      checkno = checkNoController.text;
      print("CheckNo : $checkno");
      checkdate = checkDatevalue;
      print("checkDate: $checkdate");

      try {
        String paymentMethodName = paymentMethods.entries
            .firstWhere((entry) => entry.value == selectedPaymentMethod)
            .key;

        // Show data confirmation dialog
        showDialog(
          context: currentContext, // Pass the valid context
          barrierDismissible: false, // Prevent dismissing without action
          builder: (BuildContext dialogContext) {
            return CustomAlertDialog(
              title: 'Confirm Submission',
              message: "Please confirm the details below:\n\n"
                  "Customer Name: $selectedCustomerName\n"
                  "Payment Method: $paymentMethodName\n"
                  "Amount: $amount\n"
                  "Invoice No: $invoiceno\n"
                  "Remarks: ${remarks ?? ''}",
              onCancel: () {
                // Close the dialog without taking action
                isLoading.value = false;
                Navigator.of(dialogContext).pop();
              },
              onConfirm: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                try {
                  // Submit the data to the API
                  await tempreceiptController.createTransferOrder(
                    customerId: selectedCustomerId!,
                    modeofCollection: selectedPaymentMethod!,
                    amount: amount ?? '',
                    invoiceNo: invoiceno ?? '',
                    remarks: remarks ?? "",
                    checkno: checkno,
                    checkdate: checkdate,
                    filename: filen ?? '',
                    filetype: filet ?? '',
                    image: files ?? '',
                  );

                  if (tempreceiptController.transferStatus.value ==
                      'Transfer Order Created Successfully') {
                    tempreceiptController.FileName = '';

                    final transferOrderId =
                        tempreceiptController.transferOrderId.value;

                    showDialog(
                      context: Get
                          .context!, // Use Get.context instead of currentContext
                      builder: (BuildContext dialogContext) {
                        return WillPopScope(
                          onWillPop: () async {
                            // Ensure widget is mounted before calling Get methods
                            if (mounted) {
                              Get.delete<TempReceiptController>();
                              Get.back(); // Close dialog
                              Get.back(); // Navigate back
                            }
                            return true;
                          },
                          child: CustomAlertDialog(
                            title: "Temp Receipt",
                            message:
                                "Temp Receipt has been successfully created with Temp Reciept Id: $transferOrderId",
                            showOkButton: true,
                            onOk: () {
                              if (mounted) {
                                Get.delete<TempReceiptController>();
                                Get.back();
                                Get.back();
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                } catch (e) {
                  print("Error while submitting the form: $e");
                  AppSnackBar.alert(
                      message: "Submission failed. Please try again.");
                } finally {
                  // Stop loading
                  isLoading.value = false;
                }
              },
            );
          },
        );
      } catch (e) {
        print("Error while submitting the form: $e");
        AppSnackBar.alert(message: "An error occurred. Please try again.");
      } finally {
        // Stop loading
        isLoading.value = false;
      }
    } else {
      AppSnackBar.alert(message: "Please fill out all the required fields.");
    }
  }

  @override
  void initState() {
    super.initState();
    // Allow screenshots on this page

    amountController.addListener(() {
      final text = amountController.text;

      if (text.isNotEmpty) {
        final parsedValue = int.tryParse(text);
        if (parsedValue != null) {
          amountInwordsController.text =
              NumberToWordsEnglish.convert(parsedValue);
        } else {
          amountInwordsController.clear(); // Clear if invalid input
        }
      } else {
        amountInwordsController.clear(); // Clear if input is empty
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Material(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Temp Receipt',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
          child: Stack(
        children: [
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Card(
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
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween, // Adjust this based on your layout needs
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.only(
                                                right:
                                                    8.0), // Optional padding to create space between fields
                                            child:
                                                //     CustomerSearchDropdown(
                                                //       label: "Customer",
                                                //       hintText: "Select Customer",
                                                //       globalcustomerController:
                                                //           globalcustomerController,
                                                //       onCustomerSelected:
                                                //           (int? customerId,
                                                //               String? customerName) {
                                                //         setState(() {
                                                //           selectedCustomerId =
                                                //               customerId;
                                                //           selectedCustomerName =
                                                //               customerName; // Capture the name
                                                //         });
                                                //       },
                                                //     ),
                                                //   ),
                                                // ),
                                                CustomerSearchDropdown(
                                              label: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Customer",
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    TextSpan(
                                                        text: " *",
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                  ],
                                                ),
                                              ),
                                              hintText: "Select Customer",
                                              globalcustomerController:
                                                  globalcustomerController,
                                              onCustomerSelected:
                                                  (int? customerId,
                                                      String? customerName) {
                                                setState(() {
                                                  selectedCustomerId =
                                                      customerId;
                                                  selectedCustomerName =
                                                      customerName;
                                                });
                                              },
                                            ),
                                          )),
                                          Expanded(
                                            child: _buildPaymentDropdownField(
                                              label: 'Mode Of Collection*',
                                              hintText:
                                                  'Choose Mode Of Collection...',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (selectedPaymentMethod == 2)
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            25)),
                                              ),
                                              backgroundColor: Colors.white,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  padding: EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    25)),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white,
                                                        Colors.grey[100]!
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
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
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
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
                                                                  .circular(20),
                                                        ),
                                                        color: Colors.white,
                                                        shadowColor: Colors
                                                            .black
                                                            .withOpacity(0.1),
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
                                                                  .circular(20),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15),
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
                                                                    width: 15),
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
                                                                        color: Colors
                                                                            .black87,
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
                                                                        color: Colors
                                                                            .grey[600],
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
                                                //     fontWeight: FontWeight.bold,
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
                                                              FontWeight.bold,
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
                                                          fileNameController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: fileNameController
                                                                .text.isEmpty
                                                            ? 'Choose a file'
                                                            : fileNameController
                                                                .text,
                                                        hintStyle: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                          color: isDarkMode
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                        ),
                                                        filled: true,
                                                        fillColor: isDarkMode
                                                            ? Colors.grey[850]
                                                            : Colors
                                                                .white, // Darker gray for dark mode
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          borderSide:
                                                              BorderSide(
                                                            color: isDarkMode
                                                                ? Colors
                                                                    .blueAccent
                                                                    .shade400 // Softer blue for dark mode
                                                                : Colors.blue
                                                                    .shade300, // Lighter blue for light mode
                                                            width: isDarkMode
                                                                ? 0.8
                                                                : 0.2,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  width: 0.2),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 12),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 9,
                                                      right: 8,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 6),
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
                                                                  .all(Radius
                                                                      .circular(
                                                                          8)),
                                                        ),
                                                        child: Text(
                                                          "Choose File",
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween, // Adjusts spacing between the fields
                                        children: [
                                          Expanded(
                                            child: _buildTextFieldR(
                                              label: 'Amount*',
                                              hintText: 'Enter Amount...',
                                              controller: amountController,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  16), // Adjusts spacing between fields
                                          Expanded(
                                            child: _buildTextField(
                                              label: 'Amount Words',
                                              hintText: 'Enter Amount...',
                                              controller:
                                                  amountInwordsController,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildInvoiceField(
                                              label: 'Invoice No*',
                                              hintText: 'Enter Invoice No...',
                                              controller: invoiceNoController,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (selectedPaymentMethod == 2)
                                        Row(children: [
                                          Expanded(
                                            child: _buildInvoiceField(
                                              label: 'Cheque No',
                                              hintText: 'Enter Cheque No...',
                                              controller: checkNoController,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Choose Cheque Date'.tr,
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isDarkMode
                                                        ? Colors.grey[300]
                                                        : Colors.black,
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
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100),
                                                    );
                                                    if (pickedDate1 != null) {
                                                      if (pickedDate1.isBefore(
                                                          DateTime.now())) {
                                                        ScaffoldMessenger.of(
                                                                context)
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
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? Colors.grey[850]
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                        color: isDarkMode
                                                            ? Colors.blueAccent
                                                                .shade400
                                                            : Colors
                                                                .blue.shade300,
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .calendar_month,
                                                            color: Colors.grey),
                                                        const SizedBox(
                                                            width: 4.0),
                                                        Text(
                                                            chooseDate
                                                                    .isNotEmpty
                                                                ? chooseDate
                                                                : 'Select Date',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color: chooseDate
                                                                      .isEmpty
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      const SizedBox(height: 16),
                                      _buildTextArea(
                                        label: 'Remarks',
                                        hintText: 'Maximum 50 Characters...',
                                        controller: remarksController,
                                      ),
                                      const SizedBox(height: 24),
                                      Center(
                                        child: Obx(() {
                                          return Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _submitForm(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 251, 134, 45),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                minimumSize: Size(
                                                    isTablet ? 120 : 80,
                                                    isTablet ? 50 : 30),
                                              ),
                                              child: isLoading.value
                                                  ? SizedBox(
                                                      height: isTablet
                                                          ? 50
                                                          : 30, // Make sure the height is enough
                                                      width: isTablet
                                                          ? 120
                                                          : 80, // Adjust width to match button size
                                                      child:
                                                          const CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      'Submit'.tr,
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                        color: Colors.white,
                                                        fontSize:
                                                            isTablet ? 15 : 14,
                                                      ),
                                                    ),
                                            ),
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    ));
  }

  Widget _buildPaymentDropdownField({
    required String label,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: theme.textTheme.bodyLarge?.copyWith(
        //     fontWeight: FontWeight.bold,
        //     color: isDarkMode
        //         ? Colors.white
        //         : Colors.black, // Color adjusted for dark mode
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
                  )),
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
              value: selectedPaymentMethod == null
                  ? null
                  : paymentMethods.keys.firstWhere(
                      (key) => paymentMethods[key] == selectedPaymentMethod),
              hint: Text(
                hintText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[700], // Hint text color
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentMethod = paymentMethods[newValue!];
                  print("Selected Payment Method ID: $selectedPaymentMethod");
                });
              },
              items: paymentMethods.keys
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
                    //  TextStyle(
                    //   color: isDarkMode ? Colors.white : Colors.black,
                    //   fontWeight: FontWeight.normal,
                    //   fontSize: 16,
                    // ),
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

  Widget _buildTextArea({
    required String label,
    required String hintText,
    int maxLines = 4,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Using the same blue color from the _buildPaymentDropdownField
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
          controller: controller,
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
                color: customBlue, // Using custom blue for focus
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldR({
    required String label,
    required String hintText,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: isPassword,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
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
              borderRadius: BorderRadius.circular(
                  10), // Rounded corners for focused state
              borderSide: BorderSide(
                color: const Color.fromARGB(
                    255, 62, 162, 233), // Focused border color
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade700, // Error color
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceField({
    required String label,
    required String hintText,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDarkMode
                    ? Colors.blueAccent.shade700
                    : Colors.grey.shade400,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 62, 162, 233),
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : Colors.black, // Adjusted text color for dark mode
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: isPassword,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
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
              borderRadius: BorderRadius.circular(
                  10), // Rounded corners for focused state
              borderSide: BorderSide(
                color: const Color.fromARGB(
                    255, 62, 162, 233), // Focused border color
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade700, // Error color
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
