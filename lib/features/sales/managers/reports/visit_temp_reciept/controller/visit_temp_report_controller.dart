import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/reports/visit_temp_reciept/model/visit_temp_report_model.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class VisitTempController extends GetxController {
  final RestletService _restletService = RestletService();
  RxList<VisitTempModel> visitTemp = <VisitTempModel>[].obs;
  RxBool isLoading = false.obs;
  RxString noDataMessage = ''.obs;
  final RxInt modeOfCollection = 2.obs;
  final RxList<int> recordTypeList = <int>[].obs;

  Future<void> fetchVisitTempReport() async {
    final requestBody = {
      "ModeOfCollection": modeOfCollection.value == 0
          ? recordTypeList.join(',')
          : modeOfCollection.value.toString(),
    };

    try {
      isLoading.value = true;
      var response = await _restletService.fetchReportData(
        NetSuiteScripts
            .visitTempscriptId, // Ensure to replace this with the correct script ID
        requestBody,
      );
      visitTemp.clear(); // Clear previous data
      noDataMessage.value = ''; // Reset no data message on a new fetch

      if (response != null && response.isNotEmpty) {
        for (var item in response) {
          visitTemp.add(VisitTempModel.fromJson(item));
        }

        if (visitTemp.isEmpty) {
          noDataMessage.value = "No visit reports found.";
          AppSnackBar.alert(message: noDataMessage.value);
        }
      } else {
        noDataMessage.value = "No visit reports found.";
        AppSnackBar.alert(message: noDataMessage.value);
      }
    } catch (e) {
      AppSnackBar.alert(message: "No Data Found");
    } finally {}
    isLoading.value = false; // Always set loading to false
  }
}
