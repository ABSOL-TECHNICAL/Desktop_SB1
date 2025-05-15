import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_report/model/visit_report_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class VisitReportController extends GetxController {
  final RestletService _restletService = RestletService();
  RxList<VisitReportModel> visitReports = <VisitReportModel>[].obs;
  RxBool isLoading = false.obs;
  RxString noDataMessage = ''.obs;
  final RxInt recordType = 2.obs;
  final RxList<int> recordTypeList = <int>[].obs;

  var fromDate = ''.obs;
  var toDate = ''.obs;
  var salesRepId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchVisitReportsdefault() async {
    final Map<String, dynamic> requestBody = {};

    try {
      isLoading.value = true;
      var response = await _restletService.fetchReportData(
        NetSuiteScripts.visitReportScriptId,
        requestBody,
      );
      visitReports.clear(); // Clear previous data
      noDataMessage.value = ''; // Reset no data message on a new fetch

      if (response != null && response.isNotEmpty) {
        for (var item in response) {
          visitReports.add(VisitReportModel.fromJson(item));
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
      isLoading.value = false;
    }
  }

  Future<void> fetchVisitReports() async {
    final requestBody = {
      "fromDate": fromDate.value,
      "toDate": toDate.value,
      "salesRepId": salesRepId.value,
      "recordType": recordType.value == 0
          ? recordTypeList.join(',')
          : recordType.value.toString(),
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

      if (response != null && response.isNotEmpty) {
        for (var item in response) {
          visitReports.add(VisitReportModel.fromJson(item));
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
    } finally {}
    isLoading.value = false;
  }
}
