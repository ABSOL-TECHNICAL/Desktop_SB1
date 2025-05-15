import 'dart:convert';

import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/planningindent_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/send_planning_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/cyber_end_point.dart';
import 'package:impal_desktop/features/services/url/warehouse_url.dart';

class PlanningIndentController extends GetxController {
  final WarehouseRestletService _cyberrestletService =
      WarehouseRestletService();
  final LoginController login = Get.find<LoginController>();

  final RxList<PlanningindentModel> indents = <PlanningindentModel>[].obs;
  RxBool isLoading = false.obs;
  RxString selectedLocationId = ''.obs;
  RxString selectedSupplierId = ''.obs;
  RxList<String> productGroups = <String>[].obs;
  RxList<String> divisions = <String>[].obs;
  final RxBool isNoResults = false.obs;

  void clearData() {
    selectedLocationId.value = '';
  }

  void setSelectedSupplierId(String supplierId) {
    selectedSupplierId.value = supplierId;
    print("Updated Supplier ID in Controller: $supplierId");
  }

  Future<bool> beforeSubmitPlanning({
    required SentPlanningIndentModel planningindent,
  }) async {
    try {
      isLoading.value = true;

      final requestBody = {
        "supplierId": planningindent.supplier ?? 0,
        "locationId": int.tryParse(login.employeeModel.location ?? "0") ?? 0,
        "supplierProGro": planningindent.supplierprogro ?? ' ',
        "supplierDivis": planningindent.supplierprodiv ?? ' ',
        "fms": planningindent.fms ?? 0,
      };

      final response = await _cyberrestletService.postRequest(
        CyberEndPoint.beforeSubmitPlanning,
        requestBody,
      );

      if (response is Map<String, dynamic> &&
          response["Success"] == "Success") {
        return true;
      }

      if (response is List && response.isNotEmpty) {
        final errorList = response.map((errorData) {
          return "- Name: ${errorData["Name"]}\n"
              "- Indent Ref: ${errorData["IndentRef"]}\n"
              "- Planning Run Date: ${errorData["PlanningRunDate"]}\n"
              "- User: ${errorData["User"]}";
        }).join("\n\n");

        AppSnackBar.alert(
          message: "Invalid: The data is already placed.\n\n$errorList",
        );
        return false;
      }

      AppSnackBar.alert(
        message:
            "Invalid: The data is already placed.\n\n${response.toString()}",
      );

      return false;
    } catch (e) {
      AppSnackBar.alert(message: "An error occurred: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void showErrorSnackbar(String response) {
    try {
      final decoded = jsonDecode(response);

      if (decoded is Map<String, dynamic> && decoded.containsKey('error')) {
        final errorList = decoded['error'] as List<dynamic>;
        String formattedMessage = "Invalid data, already placed:\n\n";

        for (var error in errorList) {
          error.forEach((key, value) {
            formattedMessage += "• $key: $value\n";
          });
          formattedMessage += "\n";
        }

        AppSnackBar.alert(message: formattedMessage.trim());
      } else {
        AppSnackBar.alert(message: "Unexpected error format.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error parsing response.");
    }
  }

  Future<bool> sendPlanningIndent({
    required SentPlanningIndentModel planningindent,
  }) async {
    try {
      isLoading.value = true;

      List<Map<String, dynamic>> filteredItems = planningindent.items
              ?.where((item) => (item.orderQty ?? 0) > 0)
              .map((item) {
            return {
              "slno": item.slNo ?? 0,
              "itemId": item.itemId ?? 0,
              "availableQty": item.availableQty ?? 0,
              "onHandQty": item.onHandQty ?? 0,
              "moq": item.moq ?? 0,
              "onOrderQty": item.onOrderQty ?? 0,
              "avgSaleQtyPerMonth": item.avgSaleQtyPerMonth ?? 0,
              "proAvgsalesqty": item.proAvgSalesQty ?? 0,
              "orderQty": item.orderQty ?? 0,
              "suggestedQty": item.suggestedQty ?? 0,
            };
          }).toList() ??
          [];

      if (filteredItems.isEmpty) {
        AppSnackBar.alert(message: "No valid items to send.");
        return false;
      }

      Map<String, dynamic> requestBody = {
        "Supplier": planningindent.supplier ?? 0,
        "Location": login.employeeModel.location!.toString(),
        "SupplierProGro": planningindent.supplierprogro ?? '',
        "SupplierProDiv": planningindent.supplierprodiv ?? '',
        "Fms": planningindent.fms ?? 0,
        "User": login.employeeModel.salesRepId!.toString(),
        "item": {"items": filteredItems},
      };

      final response = await _cyberrestletService.postRequest(
        CyberEndPoint.sentPlannindent,
        requestBody,
      );

      if (response != null &&
          response['status']
              .toString()
              .toLowerCase()
              .contains('planning created successfully')) {
        String planningId = response.keys.firstWhere(
            (key) => key.trim() == "PlanningId",
            orElse: () => "PlanningId");

        AppSnackBar.success(
          message:
              "Planning indent created successfully. Planning Order ID: ${response[planningId]}",
        );

        return true;
      } else {
        String errorMessage = response?['message'] ??
            "Failed to create Planning indent. Please try again.";
        AppSnackBar.alert(
          message: errorMessage,
        );
        return false;
      }
    } catch (e) {
      print("Error occurred: $e");

      AppSnackBar.alert(
        message: "An error occurred. Please try again later.",
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductgroup(String supplierId) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final requestBody = {
        'Supplier': supplierId,
      };

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.productGroupScriptId,
        requestBody,
      );

      if (result != null && result.isNotEmpty) {
        productGroups.value = result
            .map<String>(
                (e) => "${e['SupplierProdId']} - ${e['SupplierProdName']}")
            .toList();
        print("Fetched Product Group Data: $productGroups");
      } else {
        AppSnackBar.alert(
            message: "No data found for WorkSheet Planning Indent");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching Product data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDivision(String supplierId) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final requestBody = {
        'supplierid': supplierId,
      };

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.divisionScriptId,
        requestBody,
      );

      if (result != null && result.isNotEmpty) {
        divisions.value = result
            .map<String>((e) => "${e['Divisionname']} - ${e['DivisionId']}")
            .toList();
        print("Fetched Division Data: $divisions");
      } else {
        AppSnackBar.alert(
            message: "No data found for WorkSheet Planning Indent");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching Division data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitIndent({
    required String supplierId,
    required int fmsId,
    required String productGroupId,
    required divisionId,
  }) async {
    try {
      final requestBody = {
        "Supplier": supplierId,
        'Location': login.employeeModel.location!.toString(),
        "Fms": fmsId,
        "SuppDiv": divisionId,
        "SupProGro": productGroupId,
      };

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.getplanningindentScriptId,
        requestBody,
      );

      if (result is List && result.isNotEmpty) {
        indents.value =
            result.map((e) => PlanningindentModel.fromJson(e)).toList();
        isNoResults.value = false;
        AppSnackBar.success(
            message: "Planning indent data loaded successfully");
      } else {
        indents.clear();
        isNoResults.value = true;
        AppSnackBar.alert(
          message:
              "No planning indent items available for the searched criteria.",
        );
      }
    } catch (e) {
      indents.clear();
      isNoResults.value = true;
      AppSnackBar.alert(message: "Error submitting indent: $e");
    }
  }
}
