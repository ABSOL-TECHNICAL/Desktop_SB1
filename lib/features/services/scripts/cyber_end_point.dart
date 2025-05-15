class CyberEndPoint {
  static const String locationsScriptId = '1799';
  static const String branchItemsScriptId = '1800';

  ///latlong
  static const String branchesScriptId = '1777'; //branch wise lat long
  static const String itemsScriptId = '1796'; // lat long location
  static const String createTransferOrderScriptId = '1806';
  static const String supplierScriptId = '1791'; //supplier details
  static const String surplusStockScriptId = '1790'; //surplus s
  static const String worksheetStockScriptId = '1760';
  static const String transferOrderStatusScriptId = '2623';
  static const String planningIdScriptId = '2633';
  static const String manualItemScriptId = '4955';
  static const String balanceScriptId = '5364';
  static const String productGroupScriptId = '5765';
  static const String divisionScriptId = '5767';
  static const String getplanningindentScriptId = '5766';
  static const String sentPlannindent = '5872';
  static const String beforeSubmitPlanning = '5883';

  static const Map<String, String> scripts = {
    'branch_items': branchItemsScriptId,
    'branch_names': branchesScriptId,
    'branch_items_list': itemsScriptId,
    'create_transfer_order': createTransferOrderScriptId,
    'core_suppliers': supplierScriptId,
    'surplus_stock': surplusStockScriptId,
    'worksheet_planning': worksheetStockScriptId,
    'transfer_order_history': transferOrderStatusScriptId,
    'transfer_order_planning_id': planningIdScriptId,
    'manual_approver_blue_branch': manualItemScriptId,
    'balance_non_transfer_qty': balanceScriptId,
    'Supplier Product Group': balanceScriptId,
    'Division Group': divisionScriptId,
    'Get Planning Indent Screen Endpoint': getplanningindentScriptId,
    'Sent Planning Indent Screen to Netsuite': sentPlannindent,
    'Before Sent Planning Indent Screen to Netsuite': beforeSubmitPlanning,
  };
}
