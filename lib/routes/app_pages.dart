import 'package:impal_desktop/features/sales/managers/customers/customer_details/view/customer_details.dart';
import 'package:impal_desktop/features/sales/managers/reports/reports.dart';
import 'package:impal_desktop/features/sales/managers/sales/salessummary/sales_summary_manager.dart';
import 'package:impal_desktop/features/dashboard/bindings/dashboard_bindings.dart';
import 'package:impal_desktop/features/dashboard/view/dashboard.dart';
import 'package:impal_desktop/features/login/bindings/login_bindings.dart';
import 'package:impal_desktop/features/login/pages/login_page.dart';
import 'package:impal_desktop/features/sales/managers/stocks/stocks.dart';

import 'package:impal_desktop/features/navigation/bottom_navigation.dart';

import 'package:impal_desktop/features/sales/managers/sales/newproduct/newproduct_sales.dart';
import 'app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final List<GetPage> list = [
    GetPage(
      name: AppRoutes.login.toName,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.navigation.toName,
      page: () => const BottomScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard.toName,
      page: () => const HomeScreen(),
      binding: DashboardBindings(),
    ),
    GetPage(
      name: AppRoutes.salessummary.toName,
      page: () => const SalesSummaryManager(),
    ),
    GetPage(
      name: AppRoutes.product.toName,
      page: () => const ProductSalesSummary(),
    ),
    GetPage(
      name: AppRoutes.customer.toName,
      page: () => const CustomerDetails(),
    ),
    GetPage(
      name: AppRoutes.reports.toName,
      page: () => Reports(),
    ),
    GetPage(
      name: AppRoutes.stocks.toName,
      page: () => Stocks(),
    ),
  ];
}
