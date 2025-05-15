import 'dart:convert';
import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/customer/status/model/customer_status_model.dart';
import 'package:impal_desktop/features/e-credit/customer/status/model/status_model.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/url/e_credit_url.dart';

class StatusController extends GetxController {
  final EcreditRestletService _restletService = EcreditRestletService();
  var isLoadings = false.obs;
  var isLoadings1 = false.obs;
  var isLoadingsstatusApplication = false.obs;

  var applicationstatus = <CustomerStatusData>[].obs;
  var appstatus = <ApplicationStatus>[].obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchApplicationStatus();
  }

  Future<void> fetchApplicationStatus() async {
    try {
      isLoadingsstatusApplication.value = true;
      final LoginController loginController = Get.put(LoginController());

      String? branch = loginController.employeeModel.branchid;
      print("Branch ID: $branch");

      if (branch == null) {
        print("Error: Branch ID is null");
        return;
      }

      final Map<String, String> requestBody = {
        "branchID": branch,
      };

      print("Request Body: $requestBody");

      final response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.fetchStatusDataUpdatedScriptId,
        requestBody,
      );

      if (response == null) {
        print("Error: API returned null response");
        return;
      }

      if (response is String) {
        final parsedResponse = jsonDecode(response);
        if (parsedResponse is List) {
          applicationstatus.value = parsedResponse
              .map((json) => CustomerStatusData.fromJson(json))
              .toList();
        } else {
          print("Error: Expected List but got ${parsedResponse.runtimeType}");
        }
      } else if (response is Map<String, dynamic>) {
        List<dynamic> jsonResponse = response['data'] ?? [];
        applicationstatus.value = jsonResponse
            .map((json) => CustomerStatusData.fromJson(json))
            .toList();
      } else {
        print("Error: Unexpected response format ${response.runtimeType}");
      }

      update();
    } catch (e) {
      print("Error fetching DealerName: $e");
    } finally {
      isLoadingsstatusApplication.value = false;
    }
  }
}
