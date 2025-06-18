class AgingSummary {
  String? customerID;
  String? customerName;
  String? phone;
  int? days0to30;
  int? days31to60;
  int? days61to90;
  int? days91to180;
  int? above180Days;
  String? outstanding;
  String? creditLimit;
  String? creditBalance;
  String? canBillUpTo;
 
  AgingSummary(
      {this.customerID,
      this.customerName,
      this.phone,
      this.days0to30,
      this.days31to60,
      this.days61to90,
      this.days91to180,
      this.above180Days,
      this.outstanding,
      this.creditLimit,
      this.creditBalance,
      this.canBillUpTo});
 
  AgingSummary.fromJson(Map<String, dynamic> json) {
    customerID = json['CustomerID'];
    customerName = json['CustomerName'];
    phone = json['Phone'];
    days0to30 = json['Days0to30'];
    days31to60 = json['Days31to60'];
    days61to90 = json['Days61to90'];
    days91to180 = json['Days91to180'];
    above180Days = json['Above180Days'];
    outstanding = json['Outstanding'];
    creditLimit = json['CreditLimit'];
    creditBalance = json['CreditBalance'];
    canBillUpTo = json['CanBillUpTo'];
  }
 
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CustomerID'] = customerID;
    data['CustomerName'] = customerName;
    data['Phone'] = phone;
    data['Days0to30'] = days0to30;
    data['Days31to60'] = days31to60;
    data['Days61to90'] = days61to90;
    data['Days91to180'] = days91to180;
    data['Above180Days'] = above180Days;
    data['Outstanding'] = outstanding;
    data['CreditLimit'] = creditLimit;
    data['CreditBalance'] = creditBalance;
    data['CanBillUpTo'] = canBillUpTo;
    return data;
  }
}
 