import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/dashboard/controllers/dashboard_controller.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';

class GlobalAppBar extends GetView<DashboardController>
    implements PreferredSizeWidget {
  final String title;
  final LoginController loginController = Get.find<LoginController>();

  GlobalAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final employeeModel = loginController.employeeModel;
    String email = employeeModel.emailId ?? 'user@example.com';
    String username = employeeModel.employeeName ?? 'Username';

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF242424),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitle(context),
          _buildUserSection(username, email, context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Center(
        child: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(
      String username, String email, BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(username, style: _textStyle(fontSize: 14, bold: true)),
            Text(email, style: _textStyle(fontSize: 12)),
            Text('Environment:Sanbox', 
            // Production 1.0.0',
            
                style: _textStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(width: 12),
        _buildProfileMenu(context),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<int>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: const Icon(Icons.person, size: 18, color: Colors.white),
      ),
      onSelected: (value) {
        if (value == 1) _logout(context);
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Logout"),
            ],
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context) {
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

  TextStyle _textStyle(
      {double fontSize = 14, bool bold = false, Color? color}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color ?? Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
