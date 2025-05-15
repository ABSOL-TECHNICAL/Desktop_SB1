class BranchLocation {
  String? branchId;
  String? branchName;

  BranchLocation({this.branchId, this.branchName});

  BranchLocation.fromJson(Map<String, dynamic> json) {
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

class DealerNameData {
  String? customerID;
  String? dealerId;
  String? dealerName;

  DealerNameData({this.customerID, this.dealerId, this.dealerName});

  DealerNameData.fromJson(Map<String, dynamic> json) {
    customerID = json['CustomerID'];
    dealerId = json['DealerId'];
    dealerName = json['DealerName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomerID'] = customerID;
    data['DealerId'] = dealerId;
    data['DealerName'] = dealerName;
    return data;
  }
}

class ApplicationData {
  String? dealerId;
  String? customerID;
  String? name;
  String? defaultTaxReg;
  String? address1;
  String? address2;
  String? zipCode;
  String? pAN;
  String? dealerName;
  String? phone;
  String? branch;
  String? branchName;
  String? stateId;
  String? stateName;
  String? firmType;
  String? firmTypeName;
  String? town;
  String? townText;
  String? area;
  String? districtName;
  String? dealerClassification;
  String? dealerClassificationName;
  String? dealerSegment;
  String? dealerSegmentName;
  String? zone;
  String? zoneName;
  String? localOutstation;
  String? localOutstationName;
  String? creditLimit;
  String? salesMan;
  String? salesManname;
  String? registrationType;
  String? registrationTypeName;
  String? contactPersonNumber;
  String? contactPerson;
  String? email;
  String? fright;
  String? frightName;
  String? creditlimitindicator;
  String? permanentcrdlimt;
  String? validatedate;
  String? validityIndicator;
  String? validityIndicatorName;
  String? enhanceCredit;
  String? applicationDate;
  String? addressid;

  ApplicationData({
    this.dealerId,
    this.customerID,
    this.name,
    this.defaultTaxReg,
    this.address1,
    this.address2,
    this.zipCode,
    this.pAN,
    this.dealerName,
    this.phone,
    this.branch,
    this.branchName,
    this.stateId,
    this.stateName,
    this.firmType,
    this.firmTypeName,
    this.town,
    this.townText,
    this.area,
    this.districtName,
    this.dealerClassification,
    this.dealerClassificationName,
    this.dealerSegment,
    this.dealerSegmentName,
    this.zone,
    this.zoneName,
    this.localOutstation,
    this.localOutstationName,
    this.creditLimit,
    this.salesMan,
    this.salesManname,
    this.registrationType,
    this.registrationTypeName,
    this.contactPersonNumber,
    this.contactPerson,
    this.email,
    this.fright,
    this.frightName,
    this.creditlimitindicator,
    this.permanentcrdlimt,
    this.validatedate,
    this.validityIndicator,
    this.validityIndicatorName,
    this.enhanceCredit,
    this.applicationDate,
    this.addressid,
  });

  ApplicationData.fromJson(Map<String, dynamic> json) {
    dealerId = json['dealerId'];
    customerID = json['customerID'];
    name = json['Name'];
    defaultTaxReg = json['DefaultTaxReg'];
    address1 = json['Address1'];
    address2 = json['Address2'];
    zipCode = json['ZipCode'];
    pAN = json['PAN'];
    dealerName = json['DealerName'];
    phone = json['Phone'];
    branch = json['Branch'];
    branchName = json['branchName'];
    stateId = json['State'];
    stateName = json['stateName'];
    firmType = json['FirmType'];
    firmTypeName = json['firmTypeName'];
    town = json['Town'];
    townText = json['TownText'];
    area = json['Area'];
    districtName = json['DistrictName'];
    dealerClassification = json['DealerClassification'];
    dealerClassificationName = json['dealerClassificationName'];
    dealerSegment = json['DealerSegment'];
    dealerSegmentName = json['dealerSegmentName'];
    zone = json['Zone'];
    zoneName = json['zoneName'];
    localOutstation = json['Local/Outstation'];
    localOutstationName = json['localOutstationName'];
    creditLimit = json['CreditLimit'];
    salesMan = json['SalesMan'];
    salesManname = json['SalesManname'];
    registrationType = json['RegistrationType'];
    registrationTypeName = json['RegistrationTypeName'];
    contactPersonNumber = json['Contact Person Number'];
    contactPerson = json['Contact Person'];
    email = json['Email'];
    fright = json['fright'];
    frightName = json['frightName'];
    creditlimitindicator = json['Creditlimitindicator'];
    permanentcrdlimt = json['Permanentcrdlimt'];
    validatedate = json['validatedate'];
    validityIndicator = json['validityIndicator'];
    validityIndicatorName = json['validityIndicatorName'];
    enhanceCredit = json['enhanceCredit'];
    applicationDate = json['ApplicationDate'];
    addressid = json['AddressID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dealerId'] = dealerId;
    data['customerID'] = customerID;
    data['Name'] = name;
    data['DefaultTaxReg'] = defaultTaxReg;
    data['Address1'] = address1;
    data['Address2'] = address2;
    data['ZipCode'] = zipCode;
    data['PAN'] = pAN;
    data['DealerName'] = dealerName;
    data['Phone'] = phone;
    data['Branch'] = branch;
    data['branchName'] = branchName;
    data['State'] = stateId;
    data['stateName'] = stateName;
    data['FirmType'] = firmType;
    data['firmTypeName'] = firmTypeName;
    data['Town'] = town;
    data['TownText'] = townText;
    data['Area'] = area;
    data['DistrictName'] = districtName;
    data['DealerClassification'] = dealerClassification;
    data['dealerClassificationName'] = dealerClassificationName;
    data['DealerSegment'] = dealerSegment;
    data['dealerSegmentName'] = dealerSegmentName;
    data['Zone'] = zone;
    data['zoneName'] = zoneName;
    data['Local/Outstation'] = localOutstation;
    data['localOutstationName'] = localOutstationName;
    data['CreditLimit'] = creditLimit;
    data['SalesMan'] = salesMan;
    data['SalesManname'] = salesManname;
    data['RegistrationType'] = registrationType;
    data['RegistrationTypeName'] = registrationTypeName;
    data['Contact Person Number'] = contactPersonNumber;
    data['Contact Person'] = contactPerson;
    data['Email'] = email;
    data['fright'] = fright;
    data['frightName'] = frightName;
    data['Creditlimitindicator'] = creditlimitindicator;
    data['Permanentcrdlimt'] = permanentcrdlimt;
    data['validatedate'] = validatedate;
    data['validityIndicator'] = validityIndicator;
    data['validityIndicatorName'] = validityIndicatorName;
    data['enhanceCredit'] = enhanceCredit;
    data['ApplicationDate'] = applicationDate;
    data['AddressID'] = addressid;
    return data;
  }
}

class DealerCode {
  String? dealerCode;
  String? creditLimit;

  DealerCode({this.dealerCode, this.creditLimit});

  DealerCode.fromJson(Map<String, dynamic> json) {
    dealerCode = json['DealerCode'];
    creditLimit = json['CreditLimit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DealerCode'] = dealerCode;
    data['CreditLimit'] = creditLimit;

    return data;
  }
}

class SalesManName {
  String? salesManID;
  String? salesManName;

  SalesManName({this.salesManID, this.salesManName});

  SalesManName.fromJson(Map<String, dynamic> json) {
    salesManID = json['SalesManId'];
    salesManName = json['SalesManName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DealerCode'] = salesManID;
    data['CreditLimit'] = salesManName;

    return data;
  }
}

class SlbTown {
  String? slbTownId;
  String? slbTownName;

  SlbTown({this.slbTownId, this.slbTownName});

  SlbTown.fromJson(Map<String, dynamic> json) {
    slbTownId = json['SlbTownId'];
    slbTownName = json['SlbTownName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SlbTownId'] = slbTownId;
    data['SlbTownName'] = slbTownName;

    return data;
  }
}

class PeriodVisit {
  String? periodVisitId;
  String? periodVisitName;

  PeriodVisit({this.periodVisitId, this.periodVisitName});

  PeriodVisit.fromJson(Map<String, dynamic> json) {
    periodVisitId = json['PeriodVisitId'];
    periodVisitName = json['PeriodVisitName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PeriodVisitId'] = periodVisitId;
    data['PeriodVisitName'] = periodVisitName;
    return data;
  }
}

class GstLocation {
  bool? success;
  List<Data>? data;

  GstLocation({this.success, this.data});

  GstLocation.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;

  Data({this.id, this.name});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class DealerClassification {
  String? dealerClassId;
  String? dealerClassName;

  DealerClassification({this.dealerClassId, this.dealerClassName});

  DealerClassification.fromJson(Map<String, dynamic> json) {
    dealerClassId = json['DealerClassId'];
    dealerClassName = json['DealerClassName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DealerClassId'] = dealerClassId;
    data['DealerClassName'] = dealerClassName;

    return data;
  }
}

class DealerSegment {
  String? dealerBusSegId;
  String? dealerBussegName;

  DealerSegment({this.dealerBusSegId, this.dealerBussegName});

  DealerSegment.fromJson(Map<String, dynamic> json) {
    dealerBusSegId = json['DealerBusSegId'];
    dealerBussegName = json['DealerBussegName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DealerBusSegId'] = dealerBusSegId;
    data['DealerBussegName'] = dealerBussegName;

    return data;
  }
}

class TypeofFirm {
  String? typeFirmID;
  String? typeFirmName;

  TypeofFirm({this.typeFirmID, this.typeFirmName});

  TypeofFirm.fromJson(Map<String, dynamic> json) {
    typeFirmID = json['TypeFirmID'];
    typeFirmName = json['TypeFirmName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TypeFirmID'] = typeFirmID;
    data['TypeFirmName'] = typeFirmName;

    return data;
  }
}

class TypeofReg {
  bool? success;
  List<Data>? data;

  TypeofReg({this.success, this.data});

  TypeofReg.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Reg {
  int? id;
  String? name;

  Reg({this.id, this.name});

  Reg.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class DealerState {
  String? stateId;
  String? stateName;

  DealerState({this.stateId, this.stateName});

  DealerState.fromJson(Map<String, dynamic> json) {
    stateId = json['StateId'];
    stateName = json['StateName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['StateId'] = stateId;
    data['StateName'] = stateName;

    return data;
  }
}

class DealerDistrict {
  String? dealerDistrict;

  DealerDistrict({this.dealerDistrict});

  DealerDistrict.fromJson(Map<String, dynamic> json) {
    dealerDistrict = json['DealerDistrict'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['DealerDistrict'] = dealerDistrict;

    return data;
  }
}

class TownLocation {
  bool? success;
  List<Data>? data;

  TownLocation({this.success, this.data});

  TownLocation.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TownLoc {
  int? id;
  String? name;

  TownLoc({this.id, this.name});

  TownLoc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Zone {
  bool? success;
  List<Data>? data;

  Zone({this.success, this.data});

  Zone.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Zzone {
  int? id;
  String? name;

  Zzone({this.id, this.name});

  Zzone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Creditlimitindicator {
  bool? success;
  List<Data>? data;

  Creditlimitindicator({this.success, this.data});

  Creditlimitindicator.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Creditlimitindi {
  int? id;
  String? name;

  Creditlimitindi({this.id, this.name});

  Creditlimitindi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class FreightIndicator {
  bool? success;
  List<Data>? data;

  FreightIndicator({this.success, this.data});

  FreightIndicator.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Freightindi {
  int? id;
  String? name;

  Freightindi({this.id, this.name});

  Freightindi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ValidityIndicator {
  bool? success;
  List<Data>? data;

  ValidityIndicator({this.success, this.data});

  ValidityIndicator.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Validityindi {
  int? id;
  String? name;

  Validityindi({this.id, this.name});

  Validityindi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
