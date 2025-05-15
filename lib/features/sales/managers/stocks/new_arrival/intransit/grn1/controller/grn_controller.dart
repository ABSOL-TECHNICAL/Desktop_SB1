import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';

import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/grn1/model/grn_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class Grn1Controller extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<Grn1Model> grnDetails = <Grn1Model>[].obs;
  var supplier = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var toDate = ''.obs;
  RxList<Map<String, dynamic>> displayedItems = <Map<String, dynamic>>[].obs;
  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  Future<void> fetchGrn1(String partNumber) async {
    final requestBody = {"ItemId": partNumber};

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.grn1ScriptId,
        requestBody,
      );

      if (response != null && response['GRN1'] != null) {
        grnDetails.value = Grn1Model.listFromJson(response['GRN1']);
      } else {
        AppSnackBar.alert(message: "No GRN details found.");
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "An error occurred while fetching GRN details.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGrnDefault() async {
    final DateTime currentDate = DateTime.now();

    String formattedCurrentDate =
        "${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}";

    startDate.value = formattedCurrentDate;
    endDate.value = formattedCurrentDate;

    final requestBody = {
      "FromDate": formattedCurrentDate,
      "ToDate": formattedCurrentDate,
    };

    try {
      isLoading.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.grn1ScriptId,
        requestBody,
      );

      if (response == null) {
        throw Exception("No response received.");
      }

      if (response.containsKey('DefaultGRN1') &&
          response['DefaultGRN1'] is List) {
        List<dynamic> defaultGrnList = response['DefaultGRN1'];

        if (defaultGrnList.isNotEmpty) {
          grnDetails.value = defaultGrnList.map((grn) {
            return Grn1Model.fromJson(grn ?? {});
          }).toList();
        } else {
          throw Exception("No GRN1 data found for today.");
        }
      } else {
        throw FormatException("Unexpected response format.");
      }
    } catch (e) {
      AppSnackBar.alert(
        message: "No GRN1 Data found for today",
        title: 'Notification',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
