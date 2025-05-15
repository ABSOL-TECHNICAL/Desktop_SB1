import 'package:get/get.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/services/url/warehouse_url.dart';

class DashboardController extends GetxController {
  final WarehouseRestletService _cyberrestletService =
      WarehouseRestletService();
  final RxBool isLoading = RxBool(false);
  final LoginController login = Get.find<LoginController>();

  RxList<dynamic> billCustomer = <dynamic>[].obs;
  RxList<dynamic> nonbillCustomer = <dynamic>[].obs;
  RxDouble totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _cyberrestletService.init();
  }

  Future<void> fetchData(bool isBilled) async {
    final scriptId = isBilled
        ? NetSuiteScripts.billedScriptId
        : NetSuiteScripts.nonbilledScriptId;
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString()
    };

    try {
      isLoading.value = true;

      final response =
          await _cyberrestletService.fetchReportData(scriptId, requestBody);

      if (response != null && response is List<dynamic>) {
        if (isBilled) {
          billCustomer.value = response;
        } else {
          nonbillCustomer.value = response;
        }

        totalAmount.value = (isBilled ? billCustomer : nonbillCustomer)
            .fold(0.0, (sum, customer) {
          final amount = double.tryParse(customer["Amount"] ?? '0') ?? 0.0;
          return sum + amount;
        });
      } else {
        AppSnackBar.alert(
            message: isBilled
                ? "No billed data found."
                : "No non-billed data found.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "An error occurred while fetching data.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBilled() async => await fetchData(true);
  Future<void> fetchNonBilled() async => await fetchData(false);
}
