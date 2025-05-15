class DealerDetail {
  String? dealoreCode;
  String? address;
  String? location;
  double? creditAmount;
  double? amount;

  DealerDetail({
    this.dealoreCode,
    this.address,
    this.location,
    this.creditAmount,
    this.amount,
  });

  DealerDetail.fromJson(Map<String, dynamic> json) {
    dealoreCode = json['Dealore Code'];
    address = json['Address'];
    location = json['Location'];
    creditAmount = double.tryParse(json['Credit Amount'] ?? '0');
    amount = double.tryParse(json['Amount'] ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Dealore Code'] = dealoreCode;
    data['Address'] = address;
    data['Location'] = location;
    data['Credit Amount'] = creditAmount?.toString();
    data['Amount'] = amount?.toString();
    return data;
  }

  static List<DealerDetail> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => DealerDetail.fromJson(json)).toList();
}
}
