class EmployeeModel {
  String? salesRepId;
  String? employeeName;
  String? emailId;
  String? locationName;
  String? location;
  String? dob;
  String? phone;
  String? doj;
  String? employeeCategory;
  String? salaryGrade;
  String? jobTitle;
  String? empStatus;
  String? idenNo;
  String? empType;
  String? fullName;
  bool? isSalesman;
  bool? isHrms;
  bool? isManager;
  bool? isHo;
  bool? isEcredit_Ho;
  bool? isEdp;
  bool? isApprover;
  String? branchid;
  String? branchname;
  String? gstinNo;

  EmployeeModel(
      {this.salesRepId,
      this.employeeName,
      this.emailId,
      this.locationName,
      this.location,
      this.dob,
      this.phone,
      this.doj,
      this.employeeCategory,
      this.salaryGrade,
      this.jobTitle,
      this.empStatus,
      this.idenNo,
      this.empType,
      this.fullName,
      this.isSalesman,
      this.isHrms,
      this.isManager,
      this.isHo,
      this.isEcredit_Ho,
      this.isEdp,
      this.isApprover,
      this.branchid,
      this.branchname,
      this.gstinNo});

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
        salesRepId: json['salesRepId'] as String?,
        employeeName: json['EmployeeName'] as String?,
        emailId: json['EmailId'] as String?,
        locationName: json['locationName'] as String?,
        location: json['location'] as String?,
        dob: json['DOB'] as String?,
        phone: json['Phone'] as String?,
        doj: json['DOJ'] as String?,
        employeeCategory: json['Employee_category'] as String?,
        salaryGrade: json['Salary_grade'] as String?,
        jobTitle: json['Job_title'] as String?,
        empStatus: json['Emp_status'] as String?,
        idenNo: json['Iden_No'] as String?,
        empType: json['Emp_typ'] as String?,
        fullName: json['FullName'] as String?,
        isSalesman: json['IsSalesman'] as bool?,
        isHrms: json['IsHrms'] as bool?,
        isManager: json['isManager'] as bool?,
        isHo: json['isHo'] as bool?,
        isEcredit_Ho: json['IsE_CreditHO'] as bool?,
        isEdp: json['ISEDP'] as bool?,
        isApprover: json['ISApprover'] as bool?,
        branchid: json['Branchid'] as String?,
        branchname: json['Branch_name'] as String?,
        gstinNo: json['GSTINno'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'salesRepId': salesRepId,
      'EmployeeName': employeeName,
      'EmailId': emailId,
      'locationName': locationName,
      'location': location,
      'DOB': dob,
      'Phone': phone,
      'DOJ': doj,
      'Employee_category': employeeCategory,
      'Salary_grade': salaryGrade,
      'Job_title': jobTitle,
      'Emp_status': empStatus,
      'Iden_No': idenNo,
      'Emp_typ': empType,
      'FullName': fullName,
      'IsSalesman': isSalesman,
      'IsHrms': isHrms,
      'isManager': isManager,
      'isHo': isHo,
      'isEcredit_Ho': isEcredit_Ho,
      'isEdp': isEdp,
      'ISApprover': isApprover,
      'branchId': branchid,
      'Branch_name': branchname,
      'GSTINno': gstinNo,
    };
  }
}
