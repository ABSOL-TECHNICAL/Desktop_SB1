import 'dart:convert';

import 'package:get/get.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/model/addressstate_model.dart';
import 'package:impal_desktop/features/e-credit/customer/new_application/model/nexusstate_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

import 'package:impal_desktop/features/login/controllers/login_controller.dart';

import 'package:impal_desktop/features/services/scripts/ecredit_end_point.dart';
import 'package:impal_desktop/features/services/url/e_credit_url.dart';
import 'package:intl/intl.dart';

class NewCustomerApplicationController extends GetxController {
  final EcreditRestletService _restletService = EcreditRestletService();

  final LoginController ecreditLogincontroller = Get.find<LoginController>();

  // State, District, and Town Location lists
  RxList<Map<String, dynamic>> branchList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> branchRowList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> rowbranchList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> dealerNameList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> statesList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> dealerTownList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> nexusstateList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> districtList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> townLocationList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> zoneList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> firmList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> registrationList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> periodicityList = <Map<String, dynamic>>[].obs;
  // ignore: non_constant_identifier_names
  RxList<Map<String, dynamic>> GststateList = <Map<String, dynamic>>[].obs;
//  var salesmanList = <Map<String, dynamic>>[].obs;

  RxList<Map<String, dynamic>> salesmanList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> classification = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> segments = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> creditSales = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> freight = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> validityIndicators =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> customerCreation = <Map<String, dynamic>>[].obs;

  // Selected values
  var selectedBranch = "".obs;
  var selectedPeroidcity = "".obs;
  var selectedRowBranch = "".obs;
  var selectedDealerName = "".obs;
  var selectedState = "".obs;
  var selectedDistrict = "".obs;
  var selectedTownLocation = "".obs;
  var selectedZone = "".obs;
  var selectedFirm = "".obs;
  var selectedRegistration = "".obs;
  var selectedGstStateList = "".obs;
  var selectedSalesman = "".obs;
  var selectedClassification = "".obs;
  var selectedSegments = "".obs;
  var selectedCreditSales = "".obs;
  var selectedFreight = "".obs;
  var selectedcustomerCreation = "".obs;
  var selectedvalidityindicator = "".obs;
  var selectedDealerTown = "".obs;

  // Loading states
  var isLoadingBranch = false.obs;
  var isLoadingPeroidcity = false.obs;
  var isLoadingRowBranch = false.obs;
  var isLoadingDealerName = false.obs;
  var isLoadingStates = false.obs;
  var isLoadingDealerTown = false.obs;
  var isLoadingDistricts = false.obs;
  var isLoadingTownLocation = false.obs;
  var isLoadingNexusState = false.obs;
  var isLoadingAddressState = false.obs;
  var isLoadingZone = false.obs;
  var isLoadingFirm = false.obs;
  var isLoadingRegistration = false.obs;
  var isLoadingGststate = false.obs;
  var isLoadingSalesman = false.obs;
  var isLoadingClassification = false.obs;
  var isLoadingSegments = false.obs;
  var isLoadingCreditSales = false.obs;
  var isLoadingFreight = false.obs;
  var isLoadingCustomerCreation = false.obs;
  var isLoadingValidityIndicator = false.obs;

  var nexusStates = <NexusState>[].obs;
  final Rx<NexusState?> selectedNexusState = Rx<NexusState?>(null);

  var addressStates = <AddressState>[].obs;
  final Rx<AddressState?> selectedAddressState = Rx<AddressState?>(null);

  void clearSelection() {
    selectedPeroidcity.value = '';
    selectedBranch.value = '';
    selectedDealerTown.value = '';
    selectedRowBranch.value = '';
    selectedFirm.value = '';
    selectedRegistration.value = '';
    selectedDistrict.value = '';
    selectedState.value = '';
    selectedZone.value = '';
    selectedClassification.value = '';
    selectedSegments.value = '';
    selectedFreight.value = '';
    selectedCreditSales.value = '';
    selectedSalesman.value = '';
    selectedTownLocation.value = '';
    selectedvalidityindicator.value = '';
     selectedNexusState.value=null;
     selectedAddressState.value=null;
    update(); // Notify UI to update dropdowns
  }
  

  @override
  void onInit() {
    super.onInit();
    _restletService.init();

    fetchStates();
    fetchSlbTown(); // Load states first
    fetchDistricts();
    fetchTownLocations();
    fetchZone();
    fetchBranch();
    fetchRowBranch();
    fetchFirm();
    fetchRegistration();
    fetchGststate();
    fetchClasification();
    fetchSegments();
    fetchSalesMan();
    fetchCreditSales();
    fetchFreight();
    fetchPeriodicity();
    fetchValidityIndicator();
    fetchNexusState();
    fetchAddressState();
  }

  Future<void> refreshData() async {
  try {
    // Clear all selections and reload necessary data
    selectedRegistration.value = '';
    selectedBranch.value = '';
    selectedState.value = '';
    selectedDistrict.value = '';
    selectedZone.value = '';
    selectedFirm.value = '';
    selectedClassification.value = '';
    selectedSegments.value = '';
    selectedFreight.value = '';
    selectedCreditSales.value = '';
    selectedSalesman.value = '';
    selectedTownLocation.value = '';
    selectedDealerTown.value = '';
    selectedNexusState.value= null ;
    selectedAddressState.value=null;
      // var isLoadingRegistration = false.obs;
    
    // Reload dropdown data
    fetchStates();
    fetchSlbTown(); // Load states first
    fetchDistricts();
    fetchTownLocations();
    fetchZone();
    fetchBranch();
    fetchRowBranch();
    fetchFirm();
    fetchRegistration();
    fetchGststate();
    fetchClasification();
    fetchSegments();
    fetchSalesMan();
    fetchCreditSales();
    fetchFreight();
    fetchPeriodicity();
    fetchValidityIndicator();
    fetchNexusState();
    fetchAddressState();
    // Add other necessary fetch methods here
  } catch (e) {
    print('Error refreshing data: $e');
  }
}

  Future<void> fetchValidityIndicator() async {
    try {
      isLoadingValidityIndicator.value = true;
      final response = await _restletService
          .postRequest(NetSuiteScriptsEcredit.validityIndiScriptId, {});

      if (response is String) {
        List<dynamic> jsonData = json.decode(response);
        validityIndicators.assignAll(jsonData.cast<Map<String, dynamic>>());
      } else {
        print("Unexpected response type for states: ${response.runtimeType}");
        validityIndicators.clear();
      }
    } catch (e) {
      print("Error fetching states: $e");
      validityIndicators.clear();
    } finally {
      isLoadingValidityIndicator.value = false;
    }
  }

  Future<void> fetchPeriodicity() async {
    try {
      isLoadingPeroidcity.value = true;

      final response = await _restletService
          .postRequest(NetSuiteScriptsEcredit.periodicity, {});

      if (response == null || response.toString().trim().isEmpty) {
        print("❌ API returned an empty response!");
        return;
      }

      if (response is String) {
        try {
          List<dynamic> jsonData = json.decode(response);
          print("📌 Parsed JSON Data: $jsonData");

          if (jsonData.isNotEmpty) {
            periodicityList.assignAll(jsonData.cast<Map<String, dynamic>>());
            print("✅ Updated periodicityList: $periodicityList");
          } else {
            print("⚠️ Empty periodicity list from API");
            periodicityList.clear();
          }
        } catch (e) {
          print("❌ JSON Parsing Error: $e");
        }
      } else {
        print("❌ Unexpected response type: ${response.runtimeType}");
        periodicityList.clear();
      }
    } catch (e) {
      print("🚨 Exception during API call: $e");
      periodicityList.clear();
    } finally {
      isLoadingPeroidcity.value = false;
    }
  }

  // Function to fetch states
  Future<void> fetchStates() async {
    try {
      isLoadingStates.value = true;
      final response = await _restletService
          .postRequest(NetSuiteScriptsEcredit.stateScriptId, {});

      print("API Response: $response"); // Debugging line

      if (response is String) {
        List<dynamic> jsonData = json.decode(response);
        print("Parsed JSON Data: $jsonData"); // Debugging line

        statesList.assignAll(jsonData.cast<Map<String, dynamic>>());
        print("States List: $statesList"); // Debugging line
      } else {
        print("Unexpected response type for states: ${response.runtimeType}");
        statesList.clear();
      }
    } catch (e) {
      print("Error fetching states: $e");
      statesList.clear();
    } finally {
      isLoadingStates.value = false;
    }
  }

//  Future<void> fetchSlbTown() async {
//   try {
//     isLoadingDealerTown.value = true;
//     final response = await _restletService.getRequest(NetSuiteScriptsEcredit.slbtownScriptId, {});

//     print("fetchslbtownlocation  $response");

//    if (response is String) {
//   List<dynamic> jsonData = json.decode(response);
//   if (jsonData is List) {
//     dealerTownList.assignAll(jsonData.map((e) => Map<String, dynamic>.from(e)).toList());
//   } else {
//     print("Error: jsonData is not a List");
//     dealerTownList.clear();
//   }
// } else {
//   print("Unexpected response type for towns: ${response.runtimeType}");
//   dealerTownList.clear();
// }

//   } catch (e) {
//     print("Error fetching towns: $e");
//     dealerTownList.clear();
//   } finally {
//     isLoadingDealerTown.value = false;
//   }
// }

  // Function to fetch districts when a state is selected
  Future<void> fetchDistricts() async {
    try {
      isLoadingDistricts.value = true;
      final response = await _restletService
          .getRequest(NetSuiteScriptsEcredit.districtScriptId, {});

      if (response is List) {
        districtList.assignAll(response.cast<Map<String, dynamic>>());
      } else {
        print("Unexpected response format for districts: $response");
        districtList.clear();
      }
    } catch (e) {
      print("Error fetching districts: $e");
      districtList.clear();
    } finally {
      isLoadingDistricts.value = false;
    }
  }

  Future<void> fetchSlbTown() async {
    try {
      isLoadingDealerTown.value = true;
      final response = await _restletService
          .getRequest(NetSuiteScriptsEcredit.slbtownScriptId, {});

      if (response is List) {
        dealerTownList.assignAll(response.cast<Map<String, dynamic>>());
      } else {
        print("Unexpected response format for districts: $response");
        dealerTownList.clear();
      }
    } catch (e) {
      print("Error fetching districts: $e");
      dealerTownList.clear();
    } finally {
      isLoadingDealerTown.value = false;
    }
  }

  // Function to fetch town locations when a district is selected
  // Function to fetch town locations when a district is selected
  Future<void> fetchTownLocations() async {
    try {
      isLoadingTownLocation.value = true;
      selectedTownLocation.value = ""; // Reset town location
      townLocationList.clear();

      final response = await _restletService
          .getRequest(NetSuiteScriptsEcredit.townLocationId, {});

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> jsonData = response['data']; // Extract 'data' array
        townLocationList.assignAll(jsonData.cast<Map<String, dynamic>>());

        // if (townLocationList.isNotEmpty) {
        //   selectedTownLocation.value = townLocationList.first['name'] ?? "";
        // }
      } else {
        print("Unexpected response format for town locations: $response");
        townLocationList.clear();
      }
    } catch (e) {
      print("Error fetching town locations: $e");
      townLocationList.clear();
    } finally {
      isLoadingTownLocation.value = false;
    }
  }

  Future<void> fetchNexusState() async {
    try {
      isLoadingNexusState.value = true;

      final response = await _restletService
          .postRequest(NetSuiteScriptsEcredit.nexusStateId, {});

      if (response != null) {
        // Step 1: Decode the JSON string into a List
        var decodedResponse = jsonDecode(response);

        if (decodedResponse is List) {
          // Step 2: Convert List<Map<String, dynamic>> into NexusState list
          var parsedList = decodedResponse.map<NexusState>((data) {
            return NexusState.fromJson(data);
          }).toList();

          if (parsedList.isNotEmpty) {
            nexusStates.assignAll(parsedList);
          } else {
            print("Parsed list is empty.");
            nexusStates.clear();
          }
        } else {
          print("Unexpected response format for Nexus state: $decodedResponse");
          nexusStates.clear();
        }
      } else {
        print("Response is null.");
        nexusStates.clear();
      }
    } catch (e) {
      print("Error fetching Nexus state: $e");
      nexusStates.clear();
    } finally {
      isLoadingNexusState.value = false;
    }
  }

  Future<void> fetchAddressState() async {
    try {
      isLoadingAddressState.value = true;

      final response = await _restletService
          .postRequest(NetSuiteScriptsEcredit.adddressStateId, {});

      if (response != null) {
        // Step 1: Decode the JSON string into a List
        var decodedResponse = jsonDecode(response);

        if (decodedResponse is List) {
          // Step 2: Convert List<Map<String, dynamic>> into NexusState list
          var parsedList = decodedResponse.map<AddressState>((data) {
            return AddressState.fromJson(data);
          }).toList();

          if (parsedList.isNotEmpty) {
            addressStates.assignAll(parsedList);
          } else {
            print("Parsed list is empty.");
            addressStates.clear();
          }
        } else {
          print(
              "Unexpected response format for Address state: $decodedResponse");
          addressStates.clear();
        }
      } else {
        print("Response is null.");
        addressStates.clear();
      }
    } catch (e) {
      print("Error fetching Address state: $e");
      addressStates.clear();
    } finally {
      isLoadingAddressState.value = false;
    }
  }

  Future<void> fetchZone() async {
    try {
      isLoadingZone.value = true;
      selectedZone.value = "";
      zoneList.clear();
      final response =
          await _restletService.getRequest(NetSuiteScriptsEcredit.zone, {});
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> jsonData = response['data']; // Extract 'data' array
        zoneList.assignAll(jsonData.cast<Map<String, dynamic>>());

        // if (zoneList.isNotEmpty) {
        //   selectedZone.value = zoneList.first['name'] ?? "";
        // }
      } else {
        print("Unexpected response format for town locations: $response");
        zoneList.clear();
      }
    } catch (e) {
      print("Error fetching town locations: $e");
      zoneList.clear();
    } finally {
      isLoadingZone.value = false;
    }
  }

  Future<void> fetchBranch() async {
    try {
      isLoadingBranch.value = true;
      selectedBranch.value = "";
      branchList.clear();

      final response =
          await _restletService.getRequest(NetSuiteScriptsEcredit.branch, {});

      if (response is List) {
        branchList.assignAll(response.cast<Map<String, dynamic>>());
        print(
            " Branch List Content: ${branchList.map((b) => b['BranchId']).toList()}");
      } else {
        print(" Unexpected response format: $response");
        branchList.clear();
      }
    } catch (e) {
      branchList.clear();
    } finally {
      isLoadingBranch.value = false;
    }
  }

  Future<void> fetchRowBranch() async {
    try {
      isLoadingRowBranch.value = true;
      selectedRowBranch.value = "";
      branchRowList.clear();

      final response =
          await _restletService.getRequest(NetSuiteScriptsEcredit.branch, {});

      if (response is List) {
        branchRowList.assignAll(response.cast<Map<String, dynamic>>());
        print(
            " Branch List Content: ${branchRowList.map((b) => b['BranchName']).toList()}");
      } else {
        print(" Unexpected response format: $response");
        branchRowList.clear();
      }
    } catch (e) {
      branchRowList.clear();
    } finally {
      isLoadingRowBranch.value = false;
    }
  }

  Future<void> fetchFirm() async {
    try {
      isLoadingFirm.value = true;
      selectedFirm.value = "";
      firmList.clear();

      final response =
          await _restletService.getRequest(NetSuiteScriptsEcredit.firm, {});

      if (response is List) {
        firmList.assignAll(response.cast<Map<String, dynamic>>());
        print(
            " firm List Content: ${firmList.map((b) => b['TypeFirmName']).toList()}");
      } else {
        print(" Unexpected response format: $response");
        firmList.clear();
      }
    } catch (e) {
      print(" Error fetching branch: $e");
      firmList.clear();
    } finally {
      isLoadingFirm.value = false;
    }
  }

  Future<void> fetchRegistration() async {
    try {
      isLoadingRegistration.value = true;
      registrationList.clear();

      final response = await _restletService
          .getRequest(NetSuiteScriptsEcredit.registration, {});

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        List<dynamic> data = response['data'];
        registrationList.assignAll(data.cast<Map<String, dynamic>>());

        print(
            "Registration List Content: ${registrationList.map((b) => b['name']).toList()}");
      } else {
        print("Unexpected response format: $response");
        registrationList.clear();
      }
    } catch (e) {
      print("Error fetching registration: $e");
      registrationList.clear();
    } finally {
      isLoadingRegistration.value = false;
    }
  }

  Future<void> fetchGststate() async {
    try {
      isLoadingGststate.value = true;
      GststateList.clear();

      final response =
          await _restletService.getRequest(NetSuiteScriptsEcredit.gststate, {});

      // Ensure response is a Map and contains the expected 'data' field
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];

        if (data is List) {
          GststateList.assignAll(data.cast<Map<String, dynamic>>());
          print("GST Content: ${GststateList.map((b) => b['name']).toList()}");
        } else {
          print("Unexpected data format: $data");
          GststateList.clear();
        }
      } else {
        print("Unexpected response format: $response");
        GststateList.clear();
      }
    } catch (e) {
      print("Error fetching GST state: $e");
      GststateList.clear();
    } finally {
      isLoadingGststate.value = false;
    }
  }

  Future<void> fetchSalesMan() async {
    try {
      isLoadingSalesman.value = true;
      // print("Fetching Salesmen for Branch ID: $id");
      final String? branchID = ecreditLogincontroller.employeeModel.branchid;

      final response = await _restletService.postRequest(
        NetSuiteScriptsEcredit.salesman,
        {"BranchId": branchID},
      );

      print(
          "🔍 Raw Response: $response"); // ✅ Check if response contains expected data

      if (response is String) {
        try {
          var jsonData = json.decode(response);
          print("🔍 Decoded JSON: $jsonData"); // ✅ Check JSON structure

          if (jsonData is List && jsonData.isNotEmpty) {
            salesmanList.assignAll(jsonData.cast<Map<String, dynamic>>());
            print(
                "Salesmen Loaded: ${salesmanList.map((e) => e['SalesManName']).toList()}");
          } else {
            print(" Unexpected response format: $jsonData");
            salesmanList.clear();
          }
        } catch (e) {
          print(" JSON Parsing Error: $e");
          salesmanList.clear();
        }
      } else {
        print(" API Response is not a String");
        salesmanList.clear();
      }
    } catch (e) {
      print(" Error fetching Salesmen: $e");
      salesmanList.clear();
    } finally {
      isLoadingSalesman.value = false;
      print(
          "Final Salesman List: ${salesmanList.map((e) => e['SalesManName']).toList()}");
    }
  }

  Future<void> fetchClasification() async {
    try {
      isLoadingClassification.value = true;
      classification.clear();

      final rawResponse = await _restletService
          .getRequest(NetSuiteScriptsEcredit.classification, {});

      print("Raw API Response: $rawResponse"); // Debugging print

      dynamic response = rawResponse; // Create a mutable variable

      if (response is String) {
        response = jsonDecode(response); // Convert string to JSON
      }

      if (response is List) {
        classification.assignAll(response.cast<Map<String, dynamic>>());
        print(
            "classification Content: ${classification.map((b) => b['DealerClassName']).toList()}");
      } else {
        print("Unexpected response format: $response");
        classification.clear();
      }
    } catch (e) {
      print("Error fetching Salesman: $e");
      classification.clear();
    } finally {
      isLoadingClassification.value = false;
    }
  }

  Future<void> fetchSegments() async {
    try {
      isLoadingSegments.value = true;
      segments.clear();

      final rawResponse =
          await _restletService.getRequest(NetSuiteScriptsEcredit.segments, {});

      print("Raw API Response: $rawResponse"); // Debugging print

      dynamic response = rawResponse; // Create a mutable variable

      if (response is String) {
        response = jsonDecode(response); // Convert string to JSON
      }

      if (response is List) {
        segments.assignAll(response.cast<Map<String, dynamic>>());
        print(
            "segments Content: ${segments.map((b) => b['DealerBussegName']).toList()}");
      } else {
        print("Unexpected response format: $response");
        segments.clear();
      }
    } catch (e) {
      print("Error fetching segments: $e");
      segments.clear();
    } finally {
      isLoadingSegments.value = false;
    }
  }

  Future<void> fetchCreditSales() async {
    try {
      isLoadingCreditSales.value = true;
      creditSales.clear();

      final response = await _restletService
          .getRequest(NetSuiteScriptsEcredit.creditSales, {});

      // Ensure response is a Map and contains the expected 'data' field
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];

        if (data is List) {
          creditSales.assignAll(data.cast<Map<String, dynamic>>());
          print(
              "credit Sales Content: ${creditSales.map((b) => b['name']).toList()}");
        } else {
          print("Unexpected data format: $data");
          creditSales.clear();
        }
      } else {
        print("Unexpected response format: $response");
        creditSales.clear();
      }
    } catch (e) {
      print("Error fetching credit sales: $e");
      creditSales.clear();
    } finally {
      isLoadingCreditSales.value = false;
    }
  }

  Future<void> fetchFreight() async {
    try {
      isLoadingFreight.value = true;
      freight.clear();

      final response =
          await _restletService.getRequest(NetSuiteScriptsEcredit.freight, {});

      // Ensure response is a Map and contains the expected 'data' field
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];

        if (data is List) {
          freight.assignAll(data.cast<Map<String, dynamic>>());
          print("Freight Content: ${freight.map((b) => b['name']).toList()}");
        } else {
          print("Unexpected data format: $data");
          freight.clear();
        }
      } else {
        print("Unexpected response format: $response");
        freight.clear();
      }
    } catch (e) {
      print("Error fetching freight: $e");
      freight.clear();
    } finally {
      isLoadingFreight.value = false;
    }
  }

  Future<dynamic> createCustomer(
      String branchId,
      String firmid,
      String registrationid,
      String districtid,
      String stateid,
      String zoneid,
      String classificationid,
      String segmentsid,
      String freightid,
      String creditSalesid,
      String salesmanId,
      String townLocationId,
      String state,
      String slbtownlist,
      String validityIndicator,
      String email,
      String proprietorMobileController,
      String dealerNameController,
      dynamic newCustomerController,
      String town,
      String proprietorNameController,
      String credit,
      String pan,
      String address1Controller,
      String address2Controller,
      String postalcode,
      String gst,
      String dateController,
      String validateDate,
      String nexusState,
      String addressState) async {
    DateTime? parsedDate;
    try {
      parsedDate = DateFormat('dd/MM/yyyy').parseStrict(dateController);
    } catch (e) {
      print("Error parsing date: $e");
    }

    if (parsedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
      print("Formatted Date: $formattedDate"); // Debugging
    }
    try {
      isLoadingCustomerCreation.value = true;
      customerCreation.clear();

      final selectedBranchId = newCustomerController.branchList.firstWhere(
        (branch) =>
            branch['BranchName'] ==
            ecreditLogincontroller.employeeModel.branchname,
        orElse: () => {"BranchId": null},
      )['BranchId'];
      final requestBody = {
        "email": email.trim(),
        "phone": proprietorMobileController.trim(),
        "name": dealerNameController.trim(),
        "branch": selectedBranchId,
        "typeOfFirmValue": newCustomerController.selectedFirm.value.isNotEmpty
            ? newCustomerController.firmList.firstWhere((firm) =>
                firm['TypeFirmName'] ==
                newCustomerController.selectedFirm.value)['TypeFirmID']
            : null,

        "dealerSegmentValue": newCustomerController
                .selectedSegments.value.isNotEmpty
            ? newCustomerController.segments.firstWhere((seg) =>
                seg['DealerBussegName'] ==
                newCustomerController.selectedSegments.value)['DealerBusSegId']
            : null,

        "dealerClassificationValue":
            newCustomerController.selectedClassification.value.trim().isNotEmpty
                ? newCustomerController.classification.firstWhere(
                    (classifi) =>
                        classifi['DealerClassName'] ==
                        newCustomerController.selectedClassification.value,
                    orElse: () => {'DealerClassId': null})['DealerClassId']
                : null,
        "slbTown": newCustomerController.selectedDealerTown.value.isNotEmpty
            ? newCustomerController.dealerTownList.firstWhere((slbtownlist) =>
                slbtownlist['SlbTownName'] ==
                newCustomerController.selectedDealerTown.value)['SlbTownId']
            : null,
        "town": town.trim(),
        "area": "",
        "district": districtid,

        "state": newCustomerController.selectedState.value.isNotEmpty
            ? newCustomerController.statesList.firstWhere((state) =>
                state['StateName'] ==
                newCustomerController.selectedState.value)['StateId']
            : null,
        "zone": newCustomerController.selectedZone.value.isNotEmpty
            ? newCustomerController.zoneList.firstWhere((zone) =>
                zone['name'] == newCustomerController.selectedZone.value)['id']
            : null,
        "townLocationId":
            newCustomerController.selectedTownLocation.value.isNotEmpty
                ? newCustomerController.townLocationList.firstWhere(
                    (townLocation) =>
                        townLocation['name'] ==
                        newCustomerController.selectedTownLocation.value)['id']
                : null,
        "fright": newCustomerController.selectedFreight.value.isNotEmpty
            ? newCustomerController.freight.firstWhere((freight) =>
                freight['name'] ==
                newCustomerController.selectedFreight.value)['id']
            : null,
        "currency": 1, // Primary Currency (Ensure valid integer)
        "terms": 1, // Terms (Ensure valid integer)
        "Creditlimitindicator":
            newCustomerController.selectedCreditSales.value.isNotEmpty
                ? newCustomerController.creditSales.firstWhere((creditSales) =>
                    creditSales['name'] ==
                    newCustomerController.selectedCreditSales.value)['id']
                : null,
        "creditlimit": credit.trim(),

        "typeofRegistrationId": newCustomerController
                .selectedRegistration.value.isNotEmpty
            ? newCustomerController.registrationList.firstWhere((register) =>
                register['name'] ==
                newCustomerController.selectedRegistration.value)['id']
            : null,
        "pan": pan.trim(),
        "salesmanValue": newCustomerController.selectedSalesman.value.isNotEmpty
            ? newCustomerController.salesmanList.firstWhere((salesman) =>
                salesman['SalesManName'] ==
                newCustomerController.selectedSalesman.value)['SalesManID']
            : null,
        "address": {
          "attention": proprietorNameController.trim(),
          "addr1": address1Controller.trim(),
          "addr2": address2Controller.trim(),
          // "state": stateid, // Ensure correct format
          "statetext": newCustomerController.selectedState.value ?? 0,
          "Addressstate": addressState,
          "city": districtid,
          "zip": postalcode.trim(),
          "country": "IN"
        },
        "taxRegistration": {
          "items": [
            {
              "taxRegistrationNumber": gst.trim(),
              "nexusCountry": "IN",
              // "nexus": "32",
              "nexusstate": newCustomerController.selectedState.value ?? 0,
              "nexusstateId": nexusState
            }
          ]
        },

        "applicationDate": parsedDate != null
            ? DateFormat('dd/MM/yyyy').format(parsedDate)
            : "",
        "validityIndicator": validityIndicator,

        "validatedate": validateDate,
// ),
      };

      print("Sending request: $requestBody");

      final rawResponse = await _restletService.postRequest(
          NetSuiteScriptsEcredit.customerCreation, requestBody);

      print("Raw API Response: $rawResponse");

      dynamic response = rawResponse;

      if (response is String && response.isNotEmpty) {
        response = jsonDecode(response);
      }

      if (response is Map) {
        if (response.containsKey("success") && response["success"] == true) {
          print("✅ Customer Created Successfully!");
          final String dealerName = response["DealerName"];
          AppSnackBar.success(
              message:
                  "Form successfully submitted for the dealer $dealerName");
        } else if (response.containsKey("success") &&
            response["success"] == false) {
          final String error = response['error'];
          AppSnackBar.alert(message: error);
        }
      } else {
        // print("Unexpected response format: $response");
        final String error = response['error'];
        AppSnackBar.alert(message: error);
        customerCreation.clear();
      }
    } catch (e) {
      print("Error fetching customerCreation: $e");
      customerCreation.clear();
    } finally {
      isLoadingCustomerCreation.value = false;
    }
  }
}
