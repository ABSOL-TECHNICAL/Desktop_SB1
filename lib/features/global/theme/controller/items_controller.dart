import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class GlobalItemsController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController loginController = Get.find<LoginController>();

  RxList<GlobalitemDetail> globalItems = <GlobalitemDetail>[].obs;
  RxList<GlobalitemDetails> globalItemStocks = <GlobalitemDetails>[].obs;
  Map<String, String> itemMappings = {};
  RxBool isLoading = false.obs;
  RxBool isLoadingStocks = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchGlobalItems(
      String itemName, String desc, String supplierId) async {
    final requestBody = {
      "ItemName": itemName,
      "Desc": desc,
      "Supplier": supplierId, // Pass supplier ID here
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.globalitemScriptId,
        requestBody,
      );

      if (response is List<dynamic> && response.isNotEmpty) {
        globalItems.value = GlobalitemDetail.listFromJson(response);

        itemMappings.clear();
        for (var item in globalItems) {
          itemMappings[item.itemName ?? ''] = item.itemId ?? '';
        }

        if (globalItems.isEmpty) {
          AppSnackBar.alert(message: "No Items found.");
        }
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching global items: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectPartNumber(String partNoId) async {
    final locationId = loginController.employeeModel.location;

    if (locationId?.isEmpty ?? true) {
      AppSnackBar.alert(
        message: "Location ID is missing. Please check your login details.",
      );
      return;
    }

    final requestBody = {
      "ItemId": partNoId,
      "LocationId": locationId,
    };

    try {
      isLoadingStocks.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.availablestocksunitpricescriptId,
        requestBody,
      );

      if (response is List<dynamic> && response.isNotEmpty) {
        globalItemStocks.value = response.map((item) {
          return GlobalitemDetails(
            itemName: item['ItemName'] as String?,
            unitPrice: double.tryParse(item['UnitPrice']?.toString() ?? '0'),
            availableQuantity:
                int.tryParse(item['AvailableQuantity']?.toString() ?? '0'),
          );
        }).toList();

        itemMappings.clear(); // Reset item mappings
        for (var item in globalItemStocks) {
          itemMappings[item.itemName ?? ''] = item.itemId ?? '';
        }

        if (globalItemStocks.isEmpty) {
          AppSnackBar.alert(message: "No stock data found.");
        }
      } else {
        globalItemStocks.clear();
        AppSnackBar.alert(
            message: "The Selected Item doesn't have the Available Quantity");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching stock data: $e");
    } finally {
      isLoadingStocks.value = false;
    }
  }
}
