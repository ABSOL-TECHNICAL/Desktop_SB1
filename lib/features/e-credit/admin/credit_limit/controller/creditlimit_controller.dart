import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/model/Model/application_model.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/model/Model/branch_model.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/model/Model/dealername_model.dart';
import 'package:impal_desktop/features/e-credit/admin/credit_limit/model/Model/validityindicator_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/url/e_credit_url.dart';

class CreditlimitController extends GetxController {
  final EcreditRestletService _restletService = EcreditRestletService();

  var branches = <Branch>[].obs;
  var dealernname = <DealerName>[].obs;
  var application = <ApplicationDetails>[].obs;
  var validityindi = <ValidityIndicator>[].obs;
  var validityIndi = <Data>[].obs;
  var isLoading = false.obs;
  var isLoadings = false.obs;
  var isLoadings1 = false.obs;
  var isLoadings2 = false.obs;
  var isLoadings3 = false.obs;

  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController creditLimitController = TextEditingController();

  @override
  void onClose() {
    address1Controller.dispose();
    address2Controller.dispose();
    postalCodeController.dispose();
    gstController.dispose();
    mobileController.dispose();
    creditLimitController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchBranches();
    fetchValidityIndicator();
  }

  Future<void> fetchBranches() async {
    try {
      isLoading.value = true;
      final Map<String, String> requestBody = {};
      final response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.branchScriptId,
        requestBody,
      );

      if (response != null && response is List) {
        branches.value = response.map((json) => Branch.fromJson(json)).toList();
      } else {
        print("Invalid response format");
      }
    } catch (e) {
      print("Error fetching branches: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDealerName(String id) async {
    try {
      isLoadings.value = true;

      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.dealerScriptId,
        {'branchId': id},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          dealernname.clear();
          return;
        }
      }

      if (response is List) {
        dealernname.assignAll(response.map((e) => DealerName.fromJson(e)));
      } else {
        dealernname.clear();
      }
    } catch (e) {
      print("Fetch Error: $e");
      dealernname.clear();
    } finally {
      isLoadings.value = false;
    }
  }

  Future<void> fetchApplication(String dealerId, String customerId) async {
    try {
      isLoadings1.value = true;

      final Map<String, String> requestBody = {
        "customerId": customerId,
        "dealerId": dealerId
      };

      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.applicationScriptId,
        requestBody,
      );
      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          dealernname.clear();
          return;
        }
      }

      if (response is List) {
        print("Hii");
        application.value =
            response.map((json) => ApplicationDetails.fromJson(json)).toList();
        update();
        if (application.isNotEmpty) {
          var applicationDetails = application.first; // Get first item

          address1Controller.text = applicationDetails.address1 ?? "";
          address2Controller.text = applicationDetails.address2 ?? "";
          postalCodeController.text = applicationDetails.zipCode ?? "";
          gstController.text = applicationDetails.defaultTaxReg ?? "";
          mobileController.text = applicationDetails.phone ?? "";
          creditLimitController.text = applicationDetails.creditLimit ?? "";
        }
      } else {
        print("Invalid response format: Expected a list but got $response");
        final String error = response['error'];
        AppSnackBar.alert(message: error);
        dealernname.clear();
      }
    } catch (e) {
      print("Error fetching application: $e");
    } finally {
      isLoadings1.value = false;
    }
  }

  Future<void> fetchValidityIndicator() async {
    try {
      isLoadings2.value = true;
      final Map<String, String> requestBody = {};

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.validityIndiScriptId,
        requestBody,
      );
      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          dealernname.clear();
          return;
        }
      }

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          validityindi.value = [
            ValidityIndicator.fromJson(
                response) // Parse the entire response correctly
          ];
        } else {
          print(
              "Invalid response format: Missing 'data' key or incorrect type");
        }
      } else {
        print("Invalid response format");
      }
    } catch (e) {
      print("Error fetching validity indicator: $e");
    } finally {
      isLoadings2.value = false;
    }
  }

  Future<void> submitApplication(String customerId, String creditlimit,
      String validityIndicator, String validityDate) async {
    try {
      isLoadings3.value = true;

      final Map<String, String> requestBody = {
        "customerId": customerId,
        "creditlimit": creditlimit,
        "validityIndicator": validityIndicator,
        "validityDate": validityDate
      };

      final response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.submitCreditLimitScriptId,
        requestBody,
      );

      if (response is Map<String, dynamic> && response["success"] == true) {
        print("Credit Limit updated successfully");
        AppSnackBar.success(message: "Credit Limit updated Successfully");
      } else {
        print("Credit Limit Not updated successfully");
        AppSnackBar.alert(message: "Credit Limit Not Updated");
      }
    } catch (e) {
      print("Error Submitting Application: $e");
    } finally {
      isLoadings3.value = false;
    }
  }
}
