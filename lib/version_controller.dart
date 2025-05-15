import 'package:get/get.dart';

class VersionController extends GetxController {
  var version = '1.0.0'.obs;

  void updateVersion(String newVersion) {
    version.value = newVersion;
  }
}
