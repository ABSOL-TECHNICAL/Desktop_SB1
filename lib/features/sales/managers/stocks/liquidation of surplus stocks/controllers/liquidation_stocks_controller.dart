import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class LiquidationStocksController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxMap<String, String> reportData = <String, String>{}.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    liquidationofSurplusStocksData();
  }

  Future<void> liquidationofSurplusStocksData() async {
    final requestBody = {
      'Location': login.employeeModel.location!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.liquidationofstocksScriptId,
        requestBody,
      );

      if (response != null && response is Map<String, dynamic>) {
        reportData.value = {
          "Target": _getValidValue(response['Target']),
          "DaySales": _getValidValue(response['DaySales']),
          "CumulativeSales": _getValidValue(response['CumulativeSales']),
          "BalanceToDo": _getValidValue(response['BalanceToDo']),
        };
      } else {
        AppSnackBar.alert(message: "Liquidation of Surplus stocks data found.");
      }
    } catch (e) {
      print("Error fetching Liquidation of Surplus stocks data: $e");
      AppSnackBar.alert(
          message:
              "An error occurred while viewing Liquidation of Surplus stocks data.");
    } finally {
      isLoading.value = false;
    }
  }

  String _getValidValue(dynamic value) {
    // Check if value is null, empty, or whitespace
    if (value == null || (value is String && value.trim().isEmpty)) {
      return "0.0";
    }
    return value.toString();
  }
}
