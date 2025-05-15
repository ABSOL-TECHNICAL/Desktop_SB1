import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/salesperson/stocks/surplus_stocks/model/surplus_detailed.model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class SurplusStocksControllers extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<Surplustocks> supplierStocks = <Surplustocks>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchSurplusStockDetails(
      String? itemId, String description) async {
    if ((itemId == null || itemId.isEmpty) && description.isEmpty) {
      AppSnackBar.alert(
          message:
              "Please select a valid part number or provide a description.");
      return;
    }

    isLoading.value = true;

    try {
      final requestBody = {
        'ItemId': itemId ?? '',
      };

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.surplusStocksScriptId,
        requestBody,
      );

      if (response != null && response is Map<String, dynamic>) {
        final data = response['SurplusStock'];

        if (data is List && data.isNotEmpty) {
          supplierStocks.value = Surplustocks.listFromJson(data);
        } else {
          supplierStocks.clear();
          AppSnackBar.alert(message: "No surplus stocks found.");
        }
      } else {
        AppSnackBar.alert(message: "Unexpected response format.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "An error occurred: $e");
    } finally {
      if (isLoading.value) {
        isLoading.value = false;
      }
    }
  }
}
