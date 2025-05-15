import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class NewProductSalesController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxMap<String, dynamic> salesreportData = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchNewsales();
  }

  Future<void> fetchNewsales() async {
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
      'Location': login.employeeModel.location!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.newProductSalesReportScriptId,
        requestBody,
      );

      if (response != null &&
          response is List<dynamic> &&
          response.isNotEmpty) {
        salesreportData.value = {
          "Monthlytarget": _getValidValue(response[0]['Monthlytarget']),
          "DaySales": _getValidValue(response[0]['DaySales']),
          "CumulativeSales": _getValidValue(response[0]['CumulativeSales']),
          "AchSales": _getValidValue(response[0]['AchSales']),
          "BalanceToDo": _getValidValue(response[0]['BalanceToDo']),
        };
      } else {
        // If the response is null or empty, ensure we set default values
        salesreportData.value = {
          "Monthlytarget": "0.0",
          "DaySales": "0.0",
          "CumulativeSales": "0.0",
          "AchSales": "0.0",
          "BalanceToDo": "0.0",
        };
      }
    } catch (e) {
      print("Error fetching New Product Sales data: $e");
      AppSnackBar.alert(
          message: "An error occurred while viewing New Product Sales data.");
    } finally {
      isLoading.value = false; // Set loading to false
    }
  }

  String _getValidValue(dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return "0.0";
    }
    return value.toString();
  }
}
