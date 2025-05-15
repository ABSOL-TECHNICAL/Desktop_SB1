import 'package:get/get.dart';

import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/collection/model/collection_details_model.dart';

import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class CollectiondetailsManagerController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxBool isLoading = false.obs;
  RxList<CollectionDetailsManager> collectionDetails =
      RxList<CollectionDetailsManager>();

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchCollectionDetialsManagerData();
  }

  Future<void> fetchCollectionDetialsManagerData() async {
    final Map<String, dynamic> requestBody = {
      'location': login.employeeModel.location!.toString(),
    };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.collectiondetailsmanagerScriptId,
        requestBody,
      );

      print(response);

      if (response != null && response is List) {
        collectionDetails.value = response
            .map((item) => CollectionDetailsManager.fromJson(
                Map<String, dynamic>.from(item)))
            .toList();
      } else {
        AppSnackBar.alert(message: "No Collection Summary found.");
      }
    } catch (e) {
      print("Error fetching Collection Summary: $e");
      AppSnackBar.alert(
          message: "An error occurred while viewing Collection Summary.");
    } finally {
      isLoading.value = false;
    }
  }
}
