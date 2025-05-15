class Supplier {
  final String supplier;
  final String supplierId;

  Supplier({required this.supplier, required this.supplierId});

  Supplier.fromJson(Map<String, dynamic> json)
      : supplier = json['supplier'],
        supplierId = json['supplierId'];

  Map<String, dynamic> toJson() {
    return {
      'supplier': supplier,
      'supplierId': supplierId,
    };
  }
}
