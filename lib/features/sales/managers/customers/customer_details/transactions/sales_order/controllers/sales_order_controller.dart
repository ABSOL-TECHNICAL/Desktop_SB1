import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/model/saleorderslb_model.dart';

import 'package:flutter/material.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class SalesOrderController extends GetxController {
  final RestletService _restletService = RestletService();

  var slbValue = "".obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingslbvalue = false.obs;
  RxBool isLoadingslbname = false.obs;
  RxBool isLoadingslbtownlocation = false.obs;
  RxBool isLoadingslbpartnumber = false.obs;

  final isSlbPartNumberVisible = false.obs;

  RxString salesOrderStatus = ''.obs;
  RxString salesOrderId = ''.obs;
  var selectedSlbName = ''.obs;
  var slbName = ''.obs;
  var slbtownlocation = ''.obs;
  var slbtownid = ''.obs;
  var saleorderslb = <Dataslb>[].obs;
  var globalpack = <PackingQuantity>[].obs;

  var isDropdownOpen = false.obs;
  Map<String, String> itemMappings = {};
  RxBool isLoadingSales = false.obs;

  Future<void> sendCartDataToApi(Map<String, dynamic> requestBody) async {
    try {
      isLoading.value = true;

      print("Sended Data : $requestBody");

      final response = await _restletService.fetchReportData(
          NetSuiteScripts.sendsalesorderscriptId, requestBody);

      if (response != null && response is Map<String, dynamic>) {
        salesOrderStatus.value = response['status'];
        if (salesOrderStatus.value == "Version is mismatch") {
          AppSnackBar.alert(
              message:
                  "You are unable to place the order due to a version mismatch. Please install the latest version.");
          return;
        }

        if (salesOrderStatus.value == "Error") {
          AppSnackBar.alert(message: response['message']);
        } else if (salesOrderStatus.value == "Estimate Created Successfully") {
          salesOrderId.value = response['SalesOrderId'];

          AppSnackBar.success(
              message: "Estimate Created: ${salesOrderId.value}");

          showDialog(
  context: Get.context!,
  barrierDismissible: true, // Allows clicking outside to dismiss
  builder: (BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back or outside tap
        Get.back(); // close dialog
        Get.back(); // go back to previous screen
        return false; // prevent default pop
      },
      child: CustomAlertDialog(
        title: "Estimate Created",
        message: "Estimate Created successfully with ID: ${salesOrderId.value}",
        showOkButton: true,
        onOk: () {
          Get.back(); // close dialog
          Get.back(); // go back to previous screen
        },
      ),
    );
  },
);
        }
      } else {
        AppSnackBar.alert(message: 'Server error! Please try submitting again within 2 minutes.');
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchslb(String supplier, String customer, String itemId) async {
    isLoadingslbname.value = true;
    print("$supplier - $customer - $itemId");

    final requestBody = {
      "supplier": supplier,
      "customer": customer,
      "itemId": itemId
    };

    try {
      final response = await _restletService.fetchReportData(
          NetSuiteScripts.fetchslbscriptId, requestBody);

      print(response);

      if (response is Map<String, dynamic> && response['data'] != null) {
        List<Dataslb> fetchedData = (response['data'] as List)
            .map((item) => Dataslb.fromJson(item))
            .toList();

        saleorderslb.assignAll(fetchedData);
      } else {
        saleorderslb.clear();
        AppSnackBar.alert(
            message: "The Selected Item doesn't have the Available Quantity.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching stock data: $e");
    } finally {
      isLoadingslbname.value = false;
    }
  }

  Future<void> fetchslbvalue(String loc, String customer, String slb) async {
    isLoadingslbvalue.value = true;

    final requestBody = {"slbtown": loc, "Item": customer, "Slb": slb};

    try {
      final response = await _restletService.fetchReportData(
          NetSuiteScripts.fetchslbvaluescriptId, requestBody);

      if (response != null && response is List && response.isNotEmpty) {
        String value = response[0]['SLBValue']?.toString() ?? "";
        if (value.isEmpty) {
          AppSnackBar.alert(
              message: "No SLB value found!"); // Show alert if empty
          slbValue.value = "No Data"; // Update UI to show "No Data"
        } else {
          slbValue.value = value; // Store SLB Value
        }
      } else {
        AppSnackBar.alert(
            message: "No SLB data available!"); // Alert for no data
        slbValue.value = "No Data";
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching SLB value: $e");
    } finally {
      isLoadingslbvalue.value = false;
    }
  }

  Future<void> fetchslbtownlocation(String customerId) async {
    isLoadingslbtownlocation.value = true;

    final requestBody = {"CustomerId": customerId};

    try {
      final response = await _restletService.fetchReportData(
          NetSuiteScripts.fetchslbtownlocationscriptId, requestBody);

      if (response != null && response is List && response.isNotEmpty) {
        String value = response[0]['SlbTownName']?.toString() ?? "";
        String value1 = response[0]['SlbTownId']?.toString() ?? "";
        if (value.isEmpty) {
          AppSnackBar.alert(
              message: "No SLB townlocation found!"); // Show alert if empty
          slbtownlocation.value = "No Data"; // Update UI to show "No Data"
        } else {
          slbtownlocation.value = value; // Store SLB Value
          slbtownid.value = value1;
        }
      } else {
        AppSnackBar.alert(message: "No SLB data available!");
        slbtownlocation.value = "No Data";
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching SLB value: $e");
    } finally {
      isLoadingslbtownlocation.value = false;
    }
  }

  Future<void> fetchslbpartnumbervalue(
      String supplierId, String customerId) async {
    isLoadingslbpartnumber.value = true;

    final requestBody = {"supplier": supplierId, "customer": customerId};

    try {
      final response = await _restletService.fetchReportData(
          NetSuiteScripts.fetchslbPartnumberValuescriptId, requestBody);

      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true) {
        isSlbPartNumberVisible.value = true;
      } else {
        isSlbPartNumberVisible.value = false;
        AppSnackBar.alert(
            message:
                "This customer has not made any purchases from this supplier.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching SLB value: $e");
    } finally {
      isLoadingslbpartnumber.value = false;
    }
  }
  
 Future<void> fetchpacking(String supplier, String itemId) async {
  isLoadingslbname.value = true;
  print("Fetching packing for Supplier: $supplier, Item: $itemId");

  final requestBody = {
    "Supplier": supplier,
    "Item": itemId,
  };

  try {
    final response = await _restletService.fetchReportData(
      NetSuiteScripts.fetchpacking, requestBody,
    );

    print("Response: $response");

    if (response is List) {
      List<PackingQuantity> fetchedData = response
          .map((item) => PackingQuantity.fromJson(item))
          .toList();

      globalpack.assignAll(fetchedData);
    } else {
      globalpack.clear();
      AppSnackBar.alert(
          message: "The selected item doesn't have packing quantity.");
    }
  } catch (e) {
    AppSnackBar.alert(message: "Error fetching packing data: $e");
  } finally {
    isLoadingslbname.value = false;
  }
}

}
