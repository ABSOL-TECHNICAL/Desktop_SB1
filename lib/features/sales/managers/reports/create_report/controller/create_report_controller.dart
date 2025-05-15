import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class CreateReportController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxBool isLoading = false.obs;
  RxString reportStatus = ''.obs;
  RxInt reportId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> createReport({
    required int customerId,
    required String personMet,
    required String paymentMethod,
    required String nextVisitDate,
    required String reportedOnDate,
    required int purposeOfTheVisit,
    required String remarks,
    String? filename,
    String? filetype,
    String? image,
  }) async {
    final requestBody = {
      'CustomerId': customerId,
      'PersonMet': personMet,
      'PaymentMethod': paymentMethod,
      'NextVisitDate': nextVisitDate,
      'ReportedOnDate': reportedOnDate,
      'Purposeofthevisit': purposeOfTheVisit,
      'Remarks': remarks,
      "fileName": filename,
      "fileType": filetype,
      "encodedData": image
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts
            .createreportscriptId, // You need to replace this with your actual script ID.
        requestBody,
      );

      print(response);

      if (response != null && response is Map<String, dynamic>) {
        final status = response['status'];
        final reportId = response['ReportID'];

        // Handle successful response
        if (status == 'Report Created Successfully') {
          reportStatus.value = status;
          this.reportId.value = reportId;
          AppSnackBar.success(
              message: "Report Created Successfully with Report ID: $reportId");
        } else {
          final reportmessage = response['message'];
          AppSnackBar.alert(message: reportmessage);
        }
      } else {
        AppSnackBar.alert(message: "Unexpected response format.");
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "An error occurred while creating the report.");
    } finally {
      isLoading.value = false;
    }
  }
}
