class TransactionDetailsResponse {
  List<TransactionDetail>? transactionDetails;
  CashCreditSales? cashCreditSales;

  TransactionDetailsResponse({
    this.transactionDetails,
    this.cashCreditSales,
  });

  TransactionDetailsResponse.fromJson(Map<String, dynamic> json) {
    if (json['transactionDetails'] != null) {
      transactionDetails = <TransactionDetail>[];
      json['transactionDetails'].forEach((v) {
        transactionDetails!.add(TransactionDetail.fromJson(v));
      });
    }
    cashCreditSales = json['cashCreditSales'] != null
        ? CashCreditSales.fromJson(json['cashCreditSales'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (transactionDetails != null) {
      data['transactionDetails'] =
          transactionDetails!.map((v) => v.toJson()).toList();
    }
    if (cashCreditSales != null) {
      data['cashCreditSales'] = cashCreditSales!.toJson();
    }

    return data;
  }
}

class TransactionDetail {
  String? transactionDate;
  String? invoiceNumber;
  String? internalId;
  String? customerName;
  String? salesRep;
  String? invoiceType;
  // ignore: non_constant_identifier_names
  String? InvoiceValue;
  String? invoiceLink;

  TransactionDetail({
    this.transactionDate,
    this.invoiceNumber,
    this.internalId,
    this.customerName,
    this.salesRep,
    this.invoiceType,
    // ignore: non_constant_identifier_names
    this.InvoiceValue,
    this.invoiceLink,
  });

  TransactionDetail.fromJson(Map<String, dynamic> json) {
    transactionDate = json['transactionDate'];
    invoiceNumber = json['invoiceNumber'];
    internalId = json['internalId'];
    customerName = json['customerName'];
    salesRep = json['salesRep'];
    invoiceType = json['invoiceType'];
    InvoiceValue = json['InvoiceValue'];
    invoiceLink = json['invoiceLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['transactionDate'] = transactionDate;
    data['invoiceNumber'] = invoiceNumber;
    data['internalId'] = internalId;
    data['customerName'] = customerName;
    data['salesRep'] = salesRep;
    data['invoiceType'] = invoiceType;
    data['InvoiceValue'] = InvoiceValue;
    data['invoiceLink'] = invoiceLink;
    return data;
  }

  static List<TransactionDetail> listFromJson(List<dynamic> json) {
    return json.map((data) => TransactionDetail.fromJson(data)).toList();
  }
}

class CashCreditSales {
  String? cashSaleAmount;
  String? creditSaleAmount;
  int? totalCustomerVisits;

  CashCreditSales({
    this.cashSaleAmount,
    this.creditSaleAmount,
    this.totalCustomerVisits,
  });

  CashCreditSales.fromJson(Map<String, dynamic> json) {
    cashSaleAmount = json['cashSaleAmount'];
    creditSaleAmount = json['creditSaleAmount'];
    totalCustomerVisits = json['totalCustomerVisits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['cashSaleAmount'] = cashSaleAmount;
    data['creditSaleAmount'] = creditSaleAmount;
    data['totalCustomerVisits'] = totalCustomerVisits;
    return data;
  }
}

class DailyTransaction {
  String? date;
  int? transactionCount;
  double? totalAmount;

  DailyTransaction({
    this.date,
    this.transactionCount,
    this.totalAmount,
  });

  DailyTransaction.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    transactionCount = json['transactionCount'];
    totalAmount = json['totalAmount']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['date'] = date;
    data['transactionCount'] = transactionCount;
    data['totalAmount'] = totalAmount;
    return data;
  }
}

class DailyTransactions {
  List<DailyTransaction>? transactions;

  DailyTransactions({this.transactions});

  DailyTransactions.fromJson(List<dynamic> jsonList) {
    transactions =
        jsonList.map((json) => DailyTransaction.fromJson(json)).toList();
  }

  List<Map<String, dynamic>> toJson() {
    return transactions?.map((transaction) => transaction.toJson()).toList() ??
        [];
  }
}
