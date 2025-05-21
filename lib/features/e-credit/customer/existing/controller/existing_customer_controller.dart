import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:impal_desktop/features/e-credit/customer/existing/model/existing_customer_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/scripts/netsuite_end_point.dart';
import 'package:impal_desktop/features/services/url/e_credit_url.dart';

class ExistingcustomerController extends GetxController {
  final EcreditRestletService _restletService =
      EcreditRestletService(); // Define the service
  var showCustomerID = false.obs; // Set to true to show the field
  var branchLocation = <BranchLocation>[].obs;
  // var branchid = <BranchLocation>[].obs;
  var dealernnamedata = <DealerNameData>[].obs;
  var dealerNamedata = <DealerNameData>[].obs;
  var dealercodedata = <DealerCode>[].obs;
  var dealerCode = ''.obs; // Holds dealer code from API
  var creditLimit = ''.obs; // Holds credit limit from API
  var dealerId = ''.obs; // Stores selected Dealer ID
  RxList<dynamic> outstandingDetails = <dynamic>[].obs;
  RxMap<String, dynamic> selectedCustomer = RxMap<String, dynamic>();
  var selectedYesNo =
      Rxn<String>(); // ✅ Correct way to define a nullable observable string
  RxString selectedDate = ''.obs; // Store the selected date

  var customerId = ''.obs; // Stores selected Customer ID

  var applicationdata = <ApplicationData>[].obs;
  Rx<DealerNameData?> selecteddealer =
      Rx<DealerNameData?>(null); // For Dealer Name selection
  Rx<DealerNameData?> selectedDealerForCode =
      Rx<DealerNameData?>(null); // For Dealer Code selection

  var showDropdown = true.obs; // Add this observable

  RxString selectedBranchId = ''.obs; // Stores selected branch ID
  var isLoadingss = false.obs;

  var selectedSalesman = Rxn<SalesManName?>(null);
  var salesmandata = <SalesManName>[].obs; // Store fetched salesmen list
  var isLoadingsalesman = false.obs;

  var periodVisitList = <PeriodVisit>[].obs; // Stores dropdown options
  var selectedPeriodVisit = Rxn<PeriodVisit>(); // Stores selected value
  var isLoadingperiodofvisit = false.obs;

  var gstlocation = <Data>[].obs; // Holds the List<Data>
  var selectedgstlocation = Rxn<Data?>(); // Holds the selected dropdown item
  var isLoadinggstlocation = false.obs;

  var dealerclassify = <DealerClassification>[].obs; // Holds the List<Data>
  var selecteddealerclassify = Rxn<DealerClassification?>(null);
  var isLoadingclassify = false.obs;

  var dealersegment = <DealerSegment>[].obs; // Holds the List<Data>
  var selecteddealersegment = Rxn<DealerSegment?>(null);
  var isLoadingsegment = false.obs;

  var typeofFirm = <TypeofFirm>[].obs; // Holds the List<Data>
  var selectedtypeofFirm = Rxn<TypeofFirm?>(null);
  var isLoadingtypeoffirm = false.obs;

  var typeofReg = <Reg>[].obs; // Holds the List<Data>
  var selectedtypeofReg = Rxn<Reg?>(null);
  var isLoadingtypeofreg = false.obs;

  var dealerstate = <DealerState>[].obs; // Holds the List<Data>
  var selecteddealerstate = Rxn<DealerState?>(null);
  var isLoadingstate = false.obs;

  var dealerslbtown = <SlbTown>[].obs; // Holds the List<Data>
  var selectedSlbTown = Rxn<SlbTown?>(null);
  var isLoadingslbtown = false.obs;

  var dealerdistrict = <DealerDistrict>[].obs; // Holds the List<Data>
  var selecteddealerdistrict = Rxn<DealerDistrict?>(null);
  var isLoadingdistrict = false.obs;

  var dealerzone = <Zzone>[].obs; // Holds the List<Data>
  var selecteddealerzone = Rxn<Zzone?>(null);
  var isLoadingszone = false.obs;

  var dealertownlocation = <TownLoc>[].obs; // Holds the List<Data>
  var selecteddealertownlocation = Rxn<TownLoc?>(null);
  var isLoadingtownlocation = false.obs;

  var creditlimitindicator = <Creditlimitindi>[].obs; // Holds the List<Data>
  var selectedcreditlimitindicator = Rxn<Creditlimitindi?>(null);
  var isLoadingcreditlimitinid = false.obs;

  var freightindictaor = <Freightindi>[].obs; // Holds the List<Data>
  var selectedfreightindicator = Rxn<Freightindi?>(null);
  var isLoadingfreightindi = false.obs;

  var validityindicator = <Validityindi>[].obs;
  var selectedvalidityindicator = Rxn<Validityindi?>(null);
  var isLoadingvalidityindi = false.obs;

  var isLoadings = false.obs; // Loading state
  

  var isEmailValid = true.obs; // Observable to track validity
  // In your ExistingcustomerController
// Error state variables
var hasDealerError = false.obs;
var hasAddress1Error = false.obs;
// var hasAddress2Error = false.obs;
var hasZipcodeError = false.obs;
var hasPhoneError = false.obs;
var hasPropertierError = false.obs;
var hasEmailError = false.obs;
var hasPanError = false.obs;
var hasEnhanceError = false.obs;
var hasStateError = false.obs;
var hasDistrictError = false.obs;
var hasTownError = false.obs;
var hasTownLocationError = false.obs;
var hasZoneError = false.obs;
var hasTypeOfFirmError = false.obs;
var hasTypeOfRegError = false.obs;
var hasSalesmanError = false.obs;
var hasDealerClassifyError = false.obs;
var hasDealerSegmentError = false.obs;
var hasCreditLimitIndicatorError = false.obs;
var hasValidityIndicatorError = false.obs;
var hasFreightIndicatorError = false.obs;

void resetErrorStates() {
  hasDealerError.value = false;
  hasAddress1Error.value = false;

  hasZipcodeError.value = false;
  hasPhoneError.value = false;
  hasPropertierError.value = false;
  hasEmailError.value = false;
  hasPanError.value = false;
  hasEnhanceError.value = false;
  hasStateError.value = false;
  hasDistrictError.value = false;
  hasTownError.value = false;
  hasTownLocationError.value = false;
  hasZoneError.value = false;
  hasTypeOfFirmError.value = true;
  hasTypeOfRegError.value = false;
  hasSalesmanError.value = false;
  hasDealerClassifyError.value = false;
  hasDealerSegmentError.value = false;
  hasCreditLimitIndicatorError.value = false;
  hasValidityIndicatorError.value = false;
  hasFreightIndicatorError.value = false;
}

  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController enhanceController = TextEditingController();
  TextEditingController propertierController = TextEditingController();
  TextEditingController contactpersonController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController dealerController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _restletService.init();
    fetchSlbTown();
  }
  Future<void> refreshData() async {
  try {
    // Clear all selections and reload necessary data
     selecteddealer.value = null;
    selectedDealerForCode.value = null;
    dealerId.value = '';
    customerId.value = '';
    dealernnamedata.clear();
    dealerNamedata.clear();
    dealercodedata.clear();
    selectedDealerForCode.value=null;
    selectedBranchId.value = '';
    selecteddealer.value=null;
    selectedCustomer.value ={};
    selectedPeriodVisit.value = null;
    selectedSalesman.value = null;
    selectedSlbTown.value = null;
    selectedcreditlimitindicator.value =null;
    selecteddealerclassify.value =null;
    selecteddealerdistrict.value=null;
    selecteddealersegment.value =null;
    selecteddealerstate.value =null;
    selecteddealertownlocation.value =null;
    selecteddealerzone.value= null ;
    selectedfreightindicator.value=null;
    // dealernnamedata.clear();
    
       // Force UI update
    dealernnamedata.refresh();
    dealerNamedata.refresh();
    dealercodedata.refresh();
      // var isLoadingRegistration = false.obs;
    
    // Reload dropdown data
    fetchApplicationdata(dealerId.value, customerId.value);
   fetchDealerNamedata(selectedBranchId.value);
    fetchSlbTown(); // Load states first
    fetchCreditLimitIndicator();
     fetchDealerCode(selecteddealer.value!);
    fetchZone();
    fetchDealerSegment();
    fetchDealerclassify();
    fetchGstLocation();
    fetchFreightIndicator();
    fetchGstLocation();
    fetchOutstandingDetailsCustomer(customerId.value);
    fetchPeriodVisit();
    fetchSalesMan(selectedBranchId.value);
    // fetchSalesMan();
    fetchdState();
    // fetchPeriodicity();
    // fetchValidityIndicator();
    // fetchNexusState();
    // fetchAddressState();
    // Add other necessary fetch methods here
  } catch (e) {
    print('Error refreshing data: $e');
  }
}


  Future<void> fetchLocation() async {
    try {
      isLoadingss.value = true;
      final Map<String, String> requestBody = {};
      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.branchScriptId,
        requestBody,
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          return;
        }
      }

      if (response is List) {
        branchLocation.value =
            response.map((json) => BranchLocation.fromJson(json)).toList();
      } else {
        print("Invalid response format: Expected a list but got $response");
        final String error = response['error'];
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("Error fetching branches: $e");
    } finally {
      isLoadingss.value = false;
    }
  }

  Future<void> fetchDealerNamedata(String id) async {
    try {
      isLoadings.value = true;

      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.dealerScriptId,
        {'branchId': id},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");

          return;
        }
      }

      if (response is List) {
        dealernnamedata
            .assignAll(response.map((e) => DealerNameData.fromJson(e)));
        // Reset selectedDealer to avoid mismatch
        selectedDealerForCode.value = null;
      } else {
        print("Invalid response format: Expected a list but got $response");
        final String error = response['error'];
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("Fetch Error: $e");
    } finally {
      Future.delayed(Duration.zero, () {
        isLoadings.value = false;
      });
    }
  }

  Future<void> fetchApplicationdata(String dealerId, String customerId) async {
    try {
      isLoadings.value = true;

      final Map<String, String> requestBody = {
        "customerId": customerId,
        "dealerId": dealerId
      };

      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.applicationScriptId,
        requestBody,
      );
      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");

          return;
        }
      }

      if (response is List && response.isNotEmpty) {
        applicationdata.value =
            response.map((json) => ApplicationData.fromJson(json)).toList();
        update();

        // print("Fetched Address 1: ${address1.value}");
        // print("Fetched Address 2: ${address2.value}");
      } else {
        print("Invalid response format: Expected a list but got $response");
        final String error = response['error'];
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("Error fetching application: $e");
    } finally {
      Future.delayed(Duration.zero, () {
        isLoadings.value = false;
      });
    }
  }

  Future<void> fetchDealerCode(DealerNameData selectedDealer) async {
    try {
      isLoadings.value = true;

      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.dealerScriptId,
        {
          //'branchId': selectedDealer.dealerId,  // Send dealerId
          'DealerName': selectedDealer.dealerName, // Send dealer name if needed
        },
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          return;
        }
      }

      if (response is List && response.isNotEmpty) {
        var dealerData = DealerCode.fromJson(response.first);

        // ✅ Store fetched Dealer Code & Credit Limit
        dealerCode.value = dealerData.dealerCode ?? 'N/A';
        creditLimit.value = dealerData.creditLimit ?? 'N/A';
      }
    } catch (e) {
      print("Fetch Error: $e");
    } finally {
      isLoadings.value = false;
    }
  }

  Future<void> fetchSalesMan(String id) async {
    if (salesmandata.isNotEmpty) return;

    try {
      isLoadingsalesman.value = true;

      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.salesman,
        {'BranchId': id},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        salesmandata.assignAll(response.map((e) => SalesManName.fromJson(e)));

        if (selectedSalesman.value != null &&
            !salesmandata.contains(selectedSalesman.value)) {
          selectedSalesman.value =
              salesmandata.isNotEmpty ? salesmandata.first : null;
        }
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch salesmen.");
    } finally {
      isLoadingsalesman.value = false;
    }
  }

  Future<void> fetchPeriodVisit() async {
    if (periodVisitList.isNotEmpty) return;

    try {
      isLoadingperiodofvisit.value = true;
      print("⏳ Fetching Period Visit Data...");

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.periodicity,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        periodVisitList.assignAll(response.map((e) => PeriodVisit.fromJson(e)));
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch periodic visit data.");
    } finally {
      isLoadingperiodofvisit.value = false;
    }
  }

  Future<void> fetchGstLocation() async {
    try {
      isLoadinggstlocation.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.gststate,
        {},
      );

      if (response == null) {
        print("❌ API returned null. Check your endpoint or network.");
        return;
      }

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          return;
        }
      }

      if (response is Map && response.containsKey('data')) {
        var dataList = response['data']; // Extract the 'data' field
        if (dataList is List) {
          gstlocation.assignAll(dataList.map((e) => Data.fromJson(e)).toList());
        } else {
          print("❌ 'data' is not a List: $dataList");
        }
      } else {
        print("Invalid response format: Expected a list but got $response");
        final String error = response['error'];
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
    } finally {
      isLoadinggstlocation.value = false;
    }
  }

  Future<void> fetchDealerclassify() async {
    if (dealerclassify.isNotEmpty) return;

    try {
      isLoadingclassify.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.classification,
        {},
      );

      if (response == null) {
        print("❌ API returned null. Check your endpoint or network.");
        AppSnackBar.alert(message: "Failed to fetch dealer classification.");
        return;
      }

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        dealerclassify.assignAll(
            response.map((e) => DealerClassification.fromJson(e)).toList());
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch dealer classification.");
    } finally {
      isLoadingclassify.value = false;
    }
  }

  Future<void> fetchDealerSegment() async {
    if (dealersegment.isNotEmpty) return;

    try {
      isLoadingsegment.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.segments,
        {},
      );

      if (response == null) {
        print("❌ API returned null. Check your endpoint or network.");
        AppSnackBar.alert(message: "Failed to fetch dealer segments.");
        return;
      }

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        dealersegment
            .assignAll(response.map((e) => DealerSegment.fromJson(e)).toList());
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch dealer segments.");
    } finally {
      isLoadingsegment.value = false;
    }
  }

  Future<void> fetchTypeofFirm() async {
    if (typeofFirm.isNotEmpty) return;

    try {
      isLoadingtypeoffirm.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.firm,
        {},
      );

      if (response == null) {
        print("❌ API returned null. Check your endpoint or network.");
        AppSnackBar.alert(
            message: "Failed to fetch firm types. Please try again.");
        return;
      }

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        typeofFirm
            .assignAll(response.map((e) => TypeofFirm.fromJson(e)).toList());
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch firm types.");
    } finally {
      isLoadingtypeoffirm.value = false;
    }
  }

  Future<void> fetchTypeofReg() async {
    if (typeofReg.isNotEmpty) return;

    try {
      isLoadingtypeofreg.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.registration,
        {},
      );

      if (response == null) {
        print("❌ API returned null. Check your endpoint or network.");
        AppSnackBar.alert(message: "Failed to fetch registration types.");
        return;
      }

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        var dataList = response['data'];
        if (dataList is List) {
          typeofReg.assignAll(dataList.map((e) => Reg.fromJson(e)).toList());
        }
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch registration types.");
    } finally {
      isLoadingtypeofreg.value = false;
    }
  }

  Future<void> fetchdState() async {
    if (dealerstate.isNotEmpty) return;

    try {
      isLoadingstate.value = true;
      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.stateScriptId,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        dealerstate.assignAll(response.map((e) => DealerState.fromJson(e)));
      } else {
        print("Invalid response format: $response");
        AppSnackBar.alert(message: response['error'] ?? "Unexpected error.");
      }
    } catch (e) {
      print("Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch states.");
    } finally {
      isLoadingstate.value = false; // Stop loading
    }
  }

  Future<void> fetchSlbTown() async {
    if (dealerslbtown.isNotEmpty) return;

    try {
      isLoadingslbtown.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.slbtownScriptId,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        dealerslbtown.assignAll(response.map((e) => SlbTown.fromJson(e)));

        if (selectedSlbTown.value != null &&
            !dealerslbtown.contains(selectedSlbTown.value)) {
          selectedSlbTown.value =
              dealerslbtown.isNotEmpty ? dealerslbtown.first : null;
        }
      } else {
        print("Invalid response format: $response");
        final String? error = response['error'] as String?;
        AppSnackBar.alert(message: error ?? "Unexpected error.");
      }
    } catch (e) {
      print("Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch towns.");
    } finally {
      isLoadingslbtown.value = false;
    }
  }

  Future<void> fetchdDistrict() async {
    if (dealerdistrict.isNotEmpty) return;

    try {
      isLoadingdistrict.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.districtScriptId,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is List) {
        dealerdistrict
            .assignAll(response.map((e) => DealerDistrict.fromJson(e)));

        if (selecteddealerdistrict.value != null &&
            !dealerdistrict.contains(selecteddealerdistrict.value)) {
          selecteddealerdistrict.value =
              dealerdistrict.isNotEmpty ? dealerdistrict.first : null;
        }
      } else {
        print("Invalid response format: $response");
        final String? error = response['error'] as String?;
        AppSnackBar.alert(message: error ?? "Unexpected error.");
      }
    } catch (e) {
      print("Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch districts.");
    } finally {
      isLoadingdistrict.value = false;
    }
  }

  Future<void> fetchZone() async {
    if (dealerzone.isNotEmpty) return;

    try {
      isLoadingszone.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.zone,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        var dataList = response['data'];
        if (dataList is List) {
          dealerzone.assignAll(
            dataList.map((e) => Zzone.fromJson(e)).toList(),
          );
        }
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch zones.");
    } finally {
      isLoadingszone.value = false;
    }
  }

  Future<void> fetchTownLocation() async {
    if (dealertownlocation.isNotEmpty) return;

    try {
      isLoadingtownlocation.value = true;

      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.townLocationId,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        var dataList = response['data'];
        if (dataList is List) {
          dealertownlocation.assignAll(
            dataList.map((e) => TownLoc.fromJson(e)).toList(),
          );
        }
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch town locations.");
    } finally {
      isLoadingtownlocation.value = false;
    }
  }

  Future<void> fetchCreditLimitIndicator() async {
    if (creditlimitindicator.isNotEmpty) return;

    try {
      isLoadingcreditlimitinid.value = true;
      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.creditSales,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        var dataList = response['data'];
        if (dataList is List) {
          creditlimitindicator.assignAll(
              dataList.map((e) => Creditlimitindi.fromJson(e)).toList());
        }
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch credit limit indicators.");
    } finally {
      isLoadingcreditlimitinid.value = false;
    }
  }

  Future<void> fetchFreightIndicator() async {
    if (freightindictaor.isNotEmpty) return;

    try {
      isLoadingfreightindi.value = true;
      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.freight,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        var dataList = response['data'];
        if (dataList is List) {
          freightindictaor
              .assignAll(dataList.map((e) => Freightindi.fromJson(e)).toList());
        }
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch credit limit indicators.");
    } finally {
      isLoadingfreightindi.value = false;
    }
  }

  Future<void> fetchValidtyIndicator() async {
    if (validityindicator.isNotEmpty) return;

    try {
      isLoadingvalidityindi.value = true;
      var response = await _restletService.getRequest(
        NetSuiteScriptsEcredit.validityIndiScriptId,
        {},
      );

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
          AppSnackBar.alert(message: "Invalid response format.");
          return;
        }
      }

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        var dataList = response['data'];
        if (dataList is List) {
          validityindicator.assignAll(
              dataList.map((e) => Validityindi.fromJson(e)).toList());
        }
      } else {
        print("Invalid response format: $response");
        final String error = response['error'] ?? "Unexpected error.";
        AppSnackBar.alert(message: error);
      }
    } catch (e) {
      print("⚠️ Fetch Error: $e");
      AppSnackBar.alert(message: "Failed to fetch validity indicators.");
    } finally {
      isLoadingvalidityindi.value = false;
    }
  }

  Future<void> fetchOutstandingDetailsCustomer(String customerId) async {
    final requestBody = {
      'CustomerId': customerId,
    };

    try {
      isLoadingss.value = true;
      final response = await _restletService.fetchReportData(
        NetSuiteScripts.outstandingDetailsScriptId,
        requestBody,
      );

      if (response != null) {
        if (response is Map<String, dynamic>) {
          outstandingDetails.value = [response];
        } else if (response is List<dynamic>) {
          outstandingDetails.value = response;
        }

        if (outstandingDetails.isEmpty) {
          AppSnackBar.alert(message: "No outstanding data found.");
        }
      } else {
        AppSnackBar.alert(message: "No outstanding data found.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching outstanding data: $e");
      }
      AppSnackBar.alert(
          message: "An error occurred while fetching outstanding data.");
    } finally {
      isLoadingss.value = false;
    }
  }

  Future<void> fetchExistingCustomer(
      {required String customerID,
      required String dealerId,
      required String phoneNo,
      required String stateName,
      required String branch,
      required String typeOfFirmValue,
      required String dealerSegmentValue,
      required String dealerClassificationValue,
      required String town,
      required String district,
      required String propertierName,
      required String zone,
      required String townLocationId,
      required String? creditLimit,
      required String creditlimitindicator,
      required String enhanceCredit,
      required String fright,
      required String typeofRegistrationId,
      required String pan,
      required String salesmanValue,
      required String contactPersonNumber,
      required String? applicationDate,
      required String validityIndicator,
      required String validateDate,
      required String email,
      required String defaultTaxReg,
      required String nexusstate,
      required String address1,
      String? address2,
      required String postalcode,
      required String dealer,
      required String addressid}) async {
    try {
      isLoadings.value = true;

      var requestData = {
        "customerId": customerID,
        "dealerId": dealerId,
        "phone": phoneNo,
        "branch": branch,
        "typeOfFirmValue": typeOfFirmValue,
        "dealerSegmentValue": dealerSegmentValue,
        "dealerClassificationValue": dealerClassificationValue,
        "town": town,
        "district": district,
        "State": stateName,
        "zone": zone,
        "townLocationId": townLocationId,
        "creditlimit": creditLimit,
        "enhanceCredit": enhanceCredit,
        "fright": fright,
        "typeofRegistrationId": typeofRegistrationId,
        "pan": pan,
        "salesmanValue": salesmanValue,
        "applicationDate": applicationDate,
        "contactPersonNumber": contactPersonNumber,
        "validityIndicator": validityIndicator,
        'creditlimitIndicator': creditlimitindicator,
        "validatedate": validateDate,
        "email": email,
        "DealerName": dealer,
        "address": {
          "addressId": addressid,
          "attention": propertierName,
          "addr1": address1,
          "addr2": address2,
          "zip": postalcode,
          "country": "IN"
        },
        "taxRegistration": {
          "items": [
            {
              "taxRegistrationNumber": defaultTaxReg,
              "nexusCountry": "IN",
              "nexusstate": nexusstate,
            }
          ]
        },
      };

      var response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.fetchExistingCustomerScriptId,
        requestData,
      );

      if (response == null) {
        AppSnackBar.alert(message: "No response from server");
        return;
      }

      if (response is String) {
        try {
          response = jsonDecode(response);
        } catch (e) {
          AppSnackBar.alert(message: "Invalid response format");
          return;
        }
      }

      if (response is Map<String, dynamic>) {
        if (response.containsKey('success') && response['success'] == true) {
          AppSnackBar.success(message: "Form Submitted Successfully");
        } else {
          final String error = response['error'] ?? "An error occurred";
          AppSnackBar.alert(message: error);
        }
      } else {
        AppSnackBar.alert(message: "Unexpected response format");
      }
    } catch (e) {
      AppSnackBar.alert(message: "An error occurred: ${e.toString()}");
    } finally {
      isLoadings.value = false;
    }
  }
}
