import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';

import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/branch_transfers/model/branch_transfers_model.dart';
import 'package:impal_desktop/features/sales/managers/stocks/surplus_stocks_manager/model/surplus_stocks_manager_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class BranchTransfersController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  RxList<DefaulBranchstock> defaultBranchStocks = <DefaulBranchstock>[].obs;
  RxList<DefaulBranchstock> searchedBranch = <DefaulBranchstock>[].obs;
  RxList<SupplierDetail> supplierDetails = <SupplierDetail>[].obs;
  RxList<FromLocation> locations = <FromLocation>[].obs;
  RxBool isLoading = false.obs;
  var branchTransferErrorMessage = ''.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var fromDate = ''.obs;
  var toDate = ''.obs;
  var lRDate = ''.obs;
  var isFiltered = false.obs;

  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchLocations() async {
    try {
      final result = await _restletService.getRequest(
        NetSuiteScripts.locationsScriptId,
        {},
      );

      if (result is List) {
        locations.assignAll(result.map((data) => FromLocation.fromJson(data)));
      } else {
        AppSnackBar.alert(
          message: "No locations found or invalid response format.",
        );
      }
    } catch (error) {
      AppSnackBar.alert(message: "Error fetching locations: $error");
    }
  }

  Future<void> fetchBranchStockDefault() async {
    final DateTime currentDate = DateTime.now();
    // final DateTime fromDate = currentDate.subtract(Duration(days: 3));
    final DateTime fromDate = DateTime(currentDate.year, currentDate.month, 1);
    String formattedFromDate =
        "${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}";
    String formattedToDate =
        "${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}";

    startDate.value = formattedFromDate;
    endDate.value = formattedToDate;

    final requestBody = {
      "FromDate": formattedFromDate,
      "ToDate": formattedToDate,
      "BranchId": login.employeeModel.branchid!,
    };

    try {
      isLoading.value = true;
      branchTransferErrorMessage.value = '';

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.defaultBranchStocksId,
        requestBody,
      );

      if (response != null &&
          response is Map &&
          response['DefaulstockInTran'] is List) {
        defaultBranchStocks.value = List<DefaulBranchstock>.from(
          response['DefaulstockInTran']
                  ?.map((item) => DefaulBranchstock.fromJson(item ?? {})) ??
              [],
        );
      } else {
        branchTransferErrorMessage.value = "No data found in Entry Stock.";
        AppSnackBar.alert(message: "No data found in Entry Stock.");
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "Error loading default branch stock: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBranchTransferDetails(
    // String partNumber,
    RxList<DefaulBranchstock> searchedBranch, {
    required String supplierId,
    required String fromDate,
    required String toDate,
  }) async {
    // Input validation
    // if (partNumber.isEmpty) {
    //   AppSnackBar.alert(message: "Please enter the Item Number.");
    //   return;
    // }
    if (supplierId.isEmpty) {
      AppSnackBar.alert(message: "Please select a Supplier.");
      return;
    }
    if (fromDate.isEmpty) {
      AppSnackBar.alert(message: "Please select a From Date.");
      return;
    }
    if (toDate.isEmpty) {
      AppSnackBar.alert(message: "Please select a To Date.");
      return;
    }

    final requestBody = {
      // 'ItemId': partNumber,
      'Supplier': supplierId,
      'FromDate': fromDate,
      'ToDate': toDate,
      'BranchId': login.employeeModel.branchid!,
    };

    try {
      isLoading.value = true;
      branchTransferErrorMessage.value = '';

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.defaultBranchStocksId,
        requestBody,
      );

      if (response != null &&
          response is Map &&
          response['stockInTran'] is List) {
        searchedBranch.value = List<DefaulBranchstock>.from(
          response['stockInTran']
              .map((item) => DefaulBranchstock.fromJson(item ?? {})),
        );
      } else {
        branchTransferErrorMessage.value = "No data found in Entry Stock.";
        AppSnackBar.alert(message: "No Branch data found in Entry Stock.");
      }
    } catch (e) {
      branchTransferErrorMessage.value = "Error fetching branch transfers: $e";
      AppSnackBar.alert(
        message: "An error occurred while fetching branch transfers.",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
