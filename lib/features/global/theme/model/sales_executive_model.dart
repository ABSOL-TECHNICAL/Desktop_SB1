class SalesExecutiveModel {
  String? salesManID;
  String? salesManName;

  SalesExecutiveModel({this.salesManID, this.salesManName});

  SalesExecutiveModel.fromJson(Map<String, dynamic> json) {
    salesManID = json['SalesManID'];
    salesManName = json['SalesManName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SalesManID'] = salesManID;
    data['SalesManName'] = salesManName;
    return data;
  }
    static List<SalesExecutiveModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => SalesExecutiveModel.fromJson(json)).toList();
}
}