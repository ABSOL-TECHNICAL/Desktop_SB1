class LocationModel {
  int? locationId;
  String? locationName;
  List<Item>? items;

  LocationModel({this.locationId, this.locationName, this.items});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locationId: json['locationId'],
      locationName: json['locationName'],
      items:
          (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
    );
  }
}

class Item {
  String? item;
  int? itemId;
  int? onhand;
  double? purchasePrice;
  int? consignmentId;
  String? consignmentNumber;

  Item({
    this.item,
    this.itemId,
    this.onhand,
    this.purchasePrice,
    this.consignmentId,
    this.consignmentNumber,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      item: json['item'],
      itemId: json['itemId'],
      onhand: json['onhand'],
      purchasePrice: (json['purchasePrice'] is int)
          ? (json['purchasePrice'] as int).toDouble()
          : json['purchasePrice'],
      consignmentId: json['ConsignmentID'],
      consignmentNumber: json['ConsigmentNumber'],
    );
  }
}
