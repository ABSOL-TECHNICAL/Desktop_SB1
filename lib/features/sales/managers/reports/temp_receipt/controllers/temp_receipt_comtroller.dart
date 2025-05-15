// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class TempReceiptController extends GetxController {
  final RestletService _restletService = RestletService();

  RxBool isLoading = false.obs;
  RxString transferStatus = ''.obs;
  RxInt transferOrderId = 0.obs;
  String FileName = '';
  String FileType = '';
  String encodedData = '';

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
  }

  String getFileExtension(String filePath) {
    return filePath.split('.').last.toUpperCase();
  }

  Future<void> handleFileSelection(BuildContext context) async {
    try {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final String fileName = "${DateTime.now().millisecondsSinceEpoch}";
        final String fileType = getFileExtension(image.path);

        final String base64Image = base64Encode(bytes);

        print("File Type : $fileType");
        print("File Name: $fileName");
        print("Base64 encoded image: $base64Image");
        FileName = fileName;
        FileType = fileType;
        encodedData = base64Image;

        if (fileName.isNotEmpty && fileType.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File selected but not yet submitted!"),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("One or more required fields are empty."),
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        print("Image selection canceled");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error during file selection or upload: $e"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> handleDocumentSelection(BuildContext context) async {
    try {
      // Pick an image from the gallery
      XFile? document =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (document != null) {
        // Get the file extension
        String fileType = getFileExtension(document.path);
        print(fileType);
        // Check if the file is JPEG or PNG
        if (fileType == 'jpeg' ||
            fileType == 'JPEG' ||
            fileType == 'PNG' ||
            fileType == 'png' ||
            fileType == 'jpg' ||
            fileType == 'JPG') {
          final bytes = await document.readAsBytes();
          final String fileName = "${DateTime.now().millisecondsSinceEpoch}";
          final String base64Document = base64Encode(bytes);

          FileName = fileName;
          FileType = fileType;
          encodedData = base64Document;

          print("File Type : $fileType");
          print("File Name: $fileName");
          print("Base64 encoded image: $base64Document");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Document selected but not yet submitted!"),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          print("Image Not Uploaded");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Only JPEG and PNG formats are allowed."),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        print("Document selection canceled");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error during document selection or upload: $e"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> createTransferOrder({
    required int customerId,
    required int modeofCollection,
    required String amount,
    required String invoiceNo,
    required String remarks,
    String? checkno,
    String? checkdate,
    String? filename,
    String? filetype,
    String? image,
  }) async {
    final requestBody = {
      'CustomerId': customerId,
      'ModeOfCollection': modeofCollection,
      'Amount': amount,
      'InvoiceNo': invoiceNo,
      'Remarks': remarks,
      'checkno': checkno,
      'checkdate': checkdate,
      "fileName": filename,
      "fileType": filetype,
      "encodedData": image
    };

    // final requestBody = {
    //   'CustomerId': customerId,
    //   'ModeOfCollection': modeofCollection,
    //   'Amount': amount,
    //   'InvoiceNo': invoiceNo,
    //   'Remarks': remarks,
    // };

    try {
      isLoading.value = true;

      final response = await _restletService.fetchReportData(
        NetSuiteScripts
            .tempreceiptscriptId, // You need to replace this with your actual script ID.
        requestBody,
      );

      print(response);

      if (response != null) {
        final status = response['status'];
        final transferOrderId = response['TransferOrderId'];

        // Handle successful response
        if (status == 'Transfer Order Created Successfully') {
          transferStatus.value = status;
          this.transferOrderId.value = transferOrderId;
          AppSnackBar.success(
              message:
                  "Transfer Order Created Successfully with TransferStatus ID: $transferOrderId");
        } else {
          AppSnackBar.alert(message: "Failed to create the Transfer Order.");
        }
      } else {
        AppSnackBar.alert(message: "Unexpected response format.");
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "An error occurred while creating the report.");
    } finally {
      isLoading.value = false;
    }
  }
}
