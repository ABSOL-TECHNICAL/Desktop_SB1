class EcreditLoginBranch {
  List<Branches>? branches;
  String? mailID;
  String? creditLimitlevel;
  String? validateIndicator;

  EcreditLoginBranch(
      {this.branches,
      this.mailID,
      this.creditLimitlevel,
      this.validateIndicator});

  EcreditLoginBranch.fromJson(Map<String, dynamic> json) {
    if (json['Branches'] != null) {
      branches = <Branches>[];
      json['Branches'].forEach((v) {
        branches!.add(Branches.fromJson(v));
      });
    }
    mailID = json['MailID'];
    creditLimitlevel = json['CreditLimitlevel'];
    validateIndicator = json['ValidateIndicator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (branches != null) {
      data['Branches'] = branches!.map((v) => v.toJson()).toList();
    }
    data['MailID'] = mailID;
    data['CreditLimitlevel'] = creditLimitlevel;
    data['ValidateIndicator'] = validateIndicator;
    return data;
  }
}

class Branches {
  String? branchId;
  String? branchName;

  Branches({this.branchId, this.branchName});

  Branches.fromJson(Map<String, dynamic> json) {
    branchId = json['branchId'];
    branchName = json['branchName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['branchId'] = branchId;
    data['branchName'] = branchName;
    return data;
  }
}
