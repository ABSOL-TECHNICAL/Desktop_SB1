class GlobalitemDetail {
  String? itemName;
  String? itemId;
  String? desc;
  String? vehicalApplication;

  GlobalitemDetail({this.itemName, this.itemId, this.desc, this.vehicalApplication});

  GlobalitemDetail.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    itemId = json['ItemId'];
    desc = json['Desc'];
    vehicalApplication = json['vehicalApplication'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemName'] = itemName;
    data['ItemId'] = itemId;
    data['Desc'] = desc;
    data['vehicalApplication'] = vehicalApplication;
    return data;
  }



  static List<GlobalitemDetail> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => GlobalitemDetail.fromJson(json)).toList();
    }
}
 
class GlobalitemDetails {
  final String? itemName;
  final String? itemId;
  final double? unitPrice;
  final int? availableQuantity;
 
  GlobalitemDetails({
    this.itemName,
    this.itemId,
    this.unitPrice,
    this.availableQuantity,
  });
 
  static List<GlobalitemDetails> listFromJson(List<dynamic> json) {
    return json.map((item) {
      return GlobalitemDetails(
        itemName: item['ItemName'] as String?,
        unitPrice: double.tryParse(item['UnitPrice']?.toString() ?? '0'),
        availableQuantity: int.tryParse(item['AvailableQuantity']?.toString() ?? '0'),
      );
    }).toList();
  }
}
