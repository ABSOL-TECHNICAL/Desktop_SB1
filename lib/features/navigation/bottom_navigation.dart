import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/dashboard/view/default.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:impal_desktop/features/cyberwarehosue/stock_home.dart';
import 'package:impal_desktop/features/e-credit/admin/approval/approval.dart';
import 'package:impal_desktop/features/e-credit/admin/status/approver_status.dart';
import 'package:impal_desktop/features/e-credit/customer/existing/view/existing_customer.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/new_customer_application.dart';
import 'package:impal_desktop/features/e-credit/customer/status/status.dart';
import 'package:impal_desktop/features/e-credit/customer/withdraw/withdraw.dart';
import 'package:impal_desktop/features/sales/managers/collection/collection_details_m.dart';
import 'package:impal_desktop/features/sales/managers/reports/reports.dart';
import 'package:impal_desktop/features/sales/managers/sales/sales.dart';
import 'package:impal_desktop/features/dashboard/view/dashboard.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/stocks/stocks.dart';
import 'package:impal_desktop/features/sales/salesperson/collection_summary/view/collection_summary.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/customer.dart';
 
class NavigationItem {
  final Widget page;
  final IconData icon;
  final String label;
  final bool visible;
 
  NavigationItem({
    required this.page,
    required this.icon,
    required this.label,
    required this.visible,
  });
}
 
class BottomScreen extends StatefulWidget {
  const BottomScreen({super.key});
  static String routeName = "/BottomScreen";
 
  @override
  State<BottomScreen> createState() => _BottomScreenState();
}
 
class _BottomScreenState extends State<BottomScreen> {
  
  int currentSelectedIndex = 0;
  int currentPage = 0;
    final int itemsPerPage = 5;
  final employee = Get.find<LoginController>().employeeModel;
 
 
  bool get isManager => employee.isManager ?? false;
  bool get isHo => employee.isHo ?? false;
  bool get isApprover => employee.isApprover ?? false;
  bool get isEDP => employee.isEdp ?? false;
  bool get isSalesman => employee.isSalesman ?? false;
  bool get isEcredit_Ho => employee.isEcredit_Ho ?? false;
 
  List<NavigationItem> getNavigationItems() {
    return [
      NavigationItem(
          page: ApprovalStatus(),
          icon: Icons.fact_check,
          label: "Status",
          visible: isApprover),
      NavigationItem(
          page: const HomeScreen(),
          icon: Icons.home_outlined,
          label: "Home",
          visible: isManager || isSalesman),
      NavigationItem(
          page: const Sales(),
          icon: Icons.bar_chart,
          label: "Sales",
          visible: isManager),
      NavigationItem(
          page: const Status(),
          icon: Icons.check_circle,
          label: "Status",
          visible: isEDP || isManager),
      NavigationItem(
          page: NewCustomerApplication(),
          icon: Icons.person_add,
          label: "New Customer",
          visible: isEDP || isManager),
      NavigationItem(
          page: const ExistingCustomer(),
          icon: Icons.people,
          label: "Existing",
          visible: isManager || isEDP),
      NavigationItem(
          page: const WithdrawalCustomerApplication(),
          icon: Icons.account_circle,
          label: "Withdraw",
          visible: isEDP || isManager),
      NavigationItem(
          page: const CustomerSummary(),
          icon: Icons.person,
          label: "Customer",
          visible: isManager || isSalesman),
      NavigationItem(
          page: DealerApprovalPage(),
          icon: Icons.check_circle,
          label: "Dealer Approval",
          visible: isApprover),
      NavigationItem(
          page: const Reports(),
          icon: Icons.article,
          label: "Reports",
          visible: isManager || isSalesman),
      NavigationItem(
          page: Stocks(),
          icon: Icons.inventory,
          label: "Stocks",
          visible: isManager || isSalesman),
      NavigationItem(
          page: CyberStocks(),
          icon: Icons.payments,
          label: "Cyber Warehouse",
          visible: isHo),
      NavigationItem(
          page: const CollectionDetailsPage(),
          icon: Icons.payments,
          label: "Collection Details",
          visible: isManager),
      NavigationItem(
          page: const CollectionSummary(),
          icon: Icons.payments,
          label: "Collection",
          visible: isSalesman),
    ];
     
  }
 
  List<NavigationItem> getVisibleNavigationItems() {
    final allItems = getNavigationItems().where((item) => item.visible).toList();
    final startIndex = currentPage * itemsPerPage;
    var endIndex = startIndex + itemsPerPage;
    if (endIndex > allItems.length) endIndex = allItems.length;
    return allItems.sublist(startIndex, endIndex);
  }
   List<Widget> getPages() {
    final pages = getNavigationItems()
        .where((item) => item.visible)
        .map((item) => item.page)
        .toList();
    return pages.isNotEmpty ? pages : [const DefaultScreen()];
  }
 
 
  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
  final pages = getPages();
  final visibleItems = getVisibleNavigationItems();
  final allVisibleItems = getNavigationItems().where((item) => item.visible).toList();
  final hasMoreItems = (currentPage + 1) * itemsPerPage < allVisibleItems.length;

  // Reset index if it's out of range
  if (currentSelectedIndex >= pages.length) {
    setState(() => currentSelectedIndex = 0);
  }

  // Indexing logic for special items

  final ticketsIndex = visibleItems.length + (hasMoreItems ? 1 : 0);
  final logoutIndex = ticketsIndex + 1;
    final moreIndex = visibleItems.length;
  return Scaffold(
    backgroundColor: Colors.black,
    body: Row(
      children: [
        NavigationRail(
          backgroundColor: const Color(0xFF161717),
          selectedIndex: currentSelectedIndex >= currentPage * itemsPerPage &&
                         currentSelectedIndex < (currentPage + 1) * itemsPerPage
                         ? currentSelectedIndex - (currentPage * itemsPerPage)
                         : null,
     onDestinationSelected: (int index) {
  final totalVisibleItems = visibleItems.length;
  final isMoreVisible = hasMoreItems || currentPage > 0;

  final moreButtonIndex = totalVisibleItems;
  final ticketsButtonIndex = moreButtonIndex + (isMoreVisible ? 1 : 0);
  final logoutButtonIndex = ticketsButtonIndex + 1;

  if (isMoreVisible && index == moreButtonIndex) {
    setState(() {
      currentPage = currentPage == 0 ? 1 : 0;
    });
  } else if (index == ticketsButtonIndex) {
    _launchURL();
  } else if (index == logoutButtonIndex) {
    _logout();
  } else {
    setState(() {
      currentSelectedIndex = (currentPage * itemsPerPage) + index;
    });
  }
},



          labelType: NavigationRailLabelType.all,
  destinations: [
  ...visibleItems.map((item) => _buildNavigationRailDestination(item.icon, item.label)),
  if (hasMoreItems || currentPage > 0)
    _buildNavigationRailDestination(
      currentPage == 0 ? Icons.more_horiz : Icons.arrow_back,
      currentPage == 0 ? "More" : "Back",
    ),
  _buildNavigationRailDestination(Icons.confirmation_num, "Tickets"),
  _buildNavigationRailDestination(Icons.logout, "Logout"),
],
          selectedLabelTextStyle: 
          theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,color:Colors.blueAccent),
          // const TextStyle(
          //   fontWeight: FontWeight.bold,
          //   color: Colors.blueAccent,
          // ),
          unselectedLabelTextStyle:  theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.7)),
          // TextStyle(color: Colors.white.withOpacity(0.7)),
          groupAlignment: 0.0,
          elevation: 8.0,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: getPages()[currentSelectedIndex],
          ),
        ),
      ],
    ),
  );
}

NavigationRailDestination _buildNavigationRailDestination(
    IconData icon, String label) {
      final theme = Theme.of(context);
  return NavigationRailDestination(
    icon: Icon(icon, color: Colors.white),
    selectedIcon: Icon(icon, color: Colors.blueAccent),
    label: Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
    //  const TextStyle(color: Colors.white)),
  );
}

void _launchURL() async {
  const url = 'https://crm.the-absol.com/authentication/login';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch $url')),
    );
  }
}

void _logout() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: 'Logout Confirmation',
        message: 'Are you sure you want to log out?',
        onConfirm: () {
          Navigator.of(context).pop();
          LoginController.logout(context);
        },
        onCancel: () => Navigator.of(context).pop(),
      );
    },
  );
}
}