import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/view_billed_details/model/view_billed_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class ViewBilledDetailsController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<ViewBilledDetail> viewBilledDetails = <ViewBilledDetail>[].obs;
  final GlobalcustomerController globalCustomerController =
      Get.put(GlobalcustomerController());
  RxBool isLoading = false.obs;
  RxBool isLoadings = false.obs;
  var fromDate = ''.obs;
  var toDate = ''.obs;
  String? selectedCustomerID;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchViewBilledDetailsDefault();
  }

  String? fromDates;
  String? toDates;

  Future<void> fetchViewBilledDetailsDefault() async {
    final now = DateTime.now();
    fromDates ??=
        DateFormat('dd/MM/yyyy').format(now.subtract(Duration(days: 30)));
    toDates ??= DateFormat('dd/MM/yyyy').format(now);

    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
      'fromdate': fromDates,
      'todate': toDates,
    };

    try {
      isLoadings.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.viewBilledDetailsScriptId,
        requestBody,
      );

      if (response != null && response.isNotEmpty) {
        var data = response;
        if (data['DefaultBillDetails'] != null &&
            data['DefaultBillDetails'] is List) {
          var details = (data['DefaultBillDetails'] as List)
              .map((item) => ViewBilledDetail.fromJson(item))
              .toList();
          viewBilledDetails.value = details;
        } else {
          AppSnackBar.alert(message: "No billed details found.");
        }
      } else {
        AppSnackBar.alert(message: "No data returned from the server.");
      }
    } catch (e) {
      print("Error occurred: $e");
      AppSnackBar.alert(
          message: "An error occurred while fetching billed details.");
    } finally {
      isLoadings.value = false;
    }
  }

  Future<void> fetchViewBilledSearchDetails(
      String fromDate, String toDate) async {
    print('Fetching billed details for Customer ID: $selectedCustomerID');
    final requestBody = {
      'fromdate': fromDate,
      'todate': toDate,
      'CustomerId': selectedCustomerID,
    };

    try {
      viewBilledDetails.clear();
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.viewBilledDetailsScriptId,
        requestBody,
      );

      if (response != null && response.isNotEmpty) {
        print("Response received: $response");

        if (response['ViewBillDetails'] != null) {
          var details = (response['ViewBillDetails'] as List)
              .map((i) => ViewBilledDetail.fromJson(i))
              .toList();
          viewBilledDetails.value = details;
          print("viewBilledDetails updated: ${details.length} items");
        } else {
          AppSnackBar.alert(message: "No billed details found.");
        }
      } else {
        viewBilledDetails.value = [];
        AppSnackBar.alert(message: "Failed to load billed details.");
      }
    } catch (e, stackTrace) {
      print("Error fetching billed details: $e");
      print("StackTrace: $stackTrace");
      AppSnackBar.alert(
          message: "An error occurred while fetching billed details.");
    } finally {
      isLoading.value = false;
    }
  }
}
