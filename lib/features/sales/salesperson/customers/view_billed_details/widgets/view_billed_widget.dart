import 'package:flutter/material.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/view_billed_details/model/view_billed_model.dart';

class ViewBilledWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ViewBilledDetail> viewBilledDetails;

  const ViewBilledWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.viewBilledDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final totalPrice = _calculateTotalPrice(viewBilledDetails);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₹ ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDarkMode
                    ? Colors.blueGrey.shade800
                    : Colors.grey.shade100,
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(60),
                      1: FixedColumnWidth(150),
                      2: FixedColumnWidth(100),
                      3: FixedColumnWidth(80),
                      4: FixedColumnWidth(100),
                      5: FixedColumnWidth(100),
                      6: FixedColumnWidth(120),
                    },
                    children: _buildTable(viewBilledDetails, context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalPrice(List<ViewBilledDetail> details) {
    double total = 0.0;
    for (var detail in details) {
      if (detail.items != null) {
        for (var item in detail.items!) {
          total += double.tryParse(item.totalPrice ?? '0.00') ?? 0.0;
        }
      }
    }
    return total;
  }

  List<TableRow> _buildTable(
      List<ViewBilledDetail> details, BuildContext context) {
    List<TableRow> rows = [];

    // Table headers
    rows.add(_buildTableRow(
      ["#", "Part No", "Doc No", "Qty", "Unit Price", "Sales Price", "Total"],
      context,
      isHeader: true,
    ));

    // Table data rows
    int rowIndex = 1;
    for (var detail in details) {
      if (detail.items != null) {
        for (var item in detail.items!) {
          rows.add(_buildTableRow(
            [
              rowIndex.toString(),
              item.part ?? 'N/A',
              detail.docNo ?? 'N/A',
              item.qty ?? '0',
              item.unitPrice ?? '0.00',
              item.salesPrice ?? '0.00',
              item.totalPrice ?? '0.00'
            ],
            context,
            isHeader: false,
            isEvenRow: rowIndex.isEven,
          ));
          rowIndex++;
        }
      }
    }

    return rows;
  }

  TableRow _buildTableRow(List<String> data, BuildContext context,
      {bool isHeader = false, bool isEvenRow = false}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TableRow(
      decoration: BoxDecoration(
        color: isHeader
            ? (isDarkMode ? Colors.blueGrey.shade700 : Colors.blue.shade700)
            : (isEvenRow
                ? (isDarkMode ? Colors.blueGrey.shade800 : Colors.grey.shade200)
                : (isDarkMode ? Colors.blueGrey.shade900 : Colors.white)),
        borderRadius: isHeader ? BorderRadius.circular(10) : null,
      ),
      children: data.map((text) {
        return Padding(
          padding:
              EdgeInsets.symmetric(vertical: isHeader ? 4 : 10, horizontal: 12),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isHeader ? 14 : 14,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ),
        );
      }).toList(),
    );
  }
}
