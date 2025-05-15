class TransferOrderModel {
  int? tolocation;
  int? subsidiary;
  int? branchid;
  List<ItemDetail>? items;

  TransferOrderModel({
    this.tolocation,
    this.subsidiary,
    this.branchid,
    this.items,
  });

  TransferOrderModel.fromJson(Map<String, dynamic> json) {
    tolocation = json['tolocation'];
    subsidiary = json['subsidiary'];
    branchid = json['branchid'];
    if (json['item'] != null && json['item']['items'] != null) {
      items = <ItemDetail>[];
      json['item']['items'].forEach((v) {
        items!.add(ItemDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tolocation'] = tolocation;
    data['subsidiary'] = subsidiary;
    data['branchid'] = branchid;
    if (items != null) {
      data['item'] = {'items': items!.map((v) => v.toJson()).toList()};
    }
    return data;
  }
}

class ItemDetail {
  int? itemId;
  double? totalAmount;
  int? quantityAdded;
  String? consignmentId;
  String? planningId;

  ItemDetail({
    this.itemId,
    this.totalAmount,
    this.quantityAdded,
    this.consignmentId,
    this.planningId,
  });

  ItemDetail.fromJson(Map<String, dynamic> json)
      : itemId = json['itemId'],
        totalAmount = json['totalAmount']?.toDouble(),
        quantityAdded = json['quantityAdded'],
        consignmentId = json['ConsignmentID'],
        planningId = json['PlanningID'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['itemId'] = itemId;
    data['totalAmount'] = totalAmount;
    data['quantityAdded'] = quantityAdded;
    data['ConsignmentID'] = consignmentId;
    data['PlanningID'] = planningId;
    return data;
  }
}
