class Surplustocks {
  final String supplier;
  final String qty;
  final String value;
  final String aging;

  Surplustocks({
    required this.supplier,
    required this.qty,
    required this.value,
    required this.aging,
  });

  // Factory method to create a Surplustocks from JSON
  factory Surplustocks.fromJson(Map<String, dynamic> json) {
    return Surplustocks(
      supplier: json['Supplier'],
      qty: json['Qty'] ?? '0',
      value: json['Value'] ?? '0.00',
      aging: json['Aging'] ?? '0',
    );
  }

  // Method to create a list of SupplierDetail from a list of json
  static List<Surplustocks> listFromJson(List<dynamic> json) {
    return json.map((item) => Surplustocks.fromJson(item)).toList();
  }
}
