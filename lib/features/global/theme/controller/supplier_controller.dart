import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/model/supplier_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class GlobalsupplierController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  final RxList<Supplier> supplier = <Supplier>[].obs;
  RxList<dynamic> globalsupplierController = <dynamic>[].obs;
  RxBool isLoading = false.obs;

  RxString selectedSupplierId = ''.obs;
  RxString selectedSupplierName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchSupplier() async {
    final Map<String, dynamic> requestBody = {};

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.supplierScriptId,
        requestBody,
      );

      if (response != null &&
          response is List<dynamic> &&
          response.isNotEmpty) {
        supplier.value = response
            .map((item) => Supplier(
                  supplier: item['Supplier'],
                  supplierId: item['SupplierId'],
                ))
            .toList();
      } else {
        AppSnackBar.alert(message: "No supplier found.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "An error occurred while viewing supplier.");
    } finally {
      isLoading.value = false;
    }
  }
}
