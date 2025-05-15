class BranchModel {
  int? locationId;
  String? locationName;

  BranchModel({this.locationId, this.locationName});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      locationId: json['locationId'],
      locationName: json['locationName'],
    );
  }
}
