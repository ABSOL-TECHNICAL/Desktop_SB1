import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/controller/approver_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/status/controller/statuscontroller.dart';
import 'package:impal_desktop/features/e-credit/customer/status/model/application_status_model.dart';
import 'package:impal_desktop/features/e-credit/customer/withdraw/controller/withdraw_controller.dart';
import 'package:impal_desktop/features/e-credit/global/custom_textfield.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class WithdrawalCustomerApplication extends StatefulWidget {
  static const String routeName = '/WithdrawalCustomerApplication';

  const WithdrawalCustomerApplication({super.key});
  @override
  _WithdrawalCustomerApplicationState createState() =>
      _WithdrawalCustomerApplicationState();
}

class _WithdrawalCustomerApplicationState
    extends State<WithdrawalCustomerApplication> {
  bool _isLoading = false;

  final StatusController statusController = Get.put(StatusController());
  final WithdrawController withdrawController = Get.put(WithdrawController());
  final ApproverController approverController = Get.put(ApproverController());
  final LoginController loginController = Get.put(LoginController());

  String? selectedApplication;
  File? selectedFile;
  String? selectedFileName;

  @override
  void initState() {
    super.initState();
    withdrawController.nameOfDealerController.clear();
    withdrawController.custIdController.clear();
    withdrawController.rrAssignedDealerController.clear();
    withdrawController.creditSalesController.clear();
    withdrawController.appDateController.clear();
    withdrawController.nameOfDealerController.clear();
    withdrawController.authorisedPersonController.clear();
    withdrawController.dealeridController.clear();
    withdrawController.mobileNumberController.clear();
    withdrawController.branchController.clear();
    withdrawController.dStateController.clear();
    withdrawController.dZoneController.clear();
    withdrawController.typeofFirmController.clear();
    withdrawController.dTownController.clear();
    withdrawController.dDistrictController.clear();
    withdrawController.dClassificationController.clear();
    withdrawController.dBusinessSegmentController.clear();
    withdrawController.gstInLocalController.clear();
    withdrawController.exisCreditController.clear();
    withdrawController.enhCreditLimitController.clear();
    withdrawController.dBankSalesExecutiveController.clear();
    withdrawController.typeofRegController.clear();
    withdrawController.address1Controller.clear();
    withdrawController.address2Controller.clear();
    withdrawController.gstRegNumController.clear();
    withdrawController.dPostalCodeController.clear();
    withdrawController.dPanController.clear();
    withdrawController.contactPersonController.clear();
    withdrawController.contactPersonMobController.clear();
    withdrawController.emailIdController.clear();
    withdrawController.appDateController.clear();
    withdrawController.freightIndiController.clear();
    withdrawController.validityDueDateController.clear();
    withdrawController.creditLimitIndiController.clear();
    withdrawController.validityIndiController.clear();
    // model
    final String branchId = loginController.employeeModel.branchid ?? '';
    withdrawController.fetchApplicationName(branchId);
  }

  // Controllers
  final TextEditingController dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  final TextEditingController distributorController = TextEditingController(
    text: 'IMPAL',
  );

  TextEditingController branchController = TextEditingController();
  List<String> branchList = ['Branch 1', 'Branch 2', 'Branch 3'];
  TextEditingController dealerNameController = TextEditingController();
  List<String> dealernamelist = [
    'dealerName 1',
    'dealerName 2',
    'dealerName 3'
  ];

  final List<String> brands = ["WABCO", "Rane TRW", "Turbo", "Lucas"];
  void __clearFormFields() {
     withdrawController.nameOfDealerController.clear();
    withdrawController.custIdController.clear();
    withdrawController.rrAssignedDealerController.clear();
    withdrawController.creditSalesController.clear();
    withdrawController.appDateController.clear();
    withdrawController.nameOfDealerController.clear();
    withdrawController.authorisedPersonController.clear();
    withdrawController.dealeridController.clear();
    withdrawController.mobileNumberController.clear();
    withdrawController.branchController.clear();
    withdrawController.dStateController.clear();
    withdrawController.dZoneController.clear();
    withdrawController.typeofFirmController.clear();
    withdrawController.dTownController.clear();
    withdrawController.dDistrictController.clear();
    withdrawController.dClassificationController.clear();
    withdrawController.dBusinessSegmentController.clear();
    withdrawController.gstInLocalController.clear();
    withdrawController.exisCreditController.clear();
    withdrawController.enhCreditLimitController.clear();
    withdrawController.dBankSalesExecutiveController.clear();
    withdrawController.typeofRegController.clear();
    withdrawController.address1Controller.clear();
    withdrawController.address2Controller.clear();
    withdrawController.gstRegNumController.clear();
    withdrawController.dPostalCodeController.clear();
    withdrawController.dPanController.clear();
    withdrawController.contactPersonController.clear();
    withdrawController.contactPersonMobController.clear();
    withdrawController.emailIdController.clear();
    withdrawController.appDateController.clear();
    withdrawController.freightIndiController.clear();
    withdrawController.validityDueDateController.clear();
    withdrawController.creditLimitIndiController.clear();
    withdrawController.validityIndiController.clear();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdrawal Customer Application',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
        // style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // appBar: AppBar(
      //   title: const Text('Withdrawal Customer Application'),
      //   backgroundColor: const Color.fromARGB(255, 151, 161, 255),
      // ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child:         Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                child: 
            Align(
                  alignment: Alignment.topRight,
                 child: InkWell(
                      onTap: () {
                      __clearFormFields();
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
              ), ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Application",
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        // style: TextStyle(
                        //     fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (withdrawController.isLoadings.value) {
                          return const CircularProgressIndicator(); // Show loading indicator
                        }

                        if (withdrawController.applicationName.isEmpty) {
                          return Text("No Application Available",
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(color: Colors.red)
                              // style: TextStyle(color: Colors.red),
                              );
                        }

                        return DropdownButtonFormField<String>(
                          value: withdrawController.applicationName.any(
                                  (applicationno) =>
                                      applicationno.delarID ==
                                      selectedApplication)
                              ? selectedApplication
                              : null, // Reset if value is not in the list
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 1.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          hint: Text(
                            "Select an Application",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          items: withdrawController.applicationName
                              .map((ApplicationName application) {
                            return DropdownMenuItem<String>(
                              value: application.delarID,
                              child: Text(
                                "${application.delarID} - ${application.customer}",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedApplication = newValue!;
                            });
                            withdrawController.fetchApplicationDetailwithdraw(
                                selectedApplication!);
                          },
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildReadOnlyFields(
                      'Distributor Name', distributorController),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                    child: buildReadOnlyTextField("Name of Dealer/Firm/STU",
                        withdrawController.nameOfDealerController)),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: _buildReadOnlyFields(
                        'Customer ID', withdrawController.custIdController)),
              ],
            ),
            const SizedBox(height: 50),
            Text(
              'Address of Dealer/ Firm/ STU:',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "Address 1", withdrawController.address1Controller)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Address 2", withdrawController.address2Controller)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                      label:
                          'Name of the Proprietor / Director / Partner / Authorised Person',
                      hint: 'Enter Name of the Proprietor ',
                      isRequired: false),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Authorised Person",
                        withdrawController.authorisedPersonController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Mobile No. of Proprietor",
                        withdrawController.mobileNumberController)),
              ],
            ),
            const SizedBox(height: 50),
            Text(
              'If any Group/ Sister Customer exists within IMPAL :',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextFormField(
                      label: 'S.No',
                      hint: 'Enter Address 1',
                      isRequired: false),
                ),
                //  ),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Branch", withdrawController.branchController)),
                // Expanded(
                //   child: CustomDropDownField(
                //     label: 'Branch',
                //     items: branchList,
                //     isRequired: false,
                //     hint: '',
                //   ),
                // ),

                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer Name",
                        withdrawController.dealerNameController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer Code",
                        withdrawController.dealerCodeController)),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextFormField(
                    label: 'Credit Limit (Rs.)',
                    hint: 'Enter Credit Limit (Rs.)',
                    isRequired: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            Text(
              'Dealer migration from one branch to another :',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextFormField(
                      label: 'Branch',
                      hint: 'Select Branch',
                      isRequired: false),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextFormField(
                    label: 'Dealer Name',
                    hint: 'Select Dealer Name',
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextFormField(
                    label: 'Migration Branch',
                    hint: 'Select Migration Branch',
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextFormField(
                      label: 'Dealer Code (Rs.)',
                      hint: 'Select Dealer code',
                      isRequired: false),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Year Of Establishment",
                        withdrawController.yearofEstController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Dealer State", withdrawController.dStateController)
                    // CustomDropDownField(
                    //   label: 'Dealerstate',
                    //   hint: '',
                    //   isRequired: false,
                    //   items: [],
                    // ),
                    ),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer District",
                        withdrawController.dDistrictController)
                    //  CustomDropDownField(
                    //     label: 'Dealer District',
                    //     items: [],
                    //     hint: '',
                    //     isRequired: false),
                    ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Dealer Town", withdrawController.dTownController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Town Location",
                        withdrawController.townLocationController)
                    // CustomDropDownField(
                    //   label: 'Town Location',
                    //   hint: '',
                    //   isRequired: false,
                    //   items: [],
                    // ),
                    ),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Dealer Zone", withdrawController.dZoneController)
                    // CustomDropDownField(
                    //   label: 'Dealer Zone',
                    //   items: [],
                    //   isRequired: false,
                    //   hint: '',
                    // ),
                    ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 16),
                // Expanded(
                //     child: buildReadOnlyTextField("Contact Person Name",
                //         withdrawController.contactPersonController)),
                // const SizedBox(width: 16),
                // Expanded(
                //     child: buildReadOnlyTextField("Contact Person Mobile",
                //         withdrawController.contactPersonMobController)),
                // const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Email Id", withdrawController.emailIdController)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer Location",
                        withdrawController.dLocationController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer Postal Code",
                        withdrawController.dPostalCodeController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Dealer PAN", withdrawController.dPanController)),
              ],
            ),
            const SizedBox(height: 70),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Type Of Firm",
                        withdrawController.typeofFirmController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Type of Registration",
                        withdrawController.typeofRegController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("GST Registration Number",
                        withdrawController.gstRegNumController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "GSTIN Local or Outside State",
                        withdrawController.gstInLocalController)),
              ],
            ),
            const SizedBox(height: 70),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Distance from Branch to Dealer",
                        withdrawController.branchToDealerController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer Overall Stock Value",
                        withdrawController.overallStockController)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer Annual Turonover",
                        withdrawController.dAnnualTurnoverController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Dealer IMPAL Lines Sales Turnover",
                        withdrawController.salesTurnoverController)),
              ],
            ),
            const SizedBox(height: 20),
            // Row(
            //   children: [
            //     const SizedBox(width: 16),
            //     Expanded(
            //         child: buildReadOnlyTextField(
            //             "Distance from RR Location to Dealer ",
            //             withdrawController.rrLocationToDealerController)),
            //   ],
            // ),
            // const SizedBox(height: 20),
            Row(
              children: [
                // const SizedBox(width: 16),
                // Expanded(
                //     child: buildReadOnlyTextField(
                //         "Classified as Day Travel or Outstation ?",
                //         withdrawController.salesTurnoverController)
                //     // CustomDropDownField(
                //     //   label: 'Classified as Day Travel or Outstation ?',
                //     //   items: [],
                //     //   isRequired: false,
                //     //   hint: '',
                //     // ),
                //     ),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Salesman/RR assigned to the Dealer",
                        withdrawController.rrAssignedDealerController)),
              ],
            ),
            const SizedBox(height: 30),
            Row(children: [
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Grouped company',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Dealer Migration',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: CustomDropDownField(
              //     label: 'Classified as Day Travel or Outstation ?',
              //     items: [],
              //     isRequired: false,
              //     hint: '',
              //   ),
              // ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Year of Establishment',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Period Dealer Visit',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
            ]),
            const SizedBox(height: 30),
            Row(children: [
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Overall Stock Dealer Value',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Annual Turnover',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Dealer IMPAL Sales Turnover',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                    label: 'Brand Authorization Details',
                    hint: 'Enter ...',
                    isRequired: false),
              ),
            ]),
            const SizedBox(height: 30),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GST Form Upload',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();

                          if (result != null &&
                              result.files.single.path != null) {
                            setState(() {
                              selectedFile = File(result.files.single.path!);
                              selectedFileName = result.files.single.name;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedFileName ?? 'Upload File...',
                                  style: TextStyle(
                                    color: selectedFileName == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PAN Card Upload (Unregistered)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();

                          if (result != null &&
                              result.files.single.path != null) {
                            setState(() {
                              selectedFile = File(result.files.single.path!);
                              selectedFileName = result.files.single.name;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedFileName ?? 'Upload File...',
                                  style: TextStyle(
                                    color: selectedFileName == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
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
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Periodicity of Dealer Visit",
                        withdrawController.periodicityDealerController)),
                const SizedBox(width: 16),
                Expanded(
                    child: buildReadOnlyTextField("Dealer Monthly Target",
                        withdrawController.dMonthlyTargetController)),
              ],
            ),

            Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                        child: buildReadOnlyTextField("Dealer Classification ",
                            withdrawController.dClassificationController)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: buildReadOnlyTextField("Dealer Business Segment",
                            withdrawController.dBusinessSegmentController)),
                  ],
                ),
                const SizedBox(height: 50),
                // Text(
                //   'List of key lines directly purchased from Manufacturers',
                //   style: theme.textTheme.bodyLarge
                //       ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                //   // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 10),
                // Row(children: [
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(1)", withdrawController.profileOneController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(2)", withdrawController.profileTwoController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(3)", withdrawController.profileThreeController)),
                // ]),
                // const SizedBox(
                //   height: 25,
                // ),
                // Row(children: [
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(4)", withdrawController.profileFourController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(5)", withdrawController.profileFiveController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(6)", withdrawController.profileSixController)),
                // ]),
                // const SizedBox(height: 20),
                // Row(children: [
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "Is the dealer at present dealing with any TVS Group companies? If so details",
                //           withdrawController.dealerTVSController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "Any additional information",
                //           withdrawController.addInfoController)),
                // ]),
                // const SizedBox(
                //   height: 25,
                // ),
                // Row(children: [
                //   Expanded(
                //       child: buildReadOnlyTextField("Transporter Name",
                //           withdrawController.transporterNameController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "Addl Info on Dealer, if any",
                //           withdrawController.addlInfoDealerController)),
                // ]),
                // const SizedBox(height: 50),
                // Text('Details of lines as ASC',
                //     style: theme.textTheme.bodyLarge
                //         ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                //     // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //     ),
                // const SizedBox(height: 10),
                // Row(children: [
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(1)", withdrawController.ascOneController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(2)", withdrawController.ascTwoController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(3)", withdrawController.ascThreeController)),
                //   const SizedBox(width: 10),
                //   Expanded(
                //       child: buildReadOnlyTextField(
                //           "(4)", withdrawController.ascFourController)),
                // ]),
                // const SizedBox(height: 50),
                // Text('Brand Details as Authorized Service Dealer',
                //     style: theme.textTheme.bodyLarge
                //         ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                //     // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //     ),
                // const SizedBox(height: 10),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildCheckbox('WABCO', '', false),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildCheckbox('Rane TRW', '', false),
                //     ),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildCheckbox('Turbo', '', false),
                //     ),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildCheckbox('Lucas', '', false),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),
                // Row(
                //   children: [
                //     Expanded(
                //         child: buildReadOnlyTextField(
                //             "Other Brand Name (Specify)",
                //             withdrawController.otherBrandNameController)),
                //     const SizedBox(width: 16),
                //     Expanded(
                //         child: buildReadOnlyTextField(
                //             "Authorized Service Centres",
                //             withdrawController.authServicecenController)),
                //   ],
                // ),
              ],
            ),

            // Step(
            //   title: const Text(''),
            //   content:
            Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: buildReadOnlyTextField(
                            "If any cash purchase in last three months ( Specify)",
                            withdrawController.cashPurchaseController)),
                  ],
                ),
                const SizedBox(height: 50),
                Text('Expected sales detail of major lines per month',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                    // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(1)", withdrawController.commercialOneController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(2)", withdrawController.commercialTwoController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(3)", withdrawController.commercialThreeController)),
                ]),
                const SizedBox(
                  height: 25,
                ),
                Row(children: [
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(4)", withdrawController.commercialFourController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(5)", withdrawController.commercialFiveController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(6)", withdrawController.commercialSixController)),
                ]),
                const SizedBox(
                  height: 25,
                ),
                Row(children: [
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(7)", withdrawController.commercialSevenController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(8)", withdrawController.commercialEightController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "(9)", withdrawController.commercialNineController)),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                      child: buildReadOnlyTextField("Existing Credit Limit Rs",
                          withdrawController.exisCreditController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField("Outstanding Amount",
                          withdrawController.outstandingAmntController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField("Enhanced Credit Limit",
                          withdrawController.enhCreditLimitController)),
                ]),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: buildReadOnlyTextField("Credit Limit Indicator",
                            withdrawController.creditLimitIndiController)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: buildReadOnlyTextField("Credit Sales",
                            withdrawController.creditSalesController)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: buildReadOnlyTextField("Validity Due Date",
                            withdrawController.validityDueDateController)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                      child: buildReadOnlyTextField("Freight Indicator",
                          withdrawController.freightIndiController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "First Time Credit Amount Request Rs",
                          withdrawController
                              .firstTimeCreditLimitIndiController)),
                ]),
                const SizedBox(height: 50),
                Text('Dealer Bank Account Details',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: buildReadOnlyTextField(
                          "Bank Name", withdrawController.dBankNameController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField("Bank Branch Name",
                          withdrawController.dBankBranchController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField("Bank Account Number",
                          withdrawController.dBankAccNumController)),
                ]),
                const SizedBox(
                  height: 25,
                ),
                Row(children: [
                  Expanded(
                      child: buildReadOnlyTextField(
                          "IFSC Code", withdrawController.dBankIFSCController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "Name of the Bank A/C Holder ",
                          withdrawController.dNameOfBankController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField("Card No. and Expiry Date",
                          withdrawController.dBankCardNoController)),
                ]),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text("Authorized Signature with Name of Dealer",
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text("Dealer Official Seal",
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            //   isActive: _currentStep >= 2,
            // ),
            // Step(
            //   title: const Text(''),
            //   content:
            Column(
              children: [
                const SizedBox(height: 50),
                // const Text(
                //   '.Accounts & IT Department for Creation of Customer Master',
                //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                // ),
                Row(
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex to allocate more or less space
                      child: CustomTextFormField(
                          label: " No. of Cheque Returns:",
                          hint: '',
                          isRequired: false),
                    ),
                    const SizedBox(width: 12), // Smaller spacing
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                          label: 'Zonal Head Signature:',
                          hint: '',
                          isRequired: false),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   flex: 3, // Allocate more space for this field
                    //   child: CustomTextFormField('Authorised by Area Manager Name', '', false),
                    // ),
                  ],
                ),
                const SizedBox(height: 50),
                Text('Accounts & IT Department for Creation of Customer Master',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex to allocate more or less space
                      child: CustomTextFormField(
                          label: "Customer code :",
                          hint: '',
                          isRequired: false),
                    ),
                    const SizedBox(width: 12), // Smaller spacing
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                          label: 'DMD Signature (Digital):',
                          hint: '',
                          isRequired: false),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   flex: 3, // Allocate more space for this field
                    //   child: CustomTextFormField('', 'Signature & Date', false),
                    // ),
                  ],
                ),
                const SizedBox(height: 50),
                Text('Attachments Required',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex to allocate more or less space
                      child: _buildCheckbox(
                          "1.GST Registration Certificate including the type of GST :",
                          '',
                          false),
                    ),
                    const SizedBox(width: 12), // Smaller spacing
                    Expanded(
                      flex: 2,
                      child: _buildCheckbox(
                          '2.Business card of the dealership ', '', false),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3, // Allocate more space for this field
                      child:
                          _buildCheckbox('Cancelled cheque leaf ', '', false),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex to allocate more or less space
                      child: CustomTextFormField(
                          label: "",
                          hint: 'Signature & Date',
                          isRequired: false),
                    ),
                    const SizedBox(width: 12), // Smaller spacing
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                          label: '',
                          hint: 'Signature & Date',
                          isRequired: false),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3, // Allocate more space for this field
                      child: CustomTextFormField(
                          label: '',
                          hint: 'Signature & Date',
                          isRequired: false),
                    ),
                  ],
                ),
              ],
            ),
            //   isActive: _currentStep >= 3,
            // ),
            // Step(
            // title: const Text(''),
            // content:
            Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex to allocate more or less space
                      child: CustomTextFormField(
                          label: "Write off amount if any Rs.",
                          hint: '',
                          isRequired: false),
                    ),
                    const SizedBox(width: 12), // Smaller spacing
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                          label: 'CFO Signature (Digital):',
                          hint: '',
                          isRequired: false),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3, // Allocate more space for this field
                      child: CustomTextFormField(
                          label: 'DMD Signature (Digital):',
                          hint: '',
                          isRequired: false),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disables button when loading
                      : () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomAlertDialog(
                                title: 'Confirm ',
                                message:
                                    'Are you sure you want to Withdraw the Application?',
                                onConfirm: () async {
                                  Navigator.of(context).pop();

                                  if (withdrawController
                                      .custIdController.text.isEmpty) {
                                    Get.snackbar("Error",
                                        "Please choose the application");
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await withdrawController.submitwithdraw(
                                      withdrawController.custIdController.text);

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  // Clear input fields
                                  withdrawController.nameOfDealerController
                                      .clear();
                                  withdrawController.custIdController.clear();
                                  withdrawController.rrAssignedDealerController
                                      .clear();
                                  withdrawController.creditSalesController
                                      .clear();
                                  withdrawController.appDateController.clear();
                                  withdrawController.authorisedPersonController
                                      .clear();
                                  withdrawController.dealeridController.clear();
                                  withdrawController.mobileNumberController
                                      .clear();
                                  withdrawController.branchController.clear();
                                  withdrawController.dStateController.clear();
                                  withdrawController.dZoneController.clear();
                                  withdrawController.typeofFirmController
                                      .clear();
                                  withdrawController.dTownController.clear();
                                  withdrawController.dDistrictController
                                      .clear();
                                  withdrawController.dClassificationController
                                      .clear();
                                  withdrawController.dBusinessSegmentController
                                      .clear();
                                  withdrawController.gstInLocalController
                                      .clear();
                                  withdrawController.exisCreditController
                                      .clear();
                                  withdrawController.enhCreditLimitController
                                      .clear();
                                  withdrawController
                                      .dBankSalesExecutiveController
                                      .clear();
                                  withdrawController.typeofRegController
                                      .clear();
                                  withdrawController.address1Controller.clear();
                                  withdrawController.address2Controller.clear();
                                  withdrawController.gstRegNumController
                                      .clear();
                                  withdrawController.dPostalCodeController
                                      .clear();
                                  withdrawController.dPanController.clear();
                                  withdrawController.contactPersonController
                                      .clear();
                                  withdrawController.contactPersonMobController
                                      .clear();
                                  withdrawController.emailIdController.clear();
                                  withdrawController.appDateController.clear();
                                  withdrawController.freightIndiController
                                      .clear();
                                  withdrawController.validityDueDateController
                                      .clear();
                                  withdrawController.creditLimitIndiController
                                      .clear();
                                  withdrawController.validityIndiController
                                      .clear();

                                  // Fetch application name
                                  final String branchId =
                                      loginController.employeeModel.branchid ??
                                          '';
                                  withdrawController
                                      .fetchApplicationName(branchId);
                                },
                                onCancel: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFFB91C1C),
                    shadowColor: Colors.black.withOpacity(0.4),
                    elevation: 6,
                    minimumSize: const Size(190, 50),
                  ),
                  child: Text("Withdraw Application",
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),
          ]),
        ),
      ),
    );
    //   isActive: _currentStep >= 4,
    //  ];
  }

  Widget _buildReadOnlyFields(String label, TextEditingController controller) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 12)),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              filled: true,
              fillColor: const Color.fromARGB(255, 234, 232, 232),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// **Read-Only Text Field**
  Widget buildReadOnlyTextField(
      String label, TextEditingController controller) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              filled: true,
              fillColor: const Color.fromARGB(255, 234, 232, 232),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, String subtitle, bool initialValue) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return StatefulBuilder(
      builder: (context, setState) {
        bool isChecked = initialValue;

        return Row(
          children: [
            SizedBox(
              width: 20, // Reduced size for the checkbox
              height: 20,
              child: Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8), // Spacing between checkbox and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
