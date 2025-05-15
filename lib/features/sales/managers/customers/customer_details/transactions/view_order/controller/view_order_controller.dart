import 'package:get/get.dart';

import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/view_order/model/view_order_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class ViewOrderController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<dynamic> customerdetails = <dynamic>[].obs;
  RxList<ViewOrderDetails> viewOrder = <ViewOrderDetails>[].obs;
  RxBool isLoading = false.obs;
  RxString alertMessage = ''.obs;
  RxString noDataMessage = ''.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var fromDate = ''.obs;
  var toDate = ''.obs;
  RxMap<String, dynamic> selectedCustomer = RxMap<String, dynamic>();

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchViewOrderDefault({
    required String customerId,
  }) async {
    final DateTime currentDate = DateTime.now();
    DateTime fromDate = currentDate.subtract(Duration(days: 3));

    String formattedFromDate =
        "${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}";
    String formattedToDate =
        "${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}";

    startDate.value = formattedFromDate;
    endDate.value = formattedToDate;

    final requestBody = {
      "CustomerId": customerId,
      "fromdate": formattedFromDate,
      "todate": formattedToDate,
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.vieworderDetailsScriptId,
        requestBody,
      );

      if (response == null) throw Exception("No response received.");

      if (response is Map && response['defaultInvoiceDetails'] is List) {
        viewOrder.value = List<ViewOrderDetails>.from(
          response['defaultInvoiceDetails']
              .map((view) => ViewOrderDetails.fromJson(view)),
        );
      } else {
        throw FormatException("Unexpected response format.");
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "No results found for the past 3 days data for view order.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchViewOrderSearch({
    required String fromDate,
    required String toDate,
    required String customerId,
  }) async {
    this.fromDate.value = fromDate;
    this.toDate.value = toDate;

    final requestBody = {
      "startdate": fromDate,
      "enddate": toDate,
      "CustomerId": customerId,
    };

    try {
      isLoading.value = true;
      noDataMessage.value = '';
      viewOrder.clear();

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.vieworderDetailsScriptId,
        requestBody,
      );

      if (response == null) throw Exception("No response received.");

      if (response is Map && response['viewInvoiceDetails'] is List) {
        viewOrder.value = List<ViewOrderDetails>.from(
          response['viewInvoiceDetails']
              .map((view) => ViewOrderDetails.fromJson(view)),
        );
        noDataMessage.value = '';
      } else {
        if (response['message'] ==
                "No sales orders found for the given criteria." &&
            (response['data'] as List).isEmpty) {
          noDataMessage.value = "No Data Found.";
        } else {
          throw FormatException("Unexpected response format.");
        }
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error loading data: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
