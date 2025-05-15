class ApplicationDetails {
  String? name;
  String? defaultTaxReg;
  String? address1;
  String? address2;
  String? zipCode;
  String? pAN;
  String? dealerName;
  String? phone;
  String? branch;
  String? state;
  String? statename;
  String? firmType;
  String? town;
  String? area;
  String? districtName;
  String? dealerClassification;
  String? dealerSegment;
  String? zone;
  String? localOutstation;
  String? creditLimit;
  String? salesMan;
  String? registrationType;
  String? contactPersonNumber;
  String? contactPerson;
  String? email;
  String? fright;
  String? creditlimitindicator;
  String? permanentcrdlimt;
  String? validatedate;
  String? validityIndicator;

  ApplicationDetails(
      {this.name,
      this.defaultTaxReg,
      this.address1,
      this.address2,
      this.zipCode,
      this.pAN,
      this.dealerName,
      this.phone,
      this.branch,
      this.state,
      this.statename,
      this.firmType,
      this.town,
      this.area,
      this.districtName,
      this.dealerClassification,
      this.dealerSegment,
      this.zone,
      this.localOutstation,
      this.creditLimit,
      this.salesMan,
      this.registrationType,
      this.contactPersonNumber,
      this.contactPerson,
      this.email,
      this.fright,
      this.creditlimitindicator,
      this.permanentcrdlimt,
      this.validatedate,
      this.validityIndicator});

  ApplicationDetails.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    defaultTaxReg = json['DefaultTaxReg'];
    address1 = json['Address1'];
    address2 = json['Address2'];
    zipCode = json['ZipCode'];
    pAN = json['PAN'];
    dealerName = json['DealerName'];
    phone = json['Phone'];
    branch = json['Branch'];
    state = json['State'];
    statename = json['statename'];
    firmType = json['FirmType'];
    town = json['Town'];
    area = json['Area'];
    districtName = json['DistrictName'];
    dealerClassification = json['DealerClassification'];
    dealerSegment = json['DealerSegment'];
    zone = json['Zone'];
    localOutstation = json['Local/Outstation'];
    creditLimit = json['CreditLimit'];
    salesMan = json['SalesMan'];
    registrationType = json['RegistrationType'];
    contactPersonNumber = json['Contact Person Number'];
    contactPerson = json['Contact Person'];
    email = json['Email'];
    fright = json['fright'];
    creditlimitindicator = json['Creditlimitindicator'];
    permanentcrdlimt = json['Permanentcrdlimt'];
    validatedate = json['validatedate'];
    validityIndicator = json['validityIndicator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['DefaultTaxReg'] = defaultTaxReg;
    data['Address1'] = address1;
    data['Address2'] = address2;
    data['ZipCode'] = zipCode;
    data['PAN'] = pAN;
    data['DealerName'] = dealerName;
    data['Phone'] = phone;
    data['Branch'] = branch;
    data['State'] = state;
    data['statename'] = statename;
    data['FirmType'] = firmType;
    data['Town'] = town;
    data['Area'] = area;
    data['DistrictName'] = districtName;
    data['DealerClassification'] = dealerClassification;
    data['DealerSegment'] = dealerSegment;
    data['Zone'] = zone;
    data['Local/Outstation'] = localOutstation;
    data['CreditLimit'] = creditLimit;
    data['SalesMan'] = salesMan;
    data['RegistrationType'] = registrationType;
    data['Contact Person Number'] = contactPersonNumber;
    data['Contact Person'] = contactPerson;
    data['Email'] = email;
    data['fright'] = fright;
    data['Creditlimitindicator'] = creditlimitindicator;
    data['Permanentcrdlimt'] = permanentcrdlimt;
    data['validatedate'] = validatedate;
    data['validityIndicator'] = validityIndicator;
    return data;
  }
}