class Customerdetails {
  String? customer;
  String? customerId;
  String? address;
  String? phone;
 
  Customerdetails({this.customer, this.customerId, this.address, this.phone});
 
  Customerdetails.fromJson(Map<String, dynamic> json) {
    customer = json['Customer'];
    customerId = json['CustomerId'];
    address = json['address'];
    phone = json['Phone'];
  }
 
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Customer'] = customer;
    data['CustomerId'] = customerId;
    data['address'] = address;
    data['Phone'] = phone;
    return data;
  }
}
 
 