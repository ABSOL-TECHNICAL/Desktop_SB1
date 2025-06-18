

import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/all_branch_stocks/model/all_branch_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class AllBranchStocksController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxList<StateDetail> states = <StateDetail>[].obs;
  RxList<StockDetail> stocks = <StockDetail>[].obs;
  RxList<Map<String, dynamic>> displayedItems = <Map<String, dynamic>>[].obs;

  RxBool isLoadingStates = false.obs;
  RxBool isLoadingStocks = false.obs;
  RxBool isLoading = false.obs;
// Add this variable to your state class
RxBool selectAllStates = false.obs;


  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchStates(String zoneName) async {
    isLoadingStates.value = true;
    try {
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.zonesScriptId,
        {'ZoneName': zoneName},
      );

      if (response != null) {
        if (response is Map) {
          AppSnackBar.alert(message: response['message'] ?? "No states found.");
        } else if (response.isNotEmpty) {
          states.assignAll(StateDetail.listFromJson(response));
        } else {
          AppSnackBar.alert(message: "No states found.");
        }
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching states: ${e.toString()}");
    } finally {
      isLoadingStates.value = false;
    }
  }

Future<List<StockDetail>> fetchStockDetails(String itemId, String? stateId) async {
  isLoadingStocks.value = true;
  try {
    // Create mutable map for the request body
    final Map<String, dynamic> requestBody = {
      "ItemId": itemId,
    };
    
    if (selectAllStates.value) {
      // Create actual array of state IDs
      final stateIds = states
          .map((state) => state.stateId)
          .where((id) => id.isNotEmpty)
          .toList();
      
      // Assign directly as array
      requestBody["AllState"] = stateIds;
    } else if (stateId != null) {
      requestBody["StateId"] = stateId;
    } else {
      requestBody["StateId"] = "";
    }

  

    final response = await _restletService.fetchReportData(
      NetSuiteScripts.allbranchStocksScriptId,
      requestBody,
    );

    if (response != null) {
      if (response is Map) {
        AppSnackBar.alert(
            message: response['message'] ??
                "No stock available for the provided criteria.");
        return [];
      } else if (response.isNotEmpty) {
        final fetchedStocks = StockDetail.listFromJson(response);
        stocks.assignAll(fetchedStocks);
        return fetchedStocks;
      } else {
        AppSnackBar.alert(message: "No stock details found.");
        return [];
      }
    } else {
      AppSnackBar.alert(message: "Error: No response from the server.");
      return [];
    }
  } catch (e) {
    AppSnackBar.alert(
        message: "Error fetching stock details: ${e.toString()}");
    return [];
  } finally {
    isLoadingStocks.value = false;
  }
}
}