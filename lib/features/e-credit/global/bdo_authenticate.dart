// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
// import 'package:impal_desktop/features/login/controllers/login_controller.dart';
// import 'package:impal_desktop/features/services/ecredit_end_point.dart';
// import 'package:impal_desktop/features/services/restlet_api.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// class BdoAuthenticate extends GetxController {
//   final RestletService _restletService = RestletService();
//   final LoginController login = Get.find<LoginController>();

//   RxBool isLoading = true.obs;
//   String? bdoAuthToken;
//   String? clientId;
//   String? sek;
//   String? appSecretKey;
//   String? sekplain;
//   String? encryptedData;

//   @override
//   void onInit() {
//     super.onInit();
//     _restletService.init();
//     fetchBDO();
//   }

//   void ensureKeyLength() {
//     if (sekplain == null) {
//       print("Error: sekplain is null");
//       return;
//     }

//     if (sekplain!.length < 32) {
//       sekplain = sekplain!.padRight(32, '0');
//     } else if (sekplain!.length > 32) {
//       sekplain = sekplain!.substring(0, 32);
//     }

//     print("Adjusted sekplain: $sekplain (Length: ${sekplain!.length})");
//   }

//   Future<void> fetchBDO() async {
//     final Map<String, String> requestBody = {};

//     try {
//       isLoading.value = true;

//       final dynamic response = await _restletService.getRequest(
//         NetSuiteScriptsEcredit.clientid,
//         requestBody,
//       );

//       if (response == null) {
//         AppSnackBar.alert(message: "No client ID found.");
//         return;
//       }

//       List<dynamic> decodedResponse;
//       if (response is String) {
//         decodedResponse = json.decode(response);
//       } else if (response is List) {
//         decodedResponse = response;
//       } else {
//         AppSnackBar.alert(message: "Invalid response format.");
//         return;
//       }

//       if (decodedResponse.isNotEmpty &&
//           decodedResponse.first is Map<String, dynamic>) {
//         final Map<String, dynamic> firstItem = decodedResponse.first;

//         bdoAuthToken = firstItem['Authtoken'] as String?;
//         clientId = firstItem['ClientId'] as String?;
//         sek = firstItem['Sek'] as String?;
//         appSecretKey = firstItem['AppSecretkey'] as String?;
//         sekplain = firstItem['SekPlain'] as String?;

//         if (bdoAuthToken == null ||
//             bdoAuthToken!.isEmpty ||
//             clientId == null ||
//             clientId!.isEmpty) {
//           AppSnackBar.alert(message: "Missing required fields in response.");
//         } else {
//           getGstinDetails();
//         }
//       } else {
//         AppSnackBar.alert(message: "Invalid response structure.");
//       }
//     } catch (e, stackTrace) {
//       AppSnackBar.alert(message: "Error fetching client ID.");
//       debugPrint("Error: $e\nStackTrace: $stackTrace");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> getGstinDetails() async {
//     if (bdoAuthToken == null || bdoAuthToken!.isEmpty) {
//       print('BDO Auth Token is missing.');
//       return;
//     }

//     const String url =
//         'https://einvoiceapi.bdo.in/bdoapi/public/getgstinDetails/16AAACI0931P1ZI';
//     final client = HttpClient()
//       ..badCertificateCallback = (cert, host, port) => true;

//     try {
//       final request = await client.getUrl(Uri.parse(url));
//       request.headers.add('client_id', clientId ?? '0');
//       request.headers.add('bdo_authtoken', bdoAuthToken!);
//       request.headers.add(
//         'gstin',
//         login.employeeModel.gstinNo!.toString(),
//       );

//       print('Request Headers:');
//       request.headers.forEach((name, values) {
//         print('$name: ${values.join(", ")}');
//       });

//       final response = await request.close();
//       final responseBody = await response.transform(utf8.decoder).join();

//       print('Status: ${response.statusCode}');
//       print('Response: $responseBody');

//       final Map<String, dynamic> jsonResponse = json.decode(responseBody);

//       if (jsonResponse['Status'] == '1' && jsonResponse.containsKey('Data')) {
//         String encryptedData = jsonResponse['Data'];

//         ensureKeyLength();

//         if (sekplain == null || sekplain!.length != 32) {
//           print("Invalid sekplain: ${sekplain?.length} bytes");
//           return;
//         }

//         String decryptedData = decryptAES256ECB(encryptedData, sekplain!);
//         print('Decrypted Data: $decryptedData');
//       } else {
//         print('Error: ${jsonResponse['Error']}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     } finally {
//       client.close();
//     }
//   }

//   String decryptAES256ECB(String encryptedData, String sekplain) {
//     final key = encrypt.Key.fromUtf8(sekplain);
//     final encrypter = encrypt.Encrypter(
//       encrypt.AES(key, mode: encrypt.AESMode.ecb),
//     );

//     try {
//       final decrypted = encrypter.decrypt64(encryptedData);
//       return decrypted;
//     } catch (e) {
//       print('Decryption error: $e');
//       return 'Decryption failed';
//     }
//   }
// }
