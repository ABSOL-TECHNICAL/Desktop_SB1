import 'package:get/get.dart';
import 'package:impal_desktop/features/dashboard/controllers/dashboard_controller.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() async {
    Get.put<DashboardController>(DashboardController());
  }
}
