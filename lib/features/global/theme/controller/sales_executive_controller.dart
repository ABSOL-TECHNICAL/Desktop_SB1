import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class SalesExecutiveController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<dynamic> salesExecutiveController = <dynamic>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchSalesExecutives() async {
    final requestBody = {
      'Location': login.employeeModel.location!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.salesExecutivesScriptId,
        requestBody,
      );

      print(response);

      if (response != null && response is List<dynamic>) {
        salesExecutiveController.value = response;
      } else {
        AppSnackBar.alert(message: "No sales Executive found.");
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "An error occurred while viewing salesExecutive.");
    } finally {
      isLoading.value = false;
    }
  }
}
