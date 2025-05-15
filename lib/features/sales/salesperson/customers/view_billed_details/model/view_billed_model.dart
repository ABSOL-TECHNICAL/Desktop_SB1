class ViewBilledDetail {
  String? docNo;
  String? docDate;
  String? customerName;
  List<Items>? items;

  ViewBilledDetail({this.docNo, this.docDate, this.items, this.customerName});

  ViewBilledDetail.fromJson(Map<String, dynamic> json) {
    try {
      docNo = json['DocNo'];
      docDate = json['DocDate'];
      customerName = json['customerName'];
      print(
          'Parsing ViewBilledDetail - DocNo: $docNo, DocDate: $docDate, customerName: $customerName');

      if (json['Items'] != null) {
        items = (json['Items'] as List)
            .map((item) => Items.fromJson(item))
            .toList();
      }
    } catch (e, stackTrace) {
      print('Error parsing ViewBilledDetail: $e');
      print('StackTrace: $stackTrace');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'DocNo': docNo,
      'DocDate': docDate,
      'customerName': customerName,
      if (items != null) 'Items': items!.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'DocNo: $docNo, DocDate: $docDate, Items: $items';
  }
}

class Items {
  String? part;
  String? qty;
  String? unitPrice;
  String? salesPrice;
  String? totalPrice; // Keep as String

  Items({
    this.part,
    this.qty,
    this.unitPrice,
    this.salesPrice,
    this.totalPrice,
  });

  Items.fromJson(Map<String, dynamic> json) {
    try {
      part = json['Part'];
      qty = json['Qty'];
      unitPrice = json['UnitPrice'];
      salesPrice = json['SalesPrice'];
      // Ensure that totalPrice is a string, even if it comes as int
      totalPrice = json['TotalPrice'].toString(); // Convert to String

      print(
          'Parsed Item - Part: $part, Qty: $qty, UnitPrice: $unitPrice, TotalPrice: $totalPrice');
    } catch (e, stackTrace) {
      print('Error parsing Item: $e');
      print('StackTrace: $stackTrace');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Part': part,
      'Qty': qty,
      'UnitPrice': unitPrice,
      'SalesPrice': salesPrice,
      'TotalPrice': totalPrice,
    };
  }

  @override
  String toString() {
    return 'Part: $part, Qty: $qty, UnitPrice: $unitPrice, SalesPrice: $salesPrice, TotalPrice: $totalPrice';
  }
}
