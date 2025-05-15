import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class NewproductManagerController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxList<Map<String, dynamic>> reportData =
      <Map<String, dynamic>>[].obs; // Change to RxList

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchNewProductManager();
  }

  Future<void> fetchNewProductManager() async {
    final requestBody = {
      'location': login.employeeModel.location!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.newProductSalesManagerScriptId,
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
            "SalesExecutiveName":
                entry['SalesExecutiveName']?.toString() ?? "0",
            "Monthlytarget": entry['Monthlytarget']?.toString() ?? "0",
            "DaySales": entry['DaySales']?.toString() ?? "0",
            "CumulativeSales": entry['CumulativeSales']?.toString() ?? "0",
            "AchSales": entry['AchSales']?.toString() ?? "0",
            "BalanceToDo": entry['BalanceToDo']?.toString() ?? "0",
          });
        }
      } else {
        AppSnackBar.alert(message: "No New Product Sales Manager data found.");
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
