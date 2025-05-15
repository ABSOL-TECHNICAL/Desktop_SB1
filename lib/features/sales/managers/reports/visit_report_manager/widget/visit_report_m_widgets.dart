import 'package:flutter/material.dart';

class VisitReportMWidget extends StatelessWidget {
  final List<Color> gradientColors;
  final bool isExpanded;
  final VoidCallback onTap;

  final String personMet;
  final String paymentMethod;
  final String amount;
  final String reportedOn;
  final String nextVisitOn;
  final String remarks;
  final String customer; // Added customer property

  const VisitReportMWidget({
    super.key,
    required this.gradientColors,
    required this.isExpanded,
    required this.onTap,
    required this.personMet,
    required this.paymentMethod,
    required this.amount,
    required this.reportedOn,
    required this.nextVisitOn,
    required this.remarks,
    required this.customer,  // Initialize the customer property
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.blue, width: 0.4),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isDarkMode
                  ? LinearGradient(
                      colors: [
                        Colors.blueGrey.shade900,
                        Colors.blueGrey.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: gradientColors,
                      stops: const [0.0, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 214, 213, 213).withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onTap,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              customer, // Display customer passed
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 23,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 10),
                    _buildDoubleRow(theme, 'Person Met', personMet, 'Payment Method', paymentMethod),
                    const SizedBox(height: 19),
                    _buildDoubleRow(theme, 'Amount', amount, 'Reported On', reportedOn),
                    const SizedBox(height: 19),
                    _buildDoubleRow(theme, 'Next Visit On', nextVisitOn, 'Remarks', remarks),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleRow(ThemeData theme, String title1, String value1, String title2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value1,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title2,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value2,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
     ],
);
}
}