class SupplierDetail {
  final String item;
  final String supplier;
  final String qty;
  final String value;
  final String aging;

  SupplierDetail({
    required this.item,
    required this.supplier,
    required this.qty,
    required this.value,
    required this.aging,
  });

  // Factory method to create a SupplierDetail from JSON
  factory SupplierDetail.fromJson(Map<String, dynamic> json) {
    return SupplierDetail(
      item: json['Item'] ?? '',
      supplier: json['Supplier'] ?? '',
      qty: json['Qty'] ?? '0',
      value: json['Value'] ?? '0.00',
      aging: json['Aging'] ?? '0',
    );
  }

  // Method to create a list of SupplierDetail from a list of json
  static List<SupplierDetail> listFromJson(List<dynamic> json) {
    return json.map((item) => SupplierDetail.fromJson(item)).toList();
  }
}
