import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/inward/model/material_inward_model.dart';
import 'package:impal_desktop/features/sales/managers/stocks/surplus_stocks_manager/model/surplus_stocks_manager_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class MaterialInwardController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());

  RxList<SupplierDetail> supplierDetails = <SupplierDetail>[].obs;
  RxList<Map<String, dynamic>> supplier = <Map<String, dynamic>>[].obs;
  RxList<MaterialInwardDefault> defaultMaterialInward =
      <MaterialInwardDefault>[].obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var fromDate=''.obs;
  var toDate = ''.obs;
  RxBool isLoading = false.obs;
  RxString alertMessage = ''.obs;
  RxString noDataMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    alertMessage.value = '';
  }

 Future<void> fetchMaterialInwardDefault() async {
  final DateTime currentDate = DateTime.now();
  final DateTime fromDate = DateTime(currentDate.year, currentDate.month, 1); // First day of month

  String formattedFromDate =
      "${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}";
  String formattedToDate =
      "${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}";

  startDate.value = formattedFromDate;
  endDate.value = formattedToDate;

  final requestBody = {
    "fromdate": formattedFromDate,
    "todate": formattedToDate
  };

  try {
    isLoading.value = true;
    alertMessage.value = '';
    noDataMessage.value = '';

    final response = await _restletService.fetchReportData(
      NetSuiteScripts.materialInwardScriptId,
      requestBody,
    );

    if (response == null) throw Exception("No response received.");

    if (response['error'] != null) {
      noDataMessage.value = response['error'];
    } else if (response is Map && response['DefaultMaterialInward'] is List) {
      List<MaterialInwardDefault> data = List<MaterialInwardDefault>.from(
        response['DefaultMaterialInward'].map(
          (material) => MaterialInwardDefault.fromJson(material ?? {}),
        ),
      );

      if (data.isEmpty) {
        noDataMessage.value = "No results found for the provided criteria.";
      } else {
        defaultMaterialInward.value = data;
      }
    } else {
      throw FormatException("Unexpected response format.");
    }
  } catch (e) {
    alertMessage.value =
        "Error loading data: ${e is FormatException ? e.message : e.toString()}";
  } finally {
    isLoading.value = false;
  }
}

   Future<void> fetchMaterialInwardDetails(
    String supplierId,
    String fromDate,
    String toDate,
    RxList<MaterialInwardDefault> searchedMaterialInward,
  ) async {
   if (supplierId.isEmpty) {
    AppSnackBar.alert(message: "Please provide supplier.");
    return;
  }
final materialInwardController = Get.find<MaterialInwardController>();
materialInwardController.fromDate.value = fromDate;
materialInwardController.toDate.value = toDate;

    

    final requestBody = {
      'SupplierId':supplierId,
      'FromDate': fromDate,
      'ToDate': toDate,
    };

    try {
      isLoading.value = true;
      alertMessage.value = '';

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.materialInwardScriptId,
        requestBody,
      );

      if (response != null && response is Map) {
        final materialInwardList = response['MaterialInward'];

        print("Material Inward List: $materialInwardList");

        if (materialInwardList is List && materialInwardList.isNotEmpty) {
        searchedMaterialInward.value = materialInwardList
            .map((item) => MaterialInwardDefault.fromJson(item))
            .toList();
        noDataMessage.value = '';
      } 
         else {
          noDataMessage.value = "No results found for the provided criteria.";
        }
      } else {
        noDataMessage.value = "Invalid response format.";
      }
    } catch (e) {
      noDataMessage.value =
          "An error occurred while fetching Material Inward details.";
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}


//   Future<void> fetchMaterialInwardDetails(
//     String partNumber,
//     String chooseDate,
//     RxList<MaterialInwardDefault> searchedMaterialInward,
//   ) async {
//     if (partNumber.isEmpty || chooseDate.isEmpty) {
//       noDataMessage.value = '';

//       AppSnackBar.alert(message: "Please provide both part number and date.");

//       return;
//     }

//     toDate.value = chooseDate;

//     final requestBody = {
//       'ItemId': partNumber,
//       'ToDate': chooseDate,
//     };

//     try {
//       isLoading.value = true;
//       alertMessage.value = '';

//       final response = await _restletService.fetchReportData(
//         NetSuiteScripts.materialInwardScriptId,
//         requestBody,
//       );

//       if (response != null && response is Map) {
//         final materialInwardList = response['MaterialInward'];

//         print("Material Inward List: $materialInwardList");

//         if (materialInwardList is List && materialInwardList.isNotEmpty) {
//           searchedMaterialInward.value = materialInwardList.map((item) {
//             final materialInward = MaterialInwardDefault.fromJson(item);
//             print("Parsed Material Inward: $materialInward");
//             return materialInward;
//           }).toList();

//           noDataMessage.value = '';
//         } else {
//           noDataMessage.value = "No results found for the provided criteria.";
//         }
//       } else {
//         noDataMessage.value = "Invalid response format.";
//       }
//     } catch (e) {
//       noDataMessage.value =
//           "An error occurred while fetching Material Inward details.";
//       print("Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
