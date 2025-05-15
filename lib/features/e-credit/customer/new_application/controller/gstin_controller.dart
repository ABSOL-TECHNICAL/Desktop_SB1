import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class BdoAuthenticate extends GetxController {
  final RestletService _restletService = RestletService();
  final LoginController login = Get.find<LoginController>();

  var gstNumber = "".obs;
  RxBool isLoading = false.obs;
  String? bdoAuthToken;
  String? clientId;
  String? sek;
  String? appSecretKey;
  String? sekplain;

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchBDO();
  }

  void updateGstin(String value) {
    gstNumber.value = value;
    debugPrint("GST Number Updated: $gstNumber");
  }

  bool isGstValidated = false;

  Future<void> getGstinDetails() async {
    isGstValidated = false;

    if (bdoAuthToken == null || bdoAuthToken!.isEmpty) {
      debugPrint('BDO Auth Token is missing.');
      return;
    }
    if (gstNumber.isEmpty) {
      debugPrint('GST Number is empty.');
      return;
    }

    String url =
        'https://einvoiceapi.bdo.in/bdoapi/public/getgstinDetails/${gstNumber.value}';
    HttpOverrides.global = MyHttpOverrides();

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));

      request.headers.set('client_id', clientId ?? '0');
      request.headers.set('bdo_authtoken', bdoAuthToken!);
      request.headers
          .set('gstin', login.employeeModel.gstinNo?.toString() ?? '');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: $responseBody');

      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (jsonResponse['Status'] == '0' && jsonResponse.containsKey("Error")) {
        AppSnackBar.alert(message: jsonResponse["Error"]);
        return;
      }

      if (jsonResponse['Status'] == '1' && jsonResponse.containsKey('Data')) {
        String encryptedData = jsonResponse['Data'];
        ensureKeyLength();

        if (sekplain == null || sekplain!.length != 32) {
          debugPrint("Invalid sekplain length: ${sekplain?.length}");
          return;
        }

        String decryptedData = decryptAES256ECB(encryptedData, sekplain!);
        debugPrint('Decrypted Data: $decryptedData');

        final Map<String, dynamic> decryptedJson = json.decode(decryptedData);

        if (decryptedJson.containsKey("ErrorMsg") &&
            decryptedJson["ErrorMsg"].isNotEmpty) {
          AppSnackBar.alert(
              message: "Please check if the GST number entered is correct.");
        } else if (decryptedJson.containsKey("Gstin")) {
          isGstValidated = true;
          AppSnackBar.success(
              message:
                  "Success! GST number is validated. Kindly fill all other fields.");
        }
      } else {
        debugPrint('Unexpected Response Error: ${jsonResponse['Error']}');
        if (jsonResponse.containsKey("ErrorMsg") &&
            jsonResponse["ErrorMsg"].isNotEmpty) {
          AppSnackBar.alert(
              message: "Please check if the GST number entered is correct.");
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      AppSnackBar.alert(message: 'Something went wrong. Please try again.');
    }
  }

  void ensureKeyLength() {
    if (sekplain == null) {
      debugPrint("Error: sekplain is null");
      return;
    }

    sekplain = sekplain!.padRight(32, '0').substring(0, 32);
    debugPrint("Adjusted sekplain: $sekplain (Length: ${sekplain!.length})");
  }

  Future<void> fetchBDO() async {
    try {
      isLoading.value = true;
      final response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.clientid,
        {},
      );

      if (response == null) {
        AppSnackBar.alert(
            message:
                "Please check your network. If this issue persists, please log out and log in.");
        return;
      }

      List<dynamic> decodedResponse =
          (response is String) ? json.decode(response) : response;

      if (decodedResponse.isNotEmpty &&
          decodedResponse.first is Map<String, dynamic>) {
        final Map<String, dynamic> firstItem = decodedResponse.first;

        bdoAuthToken = firstItem['Authtoken'] as String?;
        clientId = firstItem['ClientId'] as String?;
        sek = firstItem['Sek'] as String?;
        appSecretKey = firstItem['AppSecretkey'] as String?;
        sekplain = firstItem['SekPlain'] as String?;

        if (bdoAuthToken?.isEmpty ?? true) {
          AppSnackBar.alert(message: "Missing required fields in response.");
        } else {
          getGstinDetails();
        }
      } else {
        AppSnackBar.alert(message: "Invalid response structure.");
      }
    } catch (e, stackTrace) {
      AppSnackBar.alert(message: "Error fetching client ID from NetSuite.");
      debugPrint("Error: $e\nStackTrace: $stackTrace");
    } finally {
      isLoading.value = false;
    }
  }

  String decryptAES256ECB(String encryptedData, String sekplain) {
    try {
      final key = encrypt.Key.fromUtf8(sekplain);
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));

      final decrypted = encrypter.decrypt64(encryptedData);
      return decrypted;
    } catch (e) {
      debugPrint('Decryption error: $e');
      return 'Decryption failed';
    }
  }
}
