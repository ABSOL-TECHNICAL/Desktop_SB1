class Supplier {
  String? supplier;
  String? supplierId;

  Supplier({this.supplier, this.supplierId});

  Supplier.fromJson(Map<String, dynamic> json) {
    supplier = json['supplier'];
    supplierId = json['supplierId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['supplier'] = supplier;
    data['supplierId'] = supplierId;
    return data;
  }
}
