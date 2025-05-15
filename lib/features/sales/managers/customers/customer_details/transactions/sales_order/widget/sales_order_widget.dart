import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';

class SalesorderSupplierdropdown extends StatefulWidget {
  final String label;
  final String hintText;
  final GlobalsupplierController globalSupplierController;
  final TextEditingController controller;
  final Function(int?) onSupplierSelected; // Callback for Supplier selection

  const SalesorderSupplierdropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.globalSupplierController,
    required this.onSupplierSelected, // Initialize callback
  });

  @override
  State<SalesorderSupplierdropdown> createState() =>
      _SalesorderSupplierdropdownState();
}

class _SalesorderSupplierdropdownState
    extends State<SalesorderSupplierdropdown> {
  String? selectedSupplierId; // To store selected Supplier ID
  List<dynamic> filteredSuppliers = []; // For search filtering
  bool isDropdownOpen = false; // Flag to show/hide dropdown

  @override
  void initState() {
    super.initState();

    // Initialize filtered list
    filteredSuppliers = widget.globalSupplierController.supplier;

    // Fetch supplier data if not already loaded
    if (widget.globalSupplierController.supplier.isEmpty) {
      widget.globalSupplierController.fetchSupplier().then((_) {
        setState(() {
          filteredSuppliers = widget.globalSupplierController.supplier;
        });
      });
    }
  }

  void _filterSuppliers(String query) {
    setState(() {
      filteredSuppliers = widget.globalSupplierController.supplier
          .where((supplier) =>
              supplier.supplier.toLowerCase().contains(query.toLowerCase()))
          .toList();
      isDropdownOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          if (widget.globalSupplierController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (widget.globalSupplierController.supplier.isEmpty) {
            return Center(
              child: Text(
                "No suppliers available",
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return Column(
            children: [
              TextField(
                controller: widget.controller,
                onChanged: _filterSuppliers,
                style: theme.textTheme.bodyLarge?.copyWith(
                   fontSize: 16,
                ),                
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                ),      
                                    errorStyle: const TextStyle(color: Colors.transparent),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: selectedSupplierId != null
                          ? Colors.lightBlue
                          : Colors.grey.shade400,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 0.8,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onTap: () {
                  setState(() {
                    isDropdownOpen = true;
                  });
                },
              ),
              if (isDropdownOpen)
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: filteredSuppliers.isNotEmpty ? 200 : 0,
                  ),
                  child: filteredSuppliers.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: filteredSuppliers.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  isDropdownOpen = false;
                                  selectedSupplierId =
                                      filteredSuppliers[index].supplierId;
                                  widget.controller.text =
                                      filteredSuppliers[index]
                                          .supplier
                                          .toString();
                                });
                                widget.onSupplierSelected(
                                  int.tryParse(filteredSuppliers[index]
                                      .supplierId
                                      .toString()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 14),
                                child: Text(
                                  filteredSuppliers[index].supplier.toString(),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                                    fontSize: 16,
                ),      
                                  
                                ),
                              ),
                            );
                          },
                        )
                      :  Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "No suppliers found",
                              style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16
                ),      
                              // TextStyle(
                              //     color: Colors.black54, fontSize: 16),
                            ),
                          ),
                        ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

// class SupplierSearchDropdown extends StatefulWidget {
//   final String label;
//   final String hintText;
//   final GlobalsupplierController globalSupplierController;
//   final Function(int?) onSupplierSelected; // Callback for Supplier selection

//   const SupplierSearchDropdown({
//     super.key,
//     required this.label,
//     required this.hintText,
//     required this.globalSupplierController,
//     required this.onSupplierSelected, // Initialize callback
//   });

//   @override
//   State<SupplierSearchDropdown> createState() => _SupplierSearchDropdownState();
// }

// class _SupplierSearchDropdownState extends State<SupplierSearchDropdown> {
//   final TextEditingController _customerController = TextEditingController();
//   String? selectedSupplierId; // To store selected Customer ID
//   List<dynamic> filteredSupplier = []; // For search filtering

//   @override
//   void initState() {
//     super.initState();

//     // Fetch customer data if not already loaded
//     if (widget.globalSupplierController.globalsupplierController.isEmpty) {
//       widget.globalSupplierController.fetchSupplier();
//     }

//     // Initialize filtered list
//     filteredSupplier = widget.globalSupplierController.globalsupplierController;
//   }

//   // Search filter logic

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.label,
//           style: theme.textTheme.bodyLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: isDarkMode
//                 ? Colors.white
//                 : Colors.black, // Adjusted text color for dark mode
//           ),
//         ),
//         const SizedBox(height: 8),
//         Obx(() {
//           if (widget.globalSupplierController.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (widget
//               .globalSupplierController.supplier.isEmpty) {
//             return Center(
//               child: Text(
//                 "No customers available",
//                 style: theme.textTheme.bodyLarge,
//               ),
//             );
//           } else {
//             return Container(
//               decoration: BoxDecoration(
//                 color: isDarkMode
//                     ? Colors.grey[850]
//                     : Colors.white, // Darker gray for dark mode
//                 borderRadius: BorderRadius.circular(10), // Rounded corners
//                 border: Border.all(
//                   color: isDarkMode
//                       ? Colors.blueAccent.shade400 // Softer blue for dark mode
//                       : Colors.blue.shade300, // Lighter blue for light mode
//                   width: 1.2, // Slightly thicker border
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const SizedBox(width: 8),
//                   // Dropdown button
//                   Expanded(
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         hint: Text(
//                           widget.hintText,
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             color: isDarkMode ? Colors.grey : Colors.black54,
//                           ),
//                         ),
//                         value: selectedSupplierId,
//                         icon: const Icon(Icons.arrow_drop_down),
//                         dropdownColor: isDarkMode
//                             ? Colors.grey[900]
//                             : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(10),
//                         isExpanded: true,
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedSupplierId = newValue;
//                             _customerController.text = newValue ?? '';
//                             print(selectedSupplierId);
//                           });
//                           widget.onSupplierSelected(int.tryParse(
//                               newValue ?? '')); // Pass selected customer ID
//                         },
//                         items: filteredSupplier
//                             .map<DropdownMenuItem<String>>((dynamic supplier) {
//                           return DropdownMenuItem<String>(
//                             value: supplier['SupplierId'].toString(),
//                             child: Text(
//                               supplier['Supplier'].toString(),
//                               style: TextStyle(
//                                 color: isDarkMode ? Colors.white : Colors.black,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//         }),
//       ],
//     );
//   }
// }
