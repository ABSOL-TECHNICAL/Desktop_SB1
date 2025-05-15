import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';
import 'package:shimmer/shimmer.dart';

class CardCustomerDropdown extends StatefulWidget {
  final String label;
  final String hintText;
  final GlobalcustomerController globalcustomerController;
  final Function(int?) onCustomerSelected;

  const CardCustomerDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.globalcustomerController,
    required this.onCustomerSelected,
  });

  @override
  State<CardCustomerDropdown> createState() => _CustomerDropdownState();
}

class _CustomerDropdownState extends State<CardCustomerDropdown> {
  final TextEditingController _customerController = TextEditingController();
  String? selectedCustomerId;
  List<dynamic> filteredCustomers = [];
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Obx(() {
          if (widget.globalcustomerController.isLoading.value) {
            return _buildShimmerEffect();
          } else if (widget
              .globalcustomerController.globalcustomerController.isEmpty) {
            return Center(
              child: Text(
                "No customers available",
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return Column(
            children: [
              TextField(
                controller: _customerController,
                onChanged: _filterCustomers,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  errorStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.transparent),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: selectedCustomerId != null
                          ? Colors.lightBlue
                          : Colors.brown.shade400,
                      width: 0.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 26, 25, 25),
                      width: 0.5,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
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
                                  _customerController.text =
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
                                    vertical: 6, horizontal: 14),
                                child: Text(
                                  filteredCustomers[index]['Customer']
                                      .toString(),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.black,
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
                              "No customers found",
                              style:theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.black54, fontSize: 16),
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
