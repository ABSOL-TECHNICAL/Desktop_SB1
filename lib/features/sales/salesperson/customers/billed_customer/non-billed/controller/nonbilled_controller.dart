// import 'package:get/get.dart';
// import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
// import 'package:impal_desktop/features/login/controllers/login_controller.dart';
// import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
// import 'package:impal_desktop/features/services/url/restlet_api.dart';

// class NonbilledController extends GetxController {
//   final RestletService _restletService = RestletService();
//   final LoginController login = Get.find<LoginController>();
//   RxList<dynamic> nonbilledCustomer = <dynamic>[].obs;
//   RxBool isLoading = false.obs;
//   RxDouble totalAmount = 0.0.obs; // To store the total amount

//   @override
//   void onInit() {
//     super.onInit();
//     _restletService.init();
//     fetchNonBilled();
//   }


//  Future<void> fetchNonBilled({String? fromDate, String? toDate}) async {
//     final requestBody = {
//       'salesRepId': login.employeeModel.salesRepId!.toString(),
//        'FromDate': fromDate?? "",
//        'ToDate': toDate?? "",
//     };


//     try {
//       isLoading.value = true;

//       final response = await _restletService.fetchReportData(
//         NetSuiteScripts.nonbilledScriptId,
//         requestBody,
//       );

//       print(response);

//       if (response != null && response is List<dynamic>) {
//         nonbilledCustomer.value = response;
//         // Calculate the total billed amount
//         totalAmount.value = nonbilledCustomer.fold(0.0, (sum, customer) {
//           final amount = double.tryParse(customer["Amount"] ?? '0') ?? 0.0;
//           return sum + amount;
//         });
//       } else {
//         AppSnackBar.alert(message: "No Non-billed data found.");
//       }
//     } catch (e) {
//       print("Error fetching billed data: $e");
//       AppSnackBar.alert(
//           message: "An error occurred while viewing billed data.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

//   // Future<void> fetchNonBilled() async {
//   //   final requestBody = {
//   //     'salesRepId': login.employeeModel.salesRepId!.toString()
//   //   };

//   //   try {
//   //     isLoading.value = true;

//   //     final response = await _restletService.fetchReportData(
//   //       NetSuiteScripts.nonbilledScriptId,
//   //       requestBody,
//   //     );

//   //     print(response);

//   //     if (response != null && response is List<dynamic>) {
//   //       nonbilledCustomer.value = response;
//   //       // Calculate the total billed amount
//   //       totalAmount.value = nonbilledCustomer.fold(0.0, (sum, customer) {
//   //         final amount = double.tryParse(customer["Amount"] ?? '0') ?? 0.0;
//   //         return sum + amount;
//   //       });
//   //     } else {
//   //       AppSnackBar.alert(message: "No  Non-billed data found.");
//   //     }
//   //   } catch (e) {
//   //     print("Error fetching billed data: $e");
//   //     AppSnackBar.alert(
//   //         message: "An error occurred while viewing billed data.");
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }



import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class NonbilledController extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();
  RxList<dynamic> nonbilledCustomer = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxDouble totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchNonBilled(); // Initial load with empty dates
  }

  Future<void> fetchNonBilled({String? fromDate, String? toDate}) async {
    final requestBody = {
      'salesRepId': login.employeeModel.salesRepId!.toString(),
      'FromDate': fromDate ?? "", // Send empty string if null
      'ToDate': toDate ?? "",    // Send empty string if null
    };

    try {
      isLoading.value = true;
      nonbilledCustomer.clear(); // Clear previous data

      final response = await _restletService.fetchReportData(
        NetSuiteScripts.nonbilledScriptId,
        requestBody,
      );

      if (response != null && response is List<dynamic>) {
        nonbilledCustomer.value = response;
        totalAmount.value = nonbilledCustomer.fold(0.0, (sum, customer) {
          final amount = double.tryParse(customer["Amount"] ?? '0') ?? 0.0;
          return sum + amount;
        });
      } else {
        AppSnackBar.alert(message: "No Non-billed data found.");
      }
    } catch (e) {
      print("Error fetching non-billed data: $e");
      AppSnackBar.alert(
          message: "An error occurred while viewing non-billed data.");
    } finally {
      isLoading.value = false;
    }
  }
}