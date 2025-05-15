class Branch {
  String? branchId;
  String? branchName;

  Branch({this.branchId, this.branchName});

  Branch.fromJson(Map<String, dynamic> json) {
    branchId = json['BranchId'];
    branchName = json['BranchName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BranchId'] = branchId;
    data['BranchName'] = branchName;
    return data;
  }
}