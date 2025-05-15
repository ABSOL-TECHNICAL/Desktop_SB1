class ViewOrderDetails {
  String? documentNumber;
  String? documentDate;
  String? item;
  int? totalQuantity;
  int? quantityBilled;
  int? quantityCommitted;
  int? quantityFulfilled;
  String? supplier;

  ViewOrderDetails({
    this.documentNumber,
    this.documentDate,
    this.item,
    this.totalQuantity,
    this.quantityBilled,
    this.quantityCommitted,
    this.quantityFulfilled,
    this.supplier,
  });

  ViewOrderDetails.fromJson(Map<String, dynamic> json) {
    documentNumber = json['DocumentNumber'];
    documentDate = json['DocumentDate'];
    item = json['Item'];
    totalQuantity = int.tryParse(json['TotalQuantity'].toString()) ?? 0;
    quantityBilled = int.tryParse(json['QuantityBilled'].toString()) ?? 0;
    quantityCommitted = int.tryParse(json['QuantityCommitted'].toString()) ?? 0;
    quantityFulfilled = int.tryParse(json['QuantityFulfilled'].toString()) ?? 0;
    supplier = json['Supplier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DocumentNumber'] = documentNumber;
    data['DocumentDate'] = documentDate;
    data['Item'] = item;
    data['TotalQuantity'] = totalQuantity.toString();
    data['QuantityBilled'] = quantityBilled.toString();
    data['QuantityCommitted'] = quantityCommitted.toString();
    data['QuantityFulfilled'] = quantityFulfilled.toString();
    data['Supplier'] = supplier;
    return data;
  }
}

class ViewOrderModel {
  List<ViewOrderDetails>? defaultInvoiceDetails;
  List<ViewOrderDetails>? viewInvoiceDetails;

  ViewOrderModel({this.defaultInvoiceDetails, this.viewInvoiceDetails});

  ViewOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['defaultInvoiceDetails'] != null) {
      defaultInvoiceDetails = <ViewOrderDetails>[];
      json['defaultInvoiceDetails'].forEach((v) {
        defaultInvoiceDetails!.add(ViewOrderDetails.fromJson(v));
      });
    }
    if (json['viewInvoiceDetails'] != null) {
      viewInvoiceDetails = <ViewOrderDetails>[];
      json['viewInvoiceDetails'].forEach((v) {
        viewInvoiceDetails!.add(ViewOrderDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (defaultInvoiceDetails != null) {
      data['defaultInvoiceDetails'] =
          defaultInvoiceDetails!.map((v) => v.toJson()).toList();
    }
    if (viewInvoiceDetails != null) {
      data['viewInvoiceDetails'] =
          viewInvoiceDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
