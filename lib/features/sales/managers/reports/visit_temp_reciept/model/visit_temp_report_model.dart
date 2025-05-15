class VisitTempModel {
  final String customerId;
  final String modeOfCollection;
  final String amount;
  final String? invoiceNo;
  final String remarks;

  VisitTempModel({
    required this.customerId,
    required this.modeOfCollection,
    required this.amount,
    this.invoiceNo,
    required this.remarks,
  });

  // Convert from JSON
  factory VisitTempModel.fromJson(Map<String, dynamic> json) {
    return VisitTempModel(
      customerId: json['CustomerId'] ?? 'N/A',
      modeOfCollection: json['ModeOfCollection'] ?? 'N/A',
      amount: json['Amount'] ?? '0.00',
      invoiceNo: json['InvoiceNo'], // Nullable field
      remarks: json['Remarks'] ?? 'NoData',
    );
  }

  

}
