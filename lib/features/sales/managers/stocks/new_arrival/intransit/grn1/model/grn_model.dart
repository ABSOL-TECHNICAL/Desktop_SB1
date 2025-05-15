class Grn1Model {
  final String? grnNumber;
  final String? supplierName;
  final String? itemName;
  final String? quantity;
  final String? lrdate;
  final String? lrnumber;

  Grn1Model({
    this.grnNumber,
    this.supplierName,
    this.itemName,
    this.quantity,
    this.lrdate,
    this.lrnumber,
  });

  factory Grn1Model.fromJson(Map<String, dynamic> json) {
    return Grn1Model(
      grnNumber: json['GRN-Number']?.toString(),
      supplierName: json['Supplier Name'] ?? "N/A",
      itemName: json['Item Name'] ?? "N/A",
      quantity: json['Quantity']?.toString() ?? "0",
      lrdate: json['LR Date'] ?? "N/A",
      lrnumber: json['LR Number'] ?? "N/A",
    );
  }

  /// ✅ **Define `listFromJson` method**
  static List<Grn1Model> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Grn1Model.fromJson(json)).toList();
  }
}
