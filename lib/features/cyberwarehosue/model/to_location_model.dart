class FromCyberLocation {
  String? locationid;
  String? locationName;
  double? latitude;
  double? longitude;

  FromCyberLocation(
      {this.locationid, this.locationName, this.latitude, this.longitude});

  FromCyberLocation.fromJson(Map<String, dynamic> json) {
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
