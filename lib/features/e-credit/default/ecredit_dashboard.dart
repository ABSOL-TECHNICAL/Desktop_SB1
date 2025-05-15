import 'package:impal_desktop/features/dashboard/controllers/dashboard_controller.dart';
import 'package:impal_desktop/features/e-credit/default/pages/status_count.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/header.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:impal_desktop/features/sales/managers/stocks/liquidation%20of%20surplus%20stocks/controllers/liquidation_stocks_controller.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/new_customer/controller/new_customers_controller.dart';

import 'package:impal_desktop/features/sales/salesperson/customers/target_vs_actual_sales_report/controllers/target_vs_actual_controller.dart';

class ECreditDashboardScreen extends StatefulWidget {
  const ECreditDashboardScreen({super.key});
  static String routeName = "/ecredit_dashboard";

  @override
  State<ECreditDashboardScreen> createState() => _ECreditDashboardScreenState();
}

class _ECreditDashboardScreenState extends State<ECreditDashboardScreen> {
  final DashboardController dashboardController =
      Get.put(DashboardController());
  final TargetVsActualController target = Get.put(TargetVsActualController());

  final LiquidationStocksController liquidsurplusstock =
      Get.put(LiquidationStocksController());
  final LoginController loginController = Get.find<LoginController>();

  final NewCustomerController newCustomerController =
      Get.put(NewCustomerController());

  bool get isManager => loginController.employeeModel.isManager ?? false;

  @override
  void initState() {
    super.initState();
    target.fetchTargetVsActualData();
    liquidsurplusstock.liquidationofSurplusStocksData();
  }

  Future<void> _loadData() async {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employeeModel = loginController.employeeModel;
    String username = employeeModel.employeeName ?? 'Username';

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitConfirmationDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: GlobalAppBar(title: 'Dashboard'),
        body: Obx(() {
          if (dashboardController.isLoading.value) {
            return Center(
              child: SpinKitCircle(
                color: theme.primaryColor,
                size: 50.0,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $username',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ECreditCustomerCount(),
                    ],
                  )),
            ),
          );
        }),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Logout Confirmation',
          message: 'Are you sure you want to log out?',
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
        );
      },
    );
  }
}
