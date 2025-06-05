import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';

class CustomerDropdownestimate extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final GlobalcustomerController globalcustomerController;
  final Function(int?) onCustomerSelected;

  const CustomerDropdownestimate({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    required this.globalcustomerController,
    required this.onCustomerSelected,
  });

  @override
  State<CustomerDropdownestimate> createState() => _CustomerDropdownestimateState();
}

class _CustomerDropdownestimateState extends State<CustomerDropdownestimate> {
  String? selectedCustomerId;
  List<dynamic> filteredCustomers = [];
  bool isDropdownOpen = false;
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();

    if (widget.globalcustomerController.globalcustomerController.isEmpty) {
      widget.globalcustomerController.fetchCustomer();
    }
    filteredCustomers =
        widget.globalcustomerController.globalcustomerController;
  }

  void _filterCustomers(String query) {
    setState(() {
      filteredCustomers = widget
          .globalcustomerController.globalcustomerController
          .where((customer) => customer['Customer']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      isDropdownOpen = query.isNotEmpty;
    });
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
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (widget.globalcustomerController.isLoading.value) {
            return _buildShimmerEffect();
          } else if (widget
              .globalcustomerController.globalcustomerController.isEmpty) {
            return Center(
              child: Text(
                "No customers available",
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            );
          }

          return Column(
            children: [
              TextField(
                controller: _internalController,
                onChanged: _filterCustomers,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                 
                  errorStyle: const TextStyle(color: Colors.transparent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: selectedCustomerId != null
                          ? Colors.lightBlue
                          : Colors.brown.shade400,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 26, 25, 25),
                      width: 1,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxHeight: filteredCustomers.isNotEmpty ? 200 : 50,
                  ),
                  child: filteredCustomers.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  isDropdownOpen = false;
                                  selectedCustomerId =
                                      filteredCustomers[index]['CustomerId'];
                                  _internalController.text =
                                      filteredCustomers[index]['Customer']
                                          .toString();
                                });
                                widget.onCustomerSelected(
                                  int.tryParse(filteredCustomers[index]
                                          ['CustomerId']
                                      .toString()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Text(
                                  filteredCustomers[index]['Customer']
                                      .toString(),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                     fontWeight: FontWeight.normal,
                                     fontSize: 16,
                                  )
                                  // const TextStyle(
                                  //   color: Colors.black,
                                  //   fontWeight: FontWeight.normal,
                                  //   fontSize: 16,
                                  // ),
                                ),
                              ),
                            );
                          },
                        )
                      :  Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "No customers found",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                    
                                     fontSize: 16,
                                  )
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
