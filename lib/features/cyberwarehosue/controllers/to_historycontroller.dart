import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/cyber_end_point.dart';
import 'package:impal_desktop/features/services/url/warehouse_url.dart';
import 'package:intl/intl.dart';

class ToHistoryController extends GetxController {
  final WarehouseRestletService _cyberrestletService =
      WarehouseRestletService();
  final LoginController login = Get.find<LoginController>();

  RxBool isLoading = true.obs;
  RxList<Map<String, dynamic>> transferOrders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _cyberrestletService.init();
    fetchTransferHistory();
  }

  Future<void> fetchTransferHistory() async {
    // ignore: non_constant_identifier_names
    final Id = login.employeeModel.location?.toString();
    if (Id == null || Id.isEmpty) {
      AppSnackBar.alert(message: "Location ID is missing.");
      return;
    }

    final requestBody = {'Id': login.employeeModel.salesRepId!.toString()};

    try {
      isLoading.value = true;

      final response = await _cyberrestletService.fetchReportData(
        CyberEndPoint.transferOrderStatusScriptId,
        requestBody,
      );

      if (response != null && response.isNotEmpty) {
        transferOrders.value = List<Map<String, dynamic>>.from(response);
        for (var order in transferOrders) {
          var items = order['items'] as List<dynamic>;
          for (var item in items) {
            String dateString = item['date']; // Parse and format date
            DateTime date = DateFormat('dd/MM/yyyy').parse(dateString);
            item['date'] = DateFormat('yyyy-MM-dd').format(date);
          }
        }
      } else {
        AppSnackBar.alert(message: "No transfer order data found.");
        transferOrders.clear();
      }
    } catch (e) {
      AppSnackBar.alert(message: "No Tranfer order created today");
    } finally {
      isLoading.value = false;
    }
  }
}
