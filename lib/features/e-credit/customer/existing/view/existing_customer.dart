import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/controller/existing_customer_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/widget/existing_widget.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

import 'package:intl/intl.dart';

class ExistingCustomer extends StatefulWidget {
  static const String routeName = '/existingCustomer';

  const ExistingCustomer({super.key});

  @override
  _ExistingCustomerState createState() => _ExistingCustomerState();
}

class _ExistingCustomerState extends State<ExistingCustomer> {
  bool _isSubmitting = false; // Add this in your class

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // GetX Controller (Initialize once)
  late final ExistingcustomerController controller;

  // Date Controller
  final TextEditingController dateController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  //  final TextEditingController phoneController = TextEditingController();
  //    final TextEditingController panController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? selectedBranchId;
   final FocusNode _focusNode = FocusNode();
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    // Initialize GetX Controller
    controller = Get.put(ExistingcustomerController());
    controller.dealerId.value = '';
    controller.customerId.value = '';
    controller.selecteddealerstate.value = null;
    controller.selecteddealerclassify.value = null;
    controller.selecteddealersegment.value = null;
    controller.selectedtypeofFirm.value = null;
    controller.selectedtypeofReg.value = null;
    controller.selectedSalesman.value = null;
    controller.selecteddealerdistrict.value = null;
    controller.selecteddealerzone.value = null;
    controller.selecteddealertownlocation.value = null;
    controller.selectedfreightindicator.value = null;
    controller.selectedvalidityindicator.value = null;

    // Clear all text controllers
    controller.emailController.clear();
    controller.phoneController.clear();
    controller.gstController.clear();
    controller.panController.clear();
    controller.enhanceController.clear();
    controller.contactpersonController.clear();
    controller.dealerController.clear();
    controller.address1Controller.clear();
    controller.address2Controller.clear();
    controller.zipcodeController.clear();

    // Reset observable values
    controller.selectedDate.value = '';

    // Optionally reset dropdown lists or other states
    controller.dealerstate.clear();
    controller.dealerclassify.clear();
    controller.dealersegment.clear();
    controller.typeofFirm.clear();
    controller.typeofReg.clear();
    controller.salesmandata.clear();
    controller.dealerdistrict.clear();
    controller.dealerzone.clear();
    controller.dealertownlocation.clear();
    controller.freightindictaor.clear();
    controller.validityindicator.clear();
    // Set default date
    _resetForm();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
  

  @override
  void dispose() {
    Get.delete<ExistingcustomerController>();
     _focusNode.dispose();
    super.dispose();
  }

  
  void _submitForm() {
  controller.resetErrorStates();
  
  bool isValid = true;

  // Validate text fields
  if (controller.dealerController.text.isEmpty) {
    controller.hasDealerError.value = true;
    isValid = false;
  }
  
  if (controller.address1Controller.text.isEmpty) {
    controller.hasAddress1Error.value = true;
    isValid = false;
  }
  
  if (controller.zipcodeController.text.isEmpty) {
    controller.hasZipcodeError.value = true;
    isValid = false;
  }
  
  if (controller.phoneController.text.isEmpty) {
    controller.hasPhoneError.value = true;
    isValid = false;
  }
  
  if (controller.propertierController.text.isEmpty) {
    controller.hasPropertierError.value = true;
    isValid = false;
  }
  
  if (controller.emailController.text.isEmpty) {
    controller.hasEmailError.value = true;
    isValid = false;
  }
  
  if (controller.panController.text.isEmpty) {
    controller.hasPanError.value = true;
    isValid = false;
  }
  
  if (controller.enhanceController.text.isEmpty) {
    controller.hasEnhanceError.value = true;
    isValid = false;
  }
  
  // Validate dropdowns
  if (controller.selecteddealerstate.value == null) {
    controller.hasStateError.value = true;
    isValid = false;
  }
  
  if (controller.selecteddealerdistrict.value == null) {
    controller.hasDistrictError.value = true;
    isValid = false;
  }
  
  if (controller.selectedSlbTown.value == null) {
    controller.hasTownError.value = true;
    isValid = false;
  }
  
  if (controller.selecteddealertownlocation.value == null) {
    controller.hasTownLocationError.value = true;
    isValid = false;
  }
  
  if (controller.selecteddealerzone.value == null) {
    controller.hasZoneError.value = true;
    isValid = false;
  }
  
  if (controller.selectedtypeofFirm.value == null) {
    controller.hasTypeOfFirmError.value = true;
    isValid = false;
  }
  
  if (controller.selectedtypeofReg.value == null) {
    controller.hasTypeOfRegError.value = true;
    isValid = false;
  }
  
  if (controller.selectedSalesman.value == null) {
    controller.hasSalesmanError.value = true;
    isValid = false;
  }
  
  if (controller.selecteddealerclassify.value == null) {
    controller.hasDealerClassifyError.value = true;
    isValid = false;
  }
  
  if (controller.selecteddealersegment.value == null) {
    controller.hasDealerSegmentError.value = true;
    isValid = false;
  }
  
  if (controller.selectedcreditlimitindicator.value == null) {
    controller.hasCreditLimitIndicatorError.value = true;
    isValid = false;
  }
  
  if (controller.selectedvalidityindicator.value == null) {
    controller.hasValidityIndicatorError.value = true;
    isValid = false;
  }
  
  if (controller.selectedfreightindicator.value == null) {
    controller.hasFreightIndicatorError.value = true;
    isValid = false;
  }

 
    // Retrieve values from controllers or fallback to API data
    String getValue(String? textController, String? apiValue) {
      return textController?.trim().isNotEmpty == true
          ? textController!.trim()
          : apiValue ?? '';
    }

    //  final controller = this.controller;

    // Retrieve values
    String customerID = controller.customerId.value;
    String dealerId = controller.dealerId.value;
    String applicationDate = dateController.text;
    String validateDate = controller.selectedDate.value;

    // Fetch data from controllers or API
    String state = getValue(
        controller.selecteddealerstate.value?.stateId,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.stateId
            : '');

    String slbtown = getValue(
        controller.selectedSlbTown.value?.slbTownId,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.townText
            : '');

    String dealerClassification = getValue(
        controller.selecteddealerclassify.value?.dealerClassId,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.dealerClassification
            : '');

    String dealersegment = getValue(
        controller.selecteddealersegment.value?.dealerBusSegId,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.dealerSegment
            : '');

    String typeofFirm = getValue(
        controller.selectedtypeofFirm.value?.typeFirmID?.toString(),
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.firmType?.toString()
            : '');

    String typeofReg = getValue(
        controller.selectedtypeofReg.value?.id?.toString(),
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.registrationType?.toString()
            : '');

    String salesMan = getValue(
        controller.selectedSalesman.value?.salesManID?.toString(),
        controller.selectedSalesman.value == null &&
                controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.salesMan?.toString()
            : '');

    String branch = controller.applicationdata.isNotEmpty
        ? controller.applicationdata.first.branch ?? ''
        : '';
    String addressid = controller.applicationdata.isNotEmpty
        ? controller.applicationdata.first.addressid ?? ''
        : '';

    String address1 = getValue(
        controller.address1Controller.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.address1
            : '');

    String address2 = getValue(
        controller.address2Controller.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.address2
            : '');

    String district = getValue(
        controller.selecteddealerdistrict.value?.dealerDistrict,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.districtName
            : '');

    String zoneId = getValue(
        controller.selecteddealerzone.value?.id?.toString(),
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.zone?.toString()
            : '');

    String townLocationId = getValue(
        controller.selecteddealertownlocation.value?.id?.toString(),
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.localOutstation?.toString()
            : '');

    String fright = getValue(
        controller.selectedfreightindicator.value?.id?.toString(),
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.fright?.toString()
            : '');

    String? creditLimit = controller.applicationdata.isNotEmpty &&
            (controller.applicationdata.first.creditLimit is num &&
                (controller.applicationdata.first.creditLimit as num) > 0.0)
        ? controller.applicationdata.first.creditLimit.toString()
        : null;

    String enhancecreditlimit = getValue(
        controller.enhanceController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.enhanceCredit
            : '');

    String pan = getValue(
        controller.panController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.pAN
            : '');

    String validityIndicator = getValue(
        controller.selectedvalidityindicator.value?.id?.toString(),
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.validityIndicator?.toString()
            : '');

    String creditlimitindicator = getValue(
        controller.selectedcreditlimitindicator.value?.id?.toString(),
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.creditlimitindicator?.toString()
            : '');

    String email = getValue(
        controller.emailController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.email
            : '');

    String propertier = getValue(
        controller.propertierController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.dealerName
            : '');

    String contactPerson = getValue(
        controller.contactpersonController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.contactPerson
            : '');

    String postalcode = getValue(
        controller.zipcodeController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.zipCode
            : '');

    String contactPersonnumber = getValue(
        controller.contactpersonController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.contactPersonNumber
            : '');

    String phoneNo = getValue(
        controller.phoneController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.phone
            : '');

    String defaultTaxReg = getValue(
        controller.gstController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.defaultTaxReg
            : '');

    String stateName = getValue(
        controller.selecteddealerstate.value?.stateName,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.stateName
            : '');

    String dealer = getValue(
        controller.dealerController.text,
        controller.applicationdata.isNotEmpty
            ? controller.applicationdata.first.name
            : '');

    String periodofVisit =
        controller.selectedPeriodVisit.value?.periodVisitId ?? '';
    String gstlocation = controller.selectedgstlocation.value?.name ?? '';

    // Required field validation
    Map<String, String> fields = {
      "Customer ID": customerID,
      "Dealer ID": dealerId,
      "Dealer Name": dealer,
      "Application Date": applicationDate,
      "Address 1": address1,
      "Postal Code": postalcode,
      "Phone Number": phoneNo,
      "Proprietor Name": propertier,
      "State": state,
      "District": district,
      "Zone": zoneId,
      "Town": slbtown,
      "Town Location": townLocationId,
      "Email": email,
      "PAN": pan,
      "Type of Firm": typeofFirm,
      "Type of Reg": typeofReg,
      "SalesMan": salesMan,
      "Dealer Classification": dealerClassification,
      "Enhance Credit Limit": enhancecreditlimit,
      "Credit Limit Indicator": creditlimitindicator,
      "Validity Indicator": validityIndicator,
      "Freight Indicator": fright
    };

    for (var entry in fields.entries) {
      if (entry.value.isEmpty) {
        AppSnackBar.alert(message: "${entry.key} cannot be empty");
        return;
      }
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: "Confirm Submission",
        message: "Are you sure you want to submit?",
        onConfirm: () async {
          setState(() {
            _isSubmitting = true; // Show loading
          });
          Navigator.of(context).pop();
          await controller.fetchExistingCustomer(
            customerID: customerID,
            dealerId: dealerId,
            phoneNo: phoneNo,
            stateName: state,
            branch: branch,
            typeOfFirmValue: typeofFirm,
            dealerSegmentValue: dealersegment,
            dealerClassificationValue: dealerClassification,
            town: slbtown,
            district: district,
            propertierName: propertier,
            zone: zoneId,
            townLocationId: townLocationId,
            creditLimit: creditLimit,
            creditlimitindicator: creditlimitindicator,
            enhanceCredit: enhancecreditlimit,
            fright: fright,
            typeofRegistrationId: typeofReg,
            pan: pan,
            salesmanValue: salesMan,
            contactPersonNumber: contactPersonnumber,
            applicationDate: applicationDate,
            validityIndicator: validityIndicator,
            validateDate: validateDate,
            email: email,
            defaultTaxReg: defaultTaxReg,
            nexusstate: stateName,
            address1: address1,
            address2: address2,
            postalcode: postalcode,
            dealer: dealer,
            addressid: addressid,
          );
          setState(() {
            _isSubmitting = false; // Show loading
          });

          _resetForm();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _resetForm() {
    controller.dealerId.value = '';
    controller.customerId.value = '';
    controller.dealerCode.value = '';
    controller.selectedBranchId.value = '';

    // Reset dropdown selections
    controller.selecteddealer.value = null; // Reset dealer
    controller.selecteddealer.refresh();
   
    controller.dealerNamedata.clear();
    controller.dealerNamedata.refresh(); // Ensure UI update
  
    // Reset dependent fields
    controller.applicationdata.clear();
    controller.applicationdata.refresh();
    

    // Reset all text fields
    controller.emailController.clear();
    controller.phoneController.clear();
    controller.gstController.clear();
    controller.panController.clear();
    controller.enhanceController.clear();
    controller.contactpersonController.clear();
    controller.dealerController.clear();
    controller.address1Controller.clear();
    controller.address2Controller.clear();
    controller.zipcodeController.clear();

    // Reset all dropdowns
    controller.selecteddealerstate.value = null;
    controller.selecteddealerclassify.value = null;
    controller.selecteddealersegment.value = null;
    controller.selectedtypeofFirm.value = null;
    controller.selectedtypeofReg.value = null;
    controller.selectedSalesman.value = null;
    controller.selecteddealerdistrict.value = null;
    controller.selecteddealerzone.value = null;
    controller.selecteddealertownlocation.value = null;
    controller.selectedSlbTown.value = null;
    controller.selectedfreightindicator.value = null;
    controller.selectedvalidityindicator.value = null;
    controller.selectedcreditlimitindicator.value = null;
    controller.selectedPeriodVisit.value = null;
    

    // Reset lists
    controller.dealerstate.clear();
    controller.dealerclassify.clear();
    controller.dealersegment.clear();
    controller.typeofFirm.clear();
    controller.typeofReg.clear();
    controller.salesmandata.clear();
    controller.dealerdistrict.clear();
    controller.dealerzone.clear();
    controller.dealertownlocation.clear();
    controller.freightindictaor.clear();
    controller.validityindicator.clear();
    controller.creditlimitindicator.clear();
    controller.periodVisitList.clear();
    controller.outstandingDetails.clear();
    

    // 🔥 Force UI update
    controller.update();
  }
  

  // Function to scroll up
  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.offset - 500, // Adjust the scroll distance as needed
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Function to scroll down
  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.offset + 5000, // Adjust the scroll distance as needed
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Existing Customer Application',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            
            controller: _scrollController,
            child: Form(
              key: _formKey,
              child:
                  Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                child: 
            Align(
                  alignment: Alignment.topRight,
                 child: InkWell(
                      onTap: () {
                        _resetForm();
                       controller. resetErrorStates() ;
                       controller. refreshData();
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
              ), ),Column(
                children: [
                  ExistingCustomerWidget(controller: controller),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10, right: 30),
                      child: SizedBox(
                        width: 120,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFF1E40AF),
                            shadowColor: Colors.black.withOpacity(0.4),
                            elevation: 6,
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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
}
