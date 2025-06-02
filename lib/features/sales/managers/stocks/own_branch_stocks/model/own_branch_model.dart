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
    };
  }

  // Static method to parse a list of JSON objects into a list of Ownbranch objects
  static List<Ownbranch> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Ownbranch.fromJson(json)).toList();
  }
}
