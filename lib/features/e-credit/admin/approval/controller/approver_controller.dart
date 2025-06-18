import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/Approval/Model/get_application_model.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/model/aging_summary_model.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/model/application_detail_model.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/model/login_branch_model.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/controller/creditlimit_controller.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/model/existing_customer_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/url/e_credit_url.dart';

class ApproverController extends GetxController {
  final CreditlimitController creditController =
      Get.put(CreditlimitController());
  final LoginController loginController = Get.put(LoginController());
  final EcreditRestletService _ecreditservice = EcreditRestletService();
  var getapp = <GetApplication>[].obs;

  var applicationDetail = <ApplicationDetail>[].obs;
  var branchdropdown = <EcreditLoginBranch>[].obs;
  RxList<AgingSummary> agingSummary = <AgingSummary>[].obs;

  var isDropdownVisible = false.obs;
  var selectedvalidityindicator = Rxn<Validityindi?>(null);

  String getValidityIndicatorName(String id) {
    switch (id) {
      case "Temporary":
        return "2";
      case "Permanent":
        return "3";
      default:
        return "";
    }
  }

  var isLoadings = false.obs;
  var isLoadingsbranch = false.obs;
  var isLoadings1 = false.obs;
  var isLoadings2 = false.obs;
  var isLoadingsaging = false.obs;
  var isLoadingsbranchstatus = false.obs;

  var validityIndi = ''.obs; // Observable string
  var validityIn = ''.obs;
  final RxBool showValidityDueDate = false.obs;

  void setValidityIndicator(String value) {
    validityIndi.value = value;
    validityIn.value = value;
  }

  final TextEditingController custIdController = TextEditingController();
  final TextEditingController dealeridController = TextEditingController();
  final TextEditingController appDateController = TextEditingController();
  //(A) Dealer KYC
  final TextEditingController nameOfDealerController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController authorisedPersonController =
      TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController dealerNameController = TextEditingController();
  final TextEditingController migrationBranchController =
      TextEditingController();
  final TextEditingController dealerCodeController = TextEditingController();
  final TextEditingController yearofEstController = TextEditingController();
  final TextEditingController dStateController = TextEditingController();
  final TextEditingController dDistrictController = TextEditingController();
  final TextEditingController dTownController = TextEditingController();
  final TextEditingController townLocationController = TextEditingController();
  final TextEditingController dZoneController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactPersonMobController =
      TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController dLocationController = TextEditingController();
  final TextEditingController dPostalCodeController = TextEditingController();
  final TextEditingController dPanController = TextEditingController();
  final TextEditingController typeofFirmController = TextEditingController();
  final TextEditingController typeofRegController = TextEditingController();
  final TextEditingController gstRegNumController = TextEditingController();
  final TextEditingController gstInLocalController = TextEditingController();
  final TextEditingController branchToDealerController =
      TextEditingController();
  final TextEditingController overallStockController = TextEditingController();
  final TextEditingController dAnnualTurnoverController =
      TextEditingController();
  final TextEditingController salesTurnoverController = TextEditingController();
  final TextEditingController rrLocationToDealerController =
      TextEditingController();
  final TextEditingController rrAssignedDealerController =
      TextEditingController();
  final TextEditingController periodicityDealerController =
      TextEditingController();
  final TextEditingController dMonthlyTargetController =
      TextEditingController();

  //(B) Dealer Profile
  final TextEditingController dClassificationController =
      TextEditingController();
  final TextEditingController dBusinessSegmentController =
      TextEditingController();
  final TextEditingController profileOneController = TextEditingController();
  final TextEditingController profileTwoController = TextEditingController();
  final TextEditingController profileThreeController = TextEditingController();
  final TextEditingController profileFourController = TextEditingController();
  final TextEditingController profileFiveController = TextEditingController();
  final TextEditingController profileSixController = TextEditingController();
  final TextEditingController dealerTVSController = TextEditingController();
  final TextEditingController addInfoController = TextEditingController();
  final TextEditingController transporterNameController =
      TextEditingController();
  final TextEditingController addlInfoDealerController =
      TextEditingController();
  final TextEditingController ascOneController = TextEditingController();
  final TextEditingController ascTwoController = TextEditingController();
  final TextEditingController ascThreeController = TextEditingController();
  final TextEditingController ascFourController = TextEditingController();
  final TextEditingController otherBrandNameController =
      TextEditingController();
  final TextEditingController authServicecenController =
      TextEditingController();

  //(c) Commercial Matters
  final TextEditingController cashPurchaseController = TextEditingController();
  final TextEditingController commercialOneController = TextEditingController();
  final TextEditingController commercialTwoController = TextEditingController();
  final TextEditingController commercialThreeController =
      TextEditingController();
  final TextEditingController commercialFourController =
      TextEditingController();
  final TextEditingController commercialFiveController =
      TextEditingController();
  final TextEditingController commercialSixController = TextEditingController();
  final TextEditingController commercialSevenController =
      TextEditingController();
  final TextEditingController commercialEightController =
      TextEditingController();
  final TextEditingController commercialNineController =
      TextEditingController();
  final TextEditingController exisCreditController = TextEditingController();
  final TextEditingController outstandingAmntController =
      TextEditingController();
  final TextEditingController enhCreditLimitController =
      TextEditingController();
  final TextEditingController creditLimitIndiController =
      TextEditingController();
  final TextEditingController creditSalesController = TextEditingController();
  final TextEditingController creditSalesControllerId = TextEditingController();
  final TextEditingController validityIndicatorId = TextEditingController();
  final TextEditingController validityIndiController = TextEditingController();
  final TextEditingController validityDueDateController =
      TextEditingController();
  final TextEditingController freightIndiController = TextEditingController();
  final TextEditingController firstTimeCreditLimitIndiController =
      TextEditingController();
  final TextEditingController dBankNameController = TextEditingController();
  final TextEditingController dBankBranchController = TextEditingController();
  final TextEditingController dBankAccNumController = TextEditingController();
  final TextEditingController dBankIFSCController = TextEditingController();
  final TextEditingController dNameOfBankController = TextEditingController();
  final TextEditingController dBankCardNoController = TextEditingController();

  //(D) Review and Approval at Branch Level
  final TextEditingController dBankSalesExecutiveController =
      TextEditingController();
  final TextEditingController dBankManagerNameController =
      TextEditingController();
  final TextEditingController dAreaManagerNameController =
      TextEditingController();

  //(E) Review and Approval at Head Office
  final TextEditingController customerCodeController = TextEditingController();

  //(E) Closure of Business with Dealer
  final TextEditingController offAmountController = TextEditingController();

  //  @override
  // void onClose() {
  //   appDateController.dispose();
  //   nameOfDealerController.dispose();
  //   authorisedPersonController.dispose();
  //   dealeridController.dispose();
  //   mobileNumberController.dispose();
  //   branchController.dispose();
  //   dStateController.dispose();
  //   dZoneController.dispose();
  //   typeofFirmController.dispose();
  //   dTownController.dispose();
  //   dDistrictController.dispose();
  //   dClassificationController.dispose();
  //   dBusinessSegmentController.dispose();
  //   gstInLocalController.dispose();
  //   exisCreditController.dispose();
  //   enhCreditLimitController.dispose();
  //   dBankSalesExecutiveController.dispose();
  //   typeofRegController.dispose();
  //   address1Controller.dispose();
  //   address2Controller.dispose();
  //   gstRegNumController.dispose();
  //   dPostalCodeController.dispose();
  //   dPanController.dispose();
  //   contactPersonController.dispose();
  //   contactPersonMobController.dispose();
  //   emailIdController.dispose();
  //   appDateController.dispose();
  //   freightIndiController.dispose();
  //   validityDueDateController.dispose();
  //   creditLimitIndiController.dispose();
  //   validityIndiController.dispose();
  //    applicationDetail.clear();
  //   print("clear");
  //   super.onClose();
  // }

  @override
  void onInit() {
    super.onInit();
    _ecreditservice.init();
    creditController.fetchValidityIndicator();
  }

  Future<void> fetchApproverBranch() async {
    try {
      isLoadingsbranch.value = true;

      final LoginController logout = Get.put(LoginController());
      final bool isApprover = logout.employeeModel.isApprover ?? false;
      final String salesRepId = logout.employeeModel.salesRepId ?? '';

      final Map<String, dynamic> requestBody = {
        "ISApprover": isApprover,
        "salesRepId": salesRepId
      };

      final response = await _ecreditservice.postRequest(
        NetSuiteScriptsEcredit.fetchApproverBranchScriptId,
        requestBody,
      );

      if (response != null) {
        List<dynamic> jsonResponse =
            response is String ? jsonDecode(response) : response;

        // Ensure it's a valid list before mapping
        branchdropdown.assignAll(jsonResponse
            .map((json) => EcreditLoginBranch.fromJson(json))
            .toList());
        update(); // Notify UI

        // branchdropdown.value = EcreditLoginBranch.fromJson(response).tolist();
      } else {
        print("No data received or response is empty");
        branchdropdown.clear();
      }
    } catch (e) {
      print("Error fetching approver branch: $e");
    } finally {
      isLoadingsbranch.value = false;
    }
    // Proceed to fetch approver applications if branches are available
    await fetchApproverApplication();
  }

  Future<void> fetchApproverApplication() async {
    try {
      isLoadingsbranchstatus.value = true;

      // Ensure branchdropdown has data before making request
      if (branchdropdown.isEmpty) {
        print("No branch data available. Fetching branch data first...");
        await fetchApproverBranch(); // Ensure branch data is fetched
      }

      // Extract branchIds from the first item of branchdropdown if available
      List<String> branchIds = [];
      if (branchdropdown.isNotEmpty) {
        branchIds = branchdropdown.first.branches
                ?.map((b) => b.branchId ?? "")
                .toList() ??
            [];
      }
      if (branchIds.isEmpty) {
        print("No valid branch IDs found after fetching.");
        return;
      }

      final LoginController logout = Get.put(LoginController());

      final String salesRepId = logout.employeeModel.salesRepId ?? '';

      Map<String, dynamic> requestBody = {
        "branchId": branchIds, // Sending all branch IDs
        "ApproverId": salesRepId
      };

      final response = await _ecreditservice.postRequest(
        NetSuiteScriptsEcredit.fetchApplicationScriptId,
        requestBody,
      );

      if (response != null) {
        print("object");

        // Ensure response is decoded correctly
        List<dynamic> jsonResponse =
            response is String ? jsonDecode(response) : response;

        // Ensure it's a valid list before mapping
        getapp.assignAll(
            jsonResponse.map((json) => GetApplication.fromJson(json)).toList());
        update(); // Notify UI
      }
    } catch (e) {
      print("Error fetching DealerName: $e");
    } finally {
      isLoadingsbranchstatus.value = false;
    }
  }

  // Future<void> fetchApproverBranch() async {
  //   try {
  //     isLoadingsbranch.value = true;

  //     final LoginController logout = Get.put(LoginController());
  //     final bool isApprover = logout.employeeModel.isApprover ?? false;
  //     final String salesRepId = logout.employeeModel.salesRepId ?? '';

  //     final Map<String, dynamic> requestBody = {
  //       "ISApprover": isApprover,
  //       "salesRepId": salesRepId
  //     };

  //     final response = await _ecreditservice.postRequest(
  //       NetSuiteScriptsEcredit.fetchApproverBranchScriptId,
  //       requestBody,
  //     );

  //     if (response != null) {
  //       List<dynamic> jsonResponse =
  //           response is String ? jsonDecode(response) : response;

  //       // Ensure it's a valid list before mapping
  //       branchdropdown.assignAll(jsonResponse
  //           .map((json) => EcreditLoginBranch.fromJson(json))
  //           .toList());
  //       update(); // Notify UI

  //       // branchdropdown.value = EcreditLoginBranch.fromJson(response).tolist();
  //     } else {
  //       print("No data received or response is empty");
  //       branchdropdown.clear();
  //     }
  //   } catch (e) {
  //     print("Error fetching approver branch: $e");
  //   } finally {
  //     isLoadingsbranch.value = false;
  //   }
  // }

  // Future<void> fetchApplication(String branchId, String approverId) async {
  //   try {
  //     isLoadings.value = true;

  //     final Map<String, String> requestBody = {
  //       "branchId": branchId,
  //       "ApproverId": approverId
  //     };

  //     final response = await _ecreditservice.postRequest(
  //       NetSuiteScriptsEcredit.fetchApplicationScriptId,
  //       requestBody,
  //     );

  //     print("object1");

  //     if (response != null) {
  //       print("object");

  //       // Ensure response is decoded correctly
  //       List<dynamic> jsonResponse =
  //           response is String ? jsonDecode(response) : response;

  //       // Ensure it's a valid list before mapping
  //       getapp.assignAll(
  //           jsonResponse.map((json) => GetApplication.fromJson(json)).toList());
  //       update(); // Notify UI
  //     }
  //   } catch (e) {
  //     print("Error fetching DealerName: $e");
  //   } finally {
  //     isLoadings.value = false;
  //   }
  // }

  Future<void> fetchApplicationDetail(String applicationNo) async {
    try {
      isLoadings1.value = true;

      final Map<String, String> requestBody = {
        "DealerId": applicationNo,
      };

      final response = await _ecreditservice.postRequest(
        NetSuiteScriptsEcredit.applicationDetailScriptId,
        requestBody,
      );

      if (response != null) {
        // Decode the response if it's a string
        List<dynamic> jsonResponse =
            response is String ? jsonDecode(response) : response;

        print("1");
        applicationDetail.assignAll(jsonResponse
            .map((json) => ApplicationDetail.fromJson(json))
            .toList());
        update();

        if (applicationDetail.isNotEmpty) {
          print("2");
          var applicationDetails = applicationDetail.first; // Get first item

          // Populate UI fields
          custIdController.text = applicationDetails.customerID ?? "";
          print("CustomerId: ${applicationDetails.customerID}");
          nameOfDealerController.text = applicationDetails.dealerName ?? "";
          dealeridController.text = applicationDetails.dealerId ?? "";
          print("DealerId : ${applicationDetails.dealerId}");
          mobileNumberController.text = applicationDetails.phone ?? "";
          // branchController.text = applicationDetails.branch ?? "";
          dStateController.text = applicationDetails.statename ?? "";
          dZoneController.text = applicationDetails.zonename ?? "";
          townLocationController.text =
              applicationDetails.localOutstationtxt ?? "";
          rrAssignedDealerController.text =
              applicationDetails.salesMantxt ?? "";
          typeofFirmController.text = applicationDetails.firmTypetxt ?? "";
          dTownController.text = applicationDetails.town ?? "";
          dDistrictController.text = applicationDetails.districtName ?? "";
          dClassificationController.text =
              applicationDetails.classification ?? "";
          dBusinessSegmentController.text =
              applicationDetails.dealerSegmenttxt ?? "";
          exisCreditController.text = applicationDetails.creditLimit ?? "";
          enhCreditLimitController.text =
              applicationDetails.enhanceCredit ?? "";
          typeofRegController.text = applicationDetails.registrationtxt ?? "";
          address1Controller.text = applicationDetails.address1 ?? "";
          address2Controller.text = applicationDetails.address2 ?? "";
          gstRegNumController.text =
              applicationDetails.gSTTaxRegistration ?? "";
          dPostalCodeController.text = applicationDetails.zipcode ?? "";
          dPanController.text = applicationDetails.pAN ?? "";
          authorisedPersonController.text =
              applicationDetails.contectPerson ?? "";
          contactPersonController.text = applicationDetails.contectPerson ?? "";
          contactPersonMobController.text =
              applicationDetails.contectNumber ?? "";
          emailIdController.text = applicationDetails.email ?? "";
          appDateController.text = applicationDetails.applicationDate ?? "";
          freightIndiController.text = applicationDetails.frighttxt ?? "";
          validityDueDateController.text =
              applicationDetails.validatedate ?? "";
          // creditLimitIndiController.text = applicationDetails.creditlimitindicator ?? "";
          validityIndicatorId.text = applicationDetails.validityIndicator ?? "";
          validityIndiController.text =
              applicationDetails.validityIndicatortxt ?? "";
          validityIndi.value = applicationDetails.validityIndicatortxt ?? "";
          creditSalesController.text =
              applicationDetails.creditlimitindicatortxt ?? "";
          creditSalesControllerId.text =
              applicationDetails.creditlimitindicator ?? "";
          print("creditSalesControllerId ${creditSalesControllerId.text}");
        }
      } else {
        print("Error fetching application details: Response is null");
      }
    } catch (e) {
      print("Error fetching DealerName: $e");
    } finally {
      isLoadings1.value = false;
    }
  }

//   Future<void> fetchApplicationDetail(String applicationNo) async {
//   try {
//     isLoadings1.value = true;

//     final Map<String, String> requestBody = {
//       "DealerId": applicationNo,

//     };

//     final response = await _ecreditservice.postRequest(
//       NetSuiteScriptsEcredit.applicationDetailScriptId,
//       requestBody,
//     );

//     if (response is List) {
//       print("1");
//     applicationDetail.value = response.map((json) => ApplicationDetail.fromJson(json)).toList();
//   update();

//   if (applicationDetail.isNotEmpty) {
//     print("2");
//     var applicationDetails = applicationDetail.first; // Get first item
//       custIdController.text = applicationDetails.customerID ?? "";
//       nameOfDealerController.text = applicationDetails.dealerName ?? "";
//       dealeridController.text = applicationDetails.dealerId ?? "";
//       mobileNumberController.text = applicationDetails.phone ?? "";
//       branchController.text = applicationDetails.branchName ?? "";
//       dStateController.text = applicationDetails.stateName ?? "";
//       dZoneController.text = applicationDetails.zoneName ?? "";
//       typeofFirmController.text = applicationDetails.firmTypeName ?? "";
//       dTownController.text = applicationDetails.town ?? "";
//       dDistrictController.text = applicationDetails.districtName ?? "";
//       dClassificationController.text = applicationDetails.dealerClassificationName ?? "";
//       dBusinessSegmentController.text = applicationDetails.dealerSegmentName ?? "";
//       gstInLocalController.text = applicationDetails.localOutstationName ?? "";
//       exisCreditController.text = applicationDetails.creditLimit ?? "";
//       enhCreditLimitController.text = applicationDetails.enhanceCredit ?? "";
//       dBankSalesExecutiveController.text = applicationDetails.salesMan ?? "";
//       typeofRegController.text = applicationDetails.registrationType ?? "";
//       address1Controller.text = applicationDetails.address1 ?? "";
//       address2Controller.text = applicationDetails.address2 ?? "";
//       gstRegNumController.text = applicationDetails.defaultTaxReg ?? "";
//       dPostalCodeController.text = applicationDetails.zipCode ?? "";
//       dPanController.text = applicationDetails.pAN ?? "";
//       contactPersonController.text = applicationDetails.contactPerson ?? "";
//       contactPersonMobController.text = applicationDetails.contactPersonNumber ?? "";
//       emailIdController.text = applicationDetails.email ?? "";
//       appDateController.text = applicationDetails.applicationDate ?? "";
//       freightIndiController.text = applicationDetails.frightName ?? "";
//       validityDueDateController.text = applicationDetails.validatedate ?? "";
//       creditLimitIndiController.text = applicationDetails.creditlimitindicator ?? "";
//       validityIndiController.text = applicationDetails.validityIndicatorName ?? "";
//       validityIndi.value = applicationDetails.validityIndicatorName ?? "";

//   }

//     } else {
//       print("Error fetching application details");

//     }
//   } catch (e) {
//     print("Error fetching DealerName: $e");
//   } finally {
//     isLoadings1.value = false;
//   }
// }

  Future<void> sendApprovalStatus(
      String status,
      String reason,
      String customerId,
      String creditlim,
      String dealerId,
      String datecontroller) async {
    try {
      isLoadings2.value = true;
      final String approverid = loginController.employeeModel.salesRepId ?? '';

      String validityIndicId = (creditSalesControllerId.text == "1")
          ? "" // Send an empty string if Creditlimitindicator is "1"
          : (validityIn.value.isNotEmpty
              ? validityIn.value // Send selected value
              : "");

      String validityDate = (creditSalesControllerId.text == "1")
          ? "" // Send an empty string if Creditlimitindicator is "1"
          : (datecontroller.isNotEmpty ? datecontroller : "");

      print("1 $customerId");
      print("2 $status");
      print("3 $creditlim");
      print("4 $approverid");
      print("5 $reason");
      print("6 $validityIndicId");
      print("7 $dealerId");
      print("8 $validityDate");

      final Map<String, String> requestBody = {
        "customerId": customerId,
        "approvalStatus": status,
        "creditlimit": creditlim,
        "approver": approverid,
        "reason": reason,
        "validityIndicator": validityIndicId,
        "validatedate": validityDate,
        "branchid": "",
        "DealerId": dealerId
      };

      final response = await _ecreditservice.postRequest(
        NetSuiteScriptsEcredit.submitApprovalScriptId,
        requestBody,
      );

      if (response is Map<String, dynamic> && response["success"] == true) {
        String? message = '';
        if (status == "2") {
          message = "Approved";
        } else {
          message = "Rejected";
        }

        custIdController.clear();
        nameOfDealerController.clear();
        appDateController.clear();
        nameOfDealerController.clear();
        authorisedPersonController.clear();
        dealeridController.clear();
        mobileNumberController.clear();
        branchController.clear();
        dStateController.clear();
        dZoneController.clear();
        typeofFirmController.clear();
        dTownController.clear();
        dDistrictController.clear();
        dClassificationController.clear();
        dBusinessSegmentController.clear();
        gstInLocalController.clear();
        exisCreditController.clear();
        enhCreditLimitController.clear();
        dBankSalesExecutiveController.clear();
        typeofRegController.clear();
        address1Controller.clear();
        address2Controller.clear();
        gstRegNumController.clear();
        dPostalCodeController.clear();
        dPanController.clear();
        contactPersonController.clear();
        contactPersonMobController.clear();
        emailIdController.clear();
        appDateController.clear();
        freightIndiController.clear();
        validityDueDateController.clear();
        creditLimitIndiController.clear();
        validityIndiController.clear();
        //model
        getapp.clear();
        fetchApproverBranch();

        print("Application $message Successfully");
        AppSnackBar.success(message: "Application $message Successfully");
      } else {
        custIdController.clear();
        nameOfDealerController.clear();
        appDateController.clear();
        nameOfDealerController.clear();
        authorisedPersonController.clear();
        dealeridController.clear();
        mobileNumberController.clear();
        branchController.clear();
        dStateController.clear();
        dZoneController.clear();
        typeofFirmController.clear();
        dTownController.clear();
        dDistrictController.clear();
        dClassificationController.clear();
        dBusinessSegmentController.clear();
        gstInLocalController.clear();
        exisCreditController.clear();
        enhCreditLimitController.clear();
        dBankSalesExecutiveController.clear();
        typeofRegController.clear();
        address1Controller.clear();
        address2Controller.clear();
        gstRegNumController.clear();
        dPostalCodeController.clear();
        dPanController.clear();
        contactPersonController.clear();
        contactPersonMobController.clear();
        emailIdController.clear();
        appDateController.clear();
        freightIndiController.clear();
        validityDueDateController.clear();
        creditLimitIndiController.clear();
        validityIndiController.clear();
        //model
        getapp.clear();
        fetchApproverBranch();

        print("Approval status Not updated successfully");
        AppSnackBar.alert(message: "Application is not Submitted");
      }
    } catch (e) {
      print("Error fetching DealerName: $e");
    } finally {
      isLoadings2.value = false;
    }
  }

  Future<void> fetchAgingSummaryDetail(String customerId) async {
    try {
      isLoadingsaging.value = true;
 
      final Map<String, String> requestBody = {
        "CustomerId": customerId,
      };
 
      final response = await _ecreditservice.postRequest(
        NetSuiteScriptsEcredit.agingSummaryDetailScriptId,
        requestBody,
      );
    if (response != null && response is String) {
      final parsed = json.decode(response); // Now parsed is List or Map
 
      if (parsed is List && parsed.isNotEmpty) {
        List<AgingSummary> fetchedData = parsed
            .map<AgingSummary>((item) => AgingSummary.fromJson(item))
            .toList();
 
        print("Parsed Aging List: $fetchedData");
        agingSummary.assignAll(fetchedData);
      } else {
        agingSummary.clear();
      }
    } else {
      agingSummary.clear();
    }
 
 
 
      //       if (response != null && response is List && response.isNotEmpty) {
      //        List<AgingSummary> fetchedData = response
      //     .map((item) => AgingSummary.fromJson(item))
      //     .toList();
 
      // agingSummary.assignAll(fetchedData);
     
      // } else {
      //   agingSummary.clear();
      // }
 
    } catch (e) {
      print("Error fetching AgeingDetails: $e");
    } finally {
      isLoadingsaging.value = false;
    }
  }
}
