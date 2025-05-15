class GetApplication {
  String? customerID;
  String? delarID;
  String? creditLimit;
  String? enhanceCredit;

  GetApplication(
      {this.customerID,
      this.delarID,
      this.creditLimit,
      this.enhanceCredit});

  GetApplication.fromJson(Map<String, dynamic> json) {
    customerID = json['CustomerID'];
    delarID = json['DelarID'];
    creditLimit = json['CreditLimit'];
    enhanceCredit = json['enhanceCredit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomerID'] = customerID;
    data['DelarID'] = delarID;
    data['CreditLimit'] = creditLimit;
    data['enhanceCredit'] = enhanceCredit;
    return data;
  }
}
