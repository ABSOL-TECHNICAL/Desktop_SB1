import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class SurplusStocksMController extends GetxController {
  
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxList<Map<String, dynamic>> reportData =
      <Map<String, dynamic>>[].obs; // Change to RxList

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchSurplusstockManager();
  }

  Future<void> fetchSurplusstockManager() async {
    final requestBody = {
      'Location': login.employeeModel.location!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.surplusStockManagerScriptId,
        requestBody,
      );

      // Check if response is a List
      if (response != null &&
          response is List<dynamic> &&
          response.isNotEmpty) {
        // Clear previous data and assign new data to reportData
        reportData.clear(); // Clear previous data
        for (var entry in response) {
          reportData.add({
            "Supplier": entry['Supplier']?.toString() ?? "0",
            "Qty": entry['Qty']?.toString() ?? "0",
            "Item": entry['Item']?.toString() ?? "0",
            "NoOfMonth": entry['NoOfMonth']?.toString() ?? "0",
            "Value": entry['Value']?.toString() ?? "0",
            "Aging": entry['Aging']?.toString() ?? "null",
          });
        }
      } else {
        AppSnackBar.alert(message: "No Surplus Stocks data found.");
      }
    } catch (e) {
      print("Error fetching New Product Sales Manager data: $e");
      AppSnackBar.alert(
          message:
              "An error occurred while viewing New Product Sales Manager data.");
    } finally {
      isLoading.value = false;
    }
  }
}
