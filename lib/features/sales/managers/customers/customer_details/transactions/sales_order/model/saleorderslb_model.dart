class SalesOrderSlb {
  bool? success;
  List<Dataslb>? data;

  SalesOrderSlb({this.success, this.data});

  SalesOrderSlb.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Dataslb>[];
      json['data'].forEach((v) {
        data!.add(Dataslb.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dataslb {
  int? id;
  String? name;

  Dataslb({this.id, this.name});

  Dataslb.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
class PackingQuantity {
  final String name;
  final String packingQty;

  PackingQuantity({required this.name, required this.packingQty});

  factory PackingQuantity.fromJson(Map<String, dynamic> json) {
    return PackingQuantity(
      name: json['name']?.toString() ?? '',
      packingQty: json['packingQty']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'packingQty': packingQty,
    };
  }
}