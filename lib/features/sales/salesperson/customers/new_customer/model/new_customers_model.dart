class CustomerData {
  List<Customer>? customerMonth;
  List<Customer>? customerYear;

  CustomerData({
    this.customerMonth,
    this.customerYear,
  });

  CustomerData.fromJson(Map<String, dynamic> json) {
    if (json['Customer_Month'] is List) {
      customerMonth = (json['Customer_Month'] as List)
          .map((item) => Customer.fromJson(item))
          .toList();
    } else {
      customerMonth = []; // Ensures empty list if it's a string
    }

    if (json['Customer_Year'] is List) {
      customerYear = (json['Customer_Year'] as List)
          .map((item) => Customer.fromJson(item))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Customer_Month'] =
        customerMonth?.map((v) => v.toJson()).toList() ?? [];
    data['Customer_Year'] = customerYear?.map((v) => v.toJson()).toList() ?? [];
    return data;
  }
}

class Customer {
  int? slNo;
  String? customerCode;
  String? customerName;
  String? sales;

  Customer({
    this.slNo,
    this.customerCode,
    this.customerName,
    this.sales,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    slNo = json['SlNo'];
    customerCode = json['CustomerCode'];
    customerName = json['CustomerName'];
    sales = json['Sales'];
  }

  Map<String, dynamic> toJson() {
    return {
      'SlNo': slNo,
      'CustomerCode': customerCode,
      'CustomerName': customerName,
      'Sales': sales,
    };
  }
}
