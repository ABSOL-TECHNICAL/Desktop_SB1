import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class CustomerDetailsController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxList<dynamic> customerdetails = <dynamic>[].obs;
  RxList<dynamic> outstandingDetails = <dynamic>[].obs;
  RxList<dynamic> vieworderDetails = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxMap<String, dynamic> selectedCustomer = RxMap<String, dynamic>();

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchCustomerdetails();
    fetchOutstandingDetails();
  }

  Future<void> fetchOutstandingDetails() async {
    final requestBody = {
      'CustomerId': selectedCustomer['CustomerId'],
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.outstandingDetailsScriptId,
        requestBody,
      );
      // if (kDebugMode) {
      //   print('Outstanding details response: $response');
      // }

      if (response != null) {
        if (response is Map<String, dynamic>) {
          outstandingDetails.value = [response];
        } else if (response is List<dynamic>) {
          outstandingDetails.value = response;
        }

        if (outstandingDetails.isEmpty) {
          AppSnackBar.alert(message: "No outstanding data found.");
        }
      } else {
        AppSnackBar.alert(message: "No outstanding data found.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching outstanding data: $e");
      }
      AppSnackBar.alert(
          message: "An error occurred while fetching outstanding data.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOutstandingDetailsCustomer(String customerId) async {
    final requestBody = {
      'CustomerId': customerId,
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.outstandingDetailsScriptId,
        requestBody,
      );

      if (response != null) {
        if (response is Map<String, dynamic>) {
          outstandingDetails.value = [response];
        } else if (response is List<dynamic>) {
          outstandingDetails.value = response;
        }

        if (outstandingDetails.isEmpty) {
          AppSnackBar.alert(message: "No outstanding data found.");
        }
      } else {
        AppSnackBar.alert(message: "No outstanding data found.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching outstanding data: $e");
      }
      AppSnackBar.alert(
          message: "An error occurred while fetching outstanding data.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVieworderDetails(
      {required String fromDate, required String toDate}) async {
    final requestBody = {
      'CustomerId': selectedCustomer['CustomerId'],
      "fromdate": fromDate,
      "todate": toDate,
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.vieworderDetailsScriptId,
        requestBody,
      );

      if (kDebugMode) {
        print('Vieworder details response: $response');
      }

      if (response != null) {
        if (response is Map<String, dynamic>) {
          vieworderDetails.value = [response];
        } else if (response is List<dynamic>) {
          vieworderDetails.value = response;
        }

        if (vieworderDetails.isEmpty) {
          AppSnackBar.alert(message: "No Vieworder data found.");
        }
      } else {
        AppSnackBar.alert(message: "No Vieworder data found.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching Vieworder data: $e");
      }
      AppSnackBar.alert(
          message: "An error occurred while fetching Vieworder data.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerdetails() async {

    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
      'branchId' :  login.employeeModel.branchid!.toString(),
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.customerDetailsScriptId,
        requestBody,
      );

      if (response != null && response['CustomerDetails'] != null) {
        // Extract customer details from response
        customerdetails.value = response['CustomerDetails'];

        for (var customer in customerdetails) {
          selectedCustomer.value = {
            'CustomerId': customer["CustomerId"],
            'Customer': customer["Customer"],
            'Phone': customer["Phone"],
            'Address':
                customer["Address"], // Ensure correct case for "Address" key
          };
        }
      } else {
        AppSnackBar.alert(message: "No customer data found.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching customer data: $e");
      }
      AppSnackBar.alert(
          message: "An error occurred while fetching customer data.");
    } finally {
      isLoading.value = false;
    }
  }
}
