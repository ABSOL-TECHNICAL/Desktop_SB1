import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/model/application_detail_model.dart';
import 'package:impal_desktop/features/e-credit/customer/status/model/application_status_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/url/e_credit_url.dart';

class WithdrawController extends GetxController {
  final EcreditRestletService _restletService = EcreditRestletService();
  var isLoadings = false.obs;
  var applicationDetail = <ApplicationDetail>[].obs;
  var applicationName = <ApplicationName>[].obs;

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

  Future<void> fetchApplicationName(String branchId) async {
    try {
      isLoadings.value = true;

      final Map<String, String> requestBody = {
        "BranchId": branchId,
      };

      final response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.fetchapplicationwithdrawScriptId,
        requestBody,
      );
      if (response != null) {
        // Decode the JSON string into a list
        List<dynamic> jsonResponse = jsonDecode(response);

        // Convert the list into ApplicationName objects
        applicationName.value =
            jsonResponse.map((json) => ApplicationName.fromJson(json)).toList();

        update();
      }
    } catch (e) {
      print("Error fetching DealerName: $e");
    } finally {
      isLoadings.value = false;
    }
  }

  Future<void> fetchApplicationDetailwithdraw(String branchId) async {
    try {
      isLoadings.value = true;

      final Map<String, String> requestBody = {
        "DealerId": branchId,
      };

      final response = await _restletService.postRequest(
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
          var applicationDetails = applicationDetail.first; // Get first item
          custIdController.text = applicationDetails.customerID ?? "";
          print("CustomerId: ${custIdController.text}");
          nameOfDealerController.text = applicationDetails.dealerName ?? "";
          dealeridController.text = applicationDetails.dealerId ?? "";
          print("DealerId : ${applicationDetails.dealerId}");
          mobileNumberController.text = applicationDetails.phone ?? "";
          branchController.text = applicationDetails.branch ?? "";
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
          // validityIndi.value = applicationDetails.validityIndicatortxt ?? "";
          creditSalesController.text =
              applicationDetails.creditlimitindicatortxt ?? "";
        }
      } else {
        print("Error fetching application details: Response is null");
      }
    } catch (e) {
      print("Error fetching DealerName: $e");
    } finally {
      isLoadings.value = false;
    }
  }

  Future<void> submitwithdraw(String branchId) async {
    try {
      isLoadings.value = true;

      final Map<String, String> requestBody = {
        "customerId": branchId,
      };

      final response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.submitwithdrawapplicationScriptId,
        requestBody,
      );

      if (response is Map<String, dynamic> && response["success"] == true) {
        print("Approval status updated successfully");
        AppSnackBar.success(message: "Application Withdraw Successfully");
      } else {
        print("Approval status Not updated successfully");
        AppSnackBar.alert(message: "Application is Not withdraw Successfully");
      }
    } catch (e) {
      print("Error fetching DealerName: $e");
    } finally {
      isLoadings.value = false;
    }
  }
}
