class FromLocation {
  String? locationid;
  String? locationName;
  double? latitude;
  double? longitude;

  FromLocation(
      {this.locationid, this.locationName, this.latitude, this.longitude});

  FromLocation.fromJson(Map<String, dynamic> json) {
    locationid = json['locationid'];
    locationName = json['locationName'];
    latitude = json['latitude']?.isEmpty ?? true
        ? null
        : double.tryParse(json['latitude'] ?? '0.0');
    longitude = json['longitude']?.isEmpty ?? true
        ? null
        : double.tryParse(json['longitude'] ?? '0.0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['locationid'] = locationid;
    data['locationName'] = locationName;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class DefaulBranchstock {
  final String toNumber;
  final String supplierName;
  final String itemName;
  final int quantity;
  final String lRDate;
  final String location; // New field

  DefaulBranchstock({
    required this.toNumber,
    required this.supplierName,
    required this.itemName,
    required this.quantity,
    required this.lRDate,
    required this.location, // Include the new field in the constructor
  });

  DefaulBranchstock.fromJson(Map<String, dynamic> json)
      : toNumber = json['To Number'] ?? 'Null',
        supplierName = json['Supplier Name'] ?? 'Null',
        itemName = json['Item Name'] ?? 'Null',
        quantity = json['Quantity'] ?? 'Null',
        lRDate = json['LR Date'] ?? 'Null',
        location = json['Location'] ?? 'Null'; // Parse the location field

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['To Number'] = toNumber;
    data['Supplier Name'] = supplierName;
    data['Item Name'] = itemName;
    data['Quantity'] = quantity;
    data['LR Date'] = lRDate;
    data['Location'] = location; // Include the location field in the JSON
    return data;
  }
}
