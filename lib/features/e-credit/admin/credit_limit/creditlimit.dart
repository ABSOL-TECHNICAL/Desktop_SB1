import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/controller/creditlimit_controller.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/model/Model/dealername_model.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/model/Model/validityindicator_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/header.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

class CreditLimitPage extends StatefulWidget {
  const CreditLimitPage({super.key});

  @override
  _CreditLimitPageState createState() => _CreditLimitPageState();
}

class _CreditLimitPageState extends State<CreditLimitPage> {
  final CreditlimitController creditController =
      Get.put(CreditlimitController());

  bool showValidityDueDate = true;

  String? selectedBranchId;
  String? selectedDealerId;
  String? selectedCustomerId;
  int? validityIndicatorId;
  final TextEditingController customerIdController = TextEditingController();
  final TextEditingController dealerIdController = TextEditingController();

  final TextEditingController validityDateController = TextEditingController();
  final TextEditingController validityIndicatorController =
      TextEditingController();
  bool _isLoading = false;
  List<DealerName> previousDealerList = [];

  @override
  void initState() {
    super.initState();
    creditController.dealernname.clear();
    creditController.address1Controller.clear();
    creditController.address2Controller.clear();
    creditController.postalCodeController.clear();
    creditController.gstController.clear();
    creditController.mobileController.clear();
    creditController.creditLimitController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: GlobalAppBar(title: 'Customer Credit Limit'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Customer Details",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Branch",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Obx(() {
                          if (creditController.isLoading.value) {
                            return const Center(
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child:
                                    CircularProgressIndicator(strokeWidth: 1.5),
                              ),
                            );
                          }

                          if (creditController.branches.isEmpty) {
                            return const Text(
                              "No branches available",
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: creditController.branches.any((branch) =>
                                    branch.branchId == selectedBranchId)
                                ? selectedBranchId
                                : null,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            hint: Text(
                              "Select a branch",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            items: creditController.branches.map((branch) {
                              return DropdownMenuItem<String>(
                                value: branch.branchId,
                                child: Text(
                                  branch.branchName ?? "Unknown",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue == null) return;

                              selectedBranchId = newValue;
                              selectedDealerId = null;

                              customerIdController.clear();
                              dealerIdController.clear();
                              creditController.address1Controller.clear();
                              creditController.address2Controller.clear();
                              creditController.postalCodeController.clear();
                              creditController.gstController.clear();
                              creditController.mobileController.clear();
                              creditController.creditLimitController.clear();

                              creditController
                                  .fetchDealerName(selectedBranchId!);
                              print("Selected Branch ID: $selectedBranchId");
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dealer Name",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Obx(() {
                          if (creditController.isLoadings.value) {
                            return const SizedBox(
                              height: 25,
                              width: 25,
                              child:
                                  CircularProgressIndicator(strokeWidth: 1.5),
                            );
                          }

                          if (creditController.dealernname.isEmpty &&
                              previousDealerList.isNotEmpty) {
                            creditController.dealernname
                                .assignAll(previousDealerList);
                          } else {
                            previousDealerList =
                                List.from(creditController.dealernname);
                          }

                          List<DropdownMenuItem<String>> dropdownItems =
                              creditController.dealernname
                                  .map((dealer) => dealer.dealerId)
                                  .toSet()
                                  .map((dealerId) {
                            final dealer = creditController.dealernname
                                .firstWhere((d) => d.dealerId == dealerId);
                            return DropdownMenuItem<String>(
                              value: dealer.dealerId,
                              child: Text(
                                dealer.dealerName ?? "Unknown",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList();

                          return DropdownButtonFormField<String>(
                            value: creditController.dealernname.any((dealer) =>
                                    dealer.dealerId == selectedDealerId)
                                ? selectedDealerId
                                : null,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            hint: Text(
                              "Select a Dealer",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            items: dropdownItems,
                            onChanged: (newValue) {
                              setState(() {
                                selectedDealerId = newValue!;
                                DealerName? selectedDealerObj =
                                    creditController.dealernname.firstWhere(
                                  (dealer) => dealer.dealerId == newValue,
                                  orElse: () => DealerName(),
                                );

                                creditController.address1Controller.text = '';
                                creditController.address2Controller.text = '';
                                creditController.postalCodeController.text = '';
                                creditController.gstController.text = '';
                                creditController.mobileController.text = '';
                                creditController.creditLimitController.text =
                                    '';

                                selectedCustomerId =
                                    selectedDealerObj.customerID ?? "";

                                // Store values in controllers
                                dealerIdController.text =
                                    selectedDealerObj.dealerId ?? "";
                                customerIdController.text =
                                    selectedDealerObj.customerID ?? "";
                              });

                              creditController.fetchApplication(
                                  dealerIdController.text,
                                  customerIdController.text);

                              print("Selected DealerID: $selectedDealerId");
                              print("Selected CustomerID: $selectedCustomerId");
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "Dealer ID", dealerIdController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildReadOnlyTextField(
                          "Customer ID", customerIdController)),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Customer Information",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: buildTextField(
                          "Address 1", creditController.address1Controller)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildTextField(
                          "Address 2", creditController.address2Controller)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: buildTextField("Dealer Postal Code *",
                          creditController.postalCodeController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildTextField("GST Registration Number *",
                          creditController.gstController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: buildTextField("Mobile No. of Proprietor *",
                          creditController.mobileController)),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Customer Limit Details",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: buildTextField("Existing Credit Limit Rs.",
                          creditController.creditLimitController)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Validity Indicator",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Obx(() {
                          if (creditController.isLoadings2.value) {
                            return const SizedBox(
                              height: 25,
                              width: 25,
                              child:
                                  CircularProgressIndicator(strokeWidth: 1.5),
                            );
                          }
                          if (creditController.validityindi.isEmpty) {
                            return const Text(
                              "No validity indicators available",
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            );
                          }
                          return DropdownButtonFormField<int>(
                            value: validityIndicatorId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 6),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            hint: Text(
                              "Select Validity Indicator",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            items: creditController.validityindi.first.data
                                    ?.map((Data valindi) {
                                  return DropdownMenuItem<int>(
                                    value: valindi.id,
                                    child: Text(
                                      valindi.name ?? "Unknown",
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 11,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList() ??
                                [],
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  validityIndicatorId = newValue;
                                  if (newValue == 2) {
                                    // Temporary
                                    DateTime now = DateTime.now();
                                    DateTime lastDay =
                                        DateTime(now.year, now.month + 1, 0);
                                    validityDateController.text =
                                        "${lastDay.day}/${lastDay.month}/${lastDay.year}";
                                    showValidityDueDate = true;
                                  } else if (newValue == 3) {
                                    // Permanent
                                    showValidityDueDate = false;
                                    validityDateController.clear();
                                  } else {
                                    showValidityDueDate = true;
                                  }
                                });
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (showValidityDueDate)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Validity Due Date",
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          TextFormField(
                            controller: validityDateController,
                            decoration: InputDecoration(
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 16),
                              hintText: "dd-mm-yyyy",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            readOnly: true,
                            style: const TextStyle(fontSize: 12),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  validityDateController.text =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 160,
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
                                  onConfirm: () async {
                                    Navigator.of(context).pop();

                                    if (selectedCustomerId == null) {
                                      AppSnackBar.alert(
                                          message:
                                              "Please select the application");
                                      return;
                                    }
                                    if (creditController
                                        .creditLimitController.text.isEmpty) {
                                      AppSnackBar.alert(
                                          message: "Please enter credit limit");
                                      return;
                                    }
                                    if (validityIndicatorId.toString() == "1" &&
                                        validityDateController.text.isEmpty) {
                                      return;
                                    }

                                    setState(() => _isLoading = true);

                                    await creditController.submitApplication(
                                      selectedCustomerId!,
                                      creditController
                                          .creditLimitController.text,
                                      validityIndicatorId.toString(),
                                      validityDateController.text,
                                    );

                                    setState(() => _isLoading = false);

                                    creditController.address1Controller.clear();
                                    creditController.address2Controller.clear();
                                    creditController.postalCodeController
                                        .clear();
                                    creditController.gstController.clear();
                                    creditController.mobileController.clear();
                                    creditController.creditLimitController
                                        .clear();
                                    validityIndicatorId = null;
                                    validityDateController.text = "";

                                    creditController.dealernname.clear();
                                    previousDealerList.clear();
                                    creditController.fetchBranches();
                                  },
                                  onCancel: () => Navigator.of(context).pop(),
                                );
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      "UPDATE",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              filled: true,
              fillColor: readOnly
                  ? const Color.fromARGB(255, 234, 232, 232)
                  : Colors.white,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
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
}
