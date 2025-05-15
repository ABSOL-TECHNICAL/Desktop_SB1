enum AppRoutes {
  root,
  login,
  navigation,
  home,
  dashboard,
  map,
  settings,
  stocks,

  product,
  salessummary,
  customer,
  reports,
}

extension AppRouteExtension on AppRoutes {
  static const appRoutes = {
    AppRoutes.root: "/",
    AppRoutes.login: "/login",
    AppRoutes.navigation: "/BottomScreen",
    AppRoutes.home: "/home",
    AppRoutes.dashboard: "/dashboard",
    AppRoutes.map: "/map",
    AppRoutes.settings: "/settings",
    AppRoutes.stocks: "/Stocks",
    AppRoutes.product: "/product_summary",
    AppRoutes.salessummary: "/sales_summary",
    AppRoutes.customer: "/Customer",
    AppRoutes.reports: "/Reports",
  };
  String get toName => appRoutes[this]!;
}
