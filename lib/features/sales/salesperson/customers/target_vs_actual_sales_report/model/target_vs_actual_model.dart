class SalesDetail {
  double? target;
  double? daySales;
  double? cumulativeSales;
  double? achSales;
  double? billToDo;

  SalesDetail({
    this.target,
    this.daySales,
    this.cumulativeSales,
    this.achSales,
    this.billToDo,
  });

  SalesDetail.fromJson(Map<String, dynamic> json) {
    target = double.tryParse(json['Target']?.toString() ?? '0');
    daySales = double.tryParse(json['DaySales']?.toString() ?? '0');
    cumulativeSales =
        double.tryParse(json['CumulativeSales']?.toString() ?? '0');
    achSales = double.tryParse(json['AchSales']?.toString() ?? '0');
    billToDo = double.tryParse(json['BillToDo']?.toString() ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Target'] = target?.toString();
    data['DaySales'] = daySales?.toString();
    data['CumulativeSales'] = cumulativeSales?.toString();
    data['AchSales'] = achSales?.toString();
    data['BillToDo'] = billToDo?.toString();
    return data;
  }

  static List<SalesDetail> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => SalesDetail.fromJson(json)).toList();
  }
}
