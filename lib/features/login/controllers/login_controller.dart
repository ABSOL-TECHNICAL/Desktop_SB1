import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/models/login_model.dart';
import 'package:impal_desktop/features/navigation/bottom_navigation.dart';
import 'package:impal_desktop/routes/app_routes.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/restlet_api.dart';

class LoginController extends GetxController {
  final RestletService _restletService = RestletService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final RxBool showPassword = false.obs;
  final RxBool isLoading = false.obs;
  late EmployeeModel employeeModel = EmployeeModel();

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    _loadCachedUserDetails();
  }

  void resetFields() {
    username.clear();
    password.clear();
  }

  static Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      final requestBody = {
        "userName": username.text,
        "password": password.text,
      };

      try {
        final result = await _restletService.fetchReportData(
          NetSuiteScripts.loginScriptId,
          requestBody,
        );

        if (result != null && result.containsKey('salesRepId')) {
          employeeModel = EmployeeModel.fromJson(result);

          await _cacheUserDetails(employeeModel);
          _onLoginSuccess();
        } else {
          _handleLoginFailure(result);
        }
      } catch (error) {
        _showErrorSnackBar("Error: $error");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void _onLoginSuccess() {
    if (employeeModel.isHrms == true && employeeModel.isSalesman != true) {
      Get.off(() => const BottomScreen());
    } else if (employeeModel.isSalesman == true &&
        employeeModel.isHrms != true) {
      Get.off(() => const BottomScreen());
    } else {
      Get.offNamed(AppRoutes.navigation.toName);
    }
    resetFields();
  }

  void _handleLoginFailure(Map<String, dynamic>? result) {
    if (result != null && result.containsKey('error')) {
      var errorData = result['error'];

      if (errorData is Map<String, dynamic> &&
          errorData.containsKey('message')) {
        _showErrorSnackBar(errorData['message']);
        return;
      }
    }

    _showErrorSnackBar(result?.toString() ?? "An unknown error occurred.");
  }

  void _showErrorSnackBar(String message) {
    AppSnackBar.alert(message: message);
  }

  Future<void> _cacheUserDetails(EmployeeModel employeeModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('salesRepId', employeeModel.salesRepId ?? '');
    prefs.setString('employeeName', employeeModel.employeeName ?? '');
    prefs.setString('emailId', employeeModel.emailId ?? '');
    prefs.setString('locationName', employeeModel.locationName ?? '');
    prefs.setString('location', employeeModel.location ?? '');
    prefs.setBool('isSalesman', employeeModel.isSalesman ?? false);
    prefs.setBool('isHo', employeeModel.isHo ?? false); // Fixed mapping
    prefs.setBool(
        'isEcredit_Ho', employeeModel.isEcredit_Ho ?? false); // Fixed case
    prefs.setBool('isApprover', employeeModel.isApprover ?? false);
    prefs.setBool('isEdp', employeeModel.isEdp ?? false);

    prefs.setBool('isManager', employeeModel.isManager ?? false);
    prefs.setString('phone', employeeModel.phone ?? '');
    prefs.setString('dob', employeeModel.dob ?? '');
    prefs.setString('doj', employeeModel.doj ?? '');
    prefs.setString('employeeCategory', employeeModel.employeeCategory ?? '');
    prefs.setString('salaryGrade', employeeModel.salaryGrade ?? '');
    prefs.setString('jobTitle', employeeModel.jobTitle ?? '');
    prefs.setString('empStatus', employeeModel.empStatus ?? '');
    prefs.setString('idenNo', employeeModel.idenNo ?? '');
    prefs.setString('empType', employeeModel.empType ?? '');
    prefs.setString('fullName', employeeModel.fullName ?? '');
    prefs.setString('Branchid', employeeModel.branchid ?? '');
    prefs.setString('Branch_name', employeeModel.branchname ?? '');
    prefs.setString('GstIn', employeeModel.branchname ?? '');
  }

  Future<void> _loadCachedUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? cachedSalesRepId = prefs.getString('salesRepId');

    if (cachedSalesRepId == null || cachedSalesRepId.isEmpty) {
      return;
    }

    employeeModel = EmployeeModel(
      salesRepId: cachedSalesRepId,
      employeeName: prefs.getString('employeeName'),
      emailId: prefs.getString('emailId'),
      locationName: prefs.getString('locationName'),
      location: prefs.getString('location'),
      isSalesman: prefs.getBool('isSalesman'),
      isHo: prefs.getBool('isHo'),
      isEcredit_Ho: prefs.getBool('isEcredit_Ho'),
      isManager: prefs.getBool('isManager'),
      isApprover: prefs.getBool('isApprover'),
      isEdp: prefs.getBool('isEdp'),
      phone: prefs.getString('phone'),
      dob: prefs.getString('dob'),
      doj: prefs.getString('doj'),
      employeeCategory: prefs.getString('employeeCategory'),
      salaryGrade: prefs.getString('salaryGrade'),
      jobTitle: prefs.getString('jobTitle'),
      empStatus: prefs.getString('empStatus'),
      idenNo: prefs.getString('idenNo'),
      empType: prefs.getString('empType'),
      fullName: prefs.getString('fullName'),
      branchid: prefs.getString('Branchid'),
      branchname: prefs.getString('Branch_name'),
      gstinNo: prefs.getString('GstIn'),
    );

    _onLoginSuccess();
  }

  String? get salesRepId => employeeModel.salesRepId;
  String? get employeeName => employeeModel.employeeName;
  String? get emailId => employeeModel.emailId;
  String? get locationName => employeeModel.locationName;
  String? get location => employeeModel.location;
  bool? get isSalesman => employeeModel.isSalesman;
  bool? get isHo => employeeModel.isHo;
  // ignore: non_constant_identifier_names
  bool? get isEcredit_Ho => employeeModel.isEcredit_Ho;
  bool? get isManager => employeeModel.isManager;
  String? get phone => employeeModel.phone;
  String? get dob => employeeModel.dob;
  String? get doj => employeeModel.doj;
  String? get employeeCategory => employeeModel.employeeCategory;
  String? get salaryGrade => employeeModel.salaryGrade;
  String? get jobTitle => employeeModel.jobTitle;
  String? get empStatus => employeeModel.empStatus;
  String? get idenNo => employeeModel.idenNo;
  String? get empType => employeeModel.empType;
  String? get fullName => employeeModel.fullName;
  String? get gstinNo => employeeModel.gstinNo;
}
