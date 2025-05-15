class VisitReportModel {
  final String customer;
  final String personMet;
  final String paymentMethod;
  final String nextVisitDate;
  final String remarks;
  final String amount;
  final String reportedOn;
 
  VisitReportModel({
    required this.customer,
    required this.personMet,
    required this.paymentMethod,
    required this.nextVisitDate,
    required this.remarks,
    required this.amount,
    required this.reportedOn,
  });
 
  factory VisitReportModel.fromJson(Map<String, dynamic> json) {
    return VisitReportModel(
      customer: json['Customer'] ?? 'N/A',
      personMet: json['PersonMet'] ?? 'N/A',
      paymentMethod: json['PaymentMethod'] ?? 'N/A',
      nextVisitDate: json['NextVisitDate'] ?? 'N/A',
      remarks: json['Remarks'] ?? 'NoData',
      amount: json['Amount'] ?? '0.00',
      reportedOn: json['ReportedOn'] ?? 'N/A',
);
}
}