class DealerName {
  String? customerID;
  String? dealerId;
  String? dealerName;

  DealerName({this.customerID, this.dealerId, this.dealerName});

  DealerName.fromJson(Map<String, dynamic> json) {
    customerID = json['CustomerID'];
    dealerId = json['DealerId'];
    dealerName = json['DealerName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomerID'] = customerID;
    data['DealerId'] = dealerId;
    data['DealerName'] = dealerName;
    return data;
  }
}