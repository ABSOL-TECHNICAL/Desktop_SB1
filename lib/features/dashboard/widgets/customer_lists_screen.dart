import 'package:flutter/material.dart';
import 'package:impal_desktop/features/dashboard/model/map_model.dart';

class CustomerListScreen extends StatelessWidget {
  final List<Customer> customers;

  const CustomerListScreen({super.key, required this.customers});

  @override
  Widget build(BuildContext context) {
    // Separate customers based on latitude/longitude null status
    final nearbyCustomers = customers
        .where((customer) =>
            customer.latitude != null && customer.longitude != null)
        .toList();
    final uncoveredCustomers = customers
        .where((customer) =>
            customer.latitude == null || customer.longitude == null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stores based on Current Location (500M)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Customers: ${customers.length}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (nearbyCustomers.isNotEmpty) ...[
                    const Text(
                      'Customers Covered in 500M:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...nearbyCustomers
                        .map((customer) => _buildCustomerCard(customer)),
                  ],
                  if (uncoveredCustomers.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Customers Not Covered in 500M:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...uncoveredCustomers
                        .map((customer) => _buildCustomerCard(customer)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: const LinearGradient(
            colors: [Color(0xFFEAEFFF), Color(0xFFFAF9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text(
              customer.customerName?.isNotEmpty == true
                  ? customer.customerName![0]
                  : "U",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            customer.customerName ?? "Unknown Customer",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Customer ID: ${customer.customerId ?? "N/A"}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
