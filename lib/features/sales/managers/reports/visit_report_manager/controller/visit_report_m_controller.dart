import 'package:get/get.dart';

import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report_manager/model/visit_report_m_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';

import 'package:impal_desktop/features/services/url/restlet_api.dart';

class VisitReportMController extends GetxController {
  final RestletService _restletService = RestletService();
  RxList<VisitReportMModel> visitReports = <VisitReportMModel>[].obs;
  final LoginController login = Get.find<LoginController>();
  RxBool isLoading = false.obs;
  RxString noDataMessage = ''.obs;

  // Input variables for the request
  var fromDate = ''.obs;
  var toDate = ''.obs;
  var salesExecutiveId = 0.obs;
  // var salesRepId = 0.obs;
  var recordType = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchVisitReports(String location) async {
    final requestBody = {
      "fromDate": fromDate.value,
      "toDate": toDate.value,
      "salesRepId": salesExecutiveId.value,
      // "salesRepId": salesRepId.value,
      "recordType": recordType.value,
      "Location": location, // Add location here
    };

    try {
      isLoading.value = true;
      var response = await _restletService.fetchReportData(
        NetSuiteScripts
            .visitReportScriptId, // Ensure to replace this with the correct script ID
        requestBody,
      );
      visitReports.clear(); // Clear previous data
      noDataMessage.value = ''; // Reset no data message on a new fetch

      // Process response
      if (response != null && response.isNotEmpty) {
        for (var item in response) {
          visitReports.add(VisitReportMModel.fromJson(item));
        }

        // Check if the report data was successfully populated
        if (visitReports.isEmpty) {
          noDataMessage.value = "No visit reports found.";
          AppSnackBar.alert(
              message: noDataMessage
                  .value); // Show the alert here if there's no data
        }
      } else {
        noDataMessage.value = "No visit reports found.";
        AppSnackBar.alert(
            message: noDataMessage
                .value); // This will also catch when there's an empty response
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "Error fetching visit reports: ${e.toString()}");
      AppSnackBar.alert(message: "No Data Found");
    } finally {
      isLoading.value = false; // Always set loading to false
    }
  }

  Future<void> fetchVisitReportsdefault() async {
    final Map<String, dynamic> requestBody = {};

    try {
      isLoading.value = true;
      var response = await _restletService.fetchReportData(
        NetSuiteScripts
            .visitReportScriptId, // Ensure to replace this with the correct script ID
        requestBody,
      );
      visitReports.clear(); // Clear previous data
      noDataMessage.value = ''; // Reset no data message on a new fetch

      if (response != null && response.isNotEmpty) {
        for (var item in response) {
          visitReports.add(VisitReportMModel.fromJson(item));
        }

        if (visitReports.isEmpty) {
          noDataMessage.value = "No visit reports found.";
          AppSnackBar.alert(message: noDataMessage.value);
        }
      } else {
        noDataMessage.value = "No visit reports found.";
        AppSnackBar.alert(message: noDataMessage.value);
      }
    } catch (e) {
      AppSnackBar.alert(message: "No Data Found");
    } finally {
      isLoading.value = false; // Always set loading to false
    }
  }
}
