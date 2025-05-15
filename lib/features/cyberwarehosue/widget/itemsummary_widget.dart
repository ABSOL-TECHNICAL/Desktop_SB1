import 'package:flutter/material.dart';

class ItemSummaryWidget extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> addedItems;

  const ItemSummaryWidget({
    super.key,
    required this.theme,
    required this.addedItems,
  });

  @override
  Widget build(BuildContext context) {
    double totalAmount = addedItems.fold(0, (sum, item) {
      double amount = double.tryParse(item['amount'] ?? '0') ?? 0;
      return sum + amount;
    });

    int totalItemCount = addedItems.length;
      final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black, // Black background for the container
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2), // White border
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 4), // Soft shadow for depth
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Item Summary".toUpperCase(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for the title
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "($totalItemCount)".toUpperCase(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for the item count
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors
                    .grey.shade800, // Dark grey background for section headers
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.white, width: 1), // White border
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "ITEM DESCRIPTION",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // White text
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "QTY",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // White text
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "AMOUNT",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // White text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            ...addedItems.map((item) {
              return Card(
                elevation: 4, // Subtle shadow for cards
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: Colors.black87, // Dark background for cards
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: SummaryRowWidget(
                    theme: theme,
                    item: item['name'] ?? 'N/A',
                    qty: item['quantity'] ?? 'N/A',
                    amount: item['amount'] ?? 'N/A',
                  ),
                ),
              );
            }),
            const SizedBox(height: 12.0),
            Divider(
              color:
                  Colors.white.withOpacity(0.2), // Light divider for separation
              thickness: 1.2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Total",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // White text for total
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    totalAmount.toStringAsFixed(2),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // White text for total amount
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryRowWidget extends StatelessWidget {
  final ThemeData theme;
  final String item;
  final String qty;
  final String amount;

  const SummaryRowWidget({
    super.key,
    required this.theme,
    required this.item,
    required this.qty,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the row
      children: [
        Expanded(
          child: Text(
            item,
            textAlign: TextAlign.center, // Center text
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white, // White text
            ),
          ),
        ),
        Expanded(
          child: Text(
            qty,
            textAlign: TextAlign.center, // Center text
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white, // White text
            ),
          ),
        ),
        Expanded(
          child: Text(
            amount,
            textAlign: TextAlign.center, // Center text
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white, // White text
            ),
          ),
        ),
      ],
    );
  }
}
