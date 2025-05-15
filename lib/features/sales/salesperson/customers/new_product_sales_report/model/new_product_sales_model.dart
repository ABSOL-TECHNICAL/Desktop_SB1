// class NewProductSales {
//   // ignore: non_constant_identifier_names
//   int? Monthlytarget;
//   double? daySales;
//   double? cumulativeSales;
//   int? achSales;

//   NewProductSales({
//     // ignore: non_constant_identifier_names
//     this.Monthlytarget,
//     this.daySales,
//     this.cumulativeSales,
//     this.achSales,
//   });

//   NewProductSales.fromJson(Map<String, dynamic> json) {
//     Monthlytarget = json['Monthlytarget'];
//     daySales = double.tryParse(json['DaySales'] ?? '0');
//     cumulativeSales = double.tryParse(json['CumulativeSales'] ?? '0');
//     achSales = json['AchSales'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['Monthlytarget'] = Monthlytarget;
//     data['DaySales'] = daySales?.toString();
//     data['CumulativeSales'] = cumulativeSales?.toString();
//     data['AchSales'] = achSales;
//     return data;
//   }

//   static List<NewProductSales> listFromJson(List<dynamic> jsonList) {
//     return jsonList.map((json) => NewProductSales.fromJson(json)).toList();
//   }
// }
