class CustomerStatusData {
  String? customerID;
  String? branch;
  int? enhanceCredit;
  String? employeeID;
  String? customercode;
  String? customername;
  String? branchTxt;
  String? reason;
  String? approvalStatus;
  String? approvalStatusId;
  double? existingCreditLimit;
  String? applicationDate;
  String? modeOfCredit;
  String? validateIndicator;
  String? vaidateIndicatortxt;
  String? oldLimit;

  CustomerStatusData(
      {this.customerID,
      this.branch,
      this.enhanceCredit,
      this.employeeID,
      this.customercode,
      this.customername,
      this.branchTxt,
      this.reason,
      this.approvalStatus,
      this.approvalStatusId,
      this.existingCreditLimit,
      this.applicationDate,
      this.modeOfCredit,
      this.validateIndicator,
      this.vaidateIndicatortxt,
      this.oldLimit});
  CustomerStatusData.fromJson(Map<String, dynamic> json) {
    customerID = json['Customer ID']?.toString();
    branch = json['Branch']?.toString();
    enhanceCredit = _parseInt(json['EnhanceCredit']);
    employeeID = json['EmployeeID']?.toString();
    customercode = json['Customercode']?.toString();
    customername = json['Customername']?.toString();
    branchTxt = json['Branch_txt']?.toString();
    reason = json['Reason']?.toString();
    approvalStatus = json['Approval_status']?.toString();
    approvalStatusId = json['Approval_statusid']?.toString();
    existingCreditLimit = _parseDouble(json['ExistingCreditLimit']);
    applicationDate = json['Applicationdate']?.toString();
    modeOfCredit = json['Modeofcredit']?.toString();
    validateIndicator = json['validateIndicator']?.toString();
    vaidateIndicatortxt = json['vaidate_Indicatortxt']?.toString();
    oldLimit = json['oldLimit']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer ID': customerID,
      'Branch': branch,
      'EnhanceCredit': enhanceCredit,
      'Employee ID': employeeID,
      'Customercode': customercode,
      'Customername': customername,
      'Branch_txt': branchTxt,
      'Reason': reason,
      'Approval_status': approvalStatus,
      'Approval_statusid': approvalStatusId,
      'ExistingCreditLimit': existingCreditLimit,
      'Applicationdate': applicationDate,
      'Modeofcredit': modeOfCredit,
      'validateIndicator': validateIndicator,
      'vaidate_Indicatortxt': vaidateIndicatortxt,
      'oldLimit': oldLimit
    };
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  double? _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '');
  }
}
