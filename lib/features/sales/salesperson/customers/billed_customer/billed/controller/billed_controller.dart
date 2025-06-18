import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class BilledController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<dynamic> billedCustomer = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxDouble totalAmount = 0.0.obs; // To store the total amount

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchBilled();
  }

  Future<void> fetchBilled({String? fromDate, String? toDate}) async {
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
      'FromDate': fromDate ?? "", // Send empty string if null
      'ToDate': toDate ?? "",    // Send empty string if null
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.billedScriptId,
        requestBody,
      );

      if (response != null && response is List<dynamic>) {
        billedCustomer.value = response;

        // Calculate the total billed amount
        totalAmount.value = billedCustomer.fold(0.0, (sum, customer) {
          // final amount = double.tryParse(customer["Amount"] ?? '0') ?? 0.0;
          final amountValue = customer["Amount"];
final amount = amountValue is double
    ? amountValue
    : double.tryParse(amountValue?.toString() ?? '0') ?? 0.0;
          return sum + amount;
        });
      } else {
        AppSnackBar.alert(message: "No billed data found.");
      }
    } catch (e) {
      print("Error fetching billed data: $e");
      AppSnackBar.alert(
          message: "An error occurred while viewing billed data.");
    } finally {
      isLoading.value = false;
    }
  }
}
