class PlanningindentModel {
  final int slno;
  final int itemId;
  final String itemName;
  final String displayName;
  final String supplier;
  final String description;
  final int onOrderQty;
  final int onHandQty;
  final int availableQty;
  final int inTransitQty;
  final int moq;
  final int suggestedQty;
  final int avgSaleQtyPerMonth;
  int orderQty;
  final int projAvgSaleQty;
  final String vehicleApplication;
  final String supersededNo;
  final String lastThreeMonthsSequentialSale;
  final String currentMonthSale;
  final String greaterThan6MonthStock;
  final String grn1Qty;
  final String stdnQty;
  final String lossOfSaleQty;
  final String backorderQty;
  final String lastDateOfReceipt;

  PlanningindentModel({
    required this.slno,
    required this.itemId,
    required this.itemName,
    required this.displayName,
    required this.supplier,
    required this.description,
    required this.onOrderQty,
    required this.onHandQty,
    required this.availableQty,
    required this.inTransitQty,
    required this.moq,
    required this.suggestedQty,
    required this.avgSaleQtyPerMonth,
    required this.orderQty, // Now mutable
    required this.projAvgSaleQty,
    required this.vehicleApplication,
    required this.supersededNo,
    required this.lastThreeMonthsSequentialSale,
    required this.currentMonthSale,
    required this.greaterThan6MonthStock,
    required this.grn1Qty,
    required this.stdnQty,
    required this.lossOfSaleQty,
    required this.backorderQty,
    required this.lastDateOfReceipt,
  });

  factory PlanningindentModel.fromJson(Map<String, dynamic> json) {
    return PlanningindentModel(
      slno: json['slno'] ?? 0,
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      displayName: json['displayName'] ?? '',
      supplier: json['supplier'] ?? '',
      description: json['description'] ?? '',
      onOrderQty: json['onOrderQty'] ?? 0,
      onHandQty: json['onHandQty'] ?? 0,
      availableQty: json['availableQty'] ?? 0,
      inTransitQty: json['inTransitQty'] ?? 0,
      moq: json['moq'] ?? 0,
      suggestedQty: json['suggestedQty'] ?? 0,
      avgSaleQtyPerMonth: json['avgSaleQtyPerMonth'] ?? 0,
      orderQty: json['orderQty'] ?? 0,
      projAvgSaleQty: json['projAvgSaleQty'] ?? 0,
      vehicleApplication: json['VehicleApplication'] ?? '',
      supersededNo: json['SupersededNo'] ?? '',
      lastThreeMonthsSequentialSale: json['LastthreeMonthsequentialSale'] ?? '',
      currentMonthSale: json['CurrentMonthSale'] ?? '',
      greaterThan6MonthStock: json['GreaterThan6MonthStock'] ?? '',
      grn1Qty: json['GRN1Qty'] ?? '',
      stdnQty: json['STDNQty'] ?? '',
      lossOfSaleQty: json['LossofSaleQty'] ?? '',
      backorderQty: json['BackorderQty'] ?? '',
      lastDateOfReceipt: json['Lastdateofreceipt'] ?? '',
    );
  }
}
