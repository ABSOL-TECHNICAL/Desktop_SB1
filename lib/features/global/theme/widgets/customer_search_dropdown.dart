import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/controller/customer_controller.dart';

class CustomerSearchDropdown extends StatefulWidget {
  // final String label;
  final Widget label;
  final String hintText;
  final GlobalcustomerController globalcustomerController;
  final Function(int? customerId, String? customerName) onCustomerSelected;

  const CustomerSearchDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.globalcustomerController,
    required this.onCustomerSelected,
  });

  @override
  State<CustomerSearchDropdown> createState() => _CustomerSearchDropdownState();
}

class _CustomerSearchDropdownState extends State<CustomerSearchDropdown> {
  final TextEditingController _customerController = TextEditingController();
  String? selectedCustomerId; // Store selected Customer ID as a string
  List<dynamic> filteredCustomers = []; // List of filtered customers
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();

    // Fetch customers if not already loaded
    if (widget.globalcustomerController.globalcustomerController.isEmpty) {
      widget.globalcustomerController.fetchCustomer();
    }

    // Initialize filtered customers
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
      isDropdownOpen = query.isNotEmpty; // Open dropdown if query is not empty
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   widget.label,
        //   style: theme.textTheme.bodyLarge?.copyWith(
        //     fontWeight: FontWeight.bold,
        //     color: isDarkMode ? Colors.white : Colors.black,
        //   ),
        // ),
        widget.label,
        const SizedBox(height: 8),
        Obx(() {
          if (widget.globalcustomerController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (widget
              .globalcustomerController.globalcustomerController.isEmpty) {
            return Center(
              child: Text(
                "No customers available",
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else {
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
                        width: 0.2,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onTap: () {
                    setState(() {
                      isDropdownOpen = true; // Open dropdown on tap
                    });
                  },
                ),
                if (isDropdownOpen)
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.blueAccent.shade400
                            : Colors.blue.shade300,
                        width: 1.2,
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 200,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isDropdownOpen = false; // Close dropdown
                              selectedCustomerId = filteredCustomers[index]
                                      ['CustomerId']
                                  .toString();
                              _customerController.text =
                                  filteredCustomers[index]['Customer']
                                      .toString();
                            });
                            widget.onCustomerSelected(
                              int.tryParse(filteredCustomers[index]
                                      ['CustomerId']
                                  .toString()),
                              filteredCustomers[index]['Customer'].toString(),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 14),
                            child: Text(
                              filteredCustomers[index]['Customer'].toString(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }
        }),
      ],
    );
  }
}
