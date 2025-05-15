class Nonbilledcustomer {
  String? dealoreCode;
  String? address;
  String? location;
  String? lastBillDate;
  double? creditAmount;

  Nonbilledcustomer({
    this.dealoreCode,
    this.address,
    this.location,
    this.lastBillDate,
    this.creditAmount,
  });

  Nonbilledcustomer.fromJson(Map<String, dynamic> json) {
    dealoreCode = json['Dealore Code'];
    address = json['Address'];
    location = json['Location'];
    lastBillDate = json['Last Bill Date'];

    creditAmount = double.tryParse(json['Credit Amount'] ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Dealore Code'] = dealoreCode;
    data['Address'] = address;
    data['Location'] = location;
    data['Last Bill Date'] = lastBillDate;
    data['Credit Amount'] = creditAmount?.toString();
    return data;
  }
}
