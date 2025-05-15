import 'package:flutter/material.dart';
import 'package:impal_desktop/features/global/theme/widgets/custom_alert.dart';

class ItemSummary extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;

  const ItemSummary(this.item, {super.key, required this.onDelete});

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Are you sure?',
          message: 'Do you want to delete this data?',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () {
            onDelete();
            Navigator.of(context).pop();
          },
          showOkButton: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (item['inventoryItems'] != null && item['inventoryItems'] is String) {
      try {} catch (e) {
        print('Error decoding inventoryItems: $e');
      }
    }
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        color: Colors.black,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns:  [
                DataColumn(
                  label: Text(
                    'Item Name',
                     style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white, fontWeight: FontWeight.bold),
                   
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Quantity',
                    style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Units',
                   style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Rate',
                   style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text(
                      '${item['name'] ?? 'N/A'}',
                      style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white),
                    )),
                    DataCell(Text(
                      '${item['quantity'] ?? 'N/A'}',
                      style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white),
                    )),
                    DataCell(Text(
                      '${item['units'] ?? 'N/A'}',
                      style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white),
                    )),
                    DataCell(Text(
                      '${item['rate'] ?? 'N/A'}',
                      style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white),
                    )),
                    DataCell(Text(
                      '${item['amount'] ?? 'N/A'}',
                      style:theme.textTheme.bodyLarge?.copyWith( color: Colors.white),
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              _showDeleteConfirmationDialog(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
