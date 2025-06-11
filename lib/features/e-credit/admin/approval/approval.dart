import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/Approval/Model/get_application_model.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/controller/approver_controller.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/model/login_branch_model.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/controller/creditlimit_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/global_fields/global_fields/custom_text_widget.dart';
import 'package:impal_desktop/features/e-credit/global/custom_dropdown.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/header.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:intl/intl.dart';

class DealerApprovalPage extends StatefulWidget {
  const DealerApprovalPage({super.key});

  @override
  _DealerApprovalPageState createState() => _DealerApprovalPageState();
}

class _DealerApprovalPageState extends State<DealerApprovalPage> {
  // Map<String, bool> expandedSections = {};

  final CreditlimitController creditController =
      Get.put(CreditlimitController());
  final ApproverController approverController = Get.put(ApproverController());
  final LoginController loginController = Get.put(LoginController());
    final ScrollController _scrollController = ScrollController();

  String? selectedBranchId;
  String? selectedApplication;

  final TextEditingController customerIdController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController applicationDateController =
      TextEditingController();
  final TextEditingController distributorNameController =
      TextEditingController(text: "IMPAL");
  bool _isLoading = false;
  bool _isloadings = false;
  TextEditingController reasonController = TextEditingController();

  String? selectedValue1;
  String? selectedValue;
  TextEditingController textController1 = TextEditingController();
  bool showValidityDueDate = true;
  int? validityIndicatorId;


  // Scroll up function
  void _scrollUp() {
    _scrollController.animateTo(
      (_scrollController.offset - 500).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Scroll down function
  void _scrollDown() {
    _scrollController.animateTo(
      (_scrollController.offset + 500).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  @override
  void initState() {
    super.initState();
    approverController.nameOfDealerController.clear();
    approverController.appDateController.clear();
    approverController.nameOfDealerController.clear();
    approverController.authorisedPersonController.clear();
    approverController.dealeridController.clear();
    approverController.mobileNumberController.clear();
    approverController.branchController.clear();
    approverController.dStateController.clear();
    approverController.dZoneController.clear();
    approverController.typeofFirmController.clear();
    approverController.dTownController.clear();
    approverController.dDistrictController.clear();
    approverController.dClassificationController.clear();
    approverController.dBusinessSegmentController.clear();
    approverController.gstInLocalController.clear();
    approverController.exisCreditController.clear();
    approverController.enhCreditLimitController.clear();
    approverController.dBankSalesExecutiveController.clear();
    approverController.typeofRegController.clear();
    approverController.address1Controller.clear();
    approverController.address2Controller.clear();
    approverController.gstRegNumController.clear();
    approverController.dPostalCodeController.clear();
    approverController.dPanController.clear();
    approverController.contactPersonController.clear();
    approverController.contactPersonMobController.clear();
    approverController.emailIdController.clear();
    approverController.appDateController.clear();
    approverController.freightIndiController.clear();
    approverController.validityDueDateController.clear();
    approverController.creditLimitIndiController.clear();
    approverController.validityIndiController.clear();
    approverController.custIdController.clear();
    approverController.townLocationController.clear();
    approverController.rrAssignedDealerController.clear();
    //model
    approverController.getapp.clear();
    approverController.fetchApproverBranch();
  }

  @override
  void dispose() {
    approverController.fetchApproverBranch();
    approverController.fetchApproverApplication();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: GlobalAppBar(title: 'Approval'),
        body: Stack(
    children: [
      CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Expanded(
                  //   child: Obx(() {
                  //     if (approverController.isLoadingsbranch.value) {
                  //       return Center(
                  //         child: SizedBox(
                  //           width: 24,
                  //           height: 24,
                  //           child: CircularProgressIndicator(
                  //             color: Colors.blue,
                  //             strokeWidth: 2,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //     if (approverController.branchdropdown.isEmpty) {
                  //       return const Center(
                  //           child: Text("No branches available"));
                  //     }

                  //     final List<Branches> allBranches =
                  //         approverController.branchdropdown.first.branches ??
                  //             [];
                  //     Map<String, String> branchMap = {
                  //       for (var branch in allBranches)
                  //         branch.branchName ?? "Unknown": branch.branchId ?? ""
                  //     };

                  //     return CustomDropDownField(
                  //       label: "Branch",
                  //       hint: "Choose a branch",
                  //       isRequired: true,
                  //       value: branchMap.entries
                  //           .firstWhere(
                  //               (entry) => entry.value == selectedBranchId,
                  //               orElse: () => MapEntry("", ""))
                  //           .key,
                  //       onChanged: (String? newValue) {
                  //         setState(() {
                  //           selectedBranchId = branchMap[newValue] ?? "";
                  //           approverController.getapp.clear();
                  //           customerIdController.text = '';

                  //           approverController.nameOfDealerController.text = '';
                  //           approverController.authorisedPersonController.text =
                  //               '';
                  //           approverController.dealeridController.text = '';
                  //           approverController.mobileNumberController.text = '';
                  //           approverController.branchController.text = '';
                  //           approverController.dStateController.text = '';
                  //           approverController.dZoneController.text = '';
                  //           approverController.typeofFirmController.text = '';
                  //           approverController.dTownController.text = '';
                  //           approverController.dDistrictController.text = '';
                  //           approverController.dClassificationController.text =
                  //               '';
                  //           approverController.dBusinessSegmentController.text =
                  //               '';
                  //           approverController.gstInLocalController.text = '';
                  //           approverController.exisCreditController.text = '';
                  //           approverController.enhCreditLimitController.text =
                  //               '';
                  //           approverController
                  //               .dBankSalesExecutiveController.text = '';
                  //           approverController.typeofRegController.text = '';
                  //           approverController.address1Controller.text = '';
                  //           approverController.address2Controller.text = '';
                  //           approverController.gstRegNumController.text = '';
                  //           approverController.dPostalCodeController.text = '';
                  //           approverController.dPanController.text = '';
                  //           approverController.contactPersonController.text =
                  //               '';
                  //           approverController.contactPersonMobController.text =
                  //               '';
                  //           approverController.emailIdController.text = '';
                  //           approverController.appDateController.text = '';
                  //           approverController.freightIndiController.text = '';
                  //           approverController.validityDueDateController.text =
                  //               '';
                  //           approverController.creditLimitIndiController.text =
                  //               '';
                  //           approverController.validityIndiController.text = '';
                  //         });

                  //         final String salesrepId =
                  //             loginController.employeeModel.salesRepId ?? '';

                  //         approverController.fetchApplication(
                  //             selectedBranchId!, salesrepId);

                  //         print("Selected Branch ID: $selectedBranchId");
                  //       },
                  //       items: allBranches
                  //           .map((branch) => branch.branchName ?? "Unknown")
                  //           .toList(),
                  //     );
                  //   }),
                  // ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      if (approverController.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (approverController.getapp.isEmpty) {
                        return const Center(
                            child: Text("No Pending Application available"));
                      }

                      final List<Branches> allBranches =
                          approverController.branchdropdown.first.branches ??
                              [];
                      return CustomDropDownField(
                        label: "Pending Application",
                        hint: "Select...",
                        isRequired: true,
                        value: approverController.getapp.any((applicationno) =>
                                applicationno.delarID == selectedApplication)
                            ? selectedApplication
                            : null,
                        onChanged: (newValue) {
                          setState(() {
                            selectedApplication = newValue!;
                            // Find selected application object
                            GetApplication? selectedApp =
                                approverController.getapp.firstWhere(
                              (app) => app.delarID == selectedApplication,
                              orElse: () => GetApplication(),
                            );

                            // Update TextEditingControllers
                            customerIdController.text =
                                selectedApp.customerID ?? "";
                          });

                          approverController
                              .fetchApplicationDetail(selectedApplication!);

                          if (!approverController.getapp.any((application) =>
                              application.delarID == selectedApplication)) {
                            setState(() {
                              selectedApplication = null;
                            });
                          }

                          print("Selected ApplicationNo: $selectedApplication");

                          // expandedSections["(A) Dealer KYC"] = true;
                        },
                        items: approverController.getapp
                            .map((GetApplication application) =>
                                application.delarID ?? "Unknown")
                            .toList(),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField("Application Date",
                          approverController.appDateController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "Distributor Name", distributorNameController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "Customer Id", approverController.custIdController)),
                ],
              ),
              const SizedBox(height: 20),
              buildSection("(A) Dealer KYC"),
              buildSection("(B) Dealer Profile"),
              buildSection("(C) Review and Approval at Branch Level"),
              buildSection("(D) Review and Approval at Head Office"),
              buildSection(
                  "(E) Closure of Business with Dealer (with closure of sister concern accounts)"),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Aligns buttons to the right
                children: [
                  SizedBox(
                    width: 120, // Reduced button width
                    height: 36, // Reduced button height
                    child: ElevatedButton(
                      onPressed: _isloadings
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomAlertDialog(
                                    title: 'Confirm',
                                    message:
                                        'Are you sure you want to update the application?',
                                    onConfirm: () async {
                                      Navigator.of(context).pop();
                                      if (approverController
                                          .custIdController.text.isEmpty) {
                                        AppSnackBar.alert(
                                            message:
                                                "Please choose the application");
                                        return;
                                      }
                                      if (approverController
                                              .creditSalesControllerId.text !=
                                          "1") {
                                        if (validityIndicatorId == null) {
                                          AppSnackBar.alert(
                                              message:
                                                  "Please choose the Approver Validity Indicator");
                                          return;
                                        }
                                      }
                                      setState(() => _isloadings = true);

                                      await approverController
                                          .sendApprovalStatus(
                                              "2",
                                              "",
                                              approverController
                                                  .custIdController.text,
                                              approverController
                                                  .enhCreditLimitController
                                                  .text,
                                              approverController
                                                  .dealeridController.text,
                                              dateController.text);

                                      setState(() => _isloadings = false);
                                      // approverController.getapp.clear();
                                      // approverController.fetchApproverBranch();
                                    },
                                    onCancel: () => Navigator.of(context).pop(),
                                  );
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isloadings)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                             Text(
                              "Approve",
                              // style:
                              //     TextStyle(color: Colors.white, fontSize: 16),
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 16),
                              
                            ),
                        ],
                      ),
                      // child: const Text(
                      //   "APPROVE",
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomAlertDialog(
                                    title: 'Confirm',
                                    message:
                                        'Are you sure you want to update the application?',
                                    textController: reasonController,
                                    onConfirm: () async {
                                      Navigator.of(context).pop();

                                      //  if(approverController.creditSalesControllerId.text != "1"){
                                      //     if(validityIndicatorId == null){
                                      //    AppSnackBar.alert(
                                      //       message:
                                      //           "Please choose the Approver Validity Indicator");
                                      //   return;
                                      //     }
                                      // }
                                      if (approverController
                                          .custIdController.text.isEmpty) {
                                        AppSnackBar.alert(
                                            message:
                                                "Please choose the application");
                                        return;
                                      }

                                      if (reasonController.text.isEmpty) {
                                        AppSnackBar.alert(
                                            message:
                                                "Please provide a reason for rejection");
                                        return;
                                      }

                                      setState(() => _isLoading = true);

                                      await approverController
                                          .sendApprovalStatus(
                                              "3",
                                              reasonController.text,
                                              approverController
                                                  .custIdController.text,
                                              approverController
                                                  .enhCreditLimitController
                                                  .text,
                                              approverController
                                                  .dealeridController.text,
                                              dateController.text);

                                      setState(() => _isLoading = false);
                                      // approverController.getapp.clear();
                                      // approverController.fetchApproverBranch();
                                    },
                                    onCancel: () {
                                      reasonController.clear();
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                             Text(
                              "Reject",
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 16),
                              // style:
                              //     TextStyle(color: Colors.white, fontSize: 16),
                             ),
                        ],
                      ),
                      
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
      Positioned(
            top: 250,
            right: 4,
            bottom: 5,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _scrollUp,
                  mini: true,
                  child: const Icon(Icons.arrow_upward),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _scrollDown,
                  mini: true,
                  child: const Icon(Icons.arrow_downward),
                ),
              ],
            ),
          ),
    ],
      ),
    );
  }
  /// **Dropdown Field**
  Widget buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
          final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, 
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        // style: TextStyle(fontWeight: FontWeight.bold)
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.yellow[100],
          ),
        ),
      ],
    );
  }

  /// **Date Picker Field**
  Widget buildDateField(String label, TextEditingController controller) {
    // Set default date when the widget is first built
    if (controller.text.isEmpty) {
      DateTime now = DateTime.now();
      controller.text = "${now.day}-${now.month}-${now.year}";
    }
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:theme.textTheme.bodyLarge?.copyWith(
            fontSize: 12, fontWeight: FontWeight.bold
          )
          // style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 38,
          child: TextFormField(
            controller: controller,
            readOnly: true, // Prevent user input
              style:theme.textTheme.bodyLarge?.copyWith(
            fontSize: 12
          ),
            // style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              filled: true,
              fillColor: Colors.yellow[100],
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

  Widget buildReadOnlyTextField(
      String label, TextEditingController controller) {
          final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
          // style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style:  theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
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

  Widget buildReadOnlyTextFieldColor(
      String label, TextEditingController controller) {
        final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:theme.textTheme.bodyLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.bold)
          // style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style:theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              filled: true,
              fillColor: Color(0xFFFFFDE7),
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

  Widget buildSection(String title) {
    // Ensure section state is initialized
    // expandedSections.putIfAbsent(title, () => false);
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          /// **Clickable Header**
          InkWell(
            // onTap: () {
            //   setState(() {
            //     expandedSections[title] = !expandedSections[title]!;
            //   });
            // },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          /// **Expanded Content (Only Shows if Section is Open)**
          // if (expandedSections[title]!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: buildSectionContent(title),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> buildSectionContent(String title) {
      final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    switch (title) {
      case "(A) Dealer KYC":
        return [
          Column(children: [
            Row(children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "If any cash purchase in last three months ( Specify)",
                        approverController.cashPurchaseController)),
                const SizedBox(width: 10),
                const Expanded(
                    child: Column(
                  children: [],
                )),
                const Expanded(
                    child: Column(
                  children: [],
                )),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField("Existing Credit Limit Rs",
                        approverController.exisCreditController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextFieldColor("Enhanced Credit Limit",
                        approverController.enhCreditLimitController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Credit Limit Indicator",
                        approverController.creditLimitIndiController)),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField("Credit Sales",
                        approverController.creditSalesController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Proposed Validity",
                        approverController.validityIndiController)),
                const SizedBox(width: 10),
                // Expanded(
                //     child: buildReadOnlyTextField("Validity Due Date",
                //         approverController.validityDueDateController)),

                if (approverController.creditSalesControllerId.text != "1")
                  const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        String selectedText =
                            approverController.validityIndi.value == "2"
                                ? "Temporary"
                                : approverController.validityIndi.value == "3"
                                    ? "Permanent"
                                    : "";

                        return CustomDropDownField(
                          label: "Approver Validity Indicator",
                          hint: "Select a Validity Indicator",
                          isRequired: true,
                          value: selectedText.isNotEmpty ? selectedText : null,
                          items: ["Temporary", "Permanent"],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              int newValueId = newValue == "Temporary" ? 2 : 3;
                              validityIndicatorId = newValueId;
                              print(
                                  "Selected Validity Indicator ID: $validityIndicatorId");

                              if (newValueId == 2) {
                                DateTime now = DateTime.now();
                                DateTime lastDay =
                                    DateTime(now.year, now.month + 1, 0);
                                dateController.text =
                                    "${lastDay.day}/${lastDay.month}/${lastDay.year}";
                                showValidityDueDate = true;
                                approverController.showValidityDueDate.value =
                                    true; // Update observable
                              } else {
                                approverController.showValidityDueDate.value =
                                    false;
                                showValidityDueDate = false;
                                dateController.clear();
                              }

                              approverController
                                  .setValidityIndicator(newValueId.toString());
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(
                    width: 16), // Space between date picker and checkbox
                Expanded(
                  child: SizedBox(
                    width: 400, // Adjust width
                    height: 65, // Adjust height
                    child: Obx(() {
                      return approverController.showValidityDueDate.value
                          ? SizedBox(
                              width: 400,
                              height: 65,
                              child: CustomTextContainer(
                                label: 'Approver Validity Due Date',
                                controller: dateController,
                                readOnly: true,
                                hint: 'Enter Validity Date',
                                required: true,
                                backgroundColor: Colors.white,
                                suffixIcon: Icon(Icons.calendar_today),
                                onTap: () async {
                                  await _pickDate(autoSelect: false);
                                },
                              ),
                            )
                          : SizedBox(); // Hides the field when not needed
                    }),
                  ),
                ),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField("Freight Indicator",
                        approverController.freightIndiController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "First Time Credit Amount Request Rs",
                        approverController.firstTimeCreditLimitIndiController)),
              ]),
              const SizedBox(
                height: 25,
              ),
               Row(
                children: [
                  Text(
                    "Dealer Bank Account Details",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(width: 10),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "Bank Name", approverController.dBankNameController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Bank Branch Name",
                        approverController.dBankBranchController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Bank Account Number",
                        approverController.dBankAccNumController)),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "IFSC Code", approverController.dBankIFSCController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "Name of the Bank A/C Holder ",
                        approverController.dNameOfBankController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Card No. and Expiry Date",
                        approverController.dBankCardNoController)),
              ]),
              const SizedBox(
                height: 25,
              ),
               Row(
                children: [
                  Expanded(
                    child: Text(
                      "Authorized Signature with Name of Dealer",
                        style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Dealer Official Seal",
                        style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Name of Dealer/Firm/STU",
                      approverController.nameOfDealerController)),
              const SizedBox(width: 10),
              const Expanded(
                  child: Column(
                children: [],
              )),
              const Expanded(
                  child: Column(
                children: [],
              )),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Text(
                  "Address of Dealer/ Firm/ STU",
                  style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                 
                )
              ],
            ),
            const SizedBox(width: 10),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField(
                      "Address 1", approverController.address1Controller)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Address 2", approverController.address2Controller)),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Text(
                  "Name of the Proprietor / Director / Partner",
                  style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(width: 10),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Authorised Person",
                      approverController.authorisedPersonController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Mobile No. of Proprietor",
                      approverController.mobileNumberController)),
              const SizedBox(width: 10),
            ]),
            const SizedBox(
              height: 25,
            ),
             Row(
              children: [
                Text(
                  "Dealer migration from one branch to another",
                    style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(width: 10),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField(
                      "Branch", approverController.branchController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Dealer Name", approverController.dealerNameController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Migration Branch",
                      approverController.migrationBranchController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Dealer Code", approverController.dealerCodeController)),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Year Of Establishment",
                      approverController.yearofEstController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Dealer State", approverController.dStateController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Dealer District",
                      approverController.dDistrictController)),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField(
                      "Dealer Town", approverController.dTownController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Town Location",
                      approverController.townLocationController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Dealer Zone", approverController.dZoneController)),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Contact Person Name",
                      approverController.contactPersonController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Contact Person Mobile",
                      approverController.contactPersonMobController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Email Id", approverController.emailIdController)),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Dealer Location",
                      approverController.dLocationController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Dealer Postal Code",
                      approverController.dPostalCodeController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Dealer PAN", approverController.dPanController)),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField(
                      "Type Of Firm", approverController.typeofFirmController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Type of Registration",
                      approverController.typeofRegController)),
              const SizedBox(width: 10),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("GST Registration Number",
                      approverController.gstRegNumController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("GSTIN Local or Outside State",
                      approverController.gstInLocalController)),
              const SizedBox(width: 10),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField(
                      "Distance from Branch to Dealer",
                      approverController.branchToDealerController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Dealer Overall Stock Value",
                      approverController.overallStockController)),
              const SizedBox(width: 10),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Dealer Annual Turonover",
                      approverController.dAnnualTurnoverController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Dealer IMPAL Lines Sales Turnover",
                      approverController.salesTurnoverController)),
              const SizedBox(width: 10),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField(
                      "Distance from RR Location to Dealer ",
                      approverController.rrLocationToDealerController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Salesman/RR assigned to the Dealer",
                      approverController.rrAssignedDealerController)),
              const SizedBox(width: 10),
            ]),
            const SizedBox(
              height: 25,
            ),
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Periodicity of Dealer Visit",
                      approverController.periodicityDealerController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Dealer Monthly Target",
                      approverController.dMonthlyTargetController)),
              const SizedBox(width: 10),
            ]),
          ]),
        ];
      case "(B) Dealer Profile":
        return [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: buildReadOnlyTextField("Dealer Classification ",
                          approverController.dClassificationController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField("Dealer Business Segment",
                          approverController.dBusinessSegmentController)),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
               Row(
                children: [
                  Text(
                    "List of key lines directly purchased from Manufacturers",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(width: 10),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "(1)", approverController.profileOneController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "(2)", approverController.profileTwoController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "(3)", approverController.profileThreeController)),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "(4)", approverController.profileFourController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "(5)", approverController.profileFiveController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "(6)", approverController.profileSixController)),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "Is the dealer at present dealing with any TVS Group companies? If so details",
                        approverController.dealerTVSController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Any additional information",
                        approverController.addInfoController)),
              ]),
              const SizedBox(
                height: 25,
              ),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField("Transporter Name",
                        approverController.transporterNameController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Addl Info on Dealer, if any",
                        approverController.addlInfoDealerController)),
              ]),
              const SizedBox(
                height: 25,
              ),
               Row(
                children: [
                  Text(
                    "Details of lines as ASC",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(width: 10),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField(
                        "(1)", approverController.ascOneController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "(2)", approverController.ascTwoController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "(3)", approverController.ascThreeController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField(
                        "(4)", approverController.ascFourController)),
              ]),
              Row(children: [
                Expanded(
                    child: buildReadOnlyTextField("Other Brand Name (Specify)",
                        approverController.otherBrandNameController)),
                const SizedBox(width: 10),
                Expanded(
                    child: buildReadOnlyTextField("Authorized Service Centres",
                        approverController.authServicecenController)),
              ]),
            ],
          ),
        ];
      // case "(C) Commercial Matters":
      //   return [
      //     Column(
      //       children: [
              
      //       ],
      //     ),
      //   ];
      case "(C) Review and Approval at Branch Level":
        return [
          Column(children: [
            Row(children: [
              Expanded(
                  child: buildReadOnlyTextField("Branch Sales Executive's Name",
                      approverController.dBankSalesExecutiveController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField("Recommended By Manager Name",
                      approverController.dBankManagerNameController)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildReadOnlyTextField(
                      "Authorised by Area Manager Name",
                      approverController.dAreaManagerNameController)),
            ]),
            const SizedBox(
              height: 25,
            ),
             Row(
              children: [
                Expanded(
                  child: Text(
                    "Signature & Date",
                    // style: TextStyle(fontWeight: FontWeight.bold),
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Signature & Date",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    // style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Signature & Date",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    // style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ]),
        ];
      case "(D) Review and Approval at Head Office":
        return [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "No. of Cheque Returns",
                        style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,color: Colors.red),
                      // style: TextStyle(
                      //     fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Expanded(
                    child: buildDateField("Date", applicationDateController),
                  ),
                  const SizedBox(width: 10),
                   Expanded(
                    child: Text(
                      "",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                   Expanded(
                    child: Text(
                      "",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
             Row(
                children: [
                  Expanded(
                    child: Text(
                      "Zonal Head Signature",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
               Row(
                children: [
                  Expanded(
                    child: Text(
                      "Accounts & IT Department for Creation of Customer Master",
                    style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "",
                    style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Expanded(
                    child: buildReadOnlyTextField("Customer code",
                        approverController.customerCodeController),
                  ),
                  const SizedBox(width: 10),
                   Expanded(
                    child: Text(
                      "DMD Signature (Digital)",
                     style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ];
      case "(E) Closure of Business with Dealer (with closure of sister concern accounts)":
        return [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildReadOnlyTextField("Write off amount if any Rs",
                        approverController.offAmountController),
                  ),
                  const SizedBox(width: 10),
                   Expanded(
                    child: Text(
                      "CFO Signature (Digital)",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                   Expanded(
                    child: Text(
                      "DMD Signature (Digital)",
                      style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ];
      default:
        return [];
    }
  }

  // Widget buildSection(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
  //     child: Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
  //       decoration: BoxDecoration(
  //         color: Color(0xFFEFF1F5),
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(color: Colors.grey.withOpacity(0.2)),
  //       ),
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //           color: Colors.black,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> _pickDate({required bool autoSelect}) async {
    DateTime now = DateTime.now();
    DateTime lastDate = DateTime(now.year, now.month + 1, 0);
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime last = DateTime(now.year, now.month + 8, 0);

    if (autoSelect) {
      // ✅ Automatically select last date of the month
      String formattedDate = DateFormat('dd/MM/yyyy').format(lastDate);
      dateController.text = formattedDate;

      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: lastDate, // ✅ Default to last date of the month
      firstDate: today, // ✅ Allow selection only from today
      lastDate: last, // ✅ Restrict to end of the two month
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      dateController.text = formattedDate;
    }
  }
}
