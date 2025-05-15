import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/controller/existing_customer_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/global_fields/global_fields/custom_dropdown.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/global_fields/global_fields/custom_text_widget.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/model/existing_customer_model.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/controller/gstin_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/login/models/login_model.dart';
import 'package:intl/intl.dart';

class ExistingCustomerWidget extends StatefulWidget {
  const ExistingCustomerWidget({super.key, required this.controller});

  final ExistingcustomerController controller;

  @override
  _ExistingCustomerWidgetState createState() => _ExistingCustomerWidgetState();
}

class _ExistingCustomerWidgetState extends State<ExistingCustomerWidget> {
  final ExistingcustomerController controller =
      Get.put(ExistingcustomerController());

  // Controllers
  final TextEditingController dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  final LoginController logincontroller = Get.find<LoginController>();

  final BdoAuthenticate bdoAuthenticate = Get.put(BdoAuthenticate());

  EmployeeModel get employee => Get.find<LoginController>().employeeModel;

  bool get isEcreditHo => employee.isEcredit_Ho ?? false;

  var isEmailValid = true.obs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // First Form
        _buildFormContainer(_buildFormContent()),

        // Second Form
        _buildFormContainer(_buidsecondform()),

        // Third Form
        _buildFormContainer(_buildthirdform()),

        // Fourth Form
        _buildFormContainer(_buildfourthform()),

        // Fifth Form
        _buildFormContainer(_buildfifthform()),
      ]),
    );
  }

  Widget _buildFormContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40.0),
      decoration: BoxDecoration(
        // color: const Color.fromARGB(255, 195, 207, 240),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.grey, // ✅ Border color
          width: 1.0, // ✅ Border thickness
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFormContent() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  if (logincontroller.isLoading.value) {
                    return const CircularProgressIndicator();
                  }

                  final employee = Get.find<LoginController>().employeeModel;
                  final bool isEcreditHo = employee.isEcredit_Ho ?? false;
                  final branchId = employee.branchid ?? "";
                  final branchName =
                      employee.branchname ?? "No branch available";

                  if (!isEcreditHo) {
                    if (branchId.isNotEmpty) {
                      controller.fetchDealerNamedata(branchId);
                    }

                    return CustomTextContainer(
                      label: 'Branch',
                      value: branchName,
                      readOnly: true,
                      required: true,
                      hint: 'Select Branch',
                      controller: TextEditingController(text: branchName),
                    );
                  }

                  if (controller.branchLocation.isEmpty) {
                    controller.fetchLocation();
                  }

                  return buildDropdown<String>(
                    label: "Branch",
                    selectedValue: controller.selectedBranchId,
                    items: controller.branchLocation
                        .map((b) => b.branchId!)
                        .toList(),
                    itemLabel: (branchId) => controller.branchLocation
                        .firstWhere(
                          (branch) => branch.branchId == branchId,
                          orElse: () => BranchLocation(
                              branchId: '', branchName: ''), // Default value
                        )
                        .branchName!,
                    fetchData: () async {
                      await controller.fetchLocation();
                    },
                    showDropdown: true,
                    onChanged: (newValue) async {
                      if (newValue != null) {
                        print("Branch Selected: $newValue");

                        // ✅ Update selected branch
                        controller.selectedBranchId.value = newValue;

                        // ✅ Fetch dealers and wait for completion
                        await controller.fetchDealerNamedata(newValue);

                        // ✅ Refresh dealer list to update UI
                        controller.dealernnamedata.refresh();
                      }
                    },
                    required: true,
                  );
                }),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Obx(() {
                  return buildDropdown<DealerNameData>(
                    label: 'Dealer Name',
                    autoFetch: true, // Fetch when user selects dealer
                    selectedValue: controller.selecteddealer,
                    required: true,
                    items: controller.dealernnamedata.toSet().toList(),
                    itemLabel: (dealer) =>
                        dealer.dealerName ?? 'Unknown Dealer',

                    fetchData: () async {
                      final branchId = controller.selectedBranchId.value;
                      print("Fetching dealers for BranchId: $branchId");

                      if (branchId.isNotEmpty) {
                        await controller.fetchDealerNamedata(branchId);
                        controller.dealernnamedata.refresh(); // Force update
                      } else {
                        print("Error: Branch ID is null or empty.");
                      }
                    }, // Debugging controller.fetchDealer, // Replace with actual function
                    showDropdown: controller.showDropdown.value,
                    fallbackValue: () => controller.applicationdata.isNotEmpty
                        ? controller.applicationdata.first.dealerName
                        : '',
                    onChanged: (DealerNameData? newValue) async {
                      final String id = controller.customerId.value =
                          newValue?.customerID ?? '';

                      print("oustanding:$id");
                      // Fetch outstanding details based on selected customer ID
                      controller.fetchOutstandingDetailsCustomer(id);

                      if (newValue != null) {
                        controller.selecteddealer.value = newValue;

                        // Assign new dealerId and customerId
                        controller.dealerId.value = newValue.dealerId ?? '';
                        controller.customerId.value = newValue.customerID ?? '';

                        // Fetch new application data based on selected dealer and customer
                        await controller.fetchApplicationdata(
                          controller.dealerId.value,
                          controller.customerId.value,
                        );

                        controller.applicationdata.refresh();
                      }
                    },
                  );
                }),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Dealer',
                    required: true,
                    readOnly: !isEcreditHo,
                    hint: "Enter Dealer",
                    value: (controller.applicationdata.isNotEmpty &&
                            controller.applicationdata.first.name != null)
                        ? controller.applicationdata.first.name!
                        : null,
                    onTap: () {
                      if (!isEcreditHo) {
                        AppSnackBar.alert(
                            message:
                                "This field can only be edited by the Head Office.");
                      }
                    },
                    onChanged: (value) {
                      controller.dealerController.text = value;
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // const SizedBox(height: 16), // Add vertical spacing between rows
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Customer ID',
                    value: controller.customerId.value,
                    readOnly: true,
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Dealer ID',
                    value: controller.dealerId.value,
                    readOnly: true,
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                  label: 'Application Date',
                  value: dateController.text, // Hardcoded value as text
                  readOnly: true,
                  required: false,
                ),
              ),
              // Expanded(
              //   child: _buildReadOnlyField('Application Date', dateController),
              // ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                  label: 'Distributor Name',
                  value: 'IMPAL', // Hardcoded value as text
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Center(
            child: Text(
              'Address of Dealer/ Firm/ STU:',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Address1',
                    required: true,
                    readOnly: !isEcreditHo, // If false, the field is read-only

                    hint: "Enter address 1",
                    value: (controller.applicationdata.isNotEmpty &&
                            controller.applicationdata.first.address1 != null)
                        ? controller.applicationdata.first.address1!
                        : null,
                    onTap: () {
                      if (!isEcreditHo) {
                        AppSnackBar.alert(
                            message:
                                "This field can only be edited by the Head Office.");
                      }
                    },
                    onChanged: (value) {
                      controller.address1Controller.text = value;
                    },
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Address 2',
                    required: false,
                    readOnly: !isEcreditHo,
                    hint: "Enter address 2",
                    value: (controller.applicationdata.isNotEmpty &&
                            controller.applicationdata.first.address2 != null)
                        ? controller.applicationdata.first.address2!
                        : null,
                    onTap: () {
                      if (!isEcreditHo) {
                        AppSnackBar.alert(
                            message:
                                "This field can only be edited by the Head Office.");
                      }
                    },
                    onChanged: (value) {
                      controller.address2Controller.text = value;
                    },
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Name of the Proprietor',
                    required: true,
                    readOnly: false,
                    hint: "Enter Name of the Proprietor",
                    value: (controller.applicationdata.isNotEmpty &&
                            controller.applicationdata.first.dealerName != null)
                        ? controller.applicationdata.first.dealerName!
                        : null,
                    onChanged: (value) {
                      controller.propertierController.text = value;
                    },
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Mobile No',
                    required: true,
                    value: (controller.applicationdata.isNotEmpty &&
                            controller.applicationdata.first.phone != null)
                        ? controller.applicationdata.first.phone!
                        : null,
                    onChanged: (value) {
                      controller.phoneController.text = value;
                    },
                    readOnly: false,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Center(
            child: Text(
              'If any Group/ Sister Customer exists within IMPAL :',
              // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextContainer(
                      label: 'Year Of Establishment ',
                      hint: 'Enter Year Of Establishment ',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.isLoadingstate.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return buildDropdown<DealerState>(
                        label: 'State',
                        required: true,
                        selectedValue: controller.selecteddealerstate,
                        items: controller.dealerstate,
                        itemLabel: (state) => state.stateName ?? 'Unknown',
                        fetchData:
                            controller.fetchdState, // Will only fetch if needed
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () {
                          return controller.applicationdata.isNotEmpty
                              ? controller.applicationdata.first.stateName ??
                                  'Unknown'
                              : '';
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.isLoadingdistrict.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // if (controller.selecteddealerdistrict.value == null &&
                      //     controller.applicationdata.isNotEmpty) {
                      //   controller.selecteddealerdistrict.value =
                      //       DealerDistrict(
                      //     dealerDistrict:
                      //         controller.applicationdata.first.districtName,
                      //   );
                      // }

                      return buildDropdown<DealerDistrict>(
                        label: 'District',
                        required: true,
                        selectedValue: controller.selecteddealerdistrict,
                        items: controller.dealerdistrict,
                        itemLabel: (district) =>
                            district.dealerDistrict ?? 'Unknown',
                        fetchData: controller.fetchdDistrict,
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () {
                          return controller.applicationdata.isNotEmpty
                              ? controller.applicationdata.first.districtName ??
                                  'Unknown'
                              : '';
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.isLoadingslbtown.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // if (controller.selectedSlbTown.value == null &&
                      //     controller.applicationdata.isNotEmpty) {
                      //   controller.selectedSlbTown.value = SlbTown(
                      //     slbTownName: controller.applicationdata.first.town,
                      //   );
                      // }

                      return buildDropdown<SlbTown>(
                        label: 'Town',
                        required: true,
                        selectedValue: controller.selectedSlbTown,
                        items: controller.dealerslbtown,
                        itemLabel: (town) => town.slbTownName ?? 'Unknown',
                        fetchData: controller.fetchSlbTown,
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () =>
                            controller.applicationdata.isNotEmpty
                                ? controller.applicationdata.first.town
                                : '',
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.isLoadingtownlocation.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // if (controller.selecteddealertownlocation.value == null &&
                      //     controller.applicationdata.isNotEmpty) {
                      //   controller.selecteddealertownlocation.value = TownLoc(
                      //     name: controller
                      //         .applicationdata.first.localOutstationName,
                      //   );
                      // }

                      return buildDropdown<TownLoc>(
                        label: 'Town Location',
                        required: true,
                        selectedValue: controller.selecteddealertownlocation,
                        items: controller.dealertownlocation,
                        itemLabel: (townLoc) => townLoc.name ?? 'Unknown',
                        fetchData: controller.fetchTownLocation,
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () =>
                            controller.applicationdata.isNotEmpty
                                ? controller
                                    .applicationdata.first.localOutstationName
                                : '',
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.isLoadingszone.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // if (controller.selecteddealerzone.value == null &&
                      //     controller.applicationdata.isNotEmpty) {
                      //   controller.selecteddealerzone.value = Zzone(
                      //     name: controller.applicationdata.first.zoneName,
                      //   );
                      // }

                      return buildDropdown<Zzone>(
                        label: 'Zone',
                        required: true,
                        selectedValue: controller.selecteddealerzone,
                        items: controller.dealerzone,
                        itemLabel: (zone) => zone.name ?? 'Unknown',
                        fetchData: controller.fetchZone,
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () =>
                            controller.applicationdata.isNotEmpty
                                ? controller.applicationdata.first.zoneName
                                : '',
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Expanded(
                  //   child: Obx(() {
                  //     return CustomTextContainer(
                  //       label: 'Contact Person Name',
                  //       value: (controller.applicationdata.isNotEmpty &&
                  //               controller
                  //                       .applicationdata.first.contactPerson !=
                  //                   null)
                  //           ? controller.applicationdata.first.contactPerson!
                  //           : null,
                  //       onChanged: (value) {
                  //         controller.contactpersonController.text = value;
                  //       },
                  //       readOnly: false,
                  //     );
                  //   }),
                  // ),
                  const SizedBox(width: 16),
                  // Expanded(
                  //   child: Obx(() {
                  //     return CustomTextContainer(
                  //       label: 'Contact Person Mobile',
                  //       value: (controller.applicationdata.isNotEmpty &&
                  //               controller.applicationdata.first
                  //                       .contactPersonNumber !=
                  //                   null)
                  //           ? controller
                  //               .applicationdata.first.contactPersonNumber!
                  //           : null,
                  //       onChanged: (value) {
                  //         controller.contactpersonController.text = value;
                  //       },
                  //       readOnly: false,
                  //     );
                  //   }),
                  // ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      return CustomTextContainer(
                        label: 'Email ID',
                        readOnly: false,
                        required: true,
                        hint: "Enter Email",
                        value: (controller.applicationdata.isNotEmpty &&
                                controller.applicationdata.first.email != null)
                            ? controller.applicationdata.first.email!
                            : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                                r'^[a-zA-Z0-9._%+-@]*$'), // ✅ Allows only valid email characters
                          ),
                        ],
                        onChanged: (value) {
                          controller.emailController.text = value;
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Row(
                children: [
                  Expanded(
                    child: CustomTextContainer(
                      label: 'Dealer Location  ',
                      hint: 'Enter Location',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      return CustomTextContainer(
                        label: 'Postal Code',
                        required: true,
                        readOnly:
                            !isEcreditHo, // If false, the field is read-only

                        hint: "Enter Postal code",
                        value: (controller.applicationdata.isNotEmpty &&
                                controller.applicationdata.first.zipCode !=
                                    null)
                            ? controller.applicationdata.first.zipCode!
                            : null,
                        onTap: () {
                          if (!isEcreditHo) {
                            AppSnackBar.alert(
                                message:
                                    "This field can only be edited by the Head Office.");
                          }
                        },
                        onChanged: (value) {
                          controller.zipcodeController.text = value;
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      return CustomTextContainer(
                        label: 'PAN',
                        readOnly: !isEcreditHo,
                        required: true,
                        hint: "Enter Pan",
                        value: (controller.applicationdata.isNotEmpty &&
                                controller.applicationdata.first.pAN != null)
                            ? controller.applicationdata.first.pAN!
                            : null,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.isLoadingtypeoffirm.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // if (controller.selectedtypeofFirm.value == null &&
                      //     controller.applicationdata.isNotEmpty) {
                      //   controller.selectedtypeofFirm.value = TypeofFirm(
                      //     typeFirmName:
                      //         controller.applicationdata.first.firmTypeName,
                      //   );
                      // }

                      return buildDropdown<TypeofFirm>(
                        label: 'Type Of Firm',
                        required: true,
                        selectedValue: controller.selectedtypeofFirm,
                        items: controller.typeofFirm,
                        itemLabel: (firm) => firm.typeFirmName ?? 'Unknown',
                        fetchData: controller.fetchTypeofFirm,
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () =>
                            controller.applicationdata.isNotEmpty
                                ? controller.applicationdata.first.firmTypeName
                                : '',
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.isLoadingtypeofreg.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return buildDropdown<Reg>(
                        label: 'Type of Registration',
                        required: true,
                        selectedValue: controller.selectedtypeofReg,
                        items: controller.typeofReg,
                        itemLabel: (state) => state.name ?? 'Unknown',
                        fetchData: controller.fetchTypeofReg,
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () =>
                            controller.applicationdata.isNotEmpty
                                ? controller
                                    .applicationdata.first.registrationTypeName
                                : '',
                        onChanged: (selected) {
                          controller.selectedtypeofReg.value = selected;
                        },
                        readOnly:
                            !isEcreditHo, // Now properly disables user interaction
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Obx(() {
                    if (controller.selectedtypeofReg.value?.name ==
                        'Unregistered') {
                      return const SizedBox();
                    }

                    return Expanded(
                      child: CustomTextContainer(
                        label: 'Gst Number',
                        required: true,
                        readOnly: !isEcreditHo,
                        hint: "Enter Gst Number",
                        value: (controller.applicationdata.isNotEmpty &&
                                controller
                                        .applicationdata.first.defaultTaxReg !=
                                    null)
                            ? controller.applicationdata.first.defaultTaxReg!
                            : null,
                        onTap: () {
                          if (!isEcreditHo) {
                            AppSnackBar.alert(
                                message:
                                    "This field can only be edited by the Head Office.");
                          }
                        },
                        onChanged: (value) {
                          bdoAuthenticate.updateGstin(value);
                          bdoAuthenticate.fetchBDO();

                          controller.gstController.text = value;
                        },
                      ),
                    );
                  }),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => buildDropdown<Data>(
                          label: 'GST Location',
                          selectedValue: controller.selectedgstlocation,
                          items: controller.gstlocation,
                          itemLabel: (state) => state.name ?? 'Unknown',
                          fetchData: controller.fetchGstLocation,
                          showDropdown: controller.showDropdown.value,
                          fallbackValue: () => '',
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Row(
                children: [
                  Expanded(
                    child: CustomTextContainer(
                      label: 'Distance from Branch to Dealer',
                      hint: 'Enter Distance',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextContainer(
                      label: 'Dealer Overall Stock Value',
                      hint: 'Enter ',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextContainer(
                      label: ' Dealer Annual Turonover',
                      hint: 'Enter ',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextContainer(
                      label: 'Dealer IMPAL Lines Sales Turnover ',
                      hint: 'Enter ',
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomTextContainer(
                      label: 'Dealer Serviced from Branch/Res/Rep ?',
                      hint: 'Enter ',
                      readOnly: true,
                    ),
                  ),
                  // const SizedBox(width: 16),
                  // Expanded(
                  //   child: CustomTextContainer(
                  //     label: 'Distance from RR Location to Dealer',
                  //     hint: 'Enter',
                  //     readOnly: true,
                  //   ),
                  // ),
                  // const SizedBox(width: 16),
                  // Expanded(
                  //   child: CustomTextContainer(
                  //     label: 'Classified as Day Travel or Outstation ?',
                  //     hint: 'Enter...',
                  //     readOnly: true,
                  //   ),
                  // ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextContainer(
                      label: 'Dealer Monthly Target',
                      hint: 'Enter ',
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.isLoadingsalesman.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.selectedSalesman.value == null &&
                          controller.applicationdata.isNotEmpty) {}
                      // Print the selected salesman's name
                      print(
                          "Selected Salesman: ${controller.selectedSalesman.value?.salesManName ?? 'None'}");

                      return buildDropdown<SalesManName>(
                        label: 'Sales Representative Assigned to the Dealer',
                        required: true,
                        selectedValue: controller.selectedSalesman,
                        items: controller.salesmandata,
                        itemLabel: (salesman) =>
                            salesman.salesManName ?? 'Unknown',
                        fetchData: () {
                          final String? branchId = isEcreditHo
                              ? controller.selectedBranchId.value
                              : employee.branchid;

                          print("BranchId: $branchId");

                          if (branchId != null && branchId.isNotEmpty) {
                            return controller.fetchSalesMan(branchId);
                          } else {
                            print("Error: Branch ID is null or empty.");
                            return Future.value();
                          }
                        },
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () =>
                            controller.applicationdata.isNotEmpty
                                ? controller.applicationdata.first.salesManname
                                : '',
                        onChanged: (SalesManName? newSalesman) {
                          controller.selectedSalesman.value =
                              newSalesman; // ✅ Updates selected salesman
                          //print("User selected: ${newSalesman?.salesManID}");
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadings.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.isLoadingperiodofvisit.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return buildDropdown<PeriodVisit>(
                        label: 'Periodicity of Dealer Visit',
                        required: false,
                        selectedValue: controller.selectedPeriodVisit,
                        items: controller.periodVisitList,
                        itemLabel: (state) =>
                            state.periodVisitName ?? 'Unknown',
                        fetchData: controller.fetchPeriodVisit,
                        showDropdown: controller.showDropdown.value,
                        fallbackValue: () => controller
                                .periodVisitList.isNotEmpty
                            ? controller.periodVisitList.first.periodVisitName
                            : 'Unknown',
                      );
                    }),
                  ),
                  // const SizedBox(height: 30),
                  //   Row(children: [
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Grouped company',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Dealer Migration',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //     // const SizedBox(width: 16),
                  //     // Expanded(
                  //     //   child: CustomDropDownField(
                  //     //     label: 'Classified as Day Travel or Outstation ?',
                  //     //     items: [],
                  //     //     isRequired: false,
                  //     //     hint: '',
                  //     //   ),
                  //     // ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Year of Establishment',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Period Dealer Visit',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //   ]),
                  //   const SizedBox(height: 30),
                  //   Row(children: [
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Overall Stock Dealer Value',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Annual Turnover',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Dealer IMPAL Sales Turnover',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: CustomTextFormField(
                  //           label: 'Brand Authorization Details',
                  //           hint: 'Enter ...',
                  //           isRequired: false),
                  //     ),
                  //   ]),
                  //   const SizedBox(height: 30),
                  //   Row(
                  //     children: [
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             const Text(
                  //               'GST Form Upload',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //             const SizedBox(height: 8),
                  //             InkWell(
                  //               onTap: () async {
                  //                 FilePickerResult? result =
                  //                     await FilePicker.platform.pickFiles();

                  //                 if (result != null &&
                  //                     result.files.single.path != null) {
                  //                   setState(() {
                  //                     selectedFile =
                  //                         File(result.files.single.path!);
                  //                     selectedFileName =
                  //                         result.files.single.name;
                  //                   });
                  //                 }
                  //               },
                  //               child: Container(
                  //                 padding: const EdgeInsets.symmetric(
                  //                     vertical: 14, horizontal: 12),
                  //                 decoration: BoxDecoration(
                  //                   border:
                  //                       Border.all(color: Colors.grey.shade400),
                  //                   borderRadius: BorderRadius.circular(8),
                  //                 ),
                  //                 child: Row(
                  //                   children: [
                  //                     const Icon(Icons.upload_file,
                  //                         color: Colors.grey),
                  //                     const SizedBox(width: 12),
                  //                     Expanded(
                  //                       child: Text(
                  //                         selectedFileName ?? 'Upload File...',
                  //                         style: TextStyle(
                  //                           color: selectedFileName == null
                  //                               ? Colors.grey
                  //                               : Colors.black,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       const SizedBox(width: 16),
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             const Text(
                  //               'PAN Card Upload (Unregistered)',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //             const SizedBox(height: 8),
                  //             InkWell(
                  //               onTap: () async {
                  //                 FilePickerResult? result =
                  //                     await FilePicker.platform.pickFiles();

                  //                 if (result != null &&
                  //                     result.files.single.path != null) {
                  //                   setState(() {
                  //                     selectedFile =
                  //                         File(result.files.single.path!);
                  //                     selectedFileName =
                  //                         result.files.single.name;
                  //                   });
                  //                 }
                  //               },
                  //               child: Container(
                  //                 padding: const EdgeInsets.symmetric(
                  //                     vertical: 14, horizontal: 12),
                  //                 decoration: BoxDecoration(
                  //                   border:
                  //                       Border.all(color: Colors.grey.shade400),
                  //                   borderRadius: BorderRadius.circular(8),
                  //                 ),
                  //                 child: Row(
                  //                   children: [
                  //                     const Icon(Icons.upload_file,
                  //                         color: Colors.grey),
                  //                     const SizedBox(width: 12),
                  //                     Expanded(
                  //                       child: Text(
                  //                         selectedFileName ?? 'Upload File...',
                  //                         style: TextStyle(
                  //                           color: selectedFileName == null
                  //                               ? Colors.grey
                  //                               : Colors.black,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buidsecondform() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoadings.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.isLoadingclassify.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // if (controller.selecteddealerclassify.value == null &&
                  //     controller.applicationdata.isNotEmpty) {
                  //   controller.selecteddealerclassify.value =
                  //       DealerClassification(
                  //     dealerClassName: controller
                  //         .applicationdata.first.dealerClassificationName,
                  //   );
                  // }

                  return buildDropdown<DealerClassification>(
                    label: 'Dealer Classification',
                    required: true,
                    selectedValue: controller.selecteddealerclassify,
                    items: controller.dealerclassify,
                    itemLabel: (classify) =>
                        classify.dealerClassName ?? 'Unknown',
                    fetchData: controller.fetchDealerclassify,
                    showDropdown: controller.showDropdown.value,
                    fallbackValue: () => controller.applicationdata.isNotEmpty
                        ? controller
                            .applicationdata.first.dealerClassificationName
                        : '',
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadings.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.isLoadingsegment.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // if (controller.selecteddealersegment.value == null &&
                  //     controller.applicationdata.isNotEmpty) {
                  //   controller.selecteddealersegment.value = DealerSegment(
                  //     dealerBussegName:
                  //         controller.applicationdata.first.dealerSegmentName,
                  //   );
                  // }

                  return buildDropdown<DealerSegment>(
                    label: 'Dealer Business/Segment',
                    required: true,
                    selectedValue: controller.selecteddealersegment,
                    items: controller.dealersegment,
                    itemLabel: (segment) =>
                        segment.dealerBussegName ?? 'Unknown',
                    fetchData: controller.fetchDealerSegment,
                    showDropdown: controller.showDropdown.value,
                    fallbackValue: () => controller.applicationdata.isNotEmpty
                        ? controller.applicationdata.first.dealerSegmentName
                        : '',
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Text(
          //   'List of key lines directly purchased from Manufacturers',
          //   style: theme.textTheme.bodyLarge
          //       ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
          //   // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 8),
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextContainer(
          //         label: '1',
          //         hint: 'Enter...',
          //         readOnly: true,
          //       ),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '2', hint: 'Enter...', readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '3', hint: 'Enter...', readOnly: true),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 8),
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '4', hint: 'Enter...', readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '5', hint: 'Enter...', readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '6', hint: 'Enter...', readOnly: true),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 20),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Obx(() {
          //         if (controller.isLoadings.value) {
          //           return const Center(child: CircularProgressIndicator());
          //         }

          //         return buildDropdown<String>(
          //           label:
          //               'Is the dealer at present dealing with any TVS Group companies? If so details',
          //           selectedValue: controller.selectedYesNo, // ✅ Null initially
          //           items: ['Yes', 'No'], // Hardcoded options
          //           itemLabel: (value) => value, // Use value as label
          //           fetchData: () async {}, // No fetch needed
          //           showDropdown: controller.showDropdown.value,
          //           fallbackValue: () => 'No', // Default fallback
          //         );
          //       }),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: 'Any additional information',
          //           hint: 'Enter...',
          //           readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: ' Transporter Name',
          //           hint: 'Enter...',
          //           readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: 'Addl Info on Dealer, if any ',
          //           hint: ' ',
          //           readOnly: true),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 50),
          // const Text(
          //   'Details of lines as ASC',
          //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 8),
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '1', hint: 'Enter...', readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '2', hint: 'Enter...', readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '3', hint: 'Enter...', readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: '4', hint: 'Enter...', readOnly: true),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 50),
          // Text(
          //   'Brand Details as Authorized Service Dealer',
          //   style: theme.textTheme.bodyLarge
          //       ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
          //   // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment:
          //       MainAxisAlignment.spaceBetween, // Distributes evenly
          //   children: [
          //     Expanded(child: _buildCheckbox('WABCO', '', false)),
          //     Expanded(child: _buildCheckbox('Rane TRW', '', false)),
          //     Expanded(child: _buildCheckbox('Turbo', '', false)),
          //     Expanded(child: _buildCheckbox('Lucas', '', false)),
          //   ],
          // ),
          // const SizedBox(height: 20),
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: 'Other Brand Name (Specify):',
          //           hint: "",
          //           readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label: 'Authorized Service Centres:',
          //           hint: 'Enter...',
          //           readOnly: true),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: CustomTextContainer(
          //           label:
          //               'If any cash purchase in last three months ( Specify) ',
          //           hint: "",
          //           readOnly: true),
          //     ),
          // ],
          // ),
        ],
      ),
    );
  }

  Widget _buildthirdform() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'Expected sales detail of major lines per month',
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                    label: '(1)', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: '(2)', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: '(3)', hint: 'Enter...', readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                    label: '(4)', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: '(5)', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: '(6)', hint: 'Enter...', readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                    label: '(7)', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: '(8)', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: '(9)', hint: 'Enter...', readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                      label: 'Existing Credit Limit',
                      required: true,
                      value: (controller.applicationdata.isNotEmpty &&
                              controller.applicationdata.first.creditLimit !=
                                  null)
                          ? controller.applicationdata.first.creditLimit!
                          : null,
                      readOnly: true);
                }),
              ),
              const SizedBox(width: 16),
              // Expanded(
              //   child: CustomTextContainer(
              //       label: 'Outstanding Amount',
              //       hint: 'Enter...',
              //       readOnly: true),
              // ),

              Expanded(
                child: Obx(() {
                  final outstandingAmount =
                      (controller.outstandingDetails.isNotEmpty &&
                              controller.outstandingDetails[0]['CanBillUpTo'] !=
                                  null &&
                              controller.outstandingDetails[0]['CanBillUpTo']
                                  .toString()
                                  .trim()
                                  .isNotEmpty)
                          ? controller.outstandingDetails[0]['CanBillUpTo']
                              .toString()
                          : '0.00';

                  // final String id = controller.customerId.toString();
                  // // Fetch outstanding details based on selected customer ID
                  // outstandingController.fetchOutstandingDetailsCustomer(id);

                  print("hii: $outstandingAmount");

                  return CustomTextContainer(
                    label: 'Outstanding Amount',
                    required: true,
                    value: outstandingAmount,
                    readOnly: true,
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  return CustomTextContainer(
                    label: 'Enhance Credit Limit',
                    required: true,
                    hint: "Enter Enhance credit limit",
                    value: (controller.applicationdata.isNotEmpty &&
                            controller.applicationdata.first.enhanceCredit !=
                                null)
                        ? controller.applicationdata.first.enhanceCredit!
                        : null,
                    backgroundColor: Color(0xFFFFFDE7),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      controller.enhanceController.text = value;

                      final parsedValue = int.tryParse(value) ?? 0;
                      if (parsedValue < 1) {
                        AppSnackBar.alert(
                            message:
                                "The minimum enhanced credit limit is 1 rupee.");
                        controller.enhanceController.clear();
                      }
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoadings.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.isLoadingcreditlimitinid.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // if (controller.selectedcreditlimitindicator.value == null &&
                  //     controller.applicationdata.isNotEmpty) {
                  //   controller.selectedcreditlimitindicator.value =
                  //       Creditlimitindi(
                  //     name:
                  //         controller.applicationdata.first.creditlimitindicator,
                  //   );
                  // }

                  return buildDropdown<Creditlimitindi>(
                    label: 'Credit Limit Indicator',
                    required: true,
                    selectedValue: controller.selectedcreditlimitindicator,
                    items: controller.creditlimitindicator,
                    itemLabel: (indicator) => indicator.name ?? 'Unknown',
                    fetchData: controller.fetchCreditLimitIndicator,
                    showDropdown: controller.showDropdown.value,
                    fallbackValue: () => controller.applicationdata.isNotEmpty
                        ? controller.applicationdata.first.creditlimitindicator
                        : '',
                  );
                }),
              ),

              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadings.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.isLoadingvalidityindi.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return buildDropdown<Validityindi>(
                    label: 'Validity Indicator',
                    required: true,
                    selectedValue: controller.selectedvalidityindicator,
                    items: controller.validityindicator,
                    itemLabel: (state) => state.name ?? 'Unknown',
                    fetchData: controller.fetchValidtyIndicator,
                    showDropdown: controller.validityindicator.isNotEmpty,
                    fallbackValue: () =>
                        controller.selectedvalidityindicator.value?.name ?? '',
                    onChanged: (Validityindi? newValue) async {
                      if (newValue != null) {
                        controller.selectedvalidityindicator.value = newValue;
                        controller.selectedvalidityindicator.refresh();
                        if (newValue.name == "Temporary") {
                          await _pickDate(autoSelect: true);
                        } else {
                          dateController.clear();
                        }
                      }
                    },
                  );
                }),
              ),

              const SizedBox(
                  width: 16), // Space between date picker and checkbox
              Expanded(
                child: Obx(() {
                  bool isTemporary =
                      controller.selectedvalidityindicator.value?.name ==
                          "Temporary";

                  if (!isTemporary) {
                    return SizedBox(); // Hide date picker if not "Temporary"
                  }

                  return SizedBox(
                    width: 400, // Adjust width
                    height: 65, // Adjust height
                    child: CustomTextContainer(
                      label: 'Validity Due Date',
                      controller: dateController,
                      readOnly: true, // Prevent manual input
                      hint: 'Enter Validity Date',
                      required: true, // Optional: Mark it required
                      backgroundColor:
                          Colors.white, // Maintain background color
                      onTap: () async {
                        await _pickDate(
                            autoSelect: false); // Allow user selection
                      },

                      suffixIcon:
                          Icon(Icons.calendar_today), // Add calendar icon here
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Expanded(
              //   child: Obx(() {
              //     if (controller.isLoadings.value) {
              //       return const Center(child: CircularProgressIndicator());
              //     }

              //     if (controller.isLoadingfreightindi.value) {
              //       return const Center(child: CircularProgressIndicator());
              //     }

              //     return buildDropdown<Freightindi>(
              //       label: 'Freight Indicator',
              //       required: true,
              //       selectedValue: controller.selectedfreightindicator,
              //       items: controller.freightindictaor,
              //       itemLabel: (indicator) => indicator.name ?? 'Unknown',
              //       fetchData: controller.fetchFreightIndicator,
              //       showDropdown: controller.showDropdown.value,
              //       fallbackValue: () => controller.applicationdata.isNotEmpty
              //           ? controller.applicationdata.first.frightName
              //           : '',
              //     );
              //   }),
              // ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadings.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.isLoadingfreightindi.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return buildDropdown<Freightindi>(
                    label: 'Freight Indicator',
                    required: true,
                    selectedValue: controller.selectedfreightindicator,
                    items: controller.freightindictaor,
                    itemLabel: (state) => state.name ?? 'Unknown',
                    fetchData: controller
                        .fetchFreightIndicator, // Will only fetch if needed
                    showDropdown: controller.showDropdown.value,
                    fallbackValue: () {
                      return controller.applicationdata.isNotEmpty
                          ? controller.applicationdata.first.frightName ??
                              'Unknown'
                          : '';
                    },
                  );
                }),
              ),

              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: 'First Time Credit Amount Request Rs.:',
                    hint: 'Enter...',
                    readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Dealer Bank Account Details',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold)
              // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                    label: 'Bank Name', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: 'Bank Branch Name ',
                    hint: 'Enter...',
                    readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: 'Bank Account Number',
                    hint: 'Enter...',
                    readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                    label: 'IFSC Code', hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: 'Name of the Bank A/C Holder',
                    hint: 'Enter...',
                    readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextContainer(
                    label: 'Card No. and Expiry Date',
                    hint: 'Enter...',
                    readOnly: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Function to pick a date
  Future<void> _pickDate({required bool autoSelect}) async {
    DateTime now = DateTime.now();
    DateTime lastDate = DateTime(now.year, now.month + 1, 0);
    DateTime today = DateTime(now.year, now.month, now.day); // ✅ Set today

    if (autoSelect) {
      // ✅ Automatically select last date of the month
      String formattedDate = DateFormat('dd/MM/yyyy').format(lastDate);
      dateController.text = formattedDate;
      controller.selectedDate.value = formattedDate; // ✅ Update controller
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: lastDate, // ✅ Default to last date of the month
      firstDate: today, // ✅ Allow selection only from today
      lastDate: lastDate, // ✅ Restrict to end of the month
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      dateController.text = formattedDate;
      controller.selectedDate.value = formattedDate; // ✅ Update controller
    }
  }

  Widget _buildfourthform() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2, // Adjust flex to allocate more or less space
                child: CustomTextContainer(
                    label: " No. of Cheque Returns:",
                    hint: 'Enter...',
                    readOnly: true),
              ),
              const SizedBox(width: 12), // Smaller spacing
              Expanded(
                flex: 2,
                child: CustomTextContainer(
                    label: 'Zonal Head Signature:',
                    hint: 'Enter...',
                    readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Accounts & IT Department for Creation of Customer Master',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2, // Adjust flex to allocate more or less space
                child: CustomTextContainer(
                    label: "Customer code :", hint: 'Enter...', readOnly: true),
              ),
              const SizedBox(width: 12), // Smaller spacing
              Expanded(
                flex: 2,
                child: CustomTextContainer(
                    label: 'DMD Signature (Digital):',
                    hint: 'Enter...',
                    readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Text(
            'Attachments Required',
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
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
                child: _buildCheckbox('Cancelled cheque leaf ', '', false),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2, // Adjust flex to allocate more or less space
                child: CustomTextContainer(
                    label: "", hint: 'Signature & Date', readOnly: true),
              ),
              const SizedBox(width: 12), // Smaller spacing
              Expanded(
                flex: 2,
                child: CustomTextContainer(
                    label: '', hint: 'Signature & Date', readOnly: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3, // Allocate more space for this field
                child: CustomTextContainer(
                    label: '', hint: 'Signature & Date', readOnly: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildfifthform() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2, // Adjust flex to allocate more or less space
                child: CustomTextContainer(
                    label: "Write off amount if any Rs.",
                    hint: 'Enter...',
                    readOnly: true),
              ),
              const SizedBox(width: 12), // Smaller spacing
              Expanded(
                flex: 2,
                child: CustomTextContainer(
                    label: 'CFO Signature (Digital):',
                    hint: 'Enter...',
                    readOnly: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3, // Allocate more space for this field
                child: CustomTextContainer(
                    label: 'DMD Signature (Digital):',
                    hint: 'Enter...',
                    readOnly: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, String subtitle, bool initialValue) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return StatefulBuilder(
      builder: (context, setState) {
        bool isChecked = initialValue;

        return CheckboxListTile(
          title: Text(
            label,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            // style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontSize: 12, color: Colors.grey))
              // style: const TextStyle(fontSize: 12, color: Colors.grey))
              : null,
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
