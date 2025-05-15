import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class TargetVsActualController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxMap<String, String> reportData = <String, String>{}.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchTargetVsActualData() async {
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.targetVsActualScriptId,
        requestBody,
      );

      if (response != null && response is Map<String, dynamic>) {
        reportData.value = {
          "Target": _getValidValue(response['Target']),
          "DaySales": _getValidValue(response['DaySales']),
          "CumulativeSales": _getValidValue(response['CumulativeSales']),
          "AchSales": _getValidValue(response['AchSales']),
          "BillToDo": _getValidValue(response['BillToDo']),
        };
      } else {
        AppSnackBar.alert(message: "No target vs actual data found.");
      }
    } catch (e) {
      print("Error fetching target vs actual data: $e");
      AppSnackBar.alert(
          message: "An error occurred while viewing target vs actual data.");
    } finally {
      isLoading.value = false;
    }
  }

  String _getValidValue(dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return "0.0";
    }
    return value.toString();
  }
}
