import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/supplier_controller.dart';

class Supplierdropdown extends StatefulWidget {
  final String label;
  final String hintText;
  final GlobalsupplierController globalSupplierController;
  final Function(int?) onSupplierSelected;

  const Supplierdropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.globalSupplierController,
    required this.onSupplierSelected,
  });

  @override
  State<Supplierdropdown> createState() => _SupplierdropdownState();
}

class _SupplierdropdownState extends State<Supplierdropdown> {
  final TextEditingController _supplierController = TextEditingController();
  String? selectedSupplierId;
  List<dynamic> filteredSuppliers = [];
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    filteredSuppliers = widget.globalSupplierController.supplier;
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
      isDropdownOpen = query.isNotEmpty;
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
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Obx(() {
          if (widget.globalSupplierController.isLoading.value) {
            return Column(
              children: List.generate(1, (index) => _buildShimmerEffect()),
            );
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
                controller: _supplierController,
                onChanged: _filterSuppliers,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  errorStyle: theme.textTheme.bodyLarge,
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
                    maxHeight: filteredSuppliers.isNotEmpty ? 200 : 50,
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
                                  _supplierController.text =
                                      filteredSuppliers[index]
                                          .supplier
                                          .toString();
                                });
                                int? supplierId = int.tryParse(
                                    filteredSuppliers[index]
                                        .supplierId
                                        .toString());
                                print("Selected Supplier ID: $supplierId");
                                widget.onSupplierSelected(supplierId);
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
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "No suppliers found",
                              style: theme.textTheme.bodyLarge?.copyWith
                              ( fontSize: 16),
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

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
