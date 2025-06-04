class Ownbranch {
  String? location;
  int? availableStock;
  // double? unitPrice;
  double? mRP;
  double? netPrice;
  String? desc;
  String? partno;
  String? partNoId;
  double? listPrice;
  String? gSTRate;
  String? sLB;

  Ownbranch({
    this.location,
    this.availableStock,
    // this.unitPrice,
    this.mRP,
    this.netPrice,
    this.desc,
    this.partno,
    this.partNoId,
    this.listPrice,
    this.gSTRate,
    this.sLB,
  });

  Ownbranch.fromJson(Map<String, dynamic> json) {
    location = json['Location'];
    availableStock = json['Available Stock'] != null
        ? int.tryParse(json['Available Stock'].toString())
        : null;
    // unitPrice = json['UnitPrice'] != null
    //     ? double.tryParse(json['UnitPrice'].toString())
    //     : null;
    mRP = json['MRP'] != null ? double.tryParse(json['MRP'].toString()) : null;
    netPrice = json['NetPrice'] != null
        ? double.tryParse(json['NetPrice'].toString())
        : null;
    desc = json['Desc'];
    partno = json['PartNo'];
    partNoId = json['Internalid'];
     listPrice = json['ListPrice'] != null ? double.tryParse(json['ListPrice'].toString()) : null;
     gSTRate=json['GSTRate'];
     sLB=json['SLB'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Location': location,
      'Available Stock': availableStock,
      // 'UnitPrice': unitPrice,
      'MRP': mRP,
      'NetPrice': netPrice,
      'Desc': desc,
      'PartNo': partno,
      'Internalid': partNoId,
      'ListPrice':listPrice,
      'GSTRate':gSTRate,
      'SLB':sLB,
    };
  }

  // Static method to parse a list of JSON objects into a list of Ownbranch objects
  static List<Ownbranch> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Ownbranch.fromJson(json)).toList();
  }
}
class SlbOption {
  final String name;
  final String id;

  SlbOption({required this.name, required this.id});
  
  @override
  String toString() => name;
}