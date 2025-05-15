import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class AppSnackBar {
  String title;
  String message;
  double titleFontSize;

  AppSnackBar(
      {required this.title, required this.message, this.titleFontSize = 16.0});

  AppSnackBar.alert({
    required this.message,
    this.title = "Alert",
    this.titleFontSize = 16.0,
    Icon? icon,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFFF44336),
      margin: const EdgeInsets.all(10.0),
      forwardAnimationCurve: Curves.easeOutBack,
      snackStyle: SnackStyle.FLOATING,
      colorText: Colors.white,
      maxWidth: 700,
      titleText: Row(
        children: [
          icon ?? const Icon(Icons.warning, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 5),
    );
  }

  AppSnackBar.success({
    required this.message,
    this.title = "Success",
    this.titleFontSize = 16.0,
    Icon? icon,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color.fromARGB(255, 71, 182, 75),
      margin: const EdgeInsets.all(10.0),
      forwardAnimationCurve: Curves.easeOutBack,
      snackStyle: SnackStyle.FLOATING,
      colorText: Colors.white,
      maxWidth: 700,
      titleText: Row(
        children: [
          icon ?? const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 5),
    );
  }

  AppSnackBar.failed({
    required this.message,
    this.title = "Failed",
    this.titleFontSize = 16.0,
    Icon? icon,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color.fromRGBO(255, 0, 0, 1.0),
      margin: const EdgeInsets.all(10.0),
      forwardAnimationCurve: Curves.easeOutBack,
      snackStyle: SnackStyle.FLOATING,
      colorText: Colors.white,
      maxWidth: 700,
      titleText: Row(
        children: [
          icon ?? const Icon(Icons.cancel, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    );
  }

  AppSnackBar.warning({
    required this.message,
    this.title = "Warning",
    this.titleFontSize = 16.0,
    Icon? icon,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orangeAccent,
      margin: const EdgeInsets.all(10.0),
      forwardAnimationCurve: Curves.easeOutBack,
      snackStyle: SnackStyle.FLOATING,
      colorText: Colors.white,
      maxWidth: 700,
      titleText: Row(
        children: [
          icon ?? const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    );
  }
}

Widget loadingWidget() => const Center(
      child: SpinKitFadingCircle(
        color: Color.fromARGB(255, 251, 252, 253),
        size: 30.0,
      ),
    );
