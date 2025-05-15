class ApproverStatusData {
  String? customerID;
  String? branch;
  int? enhanceCredit;
  String? customercode;
  String? customername;
  String? creditLimit;
  String? branchTxt;
  String? approvalStatus;
  String? approvalStatusid;
  String? applicationdate;
  String? eDPName;
  String? modeofcredit;
  String? reason;
  String? validateIndicator;
  String? validateIndicatortxt;

  ApproverStatusData(
      {this.customerID,
      this.branch,
      this.enhanceCredit,
      this.customercode,
      this.customername,
      this.creditLimit,
      this.branchTxt,
      this.approvalStatus,
      this.approvalStatusid,
      this.applicationdate,
      this.eDPName,
      this.modeofcredit,
      this.reason,
      this.validateIndicator,
      this.validateIndicatortxt});

  ApproverStatusData.fromJson(Map<String, dynamic> json) {
    customerID = json['Customer ID'];
    branch = json['Branch'];
    enhanceCredit = json['EnhanceCredit'] != null
        ? int.tryParse(json['EnhanceCredit'].toString()) ?? 0
        : null;
    customercode = json['Customercode'];
    customername = json['Customername'];
    creditLimit = json['CreditLimit'];
    branchTxt = json['Branch_txt'];
    approvalStatus = json['Approval_status'];
    approvalStatusid = json['Approval_statusid'];
    applicationdate = json['Applicationdate'];
    eDPName = json['EDP_name'];
    modeofcredit = json['Modeofcredit'];
    reason = json['Reason'];
    validateIndicator = json['validateIndicator'];
    validateIndicatortxt = json['validateIndicatortxt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Customer ID'] = customerID;
    data['Branch'] = branch;
    data['EnhanceCredit'] = enhanceCredit;
    data['Customercode'] = customercode;
    data['Customername'] = customername;
    data['CreditLimit'] = creditLimit;
    data['Branch_txt'] = branchTxt;
    data['Approval_status'] = approvalStatus;
    data['Approval_statusid'] = approvalStatusid;
    data['Applicationdate'] = applicationdate;
    data['EDP_name'] = eDPName;
    data['Modeofcredit'] = modeofcredit;
    data['Reason'] = reason;
    data['validateIndicator'] = validateIndicator;
    data['validateIndicatortxt'] = validateIndicatortxt;
    return data;
  }
}
