class StateDetail {
  final String stateId;
  final String stateName;

  StateDetail({required this.stateId, required this.stateName});

  factory StateDetail.fromJson(Map<String, dynamic> json) {
    return StateDetail(
      stateId: json['StateId'].toString(), // Convert to String
      stateName: json['StateName'].toString(),
    );
  }

  static List<StateDetail> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => StateDetail.fromJson(json)).toList();
  }
}

class StockDetail {
  String? location;
  String? availableStock;
  String? unitPrice;
  String? mRP;
  String? vehicleApplication;
  String? applicationSegment;
  String? shortDescription;
  String? productDescription;
  String? balanceQuantity;

  StockDetail({
    this.location,
    this.availableStock,
    this.unitPrice,
    this.mRP,
    this.vehicleApplication,
    this.applicationSegment,
    this.shortDescription,
    this.productDescription,
    this.balanceQuantity,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      location: json['Location']?.toString(),
      availableStock: json['Available Stock']?.toString(),
      unitPrice: json['Unit Price']?.toString(),
      mRP: json['MRP']?.toString(),
      vehicleApplication: json['VehicleApplication']?.toString(),
      applicationSegment: json['ApplicationSegment']?.toString(),
      shortDescription: json['Short Description']?.toString(),
      productDescription: json['Product Description']?.toString(),
      balanceQuantity: json['Balance Quantity']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Location': location,
      'Available Stock': availableStock,
      'Unit Price': unitPrice,
      'MRP': mRP,
      'VehicleApplication': vehicleApplication,
      'ApplicationSegment': applicationSegment,
      'Short Description': shortDescription,
      'Product Description': productDescription,
      'Balance Quantity': balanceQuantity,
    };
  }

  // To parse a list of StockDetails from JSON
  static List<StockDetail> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => StockDetail.fromJson(json)).toList();
  }
}
