import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/new_customer/model/new_customers_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class NewCustomerController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxList<CustomerData> customerData = <CustomerData>[].obs;
  RxBool isLoading = false.obs;

  RxInt customerCount = 0.obs; // For monthly count
  RxInt currentYearCustomerCount = 0.obs; // For yearly count

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchNewCustomerDetails(); // Assuming you want to load this on init
  }

  Future<void> fetchNewCustomerDetails() async {
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.newCustomerScriptId,
        requestBody,
      );

      if (response is Map<String, dynamic>) {
        customerData.value = [
          CustomerData(
            customerMonth: response['Customer_Month'] is List
                ? (response['Customer_Month'] as List)
                    .map((item) => Customer.fromJson(item))
                    .toList()
                : [],
            customerYear: response['Customer_Year'] is List
                ? (response['Customer_Year'] as List)
                    .map((item) => Customer.fromJson(item))
                    .toList()
                : [],
          ),
        ];

        customerCount.value = customerData[0].customerMonth?.length ?? 0;
        currentYearCustomerCount.value =
            customerData[0].customerYear?.length ?? 0;
      } else {
        AppSnackBar.alert(message: "Invalid response format.");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customer details: $e');
      }
      AppSnackBar.alert(message: "Failed to fetch customer data.");
    } finally {
      isLoading.value = false;
    }
  }
}
