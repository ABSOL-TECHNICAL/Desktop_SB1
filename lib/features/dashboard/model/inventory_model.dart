class Inventory {
  String? itemName;
  String? itemId;
  String? itemDescription;
  String? stockAvailable;
  String? saleUnit;
  List<String>? unitIds;
  List<String>? unitNames;
  List<double>? conversionRate;
  String? averageCost;
  String? taxCode;
  String? taxRate;
  int? serialNumber;

  Inventory({
    this.itemName,
    this.itemId,
    this.itemDescription,
    this.stockAvailable,
    this.saleUnit,
    this.unitIds,
    this.unitNames,
    this.conversionRate,
    this.averageCost,
    this.taxCode,
    this.taxRate,
    this.serialNumber,
  });

  Inventory.fromJson(Map<String, dynamic> json) {
    itemName = json['itemName'];
    itemId = json['itemId'];
    itemDescription = json['itemDescription'];
    stockAvailable = json['stockAvailable'];
    saleUnit = json['saleUnit'];
    unitIds =
        json['unitIds'] != null ? List<String>.from(json['unitIds']) : null;
    unitNames =
        json['unitNames'] != null ? List<String>.from(json['unitNames']) : null;
    conversionRate = json['conversionRate'] != null
        ? List<double>.from(json['conversionRate'].map((x) => x.toDouble()))
        : null;
    averageCost = json['averageCost'];
    taxCode = json['taxCode'];
    taxRate = json['taxRate'];
    serialNumber = json['SerialNumber'];

    // // Debugging: print conversionRate
    // print('Parsed conversionRate: $conversionRate');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['itemName'] = itemName;
    data['itemId'] = itemId;
    data['itemDescription'] = itemDescription;
    data['stockAvailable'] = stockAvailable;
    data['saleUnit'] = saleUnit;
    data['unitIds'] = unitIds;
    data['unitNames'] = unitNames;
    data['conversionRate'] = conversionRate;
    data['averageCost'] = averageCost;
    data['taxCode'] = taxCode;
    data['taxRate'] = taxRate;
    data['SerialNumber'] = serialNumber;
    return data;
  }

  static List<Inventory> listFromJson(List<dynamic> json) {
    return json.map((data) => Inventory.fromJson(data)).toList();
  }
}
