// ignore_for_file: non_constant_identifier_names

class CollectionDetailsManager {
  final String? salesRepName;
  final double? TotalOutstading;
  final double? DayCollection;
  final double? cumulativeSales;
  final double? balanceToDo;
  final double? AchSales;

  CollectionDetailsManager({
    required this.salesRepName,
    required this.TotalOutstading,
    required this.DayCollection,
    required this.cumulativeSales,
    required this.balanceToDo,
    required this.AchSales,
  });

  factory CollectionDetailsManager.fromJson(Map<String, dynamic> json) {
    return CollectionDetailsManager(
      salesRepName: json['salesRepName'] ?? '',
      TotalOutstading:
          double.tryParse(json['TotalOutstading'].toString()) ?? 0.0,
      DayCollection: double.tryParse(json['DayCollection'].toString()) ?? 0.0,
      cumulativeSales:
          double.tryParse(json['CumulativeSales'].toString()) ?? 0.0,
      balanceToDo: double.tryParse(json['BalanceToDo'].toString()) ?? 0.0,
      AchSales: double.tryParse(json['ActualSales'].toString()) ?? 0.0,
    );
  }
}
