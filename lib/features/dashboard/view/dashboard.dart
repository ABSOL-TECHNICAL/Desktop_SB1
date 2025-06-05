import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:impal_desktop/features/dashboard/controllers/dashboard_controller.dart';
import 'package:impal_desktop/features/dashboard/view/customer_count.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/header.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/liquidation%20of%20surplus%20stocks/controllers/liquidation_stocks_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/liquidation%20of%20surplus%20stocks/liquidation_surplus_stocks.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/new_customer/controller/new_customers_controller.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/new_product_sales_report/new_product_report.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/target_vs_actual_sales_report/controllers/target_vs_actual_controller.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/target_vs_actual_sales_report/target_vs_actual.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static String routeName = "/dashboard";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    _checkAndShowWelcomePopup();
  }

  void _checkAndShowWelcomePopup() async {
    final prefs = await SharedPreferences.getInstance();
    bool shouldShowPopup = prefs.getBool('show_welcome_popup') ?? false;

    if (shouldShowPopup) {
      await prefs.setBool('show_welcome_popup', false); // Clear the flag
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPopup();
      });
    }
  }

  void _showPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "What's New version Change 1.0.3",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 10),
              Text("•Sales Man:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              Padding(
                padding: EdgeInsets.only(left: 16.0, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Merged Temp Receipt and Create Report into a single Report Page.",
                        style: TextStyle(color: Colors.black)),
                    Text("• Introduced a Date Filter on the Branch Transfer Page",
                        style: TextStyle(color: Colors.black)),
                    Text("• Own Branch Stocks now include List Price, and GST Percentage",
                        style: TextStyle(color: Colors.black)), 
                    Text("• Implemented Expansion Tile Layout on the View Order Page",
                        style: TextStyle(color: Colors.black)),
                        Text("•Implemented Vehicle Application Filter.",
                        style: TextStyle(color: Colors.black)),
                           Text("•Implemented a New page directly create estimate from Own Branch Stocks .",
                        style: TextStyle(color: Colors.black)),
                         

                  ],
                ),
              ),
               Text("•Estimate Page:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              Padding(
                padding: EdgeInsets.only(left: 16.0, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("•Added Package Quantity field on the Estimate Page",
                        style: TextStyle(color: Colors.black)),
                    Text("• Replaced 'Distress Sales' with 'Advance Sales'",
                        style: TextStyle(color: Colors.black)),
                   
                  ],
                ),
              ),
            
              Text("• E-Credit Enhancements:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              Padding(
                padding: EdgeInsets.only(left: 16.0, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("•Enabled Page Up/Down navigation on the Dealer Approval Page",
                        style: TextStyle(color: Colors.black)),
                    Text("•Merged KYC and Commercial Matters into the Dealer Approval workflow",
                        style: TextStyle(color: Colors.black)),
                    Text("•Command some field across New Customer Page",
                        style: TextStyle(color: Colors.black)),
                    Text("•Page Refresh Button",
                        style: TextStyle(color: Colors.black)),
                        Text("•Mandatory fields are now highlighted if left empty",
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
             
             
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black), // Border color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              backgroundColor: Colors.white, // Optional background
            ),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employeeModel = loginController.employeeModel;

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
                      'Hello, ${employeeModel.fullName}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    NewProductReport(),
                    const SizedBox(height: 15),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: CustomerStatsPieChart(
                                monthlyCount:
                                    newCustomerController.customerCount.value,
                                yearlyCount: newCustomerController
                                    .currentYearCustomerCount.value,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: TargetVsActualPie()),
                          ],
                        )),
                    LiquidationSurplusStocks(),
                  ],
                ),
              ),
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
