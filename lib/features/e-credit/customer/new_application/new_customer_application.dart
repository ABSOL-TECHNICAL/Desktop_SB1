import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/controller/creditlimit_controller.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/model/Model/validityindicator_model.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/controller/gstin_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/controller/new_customer_application_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/model/addressstate_model.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/model/nexusstate_model.dart';
import 'package:impal_desktop/features/e-credit/global/custom_dropdown.dart';
import 'package:impal_desktop/features/e-credit/global/custom_textfield.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:file_picker/file_picker.dart';

class NewCustomerApplication extends StatefulWidget {
  const NewCustomerApplication({super.key});

  @override
  _NewCustomerApplicationState createState() => _NewCustomerApplicationState();
}

class _NewCustomerApplicationState extends State<NewCustomerApplication> {
  final BdoAuthenticate bdoAuthenticate = Get.put(BdoAuthenticate());

  final LoginController ecreditLogincontroller = Get.find<LoginController>();

  final CreditlimitController creditController =
      Get.put(CreditlimitController());

  int? validityIndicatorId;
  final TextEditingController validityDateController = TextEditingController();
  final TextEditingController nexusstateIdController = TextEditingController();
  final TextEditingController addressstateIdController =
      TextEditingController();
  bool showValidityDueDate = true;
  final RxBool isLoading = false.obs;

  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController dealerNameController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController dealerTown = TextEditingController();
  final TextEditingController proprietorNameController =
      TextEditingController();
  final TextEditingController proprietorMobileController =
      TextEditingController();
  final TextEditingController town = TextEditingController();
  final TextEditingController pan = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController postalcode = TextEditingController();
  final TextEditingController gst = TextEditingController();
  final TextEditingController credit = TextEditingController();
  final TextEditingController creditInwordsController = TextEditingController();
  final TextEditingController dateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );

  final TextEditingController distributorController = TextEditingController(
    text: 'IMPAL',
  );
  final TextEditingController controller = TextEditingController(
    text: '',
  );
  final TextEditingController gstvalue = TextEditingController();

  final NewCustomerApplicationController newCustomerController =
      Get.put(NewCustomerApplicationController());

  List<String> branchList = ['Branch 1', 'Branch 2', 'Branch 3'];
  File? selectedFile;
  String? selectedFileName;
   final FocusNode _focusNode = FocusNode();
  bool hasError = false;

  @override
  void initState() {
    super.initState();
      _focusNode.dispose();
    // Allow screenshots on this page

    credit.addListener(() {
      final text = credit.text;

      if (text.isNotEmpty) {
        final parsedValue = int.tryParse(text);
        if (parsedValue != null) {
          creditInwordsController.text =
              NumberToWordsEnglish.convert(parsedValue);
        } else {
          creditInwordsController.clear(); // Clear if invalid input
        }
      } else {
        creditInwordsController.clear(); // Clear if input is empty
      }
    });
  }
  void focus() {
  _focusNode.requestFocus();
}
void _clearFormFields() {
  dealerNameController.clear();
  address1Controller.clear();
  address2Controller.clear();
  proprietorNameController.clear();
  proprietorMobileController.clear();
  dealerTown.clear();
  pan.clear();
  email.clear();
  postalcode.clear();
  gst.clear();
  credit.clear();
  creditInwordsController.clear();
  validityDateController.clear();
  nexusstateIdController.clear();
  addressstateIdController.clear();
  
  // Reset date to today
  dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  
  // Reset other fields if needed
}
final _formKey = GlobalKey<FormState>();
bool _validateForm = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Create New Customer',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
        // style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:Form(
         key: _formKey,
  autovalidateMode: _validateForm ? AutovalidateMode.always : AutovalidateMode.disabled,
        child:  SingleChildScrollView(
           child:   Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                child: 
             InkWell(
  onTap: () async {
    try {
      isLoading.value = true;
      await newCustomerController.refreshData();
      _clearFormFields();
      AppSnackBar.success(
        message: "Application details refreshed successfully.",
      );
    } catch (e) {
      AppSnackBar.failed(
        message: "Failed to refresh data. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
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
              ),
        Container(
          padding:
              const EdgeInsets.only(top: 16.0, left: 16, right: 16, bottom: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Branch",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                                // style: TextStyle(
                                //     fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Obx(() {
                                if (ecreditLogincontroller.isLoading.value) {
                                  return const CircularProgressIndicator();
                                }

                                final branch = ecreditLogincontroller
                                        .employeeModel.branchname ??
                                    "No branch available";

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 234, 232, 232),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: double.infinity,
                                  child: Text(
                                    branch,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    //  style: const TextStyle(
                                    //   fontSize: 14,
                                    //   fontWeight: FontWeight.w400,
                                    //   color: Colors.black,
                                    // ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyField(
                              'Application Date', dateController),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyField(
                              'Distributor Name', distributorController),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Name Of the Dealer',
                            hint: 'Enter ...',
                            isRequired: true,
                            controller: dealerNameController,
                            toUpperCase: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Address of Dealer/ Firm/ STU:',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        // style: TextStyle(
                        //   fontSize: 15,
                        //   fontWeight: FontWeight.bold,
                        //   color: Colors.black,
                        // ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Address 1',
                            hint: 'Enter...',
                            isRequired: true,
                            controller: address1Controller,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Address 2',
                            hint: 'Enter ...',
                            isRequired: false,
                            controller: address2Controller,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Business Owner / Partner / Director',
                            hint: 'Enter ...',
                            isRequired: true,
                            controller: proprietorNameController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: "Proprietor's Mobile No",
                            hint: 'Enter ...',
                            isRequired: true,
                            controller: proprietorMobileController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mobile number is required';
                              } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Please enter a valid 10-digit mobile number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.length > 10) {
                                proprietorMobileController.text =
                                    value.substring(0, 10);
                                proprietorMobileController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: 10),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController
                                .isLoadingRegistration.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController
                                .registrationList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Type Of Registration",
                              hint: "Choose ...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedRegistration.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedRegistration.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController
                                      .selectedRegistration.value = newValue;
                                }
                              },
                              items: newCustomerController.registrationList
                                  .map((registration) =>
                                      registration['name']?.toString() ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Obx(() {
                          return newCustomerController
                                      .selectedRegistration.value !=
                                  "Unregistered"
                              ? Expanded(
                                  child: CustomTextFormField(
                                    label: 'GST Registration Number',
                                    hint: 'Enter GST ...',
                                    isRequired: true,
                                    controller: gst,
                                    onChanged: (value) {
                                      String upperCaseValue =
                                          value.toUpperCase();
                                      gst.text = upperCaseValue;
                                      gst.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: gst.text.length));
                                      bdoAuthenticate
                                          .updateGstin(upperCaseValue);
                                      bdoAuthenticate.fetchBDO();
                                    },
                                  ),
                                )
                              : SizedBox.shrink();
                        }),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'If any Group/ Sister Customer exists within IMPAL:',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        // style: TextStyle(
                        //   fontSize: 15,
                        //   fontWeight: FontWeight.bold,
                        //   color: Colors.black,
                        // ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                              label: 'S.NO', hint: '', isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController.isLoadingBranch.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.branchList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Dealer branch",
                              hint: "Choose ...",
                              isRequired: false,
                              value: newCustomerController
                                      .selectedRowBranch.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedRowBranch.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController
                                      .selectedRowBranch.value = newValue;
                                }
                              },
                              items: newCustomerController.branchRowList
                                  .map((branch) =>
                                      branch['BranchName'] as String)
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: ' Dealer Code (Rs.)',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Credit Limit (Rs.)',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Dealer migration from one branch to another :',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      //   style: TextStyle(
                      //       fontSize: 15,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.black),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Branch',
                              hint: 'Choose ...',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Dealer Name',
                            hint: 'Choose...',
                            isRequired: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Migration Branch',
                            hint: 'Choose ...',
                            isRequired: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Dealer Code (Rs.)',
                              hint: 'Choose ...',
                              isRequired: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Year Of Establishment ',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController.isLoadingStates.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.statesList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Dealer  State",
                              hint: "Choose ...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedState.value.isNotEmpty
                                  ? newCustomerController.selectedState.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController.selectedState.value =
                                      newValue;
                                }
                              },
                              items: newCustomerController.statesList
                                  .map((state) =>
                                      state['StateName']?.toString() ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController
                                .isLoadingDistricts.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.districtList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Dealer District",
                              hint: "Select...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedDistrict.value.isNotEmpty
                                  ? newCustomerController.selectedDistrict.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController.selectedDistrict.value =
                                      newValue;
                                }
                              },
                              items: newCustomerController.districtList
                                  .map((town) =>
                                      town['DealerDistrict']?.toString() ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController
                                .isLoadingTownLocation.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return CustomDropDownField(
                              label: "Dealer SLB Town",
                              hint: "Select...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedDealerTown.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedDealerTown.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController
                                      .selectedDealerTown.value = newValue;
                                }
                              },
                              items: newCustomerController.dealerTownList
                                  .map((slbLocation) =>
                                      slbLocation['SlbTownName']?.toString() ??
                                      '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Dealer Town',
                            hint: 'Select...',
                            isRequired: true,
                            controller: dealerTown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController
                                .isLoadingAddressState.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return CustomDropDownField(
                              label: "Address State",
                              hint: "Choose ...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedAddressState.value?.fullname ??
                                  '',
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  final selected = newCustomerController
                                      .addressStates
                                      .firstWhere(
                                          (address) =>
                                              address.fullname == newValue,
                                          orElse: () => AddressState(
                                              addressstateID: '',
                                              name: '',
                                              fullname: ''));

                                  if (selected.addressstateID!.isNotEmpty) {
                                    newCustomerController
                                        .selectedAddressState.value = selected;
                                    print(
                                        "Selected Addressstate fullname: ${selected.fullname}");
                                    print(
                                        "Selected Addressstate shortname: ${selected.name}");
                                    addressstateIdController.text =
                                        selected.name!;
                                    print(addressstateIdController.text);
                                  }
                                }
                              },
                              items: newCustomerController.addressStates
                                  .map((address) => address.fullname ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController
                                .isLoadingNexusState.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return CustomDropDownField(
                              label: "Nexus State",
                              hint: "Choose ...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedNexusState.value?.name ??
                                  '',
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  final selected = newCustomerController
                                      .nexusStates
                                      .firstWhere(
                                          (nexus) => nexus.name == newValue,
                                          orElse: () => NexusState(
                                              nexusID: '', name: ''));

                                  if (selected.nexusID.isNotEmpty) {
                                    newCustomerController
                                        .selectedNexusState.value = selected;
                                    print(
                                        "Selected Nexus ID: ${selected.nexusID}");
                                    nexusstateIdController.text =
                                        selected.nexusID;
                                  }
                                }
                              },
                              items: newCustomerController.nexusStates
                                  .map((nexus) => nexus.name)
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController
                                .isLoadingTownLocation.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return CustomDropDownField(
                              label: "Town Location",
                              hint: "Select....",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedTownLocation.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedTownLocation.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController
                                      .selectedTownLocation.value = newValue;
                                }
                              },
                              items: newCustomerController.townLocationList
                                  .map((townLocation) =>
                                      townLocation['name']?.toString() ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController.isLoadingZone.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.zoneList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Dealer Zone",
                              hint: "Select...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedZone.value.isNotEmpty
                                  ? newCustomerController.selectedZone.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController.selectedZone.value =
                                      newValue;
                                }
                              },
                              items: newCustomerController.zoneList
                                  .map((zone) => zone['name']?.toString() ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: CustomTextFormField(
                        //     label: 'Contact Person Name  ',
                        //     hint: 'Enter ...',
                        //     isRequired: false,
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Expanded(
                        //   child: CustomTextFormField(
                        //     label: 'Contact Person Mobile  ',
                        //     hint: 'Enter ... ',
                        //     isRequired: false,
                        //   ),
                        // ),
                        // const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Email Id',
                            hint: 'Enter ...',
                            isRequired: true,
                            controller: email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              final regex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@(gmail\.com|email\.com)$');
                              if (!regex.hasMatch(value)) {
                                return 'Enter a valid Gmail or email.com address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Dealer Postal Number',
                            hint: 'Enter ...',
                            isRequired: true,
                            controller: postalcode,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            label: 'Dealer PAN',
                            hint: 'Enter ... ',
                            isRequired: true,
                            controller: pan,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'PAN is required';
                              } else if (value.length < 10) {
                                return 'PAN must be at least 10 characters';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              String uppercasedValue = value.toUpperCase();
                              pan.value = TextEditingValue(
                                text: uppercasedValue,
                                selection: TextSelection.collapsed(
                                    offset: uppercasedValue.length),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController.isLoadingFirm.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.firmList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Type Of Firm",
                              hint: "Select...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedFirm.value.isNotEmpty
                                  ? newCustomerController.selectedFirm.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController.selectedFirm.value =
                                      newValue;
                                }
                              },
                              items: newCustomerController.firmList
                                  .map((firm) =>
                                      firm['TypeFirmName']?.toString() ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: Obx(() {
                        //     if (newCustomerController
                        //         .isLoadingRegistration.value) {
                        //       return const Center(
                        //           child: CircularProgressIndicator());
                        //     }
                        //     if (newCustomerController
                        //         .registrationList.isEmpty) {
                        //       return const Center(
                        //           child: Text("No data available"));
                        //     }

                        //     return CustomDropDownField(
                        //       label: "Type Of Registration",
                        //       hint: "Choose ...",
                        //       isRequired: true,
                        //       value: newCustomerController
                        //               .selectedRegistration.value.isNotEmpty
                        //           ? newCustomerController
                        //               .selectedRegistration.value
                        //           : null,
                        //       onChanged: (String? newValue) {
                        //         if (newValue != null) {
                        //           newCustomerController
                        //               .selectedRegistration.value = newValue;
                        //         }
                        //       },
                        //       items: newCustomerController.registrationList
                        //           .map((registration) =>
                        //               registration['name']?.toString() ?? '')
                        //           .toList(),
                        //     );
                        //   }),
                        // ),
                        // const SizedBox(width: 16),
                        // Obx(() {
                        //   return newCustomerController
                        //               .selectedRegistration.value !=
                        //           "Unregistered"
                        //       ? Expanded(
                        //           child: CustomTextFormField(
                        //             label: 'GST Registration Number',
                        //             hint: 'Enter GST ...',
                        //             isRequired: true,
                        //             controller: gst,
                        //             onChanged: (value) {
                        //               bdoAuthenticate.updateGstin(value);
                        //               bdoAuthenticate.fetchBDO();
                        //             },
                        //           ),
                        //         )
                        //       : SizedBox
                        //           .shrink(); // Return an empty widget if condition is false
                        // }),

                        // Expanded(
                        //   child: CustomTextFormField(
                        //       label: 'GST Registration Number',
                        //       hint: 'Enter GST ...',
                        //       isRequired: true,
                        //       controller: gst,
                        //       onChanged: (value) {
                        //         bdoAuthenticate.updateGstin(value);
                        //         bdoAuthenticate.fetchBDO();
                        //       }),
                        // ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController
                                .isLoadingPeroidcity.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return CustomDropDownField(
                              label: "Periodicty of Dealer Visit",
                              hint: "Select...",
                              isRequired: false,
                              value: newCustomerController
                                      .selectedPeroidcity.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedPeroidcity.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  print("🔹 Selected Salesman: $newValue");
                                  newCustomerController
                                      .selectedPeroidcity.value = newValue;
                                }
                              },
                              items: newCustomerController.periodicityList
                                  .map<String>((period) =>
                                      period['PeriodVisitName']?.toString() ??
                                      '')
                                  .where((name) => name.isNotEmpty)
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Dealer Monthly Target',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController.isLoadingGststate.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.GststateList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Dealer GST Local or Outside State",
                              hint: "Choose ...",
                              isRequired: false,
                              value: newCustomerController
                                      .selectedGstStateList.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedGstStateList.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController
                                      .selectedGstStateList.value = newValue;
                                }
                              },
                              items: newCustomerController.GststateList.map(
                                      (gstState) =>
                                          gstState['name']?.toString() ?? '')
                                  .toList(),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Distance from Branch to Dealer',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Dealer Overall Stock Value',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: ' Dealer Annual Turonover',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Dealer IMPAL Lines Sales Turnover ',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Dealer Serviced from Branch or Res Rep ?',
                              hint: 'Enter ...',
                              isRequired: false),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: CustomTextFormField(
                        //       label: 'Distance from RR Location to Dealer',
                        //       hint: 'Enter ...',
                        //       isRequired: false),
                        // ),
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
                          child: Obx(() {
                            if (newCustomerController.isLoadingSalesman.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.salesmanList.isEmpty) {
                              return const Center(
                                  child: Text("No salesmen available"));
                            }

                            return CustomDropDownField(
                              label: "Salesman/RR assigned to the Dealer",
                              hint: "Choose ...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedSalesman.value.isNotEmpty
                                  ? newCustomerController.selectedSalesman.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  print("🔹 Selected Salesman: $newValue");
                                  newCustomerController.selectedSalesman.value =
                                      newValue;
                                }
                              },
                              items: newCustomerController.salesmanList
                                  .map<String>((salesman) =>
                                      salesman['SalesManName']?.toString() ??
                                      '')
                                  .where((name) => name.isNotEmpty)
                                  .toList(),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(children: [
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
                                      selectedFile =
                                          File(result.files.single.path!);
                                      selectedFileName =
                                          result.files.single.name;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.upload_file,
                                          color: Colors.grey),
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
                                      selectedFile =
                                          File(result.files.single.path!);
                                      selectedFileName =
                                          result.files.single.name;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.upload_file,
                                          color: Colors.grey),
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
                  ],
                ),
              ),

              // ),
              const SizedBox(
                height: 16,
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20.0), // Padding inside the container
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController.isLoadingFirm.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.firmList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Dealer Classification",
                              hint: "Choose ...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedClassification.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedClassification.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController
                                      .selectedClassification.value = newValue;
                                }
                              },
                              items: newCustomerController.classification
                                  .map((classification) =>
                                      classification['DealerClassName']
                                          ?.toString() ??
                                      '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() {
                            if (newCustomerController.isLoadingFirm.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.firmList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            return CustomDropDownField(
                              label: "Dealer Business Segments",
                              hint: "Choose ...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedSegments.value.isNotEmpty
                                  ? newCustomerController.selectedSegments.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController.selectedSegments.value =
                                      newValue;
                                }
                              },
                              items: newCustomerController.segments
                                  .map((segments) =>
                                      segments['DealerBussegName']
                                          ?.toString() ??
                                      '')
                                  .toList(),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomDropDownField(
                            label:
                                'Is the dealer at present dealing with any TVS Group companies? If so details',
                            items: [],
                            isRequired: false,
                            hint: '',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    // Text(
                    //   'List of key lines directly purchased from Manufacturers',
                    //   style: theme.textTheme.bodyLarge
                    //       ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    //   // style:
                    //   //     TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '1', hint: '', isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '2', hint: '', isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '3', hint: '', isRequired: false),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '4', hint: '', isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '5', hint: '', isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '6', hint: '', isRequired: false),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 20),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: 'Any additional information',
                    //           hint: '',
                    //           isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: ' Transporter Name',
                    //           hint: '',
                    //           isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: 'Addl Info on Dealer, if any  ',
                    //           hint: ' ',
                    //           isRequired: false),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 50),
                    // Text(
                    //   'Details of lines as ASC',
                    //   style: theme.textTheme.bodyLarge
                    //       ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '1', hint: '', isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '2', hint: '', isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '3', hint: '', isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: '4', hint: '', isRequired: false),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 50),
                    // Text(
                    //   'Brand Details as Authorized Service Dealer',
                    //   style: theme.textTheme.bodyLarge
                    //       ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    //   // style:
                    //   //     TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildCheckbox('WABCO', '', false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildCheckbox('Rane TRW', '', false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildCheckbox('Turbo', '', false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildCheckbox('Lucas', '', false),
                    //     ),
                    //   ],
                    // ),
                    // // const SizedBox(width: 16),
                    // // Row(
                    // //   children: [
                    // //     Expanded(
                    // //       child: _buildCheckbox('Rane TRW', '', false),
                    // //     ),
                    // //   ],
                    // // ),

                    // // Row(
                    // //   children: [
                    // //     Expanded(
                    // //       child: _buildCheckbox('Turbo', '', false),
                    // //     ),
                    // //   ],
                    // // ),
                    // // Row(
                    // //   children: [
                    // //     Expanded(
                    // //       child: _buildCheckbox('Lucas', '', false),
                    // //     ),
                    // //   ],
                    // // ),
                    // const SizedBox(height: 20),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CustomDropDownField(
                    //           label: 'Other Brand Name (Specify):',
                    //           hint: "",
                    //           items: branchList,
                    //           isRequired: false),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: CustomTextFormField(
                    //           label: 'Authorized Service Centres:',
                    //           hint: '',
                    //           isRequired: false),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20.0), // Padding inside the container
                child: Column(
                  children: [
                    // const SizedBox(height: 20),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildReadOnlyField(
                    //           'Existing Credit Limit Rs.', controller),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildReadOnlyField(
                    //           'Outstanding Amount', controller),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildReadOnlyField(
                    //           ' Enhanced Credit Limit Requested Rs',
                    //           controller),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 20),
                    Obx(() {
                      return Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(child: Obx(() {
                            if (newCustomerController.isLoadingFirm.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (newCustomerController.firmList.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }
                            return CustomDropDownField(
                              label: "Credit Sales",
                              hint: "Select...",
                              isRequired: true,
                              value: newCustomerController
                                      .selectedCreditSales.value.isNotEmpty
                                  ? newCustomerController
                                      .selectedCreditSales.value
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  newCustomerController
                                      .selectedCreditSales.value = newValue;
                                }
                              },
                              items: newCustomerController.creditSales
                                  .map((credit) =>
                                      credit['name']?.toString() ?? '')
                                  .toList(),
                            );
                          })),
                          const SizedBox(width: 16),
                          if (newCustomerController.selectedCreditSales.value ==
                              "Credit")
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextFormField(
                                    label:
                                        'First Time Credit Amount Request Rs:',
                                    hint: 'Enter amount',
                                    isRequired: newCustomerController
                                            .selectedCreditSales.value ==
                                        "Credit",
                                    controller: credit,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (newCustomerController
                                              .selectedCreditSales.value ==
                                          "Credit") {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an amount';
                                        }
                                        final intAmount = int.tryParse(value);
                                        if (intAmount == null) {
                                          return 'Invalid number';
                                        }
                                        if (intAmount < 10000) {
                                          return 'Minimum amount should be Rs. 10,000';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextFormField(
                                  label: 'Amount In Words',
                                  hint: '',
                                  isRequired: false,
                                  readOnly: true,
                                  controller: creditInwordsController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    Obx(() {
                      return Row(
                        children: [
                          if (newCustomerController.selectedCreditSales.value !=
                                  "Cash" &&
                              newCustomerController.selectedCreditSales.value !=
                                  "Default" &&
                              newCustomerController.selectedCreditSales.value ==
                                  'Credit')
                            Expanded(
                              child: Obx(() {
                                if (creditController.isLoadings2.value) {
                                  return const CircularProgressIndicator();
                                }
                                if (creditController.validityindi.isEmpty) {
                                  return Text(
                                    "No validity indicators available",
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(color: Colors.red),
                                    // style: TextStyle(color: Colors.red),
                                  );
                                }
                                return CustomDropDownField(
                                  label: "Validity Indicator",
                                  hint: "Select a Validity Indicator",
                                  isRequired: true,
                                  items: creditController
                                          .validityindi.first.data
                                          ?.map((Data valindi) =>
                                              valindi.name ?? " ")
                                          .toList() ??
                                      [],
                                  value: creditController
                                      .validityindi.first.data
                                      ?.firstWhere(
                                          (element) =>
                                              element.id == validityIndicatorId,
                                          orElse: () => Data(id: 0, name: ""))
                                      .name,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        validityIndicatorId = creditController
                                                .validityindi.first.data
                                                ?.firstWhere((element) =>
                                                    element.name == newValue)
                                                .id ??
                                            0;

                                        if (validityIndicatorId == 2) {
                                          DateTime now = DateTime.now();
                                          DateTime lastDay = DateTime(
                                              now.year, now.month + 1, 0);
                                          validityDateController.text =
                                              "${lastDay.day}/${lastDay.month}/${lastDay.year}";
                                          showValidityDueDate = true;
                                        } else if (validityIndicatorId == 3) {
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
                            ),
                          const SizedBox(width: 16),
                          if (showValidityDueDate)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Validity Due Date",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    // style: TextStyle(
                                    //     fontSize: 12,
                                    //     fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    height: 40,
                                    child: TextFormField(
                                      controller: validityDateController,
                                      decoration: InputDecoration(
                                        suffixIcon: const Icon(
                                            Icons.calendar_today,
                                            size: 18),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        hintText: "",
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() {
                              if (newCustomerController.isLoadingFirm.value) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (newCustomerController.firmList.isEmpty) {
                                return const Center(
                                    child: Text("No data available"));
                              }

                              return CustomDropDownField(
                                label: "Freight Indicator",
                                hint: "Choose a Freight Indicator",
                                isRequired: true,
                                value: newCustomerController
                                        .selectedFreight.value.isNotEmpty
                                    ? newCustomerController
                                        .selectedFreight.value
                                    : null,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    newCustomerController
                                        .selectedFreight.value = newValue;
                                  }
                                },
                                items: newCustomerController.freight
                                    .map((freight) =>
                                        freight['name']?.toString() ?? '')
                                    .toList(),
                              );
                            }),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 50),
                    Text(
                      'Dealer Bank Account Details',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                      // style:
                      //     TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Bank Name', hint: '', isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Bank Branch Name ',
                              hint: '',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Bank Account Number',
                              hint: '',
                              isRequired: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'IFSC Code', hint: '', isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Name of the Bank A/C Holder',
                              hint: '',
                              isRequired: false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                              label: 'Card No. and Expiry Date',
                              hint: '',
                              isRequired: false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20.0), // Padding inside the container
                child: Column(
                  children: [
                    const SizedBox(height: 50),
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
                      ],
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Accounts & IT Department for Creation of Customer Master',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                      // style:
                      //     TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
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
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCheckbox(
                              'GST Registration Certificate including the type of GST :',
                              '',
                              false),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildCheckbox(
                              'Business card of the dealership', '', false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 3, // Allocate more space for this field
                          child: CustomTextFormField(
                              label: '',
                              hint: 'Signature & Date',
                              isRequired: false),
                        ),
                        const SizedBox(width: 12),
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
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, right: 0),
                  child: SizedBox(
                    width: 100,
                    height: 35,
                    child: ElevatedButton(
                      onPressed:
                          isLoading.value ? null : () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF1E40AF),
                        shadowColor: Colors.black.withOpacity(0.4),
                        elevation: 6,
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Submit",
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontSize: 16, color: Colors.white),
                              // style:
                              //     TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
            ],
      ),
      ),),    
    );
  }

  void _submitForm(BuildContext context) {
    // if (!bdoAuthenticate.isGstValidated) {
    //   AppSnackBar.alert(
    //       message:
    //           "Please validate the GST number. If the GST number is incorrect, you cannot proceed further.");
    //   return;
    // }
     setState(() {
    _validateForm = true; // This will trigger validation for all fields
  });

 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Confirm Submission",
          message: "Are you sure you want to submit this form?",
          onConfirm: () async {
            if (newCustomerController.selectedRegistration.value !=
                "Unregistered") {
              if (!bdoAuthenticate.isGstValidated) {
                AppSnackBar.alert(
                    message:
                        "Please validate the GST number. If the GST number is incorrect, you cannot proceed further.");
                return;
              } else {
                gstvalue.text = gst.text;
              }
            } else if (newCustomerController.selectedRegistration.value ==
                "Unregistered") {
              gstvalue.text = "";
            }
  final requiredFields = [

            if (newCustomerController.selectedFirm.value == '') {
              // AppSnackBar.alert(message: 'Please specify the of firm');
              // return;
            },

            if (newCustomerController.selectedRegistration.value == '') {
              // AppSnackBar.alert(message: 'Please  specify the of Registration');
              // return;
            },

            if (newCustomerController.selectedDistrict.value == '') {
              // AppSnackBar.alert(message: 'Please specify the district.');
              // return;
            },

            if (newCustomerController.selectedState.value == '') {
              // AppSnackBar.alert(message: 'Please specify the State');
              // return;
            },

            if (newCustomerController.selectedZone.value == '') {
              // AppSnackBar.alert(message: 'Please specify the Zone');
              // return;
            },

            if (newCustomerController.selectedClassification.value == '') {
              // AppSnackBar.alert(message: 'Please specify the Classification');
              // return;
            },

            if (newCustomerController.selectedSegments.value == '') {
              // AppSnackBar.alert(message: 'Please specify the Segments');
              // return;
            },

            if (newCustomerController.selectedFreight.value == '') {
              // AppSnackBar.alert(message: 'Please specify the Freight');
              // return;
            },

            if (newCustomerController.selectedCreditSales.value == '') {
              // AppSnackBar.alert(message: 'Please specify the CreditSales');
              // return;
            },

            if (newCustomerController.selectedSalesman.value == '') {
              // AppSnackBar.alert(message: 'Please specify the Salesman');
              // return;
            },

            if (newCustomerController.selectedTownLocation.value == '') {
              // AppSnackBar.alert(message: 'Please specify the TownLocation');
              // return;
            },

            if (email.text.isEmpty) {
              // AppSnackBar.alert(message: 'Please specify the Email');
              // return;
            },

            if (dealerTown.text.isEmpty) {
              // AppSnackBar.alert(message: 'Please specify the DealerTown');
              // return;
            },

            if (proprietorMobileController.text.isEmpty) {
              // AppSnackBar.alert(message: 'Please specify the Mobile Number');
              // return;
            },

            if (dealerNameController.text.isEmpty) {
              // AppSnackBar.alert(message: 'Please specify the Dealer Name');
              // return;
            },

            if (address1Controller.text.isEmpty) {
              // AppSnackBar.alert(message: 'Please specify the address');
              // return;
            },
            if (nexusstateIdController.text.isEmpty) {
              // AppSnackBar.alert(message: 'Please specify the Nexus State');
              // return;
            },
            if (addressstateIdController.text.isEmpty) {
              // AppSnackBar.alert(message: 'Please specify the Address State');
              // return;
            }
  ];
     if (newCustomerController.selectedFirm.value == '') {
              AppSnackBar.alert(message: 'Please specify the of firm');
              return;
            }

            if (newCustomerController.selectedRegistration.value == '') {
              AppSnackBar.alert(message: 'Please  specify the of Registration');
              return;
            }

            if (newCustomerController.selectedDistrict.value == '') {
              AppSnackBar.alert(message: 'Please specify the district.');
              return;
            }

            if (newCustomerController.selectedState.value == '') {
              AppSnackBar.alert(message: 'Please specify the State');
              return;
            }

            if (newCustomerController.selectedZone.value == '') {
              AppSnackBar.alert(message: 'Please specify the Zone');
              return;
            }

            if (newCustomerController.selectedClassification.value == '') {
              AppSnackBar.alert(message: 'Please specify the Classification');
              return;
            }

            if (newCustomerController.selectedSegments.value == '') {
              AppSnackBar.alert(message: 'Please specify the Segments');
              return;
            }

            if (newCustomerController.selectedFreight.value == '') {
              AppSnackBar.alert(message: 'Please specify the Freight');
              return;
            }

            if (newCustomerController.selectedCreditSales.value == '') {
              AppSnackBar.alert(message: 'Please specify the CreditSales');
              return;
            }

            if (newCustomerController.selectedSalesman.value == '') {
              AppSnackBar.alert(message: 'Please specify the Salesman');
              return;
            }

            if (newCustomerController.selectedTownLocation.value == '') {
              AppSnackBar.alert(message: 'Please specify the TownLocation');
              return;
            }

            if (email.text.isEmpty) {
              AppSnackBar.alert(message: 'Please specify the Email');
              return;
            }

            if (dealerTown.text.isEmpty) {
              AppSnackBar.alert(message: 'Please specify the DealerTown');
              return;
            }

            if (proprietorMobileController.text.isEmpty) {
              AppSnackBar.alert(message: 'Please specify the Mobile Number');
              return;
            }

            if (dealerNameController.text.isEmpty) {
              AppSnackBar.alert(message: 'Please specify the Dealer Name');
              return;
            }

            if (address1Controller.text.isEmpty) {
              AppSnackBar.alert(message: 'Please specify the address');
              return;
            }
            if (nexusstateIdController.text.isEmpty) {
              AppSnackBar.alert(message: 'Please specify the Nexus State');
              return;
            }
            if (addressstateIdController.text.isEmpty) {
              AppSnackBar.alert(message: 'Please specify the Address State');
              return;
            }

            // if (address2Controller.text.isEmpty) {
            //   AppSnackBar.alert(message: 'Please fill address');
            //   return;
            // }

            // if (pan.text.isEmpty) {
            //   AppSnackBar.alert(message: 'Please fill Pan');
            //   return;
            // }

            // if (credit.text.isEmpty) {
            //   AppSnackBar.alert(message: 'Please fill Pan');
            //   return;
            // }

            // if (postalcode.text.isEmpty) {
            //   AppSnackBar.alert(message: 'Please fill Pan');
            //   return;
            // }

            // if (gst.text.isEmpty) {
            //   AppSnackBar.alert(message: 'Please fill PAN');
            //   return;
            // }

            Navigator.of(context).pop();

            String validityIndicator = validityIndicatorId?.toString() ?? '';

            var response = await newCustomerController.createCustomer(
                newCustomerController.selectedBranch.value,
                newCustomerController.selectedFirm.value,
                newCustomerController.selectedRegistration.value,
                newCustomerController.selectedDistrict.value,
                newCustomerController.selectedState.value,
                newCustomerController.selectedZone.value,
                newCustomerController.selectedClassification.value,
                newCustomerController.selectedSegments.value,
                newCustomerController.selectedFreight.value,
                newCustomerController.selectedCreditSales.value,
                newCustomerController.selectedSalesman.value,
                newCustomerController.selectedTownLocation.value,
                newCustomerController.selectedState.value,
                newCustomerController.selectedDealerTown.value,
                validityIndicator,
                email.text,
                proprietorMobileController.text,
                dealerNameController.text,
                newCustomerController,
                dealerTown.text,
                proprietorNameController.text,
                credit.text,
                pan.text,
                address1Controller.text,
                address2Controller.text,
                postalcode.text,
                gstvalue.text,
                dateController.text,
                validityDateController.text,
                nexusstateIdController.text,
                addressstateIdController.text);

            dealerNameController.clear();
            address1Controller.clear();
            address2Controller.clear();
            proprietorNameController.clear();
            proprietorMobileController.clear();
            dealerTown.clear();
            pan.clear();
            postalcode.clear();
            gst.clear();
            credit.clear();
            dateController.text =
                DateFormat('dd/MM/yyyy').format(DateTime.now());

            newCustomerController.clearSelection();

            // Get.snackbar(
            //   'Success',
            //   'Customer application submitted successfully!',
            //   snackPosition: SnackPosition.TOP,
            //   backgroundColor: Colors.green,
            //   colorText: Colors.white,
            // );
  
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      },
    );
  }

  @override
  void dispose() {
    Get.delete<NewCustomerApplicationController>();
    super.dispose();
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontSize: 12, fontWeight: FontWeight.bold)
            // style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
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

  Widget _buildCheckbox(String label, String subtitle, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isChecked = initialValue;

        return CheckboxListTile(
          title: Text(label),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
          controlAffinity:
              ListTileControlAffinity.leading, // Checkbox on the left
        );
      },
    );
  }
}
