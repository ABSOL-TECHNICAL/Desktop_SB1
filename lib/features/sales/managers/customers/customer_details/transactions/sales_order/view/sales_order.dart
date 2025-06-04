import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/controllers/customer_details_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/controllers/sales_order_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/model/saleorderslb_model.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/sales_order/widget/sales_order_widget.dart';
import 'package:impal_desktop/features/sales/salesperson/stocks/surplus_stocks/controllers/surplus_stocks_controller.dart';
import 'package:impal_desktop/version_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';

// import 'package:sales_app/global/widgets/shimmer_widget.dart';

class SalesOrderPage extends StatefulWidget {
  static const String routeName = '/SalesOrderPage';

  const SalesOrderPage({super.key});

  @override
  _SalesOrderPageState createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  String partnumberId = '';
  bool _isLoading = false;
  bool isSupplierSelected = false;
  RxList<String> slbNames = <String>[].obs;
  Rx<String?> selectedSlbName = Rx<String?>(null);

  TextEditingController requiredQuantityController = TextEditingController();
  TextEditingController packingQuantityController = TextEditingController();

  final CustomerDetailsController customerDetailsController =
      Get.put(CustomerDetailsController());
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController slbvalueController = TextEditingController();
  TextEditingController slbtownlocationController = TextEditingController();
  TextEditingController availableQuantityController = TextEditingController();
  TextEditingController partNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController slb = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();

  RxBool showPartNumberDropdown = false.obs;
  RxBool showDescriptionDropdown = false.obs;

  Rx<String?> selectedPartNumberId = Rx<String?>(null);
  Rx<String?> selectedDescriptionId = Rx<String?>(null);
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  final GlobalsupplierController globalSupplierController =
      Get.put(GlobalsupplierController());
  final SurplusStocksControllers surplusStocksController =
      Get.put(SurplusStocksControllers());
  final GlobalItemsController globalItemsController =
      Get.put(GlobalItemsController());
  final SalesOrderController salesOrderController =
      Get.put(SalesOrderController());
  final VersionController versionController = Get.put(VersionController());

  bool isLoading = true;
  int? selectedSupplierIds;
  String? selectedSupplierName;
  String? id;
  String? validdays;
  String? sbbl;
  String? slbname;

  int? selectedSalesId;
  bool isDropdownDisabled = false;
  String? ordertypeId;

  final List<Map<String, dynamic>> salesOptions = [
    {"name": "Cash Sales", "id": 1},
    {"name": "Credit Sales", "id": 2},
    {"name": "Advance Sale", "id": 5}
  ];

  @override
  void initState() {
    super.initState();
    selectedSalesId = 2;
    ordertypeId = selectedSalesId.toString();

    customerDetailsController.fetchOutstandingDetails();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void onPartNumberChanged(String value) {
    if (value.isNotEmpty) {
      Get.find<GlobalsupplierController>();
      globalItemsController.fetchGlobalItems(value, "", id!).then((_) {
        setState(() {
          showPartNumberDropdown.value = true;
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showPartNumberDropdown.value = false;
      descriptionController.clear();
      selectedDescriptionId.value = null;
      selectedPartNumberId.value = null;
      showDescriptionDropdown.value = false;
      surplusStocksController.supplierStocks.clear();
    }
  }

  void onSelectPartNumber(GlobalitemDetail item) {
    FocusScope.of(context).unfocus();
    partNumberController.text = item.itemName ?? '';
    selectedPartNumberId.value = item.itemId;

    requiredQuantityController.text = '';
    requiredQuantityController.clear();

    descriptionController.text = item.desc ?? '';
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear();
    showPartNumberDropdown.value = false;
    showDescriptionDropdown.value = true;
    // salesOrderController.saleorderslb.clear();
    slbtownlocationController.text = '';
    salesOrderController.slbtownlocation.value = '';

    packingQuantityController.text = '';
    packingQuantityController.clear();

    slbvalueController.clear();
    salesOrderController.slbValue.value = '';
    salesOrderController.saleorderslb.clear();
    salesOrderController.selectedSlbName.value = '';
    salesOrderController.slbName.value = '';
    // globalSupplierController.supplier.clear();
    // globalSupplierController.fetchSupplier();
    final int? supplierId = selectedSupplierIds;
    final String id = supplierId.toString();
    final String customerId = customerDetailsController.outstandingDetails[0]
            ['CustomerID']
        .toString();
    final String? itemID = selectedPartNumberId.value;
    salesOrderController.fetchslb(id, customerId, itemID!);
    print("hiiiiiiii");
    salesOrderController.fetchslbtownlocation(customerId);
    if (selectedSupplierIds != null && item.itemId != null) {
      salesOrderController.fetchpacking(
          selectedSupplierIds.toString(), item.itemId!);
    }
    // salesOrderController.fetchslb(item.itemId!);
  }

  void onDescriptionChanged(String value) {
    if (value.isNotEmpty) {
      Get.find<GlobalsupplierController>();

      globalItemsController.fetchGlobalItems("", value, id!).then((_) {
        setState(() {
          showDescriptionDropdown.value = true;
        });
      });
    } else {
      globalItemsController.globalItems.clear();
      showDescriptionDropdown.value = false;

      surplusStocksController.supplierStocks.clear();
    }
  }

  void onSelectDescription(GlobalitemDetail item) {
    FocusScope.of(context).unfocus();
    descriptionController.text = item.desc ?? '';
    selectedDescriptionId.value = item.itemId;

    globalItemsController.globalItems.clear();

    fetchPartNumbersByDescription(item.desc!);
    showDescriptionDropdown.value = false;
    // salesOrderController.fetchslb(item.itemId!);
    // salesOrderController.fetchslb(item.itemId!);
  }

  void fetchPartNumbersByDescription(String description) {
    Get.find<GlobalsupplierController>();

    globalItemsController.fetchGlobalItems("", description, id!).then((_) {
      if (globalItemsController.globalItems.isNotEmpty) {
        selectedPartNumberId.value = null;
        partNumberController.text = '';
        showPartNumberDropdown.value = true;
      }
    });
  }

  void toggleFields(String field) {
    if (field == 'partNo') {
      descriptionController.clear();
      selectedDescriptionId.value = null;
      partNumberController.text = '';
      selectedPartNumberId.value = null;
      showDescriptionDropdown.value = false;
    } else {
      partNumberController.clear();
      availableQuantityController.text = '';
      packingQuantityController.text = '';
      unitPriceController.text = '';
      globalItemsController.globalItemStocks.clear();
      selectedPartNumberId.value = null;
      descriptionController.text = '';
      selectedDescriptionId.value = null;
      showPartNumberDropdown.value = false;
    }
    surplusStocksController.supplierStocks.clear();
  }

  void clear() {
    bool hasCartItems = cartItems.isNotEmpty; // Check if items are added
    packingQuantityController.clear();
    packingQuantityController.text = '';
    partNumberController.clear();
    descriptionController.clear();
    requiredQuantityController.clear();

    unitPriceController.clear();
    availableQuantityController.clear();
    availableQuantityController.text = '';
    unitPriceController.text = '';

    slbtownlocationController.text = '';
    salesOrderController.slbtownlocation.value = '';

    slbvalueController.clear();
    salesOrderController.slbValue.value = '';

    globalItemsController.globalItemStocks.clear();
    salesOrderController.saleorderslb.clear();
    salesOrderController.selectedSlbName.value = '';
    salesOrderController.slbName.value = '';

    selectedSupplierIds = null;
    isSupplierSelected = false;
    _supplierController.text = '';
    if (!hasCartItems) {
      selectedSalesId = null;
      ordertypeId = "";
      isDropdownDisabled = false;
    }

    setState(() {});
  }

  void addToCart() {
    // Immediately update the state to disable dropdown
    setState(() {
      isDropdownDisabled = true;
    });

    if (ordertypeId != "4") {
      if (selectedSupplierIds == null) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }
      if (partnumberId.isEmpty) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }
      if (ordertypeId!.isEmpty) {
        AppSnackBar.alert(message: 'Please choose OrderType!');
        return;
      }
      if (slbvalueController.text == "No Data") {
        AppSnackBar.alert(
            message: '"SLB value is required. Please contact the head office!');
        return;
      }
      final String slbvalue = slbvalueController.text;
      final String partNumberID = partnumberId;
      final String partNumber = partNumberController.text.trim();
      final String description = descriptionController.text.trim();
      print("Correct $requiredQuantityController");
      final int requiredQty =
          int.tryParse(requiredQuantityController.text) ?? 0;
      if (requiredQuantityController.text.isEmpty || requiredQty <= 0) {
        AppSnackBar.alert(message: 'Required quantity cannot be 0 or empty!');
        return;
      }
      if (requiredQuantityController.text.isEmpty || requiredQty <= 0) {
        AppSnackBar.alert(message: 'Required quantity cannot be 0 or empty!');
        return;
      }
      print("Wrong $requiredQty");
      if (requiredQuantityController.text.isEmpty) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }
      // Ensure slb is selected
      sbbl = salesOrderController.selectedSlbName.value;
      if (sbbl == null || sbbl!.isEmpty) {
        AppSnackBar.alert(message: 'Please select an SLB Field!');
        return;
      }

      final int? supplierId = selectedSupplierIds;
      final String id = supplierId.toString();
      final String? supplierName = selectedSupplierName;
      final String customerId = customerDetailsController.outstandingDetails[0]
              ['CustomerID']
          .toString();
      final String unitprice = unitPriceController.text.trim();
      if (description.isEmpty) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }

      bool isDuplicate =
          cartItems.any((item) => item['partNumberID'] == partNumberID);
      if (isDuplicate) {
        AppSnackBar.alert(message: 'Item already exists in the cart!');
        return;
      }
      //     final selectedSlb = salesOrderController.saleorderslb.firstWhere(
      //   (item) => item.slbname == salesOrderController.selectedSlbName.value,
      //   orElse: () => salesorderslb(slbid: '', slbname: ''), // Default empty if not found
      // );
      sbbl = salesOrderController.selectedSlbName.value;
      slbname = salesOrderController.slbName.value;
      final String? slb = sbbl;
      final String? slbnames = slbname;
      print("good  $slb");
      print("Bad $slbnames");

      // print("Hii ${selectedSlb.slbid}");
      print(selectedPartNumberId.value);
      // Add item to cart
      cartItems.add({
        'partNumberID': partNumberID,
        'customerId': customerId,
        'SupplierId': supplierId,
        'partNumber': partNumber,
        'description': description,
        'requiredQty': requiredQty,
        'unitprice': unitprice,
        'selectedSlbName': slb, // Add selected SLB name
        'slbname': slbnames,
        'slbvalue': slbvalue
      });
       packingQuantityController.clear();
         packingQuantityController.text = '';

      // Clear fields after adding
      partNumberController.clear();
      descriptionController.clear();
      requiredQuantityController.clear();

      unitPriceController.clear();
      availableQuantityController.clear();
      availableQuantityController.text = '';
     
      unitPriceController.text = '';

      slbtownlocationController.text = '';
      salesOrderController.slbtownlocation.value = '';

      slbvalueController.clear();
      salesOrderController.slbValue.value = '';

      globalItemsController.globalItemStocks.clear();
      salesOrderController.saleorderslb.clear();
      salesOrderController.selectedSlbName.value = '';
      salesOrderController.slbName.value = '';
      // globalSupplierController.supplier.clear();
      // globalSupplierController.fetchSupplier();
      // salesOrderController.fetchslb(id, customerId);

      showPartNumberDropdown.value = false;
      showDescriptionDropdown.value = false;

      AppSnackBar.success(message: 'Item Added to the Cart');
    } else {
      if (selectedSupplierIds == null) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }
      if (partnumberId.isEmpty) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }
      if (ordertypeId!.isEmpty) {
        AppSnackBar.alert(message: 'Please choose OrderType!');
        return;
      }
      // if (slbvalueController.text == "No Data") {
      //   AppSnackBar.alert(
      //       message: '"SLB value is required. Please contact the head office!');
      //   return;
      // }
      // final String slbvalue = slbvalueController.text;
      final String partNumberID = partnumberId;
      final String partNumber = partNumberController.text.trim();
      final String description = descriptionController.text.trim();
      print("Correct $requiredQuantityController");
      final int requiredQty =
          int.tryParse(requiredQuantityController.text) ?? 0;
      if (requiredQuantityController.text.isEmpty || requiredQty <= 0) {
        AppSnackBar.alert(message: 'Required quantity cannot be 0 or empty!');
        return;
      }
      if (requiredQuantityController.text.isEmpty || requiredQty <= 0) {
        AppSnackBar.alert(message: 'Required quantity cannot be 0 or empty!');
        return;
      }
      print("Wrong $requiredQty");
      if (requiredQuantityController.text.isEmpty) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }
      // Ensure slb is selected
      // sbbl = salesOrderController.selectedSlbName.value;
      // if (sbbl == null || sbbl!.isEmpty) {
      //   AppSnackBar.alert(message: 'Please select an SLB Field!');
      //   return;
      // }

      final int? supplierId = selectedSupplierIds;
      final String id = supplierId.toString();
      final String? supplierName = selectedSupplierName;
      final String customerId = customerDetailsController.outstandingDetails[0]
              ['CustomerID']
          .toString();
      final String unitprice = unitPriceController.text.trim();
      if (description.isEmpty) {
        AppSnackBar.alert(message: 'Please fill in all fields!');
        return;
      }

      bool isDuplicate =
          cartItems.any((item) => item['partNumberID'] == partNumberID);
      if (isDuplicate) {
        AppSnackBar.alert(message: 'Item already exists in the cart!');
        return;
      }
      //     final selectedSlb = salesOrderController.saleorderslb.firstWhere(
      //   (item) => item.slbname == salesOrderController.selectedSlbName.value,
      //   orElse: () => salesorderslb(slbid: '', slbname: ''), // Default empty if not found
      // );
      // sbbl = salesOrderController.selectedSlbName.value;
      // slbname = salesOrderController.slbName.value;
      // final String? slb = sbbl;
      // final String? slbnames = slbname;
      // print("good  $slb");
      // print("Bad $slbnames");

      // print("Hii ${selectedSlb.slbid}");
      print(selectedPartNumberId.value);
      // Add item to cart
      cartItems.add({
        'partNumberID': partNumberID,
        'customerId': customerId,
        'SupplierId': supplierId,
        'partNumber': partNumber,
        'description': description,
        'requiredQty': requiredQty,
        'unitprice': unitprice,
        'selectedSlbName': "",
        'slbname': "",
        'slbvalue': ""
      });

      // Clear fields after adding
      partNumberController.clear();
      descriptionController.clear();
      requiredQuantityController.clear();

      unitPriceController.clear();
      availableQuantityController.clear();
      availableQuantityController.text = '';
      packingQuantityController.clear();
      packingQuantityController.text = '';
      unitPriceController.text = '';

      slbtownlocationController.text = '';
      salesOrderController.slbtownlocation.value = '';

      slbvalueController.clear();
      salesOrderController.slbValue.value = '';

      globalItemsController.globalItemStocks.clear();
      salesOrderController.saleorderslb.clear();
      salesOrderController.selectedSlbName.value = '';
      salesOrderController.slbName.value = '';
      // globalSupplierController.supplier.clear();
      // globalSupplierController.fetchSupplier();
      // salesOrderController.fetchslb(id, customerId);

      showPartNumberDropdown.value = false;
      showDescriptionDropdown.value = false;

      AppSnackBar.success(message: 'Item Added to the Cart');
    }
  }

  Widget buildCartItems() {
    final theme = Theme.of(context);
    return Obx(() {
      if (cartItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Icon(
                  Icons.remove_shopping_cart,
                  size: 70,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Text(
                  'No items have been added to the cart yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    color: Color.fromARGB(255, 10, 10, 10),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTableTheme(
          data: DataTableThemeData(
            headingRowColor: MaterialStateProperty.all(
                Colors.blue), // Set entire header row background to blue
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Set header text color to white
            ),
          ),
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: const [
              DataColumn(label: Text('Part No')),
              DataColumn(label: Text('Description')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('SLB')),
              DataColumn(label: Text('SLB Value')),
              // DataColumn(label: Text('Price')),
              DataColumn(label: Text('Actions')),
            ],
            rows: cartItems.map((item) {
              return DataRow(
                cells: [
                  DataCell(Text('${item['partNumber']}')),
                  DataCell(Text('${item['description']}')),
                  DataCell(Text('${item['requiredQty']}')),
                  DataCell(Text('${item['slbname']}')),
                  DataCell(Text('${item['slbvalue']}')),
                  // DataCell(Text('${item['unitprice']}')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) {
                            return CustomAlertDialog(
                              title: "Delete Item",
                              message:
                                  "Are you sure you want to delete this item?",
                              onConfirm: () {
                                cartItems.remove(item);
                                Get.back();
                                AppSnackBar.success(
                                    message: 'Item removed from cart!');
                              },
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    partNumberController.dispose();
    descriptionController.dispose();
    requiredQuantityController.dispose();
    availableQuantityController.dispose();
    unitPriceController.dispose();
    packingQuantityController.dispose();

    globalItemsController.globalItems.clear();
    Get.delete<GlobalItemsController>();

    final globalsupplierController = Get.find<GlobalsupplierController>();
    globalsupplierController.selectedSupplierId.value = '';

    if (Get.isRegistered<SalesOrderController>()) {
      Get.delete<SalesOrderController>();
    }

    super.dispose();
  }

  final GlobalKey key = GlobalKey();

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: "Exit Confirmation",
            message: "Are you sure you want to leave this page?",
            onCancel: () {
              Navigator.of(context).pop(false);
            },
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return WillPopScope(
        onWillPop: () async {
          bool shouldExit = await _showExitConfirmationDialog(context);
          return shouldExit;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Estimate',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF161717),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Stack(children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 10, bottom: 0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16, right: 16, bottom: 5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: SingleChildScrollView(
                            child: Column(children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Card(
                                            margin: const EdgeInsets.all(8.0),
                                            elevation: 5,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Obx(
                                                        () => Text(
                                                          customerDetailsController
                                                                  .outstandingDetails
                                                                  .isNotEmpty
                                                              ? customerDetailsController
                                                                  .outstandingDetails[
                                                                      0][
                                                                      'CustomerName']
                                                                  .toString()
                                                              : 'Name',
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 19,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Obx(() {
                                                        if (customerDetailsController
                                                            .outstandingDetails
                                                            .isNotEmpty) {
                                                          return Text(
                                                            'Available Credit Limit: ${customerDetailsController.outstandingDetails[0]['CanBillUpTo'].toString()}',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          );
                                                        } else {
                                                          return SizedBox
                                                              .shrink(); // This ensures no text is displayed when the condition is false
                                                        }
                                                      }),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(children: [
                                                        Expanded(
                                                          child:
                                                              SalesorderSupplierdropdown(
                                                            label:
                                                                'Supplier Name'
                                                                    .tr,
                                                            hintText:
                                                                'Choose Supplier Name...'
                                                                    .tr,
                                                            controller:
                                                                _supplierController,
                                                            globalSupplierController:
                                                                globalSupplierController,
                                                            onSupplierSelected:
                                                                (selectedId) {
                                                              setState(() {
                                                                salesOrderController
                                                                    .saleorderslb
                                                                    .clear();
                                                                selectedSupplierIds =
                                                                    selectedId;
                                                                print(
                                                                    selectedSupplierIds);
                                                                id = selectedId
                                                                    .toString();
                                                                partNumberController
                                                                    .clear();
                                                                descriptionController
                                                                    .clear();
                                                                availableQuantityController
                                                                    .text = '';
                                                                unitPriceController
                                                                    .text = '';
                                                                globalItemsController
                                                                    .globalItemStocks
                                                                    .clear();
                                                                isSupplierSelected =
                                                                    true; // Set the flag to true when a supplier is selected
                                                                final String
                                                                    customerId =
                                                                    customerDetailsController
                                                                        .outstandingDetails[
                                                                            0][
                                                                            'CustomerID']
                                                                        .toString();

                                                                salesOrderController
                                                                    .fetchslbpartnumbervalue(
                                                                        id!,
                                                                        customerId);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child:
                                                              _buildSalesTypeDropdownField(
                                                            label:
                                                                'Select Sales Type',
                                                            hintText:
                                                                'Choose Sales Type...',
                                                          ),
                                                        ),

                                                        // Expanded(
                                                        //   child: Column(
                                                        //     crossAxisAlignment:
                                                        //         CrossAxisAlignment
                                                        //             .start,
                                                        //     children: [
                                                        //       Text(
                                                        //         "Select Sales Type",
                                                        //         style: theme
                                                        //             .textTheme
                                                        //             .bodyLarge
                                                        //             ?.copyWith(
                                                        //           fontWeight:
                                                        //               FontWeight
                                                        //                   .bold,
                                                        //           color: Colors
                                                        //               .black,
                                                        //         ),
                                                        //       ),
                                                        //       SizedBox(
                                                        //           height: 10),
                                                        //       DropdownButtonFormField<
                                                        //           int>(
                                                        //         decoration:
                                                        //             InputDecoration(
                                                        //           filled: true,
                                                        //           fillColor:
                                                        //               Colors
                                                        //                   .white,
                                                        //           errorStyle:
                                                        //               const TextStyle(
                                                        //                   color:
                                                        //                       Colors.transparent),
                                                        //           border:
                                                        //               OutlineInputBorder(
                                                        //             borderRadius:
                                                        //                 BorderRadius.circular(
                                                        //                     10),
                                                        //             borderSide:
                                                        //                 BorderSide
                                                        //                     .none,
                                                        //           ),
                                                        //           enabledBorder:
                                                        //               OutlineInputBorder(
                                                        //             borderRadius:
                                                        //                 BorderRadius.circular(
                                                        //                     10),
                                                        //             borderSide:
                                                        //                 BorderSide(
                                                        //               color: Colors
                                                        //                   .grey
                                                        //                   .shade400,
                                                        //               width: 1,
                                                        //             ),
                                                        //           ),
                                                        //           focusedBorder:
                                                        //               OutlineInputBorder(
                                                        //             borderRadius:
                                                        //                 BorderRadius.circular(
                                                        //                     10),
                                                        //             borderSide:
                                                        //                 const BorderSide(
                                                        //               color: Colors
                                                        //                   .blue,
                                                        //               width:
                                                        //                   0.8,
                                                        //             ),
                                                        //           ),
                                                        //           contentPadding: const EdgeInsets
                                                        //               .symmetric(
                                                        //               horizontal:
                                                        //                   12,
                                                        //               vertical:
                                                        //                   8),
                                                        //         ),
                                                        //         dropdownColor:
                                                        //             Colors
                                                        //                 .white,
                                                        //         hint: Text(
                                                        //             "Choose Sales Type"),
                                                        //         style: theme
                                                        //             .textTheme
                                                        //             .bodyLarge
                                                        //             ?.copyWith(
                                                        //           color: Colors
                                                        //               .black,
                                                        //         ),
                                                        //         value:
                                                        //             selectedSalesId ??
                                                        //                 salesOptions
                                                        //                     .firstWhere(
                                                        //                   (option) =>
                                                        //                       option["name"] ==
                                                        //                       "Credit Sales",
                                                        //                   orElse: () =>
                                                        //                       salesOptions[0],
                                                        //                 )["id"],
                                                        //         items: salesOptions
                                                        //             .map(
                                                        //                 (option) {
                                                        //           return DropdownMenuItem<
                                                        //               int>(
                                                        //             value: option[
                                                        //                 "id"],
                                                        //             child: Text(
                                                        //                 option[
                                                        //                     "name"]),
                                                        //           );
                                                        //         }).toList(),
                                                        //         onChanged:
                                                        //             isDropdownDisabled
                                                        //                 ? null
                                                        //                 : (value) {
                                                        //                     setState(() {
                                                        //                       selectedSalesId = value;
                                                        //                       ordertypeId = selectedSalesId.toString();
                                                        //                       isDropdownDisabled = true;
                                                        //                     });
                                                        //                   },
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                      ]),
                                                      Obx(() {
                                                        if (salesOrderController
                                                            .isSlbPartNumberVisible
                                                            .value) {
                                                          return Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 3,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    _buildTextFields(
                                                                      label:
                                                                          'Enter Part No / Description',
                                                                      hintText:
                                                                          'Please Search Part No or Description...',
                                                                      controller:
                                                                          partNumberController,
                                                                      onChanged:
                                                                          onPartNumberChanged,
                                                                      enabled:
                                                                          true,
                                                                      onFocusChange:
                                                                          (hasFocus) {
                                                                        if (hasFocus) {
                                                                          toggleFields(
                                                                              'partNo');
                                                                          showPartNumberDropdown.value =
                                                                              false;
                                                                        } else {
                                                                          showPartNumberDropdown.value =
                                                                              true;
                                                                        }
                                                                      },
                                                                    ),
                                                                    Obx(() => showPartNumberDropdown
                                                                            .value
                                                                        ? _buildSuggestionsList()
                                                                        : const SizedBox
                                                                            .shrink()),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (partNumberController
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  ordertypeId !=
                                                                      "4")
                                                                Expanded(
                                                                  flex: 3,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                          height:
                                                                              15),
                                                                      Text(
                                                                        'Select SLB',
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              5),
                                                                      Obx(() {
                                                                        if (salesOrderController
                                                                            .isLoadingslbname
                                                                            .value) {
                                                                          return Center(
                                                                              child: CircularProgressIndicator()); // Show loader while fetching data
                                                                        }
                                                                        return GestureDetector(
                                                                          key:
                                                                              key,
                                                                          onTap:
                                                                              () {
                                                                            if (salesOrderController.saleorderslb.isEmpty) {
                                                                              AppSnackBar.alert(message: "The Selected SLB doesn't have value please contact Head office.");
                                                                              return;
                                                                            }

                                                                            final RenderBox
                                                                                renderBox =
                                                                                key.currentContext!.findRenderObject() as RenderBox;
                                                                            final Offset
                                                                                offset =
                                                                                renderBox.localToGlobal(Offset.zero);
                                                                            final Size
                                                                                size =
                                                                                renderBox.size;

                                                                            showMenu(
                                                                              context: Get.context!,
                                                                              position: RelativeRect.fromLTRB(
                                                                                offset.dx,
                                                                                offset.dy + size.height,
                                                                                offset.dx + size.width + 800, // Adjusted width
                                                                                offset.dy + size.height + 500, // Adjusted height
                                                                              ),
                                                                              color: Colors.white,
                                                                              items: salesOrderController.saleorderslb.map((item) {
                                                                                return PopupMenuItem<String>(
                                                                                  value: item.id.toString(),
                                                                                  padding: EdgeInsets.zero, // Remove default padding
                                                                                  child: Container(
                                                                                    width: size.width + 800, // Wider dropdown
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                                                    child: Text(item.name ?? 'N/A'),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                            ).then((selectedValue) {
                                                                              if (selectedValue != null) {
                                                                                final selectedSlb = salesOrderController.saleorderslb.firstWhere(
                                                                                  (item) => item.id.toString() == selectedValue,
                                                                                  orElse: () => Dataslb(id: 0, name: ""),
                                                                                );
                                                                                final LoginController logcont = Get.put(LoginController());
                                                                                final String? loc = logcont.location;
                                                                                final String townid = salesOrderController.slbtownid.value;
                                                                                final String? itemid = selectedPartNumberId.value;
                                                                                final String slb = selectedValue;
                                                                                print("location: $townid - ITemId: $itemid - SlbId: $slb");

                                                                                salesOrderController.fetchslbvalue(townid, itemid!, slb);

                                                                                salesOrderController.selectedSlbName.value = selectedValue;
                                                                                salesOrderController.slbName.value = selectedSlb.name ?? '';
                                                                                FocusScope.of(Get.context!).unfocus();
                                                                              }
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.grey),
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              color: Colors.white,
                                                                            ),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    salesOrderController.selectedSlbName.value.isEmpty
                                                                                        ? "Select SLB Name"
                                                                                        : salesOrderController.saleorderslb
                                                                                            .firstWhere(
                                                                                              (item) => item.id.toString() == salesOrderController.selectedSlbName.value,
                                                                                              orElse: () => Dataslb(id: 0, name: ""),
                                                                                            )
                                                                                            .name!,
                                                                                    style: theme.textTheme.bodyLarge?.copyWith(
                                                                                      fontSize: 16,
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(width: 8), // Optional spacing between text and icon
                                                                                const Icon(Icons.arrow_drop_down, color: Colors.black),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ],
                                                                  ),
                                                                ),
                                                            ],
                                                          );
                                                        } else {
                                                          return const SizedBox
                                                              .shrink();
                                                        }
                                                      }),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Obx(() {
                                                                  if (salesOrderController
                                                                      .isLoadingslbtownlocation
                                                                      .value) {
                                                                    return Center(
                                                                        child:
                                                                            CircularProgressIndicator()); // Show loader while fetching data
                                                                  }

                                                                  final slbtownlocation =
                                                                      salesOrderController
                                                                          .slbtownlocation;

                                                                  if (slbtownlocation
                                                                      .isNotEmpty) {
                                                                    slbtownlocationController
                                                                            .text =
                                                                        slbtownlocation
                                                                            .value;
                                                                  }

                                                                  return _buildTextFieldua(
                                                                    label:
                                                                        'SLB Town / Location'
                                                                            .tr,
                                                                    hintText:
                                                                        '',
                                                                    controller:
                                                                        slbtownlocationController,
                                                                  );
                                                                }),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          if (ordertypeId !=
                                                              "4")
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Obx(() {
                                                                    if (salesOrderController
                                                                        .isLoadingslbvalue
                                                                        .value) {
                                                                      return Center(
                                                                          child:
                                                                              CircularProgressIndicator()); // Show loader while fetching data
                                                                    }

                                                                    final slbvalue =
                                                                        salesOrderController
                                                                            .slbValue;

                                                                    if (slbvalue
                                                                        .isNotEmpty) {
                                                                      slbvalueController
                                                                              .text =
                                                                          slbvalue
                                                                              .value;
                                                                    }

                                                                    return _buildTextFieldua(
                                                                      label:
                                                                          'SLB Value'
                                                                              .tr,
                                                                      hintText:
                                                                          '0',
                                                                      controller:
                                                                          slbvalueController,
                                                                    );
                                                                  }),
                                                                ],
                                                              ),
                                                            ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Obx(() {
                                                                  final availableQuantity = globalItemsController
                                                                          .globalItemStocks
                                                                          .isNotEmpty
                                                                      ? globalItemsController
                                                                              .globalItemStocks
                                                                              .first
                                                                              .availableQuantity
                                                                              ?.toInt()
                                                                              .toString() ??
                                                                          '0'
                                                                      : 'N/A';

                                                                  if (availableQuantity !=
                                                                      'N/A') {
                                                                    availableQuantityController
                                                                            .text =
                                                                        availableQuantity;
                                                                  }

                                                                  return _buildTextFieldua(
                                                                    label:
                                                                        'Available Qty'
                                                                            .tr,
                                                                    hintText:
                                                                        'Available Qty',
                                                                    controller:
                                                                        availableQuantityController,
                                                                  );
                                                                }),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Obx(() {
                                                                  final packingQty = salesOrderController
                                                                          .globalpack
                                                                          .isNotEmpty
                                                                      ? salesOrderController
                                                                          .globalpack
                                                                          .first
                                                                          .packingQty
                                                                      : 'N/A';

                                                                  if (packingQty
                                                                          .isNotEmpty &&
                                                                      packingQty !=
                                                                          'N/A') {
                                                                    packingQuantityController
                                                                            .text =
                                                                        packingQty;
                                                                  }

                                                                  return _buildTextFieldua(
                                                                    label:
                                                                        'Packing Qty'
                                                                            .tr,
                                                                    hintText:
                                                                        'Packing Qty',
                                                                    controller:
                                                                        packingQuantityController,
                                                                  );
                                                                }),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Required Qty',
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                Obx(() {
                                                                  // Display available quantity dynamically
                                                                  final availableQuantity = globalItemsController
                                                                          .globalItemStocks
                                                                          .isNotEmpty
                                                                      ? globalItemsController
                                                                              .globalItemStocks
                                                                              .first
                                                                              .availableQuantity ??
                                                                          0
                                                                      : 0;

                                                                  return Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            500, // Set the desired width
                                                                        height:
                                                                            50,
                                                                        child: TextField(
                                                                            controller: requiredQuantityController,
                                                                            keyboardType: TextInputType.number,
                                                                            inputFormatters: [
                                                                              FilteringTextInputFormatter.allow(
                                                                                RegExp(r'^[0-9]*$'), // Allows only digits (0-9) and prevents decimals
                                                                              ),
                                                                            ],
                                                                            maxLines: 1,
                                                                            decoration: InputDecoration(
                                                                              hintText: 'Enter required quantity',
                                                                              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                                                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Adjusted hint color
                                                                              ),
                                                                              filled: true,
                                                                              fillColor: isDarkMode ? Colors.grey[850] : Colors.white, // Dark mode background color
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(
                                                                                  color: isDarkMode ? Colors.blueAccent.shade700 : Colors.grey.shade400, // Border color
                                                                                  width: 1,
                                                                                ),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(
                                                                                  color: const Color.fromARGB(255, 62, 162, 233), // Focused border color
                                                                                  width: 1.5,
                                                                                ),
                                                                              ),
                                                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                                              constraints: const BoxConstraints(maxHeight: 46), // Keep height reasonable
                                                                            ),
                                                                            onChanged: (value) {}),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  addToCart,
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor: Theme.of(context)
                                                                            .brightness ==
                                                                        Brightness
                                                                            .dark
                                                                    ? const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        255,
                                                                        87,
                                                                        34) // Dark mode color
                                                                    : const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        251,
                                                                        134,
                                                                        45), // Light mode color
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                // padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                minimumSize:
                                                                    const Size(
                                                                        70, 40),
                                                              ),
                                                              child: Text(
                                                                  'Add To Cart'
                                                                      .tr,
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        14,
                                                                  )
                                                                  //     const TextStyle(
                                                                  //   fontSize: 14,
                                                                  // ),
                                                                  ),
                                                            ),
                                                            // const SizedBox(
                                                            //     width: 10),
                                                            // ElevatedButton(
                                                            //   onPressed: clear,
                                                            //   style:
                                                            //       ElevatedButton
                                                            //           .styleFrom(
                                                            //     backgroundColor: Theme.of(context)
                                                            //                 .brightness ==
                                                            //             Brightness
                                                            //                 .dark
                                                            //         ? const Color
                                                            //             .fromARGB(
                                                            //             255,
                                                            //             255,
                                                            //             87,
                                                            //             34) // Dark mode color
                                                            //         : const Color
                                                            //             .fromARGB(
                                                            //             255,
                                                            //             251,
                                                            //             134,
                                                            //             45), // Light mode color
                                                            //     foregroundColor:
                                                            //         Colors
                                                            //             .white,
                                                            //     // padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                                            //     shape:
                                                            //         RoundedRectangleBorder(
                                                            //       borderRadius:
                                                            //           BorderRadius
                                                            //               .circular(
                                                            //                   10),
                                                            //     ),
                                                            //     minimumSize:
                                                            //         const Size(
                                                            //             70, 40),
                                                            //   ),
                                                            //   child: Text(
                                                            //     'Clear'.tr,
                                                            //     style:
                                                            //         const TextStyle(
                                                            //       fontSize: 14,
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                          ]),
                                                      const Divider(),
                                                      Text(
                                                        'Added Items:',
                                                        style: theme
                                                            .textTheme.bodyLarge
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        //  TextStyle(
                                                        //     fontSize: 18,
                                                        //     fontWeight:
                                                        //         FontWeight
                                                        //             .bold),
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      buildCartItems(),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: _isLoading
                                                                  ? null // Disables button when loading
                                                                  : () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return CustomAlertDialog(
                                                                            title:
                                                                                'Confirm ',
                                                                            message:
                                                                                'Are you sure you want to submit this order?',
                                                                            onConfirm:
                                                                                () async {
                                                                              Navigator.of(context).pop();

                                                                              if (cartItems.isEmpty) {
                                                                                AppSnackBar.alert(message: 'Cart is empty!');
                                                                                return;
                                                                              }

                                                                              setState(() {
                                                                                _isLoading = true;
                                                                              });

                                                                              final String customerId = customerDetailsController.outstandingDetails[0]['CustomerID'].toString();
                                                                              final String version = versionController.version.toString();

                                                                              Map<String, dynamic> requestBody = {
                                                                                "CustomerId": customerId,
                                                                                "OrderType": ordertypeId,
                                                                                "Version": version,
                                                                                "item": {
                                                                                  "items": cartItems.map((item) {
                                                                                    return {
                                                                                      "Supplier": item['SupplierId'],
                                                                                      "itemId": item['partNumberID'],
                                                                                      "Unitprice": item['unitprice'],
                                                                                      "itemQuantity": item['requiredQty'],
                                                                                      "slbid": item['selectedSlbName'],
                                                                                      "slbValue": item['slbvalue'],
                                                                                      "Source": "Desktop App",
                                                                                    };
                                                                                  }).toList(),
                                                                                }
                                                                              };

                                                                              await salesOrderController.sendCartDataToApi(requestBody);

                                                                              setState(() {
                                                                                _isLoading = false;
                                                                              });
                                                                            },
                                                                            onCancel:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor: Theme.of(context)
                                                                            .brightness ==
                                                                        Brightness
                                                                            .dark
                                                                    ? const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        255,
                                                                        87,
                                                                        34)
                                                                    : const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        251,
                                                                        134,
                                                                        45),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                minimumSize:
                                                                    const Size(
                                                                        75, 40),
                                                              ),
                                                              child: _isLoading
                                                                  ? const SizedBox(
                                                                      width: 24,
                                                                      height:
                                                                          24,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2.5,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      'Send Order'
                                                                          .tr,
                                                                    ),
                                                            )
                                                          ]),
                                                    ]))))
                                  ]),
                            ]),
                          ))
                        ]),
                  ),
                ),
              ),
            ])));
  }

  Widget _buildTextFieldua({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : Colors.black, // Adjusted text color for dark mode
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 500, // Set the desired width
          height: 50, // Set the desired height

          child: TextField(
            readOnly: true,
            maxLines: maxLines,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600], // Adjusted hint color
              ),
              filled: true,
              fillColor: isDarkMode
                  ? Colors.grey[850]
                  : Colors.white, // Dark mode background color
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    10), // Rounded corners for a smoother look
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.blueAccent.shade700
                      : Colors.grey.shade400, // Border color
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    10), // Rounded corners for focused state
                borderSide: BorderSide(
                  color: const Color.fromARGB(
                      255, 62, 162, 233), // Focused border color
                  width: 1.5,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints:
                  const BoxConstraints(maxHeight: 46), // Keep height reasonable
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields({
    required String label,
    required String hintText,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextEditingController? controller,
    bool enabled = true,
    required ValueChanged<bool> onFocusChange,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Focus(
      onFocusChange: (hasFocus) => onFocusChange(hasFocus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black, // Adjusted text color for dark mode
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 500, // Set the desired width
            height: 50, // Set the desired height
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              onChanged: enabled ? onChanged : (value) {},
              enabled: enabled,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600], // Adjusted hint color
                ),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.grey[850]
                    : Colors.white, // Dark mode background color
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Rounded corners for a smoother look
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.blueAccent.shade700
                        : Colors.grey.shade400, // Border color
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Rounded corners for focused state
                  borderSide: BorderSide(
                    color: const Color.fromARGB(
                        255, 62, 162, 233), // Focused border color
                    width: 1.5,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                constraints: const BoxConstraints(
                    maxHeight: 46), // Keep height reasonable
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTypeDropdownField({
    required String label,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? Colors.grey : Colors.grey,
              width: 1.2,
            ),
          ),
          constraints: const BoxConstraints(
            maxHeight: 46,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedSalesId, // Default to "Credit Sales"
              hint: Text(
                hintText,
                style: theme.textTheme.bodyLarge,
              ),
              onChanged: isDropdownDisabled
                  ? null
                  : (int? newValue) {
                      setState(() {
                        selectedSalesId = newValue;
                        ordertypeId = selectedSalesId.toString();
                        print("Selected Sales Type ID: $selectedSalesId");
                        print("ordertypeId: $ordertypeId");
                        isDropdownDisabled = true; // Disable after selection
                        slbvalueController.clear();
                      });
                    },
              items: salesOptions.map<DropdownMenuItem<int>>((option) {
                return DropdownMenuItem<int>(
                  value: option["id"],
                  child: Text(
                    option["name"],
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.grey[900]! : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    if (globalItemsController.globalItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: globalItemsController.globalItems.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade300,
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            final item = globalItemsController.globalItems[index];
            return GestureDetector(
              onTap: () {
                onSelectPartNumber(item);
                if (item.itemId != null && item.itemId!.isNotEmpty) {
                  partnumberId = item.itemId ?? '';
                  // salesOrderController.fetchslb(item.itemId!);
                  globalItemsController.selectPartNumber(item.itemId!);
                } else {
                  AppSnackBar.alert(message: "Invalid Part Number ID.");
                  print("invalid partno id");
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Text(
                  item.itemName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
