class Item {
  int? itemId;
  double? unitPrice;
  String? _itemName;

  Item({this.itemId, this.unitPrice, String? itemName}) {
    _itemName = itemName;
  }

  Item.fromJson(Map<String, dynamic> json) {
    itemId = json['itemId'];
    unitPrice = json['unitPrice']?.toDouble();
    _itemName = json['itemName'];
  }

  String? get itemName => _itemName;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'unitPrice': unitPrice,
      'itemName': _itemName,
    };
  }
}

class Customer {
  String? customerName;
  int? customerId;
  String? shipTo;
  int? branchInternalId;
  int? salesRepId;
  String? salesRepName;
  double? latitude;
  double? longitude;
  String? paymentTerms;
  List<Item>? items;

  Customer({
    this.customerName,
    this.customerId,
    this.shipTo,
    this.branchInternalId,
    this.salesRepId,
    this.salesRepName,
    this.latitude,
    this.longitude,
    this.paymentTerms,
    this.items,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    customerName = json['customerName'];
    customerId = json['customerId'];
    shipTo = json['shipTo'];
    branchInternalId = json['branchInternalId'];
    salesRepId = json['salesRepId'];
    salesRepName = json['salesRepName'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    paymentTerms = json['paymentTerms'];

    if (json['items'] != null) {
      items = <Item>[];
      json['items'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['customerName'] = customerName;
    data['customerId'] = customerId;
    data['shipTo'] = shipTo;
    data['branchInternalId'] = branchInternalId;
    data['salesRepId'] = salesRepId;
    data['salesRepName'] = salesRepName;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['paymentTerms'] = paymentTerms;

    if (items != null) {
      data['items'] = items!.map((item) => item.toJson()).toList();
    }
    return data;
  }

  // Method to check if the customer has an item with a specific itemId
  bool hasItem(int itemId) {
    return items?.any((item) => item.itemId == itemId) ?? false;
  }
}

class CustomersList {
  List<Customer>? customers;
  CustomersList({this.customers});

  CustomersList.fromJson(List<dynamic> jsonList) {
    customers = jsonList.map((json) => Customer.fromJson(json)).toList();
  }

  List<Map<String, dynamic>> toJson() {
    return customers?.map((customer) => customer.toJson()).toList() ?? [];
  }
}
