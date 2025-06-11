class MaterialInward {
  List<MaterialInward>? materialInward;
  List<MaterialInward>? defaultMaterialInward;

  MaterialInward({this.materialInward});

  MaterialInward.fromJson(Map<String, dynamic> json) {
    if (json['MaterialInward'] != null) {
      materialInward = <MaterialInward>[];
      json['MaterialInward'].forEach((v) {
        materialInward!.add(MaterialInward.fromJson(v));
      });
    }
    if (json['DefaultMaterialInward'] != null) {
      defaultMaterialInward = <MaterialInward>[];
      json['DefaultMaterialInward'].forEach((v) {
        defaultMaterialInward!.add(MaterialInward.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (materialInward != null) {
      data['MaterialInward'] = materialInward!.map((v) => v.toJson()).toList();
    }
    if (defaultMaterialInward != null) {
      data['DefaultMaterialInward'] =
          defaultMaterialInward!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MaterialEntry {
  String? supplier;
  String? partNo;
  String? desc; // Keeping 'Desc' as per the provided structure
  int? inwardQty;

  MaterialEntry({this.supplier, this.partNo, this.desc, this.inwardQty});

  MaterialEntry.fromJson(Map<String, dynamic> json) {
    supplier = json['Supplier'];
    partNo = json['part_no'];
    desc = json['Desc']; // Keeping 'Desc' as is
    inwardQty = json['Inward Qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Supplier'] = supplier;
    data['part_no'] = partNo;
    data['Desc'] = desc; // Keeping 'Desc' as is
    data['Inward Qty'] = inwardQty;
    return data;
  }
}

class MaterialInwardDefault {
  final int id;
  final String supplierName;
  final String? partNo;
  final String? desc; // Keeping 'Desc' as per the provided structure
  final int inwardQty;

  MaterialInwardDefault({
    required this.id,
    required this.supplierName,
     this.partNo,
     this.desc,
    required this.inwardQty,
  });

  MaterialInwardDefault.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        supplierName = json['Supplier'] ?? '',
        partNo = json['part_no'] ?? '',
        desc = json['Desc'] ?? '', // Keeping 'Desc' as is
        inwardQty = json['Inward Qty'] ?? 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['Supplier'] = supplierName;
    data['part_no'] = partNo;
    data['Desc'] = desc; // Keeping 'Desc' as is
    data['Inward Qty'] = inwardQty;
    return data;
  }
}
