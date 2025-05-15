// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/cyberwarehosue/controllers/to_historycontroller.dart';

import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class TransferOrder extends StatefulWidget {
  const TransferOrder({super.key});

  @override
  _TransferOrderState createState() => _TransferOrderState();
}

class _TransferOrderState extends State<TransferOrder> {
  final ToHistoryController controller = Get.put(ToHistoryController());

  @override
  void initState() {
    super.initState();
    controller.fetchTransferHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Transfer Order History',
           style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
          // style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                if (controller.isLoading.value) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 6,
                            color: const Color(0xFFF8F8F8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 15,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: 100,
                                    height: 15,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    height: 15,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                if (controller.transferOrders.isEmpty) {
                  // Show placeholder or message when no data
                  return Expanded(
                      child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Shimmer.fromColors(
                          baseColor: const Color.fromARGB(255, 53, 51, 51),
                          highlightColor: Colors.white,
                          child: Icon(
                            Icons.search_off,
                            size: 120,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Shimmer.fromColors(
                          baseColor: const Color.fromARGB(255, 53, 51, 51),
                          highlightColor: Colors.white,
                          child:  Text(
                            'No transfer History Available for today.',
                            style:  theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 20,
                              color: Color.fromARGB(255, 10, 10, 10),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ));
                }
              }

              if (controller.transferOrders.isEmpty) {
                return Expanded(
                    child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 170),
                      Shimmer.fromColors(
                        baseColor: const Color.fromARGB(255, 53, 51, 51),
                        highlightColor: Colors.white,
                        child: Icon(
                          Icons.search_off,
                          size: 120,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Shimmer.fromColors(
                        baseColor: const Color.fromARGB(255, 53, 51, 51),
                        highlightColor: Colors.white,
                        child:  Text(
                          'No transfer History Available for today.',
                          style:  theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                            color: Color.fromARGB(255, 10, 10, 10),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: controller.transferOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.transferOrders[index];
                    final toNumber = order['ToNumber'] != null
                        ? order['ToNumber'] as String
                        : '';
                    final items = order['items'] as List;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 6,
                      color: const Color(0xFFF8F8F8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Transfer Order #: $toNumber',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              'Total Items: ${items.length}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Total Amount: ',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: items
                                        .fold<double>(
                                            0.0,
                                            (sum, item) =>
                                                sum +
                                                (item["amount"] as num)
                                                    .toDouble())
                                        .toStringAsFixed(2),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Table(
                              border: TableBorder.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Item #',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'From Location',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'To Location',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Quantity',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Amount',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Created Date',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ...List.generate(
                                  items.length,
                                  (itemIndex) {
                                    final item = items[itemIndex]
                                        as Map<String, dynamic>;

                                    final itemName = item["item"] as String;
                                    final FromLocation =
                                        item["fromlocation"] as String;
                                    final ToLocation =
                                        item["tolocation"] as String;
                                    final quantity = item["quantity"] as int;
                                    final amount = (item["amount"] is int)
                                        ? (item["amount"] as int).toDouble()
                                        : item["amount"] as double;
                                    final dateString = item["date"] as String;

                                    DateTime date;
                                    try {
                                      date = DateTime.parse(dateString);
                                    } catch (e) {
                                      date = DateFormat('dd/MM/yyyy')
                                          .parse(dateString);
                                    }

                                    final formattedDate =
                                        DateFormat('yyyy-MM-dd').format(date);

                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            itemName,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            FromLocation,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            ToLocation,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            quantity.toString(),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment: Alignment
                                                .centerRight, // Right alignment
                                            child: Text(
                                              amount.toStringAsFixed(2),
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            formattedDate,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
