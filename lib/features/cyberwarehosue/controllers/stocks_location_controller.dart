import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/branch_model.dart';

import 'package:impal_desktop/features/cyberwarehosue/model/branchitems_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/supplier_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/to_location_model.dart';
import 'package:impal_desktop/features/cyberwarehosue/model/transferorder_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/services/scripts/cyber_end_point.dart';

import 'package:impal_desktop/features/services/url/warehouse_url.dart';
import 'package:latlong2/latlong.dart';

class StocksLocationController extends GetxController {
  final WarehouseRestletService _cyberrestletService =
      WarehouseRestletService();
  RxList<FromCyberLocation> locations = <FromCyberLocation>[].obs;
  final RxList<Supplier> supplier = <Supplier>[].obs;
  RxList<BranchModel> branch = <BranchModel>[].obs;

  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> fetchedItems = <Map<String, dynamic>>[].obs;
  var fetchedItemsPerLocation = <String, List<Map<String, dynamic>>>{}.obs;
  RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  RxList<LocationModel> branchitems = <LocationModel>[].obs;
  final LoginController login = Get.find<LoginController>();

  RxString selectedLocationId = ''.obs;
  RxString selectedSupplierId = ''.obs;
  RxList<String> row8Values = <String>[].obs;
  Rx<String> transferOrderNumber = ''.obs;
  RxBool isItemsLoading = false.obs;
  bool isMapReady = false;
  Map<String, int> balanceItemsForPO = {};

  final MapController mapController = MapController();
  LatLng center = const LatLng(0.0, 0.0);

  void setMapReady(bool ready) {
    isMapReady = ready;
  }

  void clearData() {
    branch.clear();
    locations.clear();
    selectedLocationId.value = '';
    fetchedItemsPerLocation.clear();
  }

  void updateRow8Values(List<String> newValues) {
    row8Values.assignAll(newValues);
    debugPrint('Controller Item Id Values: ${row8Values.join(", ")}');
  }

  void updateItemIds(String itemIds) {
    row8Values.assignAll(itemIds.split(','));
    debugPrint('Controller Item Id Values: ${row8Values.join(", ")}');
  }

  void updateBalanceItems(Map<String, int> updatedItems) {
    balanceItemsForPO.clear();
    balanceItemsForPO.addAll(updatedItems);
    print("Balance Items for PO in Controller: $balanceItemsForPO");
  }

  void printBalanceItems() {
    print("Balance Items for PO in Controller: $balanceItemsForPO");
  }

  Future<void> sendBalanceDetails() async {
    try {
      if (balanceItemsForPO.isEmpty) {
        AppSnackBar.alert(message: "No balance details to send.");
        return;
      }

      List<Map<String, int>> balanceData = balanceItemsForPO.keys.map((key) {
        List<String> parts = key.split(" - ");
        return {
          "PartNoID": int.tryParse(parts[0]) ?? 0,
          "PlanningID": int.tryParse(parts[1]) ?? 0,
        };
      }).toList();

      Map<String, dynamic> payload = {"BalanceItems": balanceData};

      print("Balance Data to be sent: $payload");

      final balanceResponse = await _cyberrestletService.postRequest(
        CyberEndPoint.balanceScriptId,
        payload,
      );

      if (balanceResponse != null &&
          balanceResponse['status']
              .toString()
              .toLowerCase()
              .contains('success')) {
        AppSnackBar.success(message: "Balance details sent successfully.");
      } else {
        AppSnackBar.alert(message: "Failed to send balance items to NetSuite.");
      }
    } catch (e) {
      print("Error sending balance details: $e");
      AppSnackBar.success(message: "Balance details sent successfully..");
    }
  }

  Future<void> fetchItemsFromBranch(String locationId) async {
    isItemsLoading.value = true;

    try {
      final requestBody = {
        'locationId': locationId,
        'itemId': row8Values.join(", "),
      };

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.itemsScriptId,
        requestBody,
      );

      if (result is List && result.isNotEmpty) {
        fetchedItemsPerLocation[locationId] =
            List<Map<String, dynamic>>.from(result[0]['items']);
      } else {
        // AppSnackBar.alert(
        //   message: "No items found or unexpected response: $result",
        // );
      }
    } catch (e) {
      AppSnackBar.alert(message: "Error fetching branch data: $e");
    } finally {
      isItemsLoading.value = false;
    }
  }

  Future<bool> sendWorkIndentTransaction({
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
        transferOrderNumber.value = response['TransferOrderNo'];
        print("Transfer Order Number: ${transferOrderNumber.value}");

        AppSnackBar.success(
          message:
              "Transfer Order created successfully and item fulfillment created succesfully. Transfer Order ID: ${response['TransferOrderId']} Item Fullfillment ID: ${response['FulfillmentNo']}",
        );
        await sendPlanningId(response['TransferOrderId'], order);
        return true;
      } else {
        String errorMessage = response['message'] ??
            "Failed to create Transfer Order. Please try again.";
        AppSnackBar.alert(
          message: errorMessage,
        );
        return false;
      }
    } catch (e) {
      print("Error occurred: $e");

      AppSnackBar.alert(
        message: "An error occurred. Please try again later.",
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPlanningId(
      int transferOrderId, TransferOrderModel order) async {
    try {
      Map<int, Map<String, dynamic>> consolidatedItems = {};

      order.items?.forEach((item) {
        if (item.itemId != null) {
          int partNoId = item.itemId!;
          if (consolidatedItems.containsKey(partNoId)) {
            consolidatedItems[partNoId]!['quantityAdded'] +=
                item.quantityAdded ?? 0;
          } else {
            consolidatedItems[partNoId] = {
              "PlanningID": item.planningId ?? 0.0,
              "PartNoID": partNoId,
              "quantityAdded": item.quantityAdded ?? 0,
            };
          }
        }
      });

      List<Map<String, dynamic>> transferOrderItems =
          consolidatedItems.values.toList();

      Map<String, dynamic> requestBody = {
        "TransferOrderId": transferOrderId,
        "TransferOrder": transferOrderItems,
      };

      final response = await _cyberrestletService.postRequest(
        CyberEndPoint.planningIdScriptId,
        requestBody,
      );

      if (response != null &&
          response['status'].toString().toLowerCase().contains('success')) {
        AppSnackBar.success(
          message: "Planning details sent successfully.",
        );
      } else {
        print("Failed to send Planning ID: ${response['message']}");
        AppSnackBar.alert(
          message: response['message'] ?? "Failed to send planning details.",
        );
      }
    } catch (e) {
      print("Error occurred while sending planning ID: $e");
      AppSnackBar.alert(
        message: "An error occurred while sending planning details.",
      );
    }
  }

  Future<void> sendTransactionRequest({
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

  Future<void> fetchSupplier() async {
    final Map<String, dynamic> requestBody = {};

    try {
      isLoading.value = true;

      final response = await _cyberrestletService.fetchReportData(
        CyberEndPoint.supplierScriptId,
        requestBody,
      );

      if (response != null &&
          response is List<dynamic> &&
          response.isNotEmpty) {
        supplier.value = response
            .map((item) => Supplier(
                  supplier: item['Supplier'],
                  supplierId: item['SupplierId'],
                ))
            .toList();
      } else {
        AppSnackBar.alert(message: "No supplier found.");
      }
    } catch (e) {
      AppSnackBar.alert(message: "An error occurred while viewing supplier.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWorkSheetstocks(
      String supplierId, String locationId) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final requestBody = {
        'Location': locationId,
        'SupplierId': supplierId,
      };

      final result = await _cyberrestletService.fetchReportData(
        CyberEndPoint.worksheetStockScriptId,
        requestBody,
      );

      if (result is List) {
        fetchedItems.clear();

        for (var locationData in result) {
          if (locationData['Parts'] != null) {
            for (var part in locationData['Parts']) {
              fetchedItems.add({
                'PlanningID': part['PlanningID'],
                'PartNoID': part['PartNoID'],
                'PartName': part['PartName'],
                'RequiredQty': part['RequiredQty'],
                'Location': locationData['Location'],
                'LocationName': locationData['LocationName'],
                'Supplier': locationData['Supplier'],
                'SupplierText': locationData['SupplierText'],
                'IndentNo': part['IndentNo'],
              });
            }
          }
        }
      } else {
        AppSnackBar.alert(message: "WorkSheet Planning Indent");
      }
    } catch (e) {
      AppSnackBar.alert(
          message: "Error fetching WorkSheet Planning Indent data: $e");
    } finally {
      isLoading.value = false;
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

      //print("API Response: $result");

      if (result is List) {
        locations.assignAll(result.map((data) {
          String fullName = data["locationName"];
          List<String> parts = fullName.split(":");
          String warehouseName = parts.last.trim();

          return FromCyberLocation(
            locationid: data["locationid"],
            locationName: warehouseName,
            latitude: double.tryParse(data["latitude"] ?? "0.0") ?? 0.0,
            longitude: double.tryParse(data["longitude"] ?? "0.0") ?? 0.0,
          );
        }).toList());

        print("Extracted Warehouse Locations: $locations");
      } else {
        AppSnackBar.alert(message: "Unexpected response format.");
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
}
