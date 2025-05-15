import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class CollectionsummaryController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxMap<String, String> reportData = <String, String>{}.obs;
  RxBool isLoading = false.obs;
  RxInt totalAmount = 0.obs; // To store the total amount

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchCollectionsummaryData();
  }

  Future<void> fetchCollectionsummaryData() async {
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.collectionsummaryScriptId,
        requestBody,
      );

      print(response);

      if (response != null && response is Map<String, dynamic>) {
        reportData.value = {
          "TotalOutstanding": response['TotalOutstanding']?.toString() ?? "0",
          "TotalOutstandingabove90days":
              response['TotalOutstandingabove90days']?.toString() ?? "0",
          "Totalout91to180day":
              response['Totalout91to180day']?.toString() ?? "0",
          "Totalout180daysabove":
              response['Totalout180daysabove']?.toString() ?? "0",
          "DayCollection": response['DayCollection']?.toString() ?? "0",
          "DayCollectionabove90days":
              response['DayCollectionabove90days']?.toString() ?? "0",
          "Daycollection91to180day":
              response['Daycollection91to180day']?.toString() ?? "0",
          "Daycollection180daysabove":
              response['Daycollection180daysabove']?.toString() ?? "0",
          "CumulativeSales": response['CumulativeSales']?.toString() ?? "0",
          "CumulativeSalesabove90days":
              response['CumulativeSalesabove90days']?.toString() ?? "0",
          "CumulativeSales91to180days":
              response['CumulativeSales91to180days']?.toString() ?? "0",
          "CumulativeSales180daysabove":
              response['CumulativeSales180daysabove']?.toString() ?? "0",
          "Achcollection": response['Achcollection']?.toString() ?? "0",
          "Achcollectionsabove90days":
              response['Achcollectionsabove90days']?.toString() ?? "0",
          "Achcollection91to180day":
              response['Achcollection91to180day']?.toString() ?? "0",
          "Achcollection180daysabove":
              response['Achcollection180daysabove']?.toString() ?? "0",
        };
      } else {
        AppSnackBar.alert(message: "No Collection Summary found.");
      }
    } catch (e) {
      print("Error fetching Collection Summary: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
