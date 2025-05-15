class ApplicationName {
  String? customer;
  String? delarID;
 
  ApplicationName({this.customer, this.delarID});
 
  ApplicationName.fromJson(Map<String, dynamic> json) {
    customer = json['Customer'];
    delarID = json['DelarID'];
  }
 
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Customer'] = customer;
    data['DelarID'] = delarID;
    return data;
  }
}
 
 