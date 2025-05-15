import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/branch_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/branchitems_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/to_location_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/transferorder_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/cyber_end_point.dart';
import 'package:impal_desktop/features/services/url/warehouse_url.dart';
import 'package:latlong2/latlong.dart';

class StocksManualController extends GetxController {
  final WarehouseRestletService _cyberrestletService =
      WarehouseRestletService();

  RxList<FromCyberLocation> locations = <FromCyberLocation>[].obs;
  RxList<BranchModel> branch = <BranchModel>[].obs;
  RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  var fetchedItems = <Map<String, dynamic>>[].obs;
  var fetchedItemsPerLocation = <String, List<Map<String, dynamic>>>{}.obs;
  RxList<LocationModel> branchitems = <LocationModel>[].obs;
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final LoginController login = Get.find<LoginController>();
  Rx<String> transferOrderNumber = ''.obs;

  RxString selectedLocationId = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isItemsLoading = false.obs;
  bool isMapReady = false;

  final MapController mapController = MapController();
  LatLng center = const LatLng(0.0, 0.0);

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  void setSelectedLocation(String locationId) {
    selectedLocationId.value = locationId;
    update();
  }

  void updateBranchOnLocationChange() {
    if (selectedLocationId.isNotEmpty) {
      fetchBranch(1000.0, selectedLocationId.value);
    }
  }

  void setMapReady(bool ready) {
    isMapReady = ready;
  }

  void clearData() {
    branch.clear();
    locations.clear();
    selectedLocationId.value = '';
    fetchedItemsPerLocation.clear();
  }

  Future<void> fetchItemsLocation(String locationId) async {
    isItemsLoading.value = true;

    try {
      final requestBody = {'locationId': locationId};

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.manualItemScriptId,
        requestBody,
      );

      if (result is List && result.isNotEmpty) {
        final locationData = result.firstWhere(
          (location) => location['locationId']?.toString() == locationId,
          orElse: () => null,
        );

        if (locationData != null && locationData['items'] is List) {
          items.value = locationData['items'].map<Map<String, dynamic>>((item) {
            return {
              'itemId': item['itemId'] ?? 0,
              'item': item['item'] ?? 'Unknown',
              'onhand': item['onhand'] ?? 0,
              'purchasePrice': item['purchasePrice'] ?? 0.0,
              'ConsigmentNumber': item['ConsigmentNumber'] ?? 'N/A',
              'ConsignmentID': item['ConsignmentID']?.toString() ?? '',
              'isInCart': false,
            };
          }).toList();
        } else {
          AppSnackBar.alert(
              message:
                  "No items found for location ID: $locationId. Location data: $locationData");
        }
      } else {
        AppSnackBar.alert(
            message: "No items found or unexpected response: $result");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching branch data: $e");
    } finally {
      isItemsLoading.value = false;
    }
  }

  Future<void> fetchItemsFromBranch(String locationId) async {
    isItemsLoading.value = true;

    try {
      final requestBody = {
        'locationId': locationId,
      };

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.itemsScriptId,
        requestBody,
      );

      if (result is List && result.isNotEmpty) {
        fetchedItemsPerLocation[locationId] =
            List<Map<String, dynamic>>.from(result[0]['items']);
      } else {
        AppSnackBar.alert(
          message: "No items found or unexpected response: $result",
        );
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching branch data: $e");
    } finally {
      isItemsLoading.value = false;
    }
  }

  void setSelectedLocationId(String locationId) {
    selectedLocationId.value = locationId;
  }

  Future<void> fetchBranch(double radiusInMeters, String locationId) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      branch.clear();
      final points = getBoundingBoxPoints(center, radiusInMeters);

      final requestBody = {
        'Latitude1': points[0].latitude.toString(),
        'Longitude1': points[0].longitude.toString(),
        'Latitude2': points[1].latitude.toString(),
        'Longitude2': points[1].longitude.toString(),
        'Latitude3': points[2].latitude.toString(),
        'Longitude3': points[2].longitude.toString(),
        'Latitude4': points[3].latitude.toString(),
        'Longitude4': points[3].longitude.toString(),
        'locationId': locationId,
      };

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.branchesScriptId,
        requestBody,
      );

      if (result is List) {
        final branchData = result
            .map<BranchModel>((data) => BranchModel.fromJson(data))
            .toList();

        branch.value = branchData;
      } else {
        AppSnackBar.alert(message: "No Branch found in the selected kilometer");
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching branch data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLocations() async {
    try {
      final Map<String, String> requestBody = {};

      final result = await _cyberrestletService.getRequest(
        CyberEndPoint.locationsScriptId,
        requestBody,
      );

      if (result is List) {
        locations.assignAll(
            result.map((data) => FromCyberLocation.fromJson(data)).toList());
      } else if (result is Map && result.containsKey('Location List')) {
        final List<dynamic> locationList = result['Location List'];
        locations.assignAll(locationList
            .map((data) => FromCyberLocation.fromJson(data))
            .toList());
      } else {
        AppSnackBar.alert(
          message: "No locations found or invalid response format.",
        );
      }
    } catch (error) {
      AppSnackBar.alert(message: "Error fetching locations: $error");
    }
  }

  void updateMapCenter(LatLng newCenter) {
    if (!isMapReady) return;

    center = newCenter;
    mapController.move(center, 13.0);
    update();
  }

  List<LatLng> getBoundingBoxPoints(LatLng center, double radiusInMeters) {
    double latOffset = (radiusInMeters / 1000) / 111.32;
    double lonOffset =
        (radiusInMeters / 1000) / (111.32 * cos(center.latitude * pi / 180));

    latOffset = latOffset.clamp(-90.0, 90.0);
    lonOffset = lonOffset.clamp(-180.0, 180.0);
    LatLng topLeft =
        LatLng(center.latitude + latOffset, center.longitude - lonOffset);
    LatLng topRight =
        LatLng(center.latitude + latOffset, center.longitude + lonOffset);
    LatLng bottomLeft =
        LatLng(center.latitude - latOffset, center.longitude - lonOffset);
    LatLng bottomRight =
        LatLng(center.latitude - latOffset, center.longitude + lonOffset);

    return [
      topLeft,
      topRight,
      bottomRight,
      bottomLeft,
      topLeft,
    ];
  }

  Future<void> sendTransactionManualRequest({
    required TransferOrderModel order,
  }) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> requestBody = {
        'Id': login.employeeModel.salesRepId!.toString(),
        "tolocation": order.tolocation ?? 0,
        "subsidiary": 2,
        "branchid": order.branchid ?? 0,
        "item": {
          "items": order.items?.map((item) {
                return {
                  "itemId": item.itemId,
                  "totalAmount": item.totalAmount ?? 0.0,
                  "quantityAdded": item.quantityAdded ?? 0,
                  "ConsignmentID": item.consignmentId,
                };
              }).toList() ??
              [],
        },
      };

      final response = await _cyberrestletService.postRequest(
        CyberEndPoint.createTransferOrderScriptId,
        requestBody,
      );

      if (response != null &&
          response['status'].toString().toLowerCase().contains('success')) {
        print("Transaction successful: ${response['status']}");
        print("Transfer Order ID: ${response['TransferOrderId']}");

        transferOrderNumber.value = response['TransferOrderNo'];
        print("Transfer Order Number: ${transferOrderNumber.value}");

        AppSnackBar.success(
          message:
              "Transfer Order created successfully. Transfer Order ID: ${response['TransferOrderId']}",
        );
      } else {
        print("Unexpected response: ${response['status']}");
        String errorMessage = response['message'] ??
            "Failed to create Transfer Order. Please try again.";
        AppSnackBar.alert(
          message: errorMessage,
        );
      }
    } catch (e) {
      print("Error occurred: $e");

      AppSnackBar.alert(
        message: "An error occurred. Please try again later.",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
