import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';

class SoaPage extends StatefulWidget {
  static const String routeName = '/SoaPage';

  const SoaPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SoaPageState createState() => _SoaPageState();
}

class _SoaPageState extends State<SoaPage> {
  bool isLoading = true;
  List<double> monthlysummary = [
    20,
    40,
    10,
    70,
    5,
    95,
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    DateTime now = DateTime.now();

    // Get the month and year
    String month = DateFormat('MMMM').format(now);
    int year = now.year;
    return Material(
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        top: 100, bottom: 0), // Remove bottom padding
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16, right: 16, bottom: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 25),
                            isLoading
                                ? ShimmerCard(
                                    height:
                                        100, // Adjust height to match CustomCard
                                    borderRadius: BorderRadius.circular(16),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: isDarkMode
                                          ? LinearGradient(
                                              colors: [
                                                Colors.blueGrey
                                                    .withOpacity(0.3),
                                                Colors.blueGrey.withOpacity(0.3)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : const LinearGradient(
                                              colors: [
                                                Color(0xFF6B71FF),
                                                Color(0xFF57AEFE)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(children: [
                                              Row(
                                                children: [
                                                  Text("Farhaan Automobiles".tr,
                                                      style: theme.textTheme
                                                          .headlineLarge
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ))
                                                ],
                                              ),
                                            ]),
                                            const SizedBox(height: 10),
                                            Row(children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text("CHE456",
                                                        style: theme.textTheme
                                                            .bodySmall)
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.call,
                                                          color: Colors.white),
                                                      onPressed: () =>
                                                          launchUrl(Uri.parse(
                                                              'tel:+91 0987654321')),
                                                    ),
                                                  ]),
                                            ]),
                                            const SizedBox(height: 10),
                                             Row(
                                              children: [
                                                Text(
                                                  "10234000000123",
                                                  style: theme.textTheme.bodyLarge?.copyWith(
                                                     fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.white
                                                  )
                                                 
                                                )
                                              ],
                                            ),
                                          ]),
                                    ),
                                  ),
                            const SizedBox(height: 15),
                            isLoading
                                ? ShimmerCard(
                                    height:
                                        100, // Adjust height to match CustomCard
                                    borderRadius: BorderRadius.circular(16),
                                  )
                                : Expanded(
                                    child: SingleChildScrollView(
                                        child: Column(children: [
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Statement of Account'.tr,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          Text('for the month of $month $year',
                                              style:
                                                  theme.textTheme.titleSmall),
                                          SizedBox(height: 18),
                                          Text(
                                            'OPENING BALANCE: 134.10',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                              '-------------------------------------------------------'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const SizedBox(height: 0.5),
                                    isLoading
                                        ? ShimmerCard(
                                            height:
                                                100, // Adjust height to match CustomCard
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  _buildDivider(),
                                                  _buildTableHead(
                                                    title: 'Date / Bill #'.tr,
                                                    amount: 'Amount'.tr,
                                                  ),
                                                  _buildDivider(),
                                                  _buildTableRow(
                                                    icon: Icons.credit_card,
                                                    title: '9 Sep 2024',
                                                    date: '24/03117/CHE/111',
                                                    amount: '1,604.00',
                                                    amountColor: Colors.red,
                                                    description: 'CREDIT SALES',
                                                  ),
                                                  _buildDivider(),
                                                  _buildTableRow(
                                                    icon: Icons.credit_card,
                                                    title: '9 Sep 2024',
                                                    date: '24/03117/CHE/111',
                                                    amount: '1,604.00',
                                                    amountColor: Colors.red,
                                                    description: 'CREDIT SALES',
                                                  ),
                                                  _buildDivider(),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ]))),
                            isLoading
                                ? ShimmerCard(
                                    height:
                                        100, // Adjust height to match CustomCard
                                    borderRadius: BorderRadius.circular(16),
                                  )
                                : Center(
                                    child: Text(
                                      '-------------------------------------------------\n'
                                      'CLOSING BALANCE: 56,989.00',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                          ]),
                    ), // SizedBox()
                  ))
            ],
          )),
    );
  }

  Widget _buildTableRow({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required Color amountColor,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.grey, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  _buildTableHead({required String title, required String amount}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Divider(
      color: isDarkMode ? Colors.white60 : Colors.grey[300],
      thickness: 1,
    );
  }
}
