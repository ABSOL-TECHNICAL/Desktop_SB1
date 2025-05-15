class AddressState {
  String? addressstateID;
  String? name;
  String? fullname;

  AddressState({this.addressstateID, this.name, this.fullname});

  AddressState.fromJson(Map<String, dynamic> json) {
    addressstateID = json['AddressstateID'];
    name = json['Name'];
    fullname = json['FullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AddressstateID'] = addressstateID;
    data['Name'] = name;
    data['FullName'] = fullname;
    return data;
  }
}
