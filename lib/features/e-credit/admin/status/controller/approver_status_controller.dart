import 'dart:convert';

import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/controller/approver_controller.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/model/login_branch_model.dart';
import 'package:impal_desktop/features/e-credit/admin/status/model/approver_status_model.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/url/e_credit_url.dart';

class ApprovalStatusController extends GetxController {
  final EcreditRestletService _restletService = EcreditRestletService();
  // final RestletService _restletService = RestletService();
  var isLoadingsbranch = false.obs;
  var isLoadingsbranchstatus = false.obs;
  var isLoadings1 = false.obs;
  var branchdropdown = <EcreditLoginBranch>[].obs;
  var statusData = <ApproverStatusData>[].obs;

  final ApproverController approverController = Get.put(ApproverController());

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
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

      final response = await _restletService.postRequest(
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
  }

  Future<void> fetchApproverStatusData() async {
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
        "branchID": branchIds, // Sending all branch IDs
        "ApproverId": salesRepId
      };

      final response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.fetchApproverStatusScriptId,
        requestBody,
      );

      if (response != null) {
        List<dynamic> jsonResponse =
            response is String ? jsonDecode(response) : response;

        statusData.assignAll(jsonResponse
            .map((json) => ApproverStatusData.fromJson(json))
            .toList());
        update(); // Notify UI
      } else {}
    } catch (e) {
      print("Error fetching approver branch: $e");
    } finally {
      isLoadingsbranchstatus.value = false;
    }
  }
}
