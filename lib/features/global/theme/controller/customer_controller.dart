import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class GlobalcustomerController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<dynamic> globalcustomerController = <dynamic>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchCustomer() async {
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString()
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.customerScriptId,
        requestBody,
      );

      if (response != null && response is List<dynamic>) {
        globalcustomerController.value = response;
      } else {
        AppSnackBar.alert(message: "No customer found.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "An error occurred while viewing customer.");
    } finally {
      isLoading.value = false;
    }
  }
}
