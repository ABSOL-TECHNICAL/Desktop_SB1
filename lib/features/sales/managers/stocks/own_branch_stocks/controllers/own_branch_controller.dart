import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/own_branch_stocks/model/own_branch_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class OwnBranchController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController loginController = Get.find<LoginController>();

  RxList<Ownbranch> ownDetails = <Ownbranch>[].obs;
  RxList<GlobalitemDetail> globalItems = <GlobalitemDetail>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchOwnBranchDetails(
      String itemId, String supplierId, String branchId) async {
    print(
        "Fetching details with Item ID: $itemId, Supplier ID: $supplierId, Location: ${loginController.location}");

    final requestBody = {
      "ItemId": itemId,
      "BranchId": loginController.location,
      "SupplierId": supplierId,
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.ownbranchStocksScriptId,
        requestBody,
      );

      if (response != null) {
        if (response is List) {
          ownDetails.value = Ownbranch.listFromJson(response);
          print(
              "Fetched Own Branch Details: ${ownDetails.map((o) => o.location)}");
        } else if (response is Map<String, dynamic> &&
            response.containsKey("message")) {
          // Handle case where no stock is found
          AppSnackBar.alert(message: response["message"]);
        } else {
          _handleInvalidResponseType(response);
        }
      } else {
        AppSnackBar.alert(message: "Received null response.");
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(dynamic error) {
    print("An error occurred while fetching details: $error");
    AppSnackBar.alert(message: "An error occurred while fetching details.");
  }

  void _handleInvalidResponseType(dynamic response) {
    print("Expected a List for response, but got: ${response.runtimeType}");
    AppSnackBar.alert(
      message:
          "Unexpected response type: ${response.runtimeType}. Expected a List.",
    );
  }
}
