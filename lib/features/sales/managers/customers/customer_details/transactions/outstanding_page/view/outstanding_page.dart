import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/controllers/customer_details_controller.dart';

class OsPage extends StatefulWidget {
  static const String routeName = '/OsPage';

  const OsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OsPageState createState() => _OsPageState();
}

class _OsPageState extends State<OsPage> {
  final CustomerDetailsController outstandingController =
      Get.put(CustomerDetailsController());
  bool isLoading = true;
  final bool _hideSensitiveData = false;

  @override
  void initState() {
    super.initState();

    outstandingController.fetchOutstandingDetails().then((_) {
      setState(() {
        isLoading = false; // Update UI after fetching data
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Outstanding Details',
          style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });

              outstandingController.fetchOutstandingDetails().then((_) {
                setState(() {
                  isLoading = false;
                });
                AppSnackBar.success(message: "Data refreshed successfully!");
              });
            },
          ),
        ],
      ),
      body: Stack(children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: screenWidth,
            padding: const EdgeInsets.only(top: 30, bottom: 0),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 16.0, right: 150.0, left: 150.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isDarkMode
                              ? LinearGradient(
                                  colors: [
                                    Colors.blueGrey.withOpacity(0.3),
                                    Colors.blueGrey.withOpacity(0.3)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      outstandingController
                                              .outstandingDetails.isNotEmpty
                                          ? outstandingController
                                              .outstandingDetails[0]
                                                  ['CustomerName']
                                              .toString()
                                          : 'Name',
                                      style: theme.textTheme.bodyLarge?.copyWith(      
                    fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: Colors.white,
                ),
                                      // TextStyle(
                                      //   fontWeight: FontWeight.bold,
                                      //   fontSize: 19,
                                      //   color: Colors.white,
                                      // ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    outstandingController
                                            .outstandingDetails.isNotEmpty
                                        ? outstandingController
                                                .outstandingDetails[0]['Phone']
                                                ?.toString() ??
                                            'No Mobile Number Found'
                                        : 'No Mobile Number Found',
                                    style: theme.textTheme.bodyLarge?.copyWith(      
                       fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                ),
                                    // TextStyle(
                                    //   fontWeight: FontWeight.bold,
                                    //   fontSize: 15,
                                    //   color: Colors.white,
                                    // ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: Column(
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDarkMode
                                    ? Colors.blue.shade200
                                    : Colors.blue,
                                width: 0.4,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: isDarkMode
                                    ? LinearGradient(
                                        colors: [
                                          Colors.blueGrey.shade900,
                                          Colors.blueGrey.shade900,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : RadialGradient(
                                        colors: [
                                          const Color(0xFFFFFFFF),
                                          const Color(0xFFF9F9FF),
                                        ],
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode
                                        ? Colors.blueGrey.shade800
                                        : const Color.fromARGB(
                                                255, 214, 213, 213)
                                            .withOpacity(0.2),
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
                                    Obx(
                                      () {
                                        final outstandingData =
                                            outstandingController
                                                    .outstandingDetails
                                                    .isNotEmpty
                                                ? outstandingController
                                                    .outstandingDetails[0]
                                                : {};

                                        final outstandingAmount =
                                            (outstandingData['Outstanding']
                                                        ?.toString()
                                                        .trim()
                                                        .isEmpty ??
                                                    true)
                                                ? '0.00'
                                                : outstandingData['Outstanding']
                                                        ?.toString() ??
                                                    '0.00';

                                        final days0to30Amount =
                                            (outstandingData['Days0to30']
                                                        ?.toString()
                                                        .trim()
                                                        .isEmpty ??
                                                    true)
                                                ? '0.00'
                                                : outstandingData['Days0to30']
                                                        ?.toString() ??
                                                    '0.00';

                                        return Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Outstanding',
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    outstandingAmount,
                                                    style: theme
                                                        .textTheme.bodyLarge,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '0-30 Days',
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    (days0to30Amount
                                                            .trim()
                                                            .isEmpty)
                                                        ? '0.00'
                                                        : days0to30Amount,
                                                    style: theme
                                                        .textTheme.bodyLarge,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '31-60 Days'.tr,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (outstandingController
                                                            .outstandingDetails
                                                            .isNotEmpty &&
                                                        outstandingController
                                                            .outstandingDetails[
                                                                0]['Days31to60']
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty)
                                                    ? outstandingController
                                                        .outstandingDetails[0]
                                                            ['Days31to60']
                                                        .toString()
                                                    : '0.00',
                                                style:
                                                    theme.textTheme.bodyLarge,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '61-90 Days'.tr,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (outstandingController
                                                            .outstandingDetails
                                                            .isNotEmpty &&
                                                        outstandingController
                                                            .outstandingDetails[
                                                                0]['Days61to90']
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty)
                                                    ? outstandingController
                                                        .outstandingDetails[0]
                                                            ['Days61to90']
                                                        .toString()
                                                    : '0.00',
                                                style:
                                                    theme.textTheme.bodyLarge,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '91-180 Days'.tr,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (outstandingController
                                                            .outstandingDetails
                                                            .isNotEmpty &&
                                                        outstandingController
                                                            .outstandingDetails[
                                                                0]
                                                                ['Days91to180']
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty)
                                                    ? outstandingController
                                                        .outstandingDetails[0]
                                                            ['Days91to180']
                                                        .toString()
                                                    : '0.00',
                                                style:
                                                    theme.textTheme.bodyLarge,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Above 180 Days'.tr,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (outstandingController
                                                            .outstandingDetails
                                                            .isNotEmpty &&
                                                        outstandingController
                                                            .outstandingDetails[
                                                                0]
                                                                ['Above180Days']
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty)
                                                    ? outstandingController
                                                        .outstandingDetails[0]
                                                            ['Above180Days']
                                                        .toString()
                                                    : '0.00',
                                                style:
                                                    theme.textTheme.bodyLarge,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    ClipRect(
                                      child: BackdropFilter(
                                        filter: _hideSensitiveData
                                            ? ImageFilter.blur(
                                                sigmaX: 10.0, sigmaY: 10.0)
                                            : ImageFilter.blur(
                                                sigmaX: 0, sigmaY: 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Credit Limit'.tr,
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _hideSensitiveData
                                                        ? '*'
                                                        : (outstandingController
                                                                    .outstandingDetails
                                                                    .isNotEmpty &&
                                                                outstandingController
                                                                    .outstandingDetails[
                                                                        0][
                                                                        'CreditLimit']
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty)
                                                            ? outstandingController
                                                                .outstandingDetails[
                                                                    0][
                                                                    'CreditLimit']
                                                                .toString()
                                                            : '0.00',
                                                    style: theme
                                                        .textTheme.bodyLarge,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Credit Balance'.tr,
                                                    style: theme
                                                        .textTheme.bodyLarge
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _hideSensitiveData
                                                        ? '*'
                                                        : (outstandingController
                                                                    .outstandingDetails
                                                                    .isNotEmpty &&
                                                                outstandingController
                                                                    .outstandingDetails[
                                                                        0][
                                                                        'CreditBalance']
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty)
                                                            ? outstandingController
                                                                .outstandingDetails[
                                                                    0][
                                                                    'CreditBalance']
                                                                .toString()
                                                            : '0.00',
                                                    style: theme
                                                        .textTheme.bodyLarge,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Can Bill UpTo'.tr,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _hideSensitiveData
                                                    ? '*'
                                                    : (outstandingController
                                                                .outstandingDetails
                                                                .isNotEmpty &&
                                                            outstandingController
                                                                .outstandingDetails[
                                                                    0][
                                                                    'CanBillUpTo']
                                                                .toString()
                                                                .trim()
                                                                .isNotEmpty)
                                                        ? outstandingController
                                                            .outstandingDetails[
                                                                0]
                                                                ['CanBillUpTo']
                                                            .toString()
                                                        : '0.00',
                                                style:
                                                    theme.textTheme.bodyLarge,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}
