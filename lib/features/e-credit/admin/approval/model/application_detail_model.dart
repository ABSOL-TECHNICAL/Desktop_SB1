class ApplicationDetail {
  String? customerID;
  String? dealerName;
  String? getDealer;
  String? dealerId;
  String? phone;
  String? branch;
  String? state;
  String? statename;
  String? zone;
  String? zonename;
  String? firmType;
  String? firmTypetxt;
  String? town;
  Null towntxt;
  String? area;
  String? districtName;
  String? dealerClassification;
  String? classification;
  String? dealerSegment;
  String? dealerSegmenttxt;
  String? localOutstation;
  String? localOutstationtxt;
  String? creditLimit;
  String? enhanceCredit;
  String? salesMan;
  String? salesMantxt;
  String? registrationType;
  String? registrationtxt;
  String? address1;
  String? address2;
  String? gSTTaxRegistration;
  String? gSTTaxRegistrationtxt;
  String? zipcode;
  String? pAN;
  String? contectPerson;
  String? contectNumber;
  String? email;
  String? applicationDate;
  String? fright;
  String? frighttxt;
  String? validatedate;
  String? permanetcredit;
  String? creditlimitindicator;
  String? creditlimitindicatortxt;
  String? validityIndicator;
  String? validityIndicatortxt;

  ApplicationDetail(
      {this.customerID,
      this.dealerName,
      this.getDealer,
      this.dealerId,
      this.phone,
      this.branch,
      this.state,
      this.statename,
      this.zone,
      this.zonename,
      this.firmType,
      this.firmTypetxt,
      this.town,
      this.towntxt,
      this.area,
      this.districtName,
      this.dealerClassification,
      this.classification,
      this.dealerSegment,
      this.dealerSegmenttxt,
      this.localOutstation,
      this.localOutstationtxt,
      this.creditLimit,
      this.enhanceCredit,
      this.salesMan,
      this.salesMantxt,
      this.registrationType,
      this.registrationtxt,
      this.address1,
      this.address2,
      this.gSTTaxRegistration,
      this.gSTTaxRegistrationtxt,
      this.zipcode,
      this.pAN,
      this.contectPerson,
      this.contectNumber,
      this.email,
      this.applicationDate,
      this.fright,
      this.frighttxt,
      this.validatedate,
      this.permanetcredit,
      this.creditlimitindicator,
      this.creditlimitindicatortxt,
      this.validityIndicator,
      this.validityIndicatortxt});

  ApplicationDetail.fromJson(Map<String, dynamic> json) {
    customerID = json['CustomerID'];
    dealerName = json['DealerName'];
    getDealer = json['GetDealer'];
    dealerId = json['DealerId'];
    phone = json['Phone'];
    branch = json['Branch'];
    state = json['State'];
    statename = json['statename'];
    zone = json['Zone'];
    zonename = json['zonename'];
    firmType = json['FirmType'];
    firmTypetxt = json['FirmTypetxt'];
    town = json['Town'];
    towntxt = json['Towntxt'];
    area = json['Area'];
    districtName = json['DistrictName'];
    dealerClassification = json['DealerClassification'];
    classification = json['classification'];
    dealerSegment = json['DealerSegment'];
    dealerSegmenttxt = json['DealerSegmenttxt'];
    localOutstation = json['Local/Outstation'];
    localOutstationtxt = json['Local/Outstationtxt'];
    creditLimit = json['CreditLimit'];
    enhanceCredit = json['enhanceCredit'];
    salesMan = json['SalesMan'];
    salesMantxt = json['SalesMantxt'];
    registrationType = json['RegistrationType'];
    registrationtxt = json['registrationtxt'];
    address1 = json['Address1'];
    address2 = json['Address2'];
    gSTTaxRegistration = json['GSTTaxRegistration'];
    gSTTaxRegistrationtxt = json['GSTTaxRegistrationtxt'];
    zipcode = json['zipcode'];
    pAN = json['PAN'];
    contectPerson = json['ContectPerson'];
    contectNumber = json['ContectNumber'];
    email = json['email'];
    applicationDate = json['ApplicationDate'];
    fright = json['fright'];
    frighttxt = json['frighttxt'];
    validatedate = json['validatedate'];
    permanetcredit = json['Permanetcredit'];
    creditlimitindicator = json['Creditlimitindicator'];
    creditlimitindicatortxt = json['Creditlimitindicatortxt'];
    validityIndicator = json['validityIndicator'];
    validityIndicatortxt = json['validityIndicatortxt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomerID'] = customerID;
    data['DealerName'] = dealerName;
    data['GetDealer'] = getDealer;
    data['DealerId'] = dealerId;
    data['Phone'] = phone;
    data['Branch'] = branch;
    data['State'] = state;
    data['statename'] = statename;
    data['Zone'] = zone;
    data['zonename'] = zonename;
    data['FirmType'] = firmType;
    data['FirmTypetxt'] = firmTypetxt;
    data['Town'] = town;
    data['Towntxt'] = towntxt;
    data['Area'] = area;
    data['DistrictName'] = districtName;
    data['DealerClassification'] = dealerClassification;
    data['classification'] = classification;
    data['DealerSegment'] = dealerSegment;
    data['DealerSegmenttxt'] = dealerSegmenttxt;
    data['Local/Outstation'] = localOutstation;
    data['Local/Outstationtxt'] = localOutstationtxt;
    data['CreditLimit'] = creditLimit;
    data['enhanceCredit'] = enhanceCredit;
    data['SalesMan'] = salesMan;
    data['SalesMantxt'] = salesMantxt;
    data['RegistrationType'] = registrationType;
    data['registrationtxt'] = registrationtxt;
    data['Address1'] = address1;
    data['Address2'] = address2;
    data['GSTTaxRegistration'] = gSTTaxRegistration;
    data['GSTTaxRegistrationtxt'] = gSTTaxRegistrationtxt;
    data['zipcode'] = zipcode;
    data['PAN'] = pAN;
    data['ContectPerson'] = contectPerson;
    data['ContectNumber'] = contectNumber;
    data['email'] = email;
    data['ApplicationDate'] = applicationDate;
    data['fright'] = fright;
    data['frighttxt'] = frighttxt;
    data['validatedate'] = validatedate;
    data['Permanetcredit'] = permanetcredit;
    data['Creditlimitindicator'] = creditlimitindicator;
    data['Creditlimitindicatortxt'] = creditlimitindicatortxt;
    data['validityIndicator'] = validityIndicator;
    data['validityIndicatortxt'] = validityIndicatortxt;
    return data;
  }
}
