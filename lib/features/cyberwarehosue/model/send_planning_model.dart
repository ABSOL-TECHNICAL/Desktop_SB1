class SentPlanningIndentModel {
  int? supplier;
  int? location;
  int? supplierprodiv;
  int? supplierprogro;
  int? fms;
  int? user;
  List<ItemDetail>? items;

  SentPlanningIndentModel({
    this.supplier,
    this.location,
    this.supplierprodiv,
    this.supplierprogro,
    this.fms,
    this.user,
    this.items,
  });

  SentPlanningIndentModel.fromJson(Map<String, dynamic> json) {
    supplier = json['Supplier'];
    location = json['Location'];
    supplierprodiv = json['SupplierProDiv'];
    supplierprogro = json['SupplierProGro'];
    fms = json['Fms'];
    user = json['User'];

    if (json['items'] != null) {
      items = <ItemDetail>[];
      json['items'].forEach((v) {
        items!.add(ItemDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Supplier'] = supplier;
    data['Location'] = location;
    data['SupplierProDiv'] = supplierprodiv;
    data['SupplierProGro'] = supplierprogro;
    data['Fms'] = fms;
    data['User'] = user;

    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemDetail {
  int? slNo;
  int? itemId;
  int? availableQty;
  int? onHandQty;
  int? moq;
  int? onOrderQty;
  int? avgSaleQtyPerMonth;
  int? proAvgSalesQty;
  int? orderQty;
  int? suggestedQty;

  ItemDetail({
    this.slNo,
    this.itemId,
    this.availableQty,
    this.onHandQty,
    this.moq,
    this.onOrderQty,
    this.avgSaleQtyPerMonth,
    this.proAvgSalesQty,
    this.orderQty,
    this.suggestedQty,
  });

  ItemDetail.fromJson(Map<String, dynamic> json)
      : slNo = json['slno'],
        itemId = json['itemId'],
        availableQty = json['availableQty'],
        onHandQty = json['onHandQty'],
        moq = json['moq'],
        onOrderQty = json['onOrderQty'],
        avgSaleQtyPerMonth = json['avgSaleQtyPerMonth'],
        proAvgSalesQty = json['proAvgsalesqty'],
        orderQty = json['orderQty'],
        suggestedQty = json['suggestedQty'];

  Map<String, dynamic> toJson() {
    return {
      'slno': slNo,
      'itemId': itemId,
      'availableQty': availableQty,
      'onHandQty': onHandQty,
      'moq': moq,
      'onOrderQty': onOrderQty,
      'avgSaleQtyPerMonth': avgSaleQtyPerMonth,
      'proAvgsalesqty': proAvgSalesQty,
      'orderQty': orderQty,
      'suggestedQty': suggestedQty,
    };
  }
}
