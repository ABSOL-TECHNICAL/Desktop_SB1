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
   // Handle both String and double for Credit Amount
  final credit = json['Credit Amount'];
  if (credit is String) {
    creditAmount = double.tryParse(credit) ?? 0.0;
  } else if (credit is num) {
    creditAmount = credit.toDouble();
  }

  // Handle both String and double for Amount
  final amt = json['Amount'];
  if (amt is String) {
    amount = double.tryParse(amt) ?? 0.0;
  } else if (amt is num) {
    amount = amt.toDouble();
  }
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
