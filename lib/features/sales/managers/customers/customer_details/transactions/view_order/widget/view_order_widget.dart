import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/controllers/customer_details_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/view_order/controller/view_order_controller.dart';
import 'package:impal_desktop/features/sales/managers/customers/customer_details/transactions/view_order/model/view_order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ViewOrderPage extends StatefulWidget {
  static const String routeName = '/ViewOrderPage';
  final String customerName;

  const ViewOrderPage({super.key, required this.customerName});

  @override
  _ViewOrderPageState createState() => _ViewOrderPageState();
}

class _ViewOrderPageState extends State<ViewOrderPage> {
  bool isLoading = true;
  bool isSearchLoading = false;
  bool showSelectedDateWidget = false;
  String fromDate = 'Choose Date';
  String toDate = 'Choose Date';

  final CustomerDetailsController viewOrderController =
      Get.put(CustomerDetailsController());
  final ViewOrderController viewController = Get.put(ViewOrderController());
  final CustomerDetailsController customerDetailsController =
      Get.put(CustomerDetailsController());
  @override
  void initState() {
    super.initState();
    String customerId =
        customerDetailsController.selectedCustomer['CustomerId'] ?? '';
    viewController.fetchViewOrderDefault(customerId: customerId);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _onSearchButtonPressed() {
    setState(() {
      isSearchLoading = true;
      showSelectedDateWidget = true;
    });
    String customerId =
        customerDetailsController.selectedCustomer['CustomerId'] ?? '';
    viewController.fetchViewOrderSearch(
      fromDate: fromDate == 'Choose Date' ? '' : fromDate,
      toDate: toDate == 'Choose Date' ? '' : toDate,
      customerId: customerId, // Pass the customer ID
    );
    setState(() {
      isSearchLoading = false; // Set loading off after search
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _pickFromDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fromDate == 'Choose Date'
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy').parse(fromDate),
      firstDate: DateTime(2000),
      lastDate: toDate == 'Choose Date'
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy').parse(toDate),
    );

    if (pickedDate != null) {
      _onFromDatePicked(pickedDate);
    }
  }

  Future<void> _pickToDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: toDate == 'Choose Date'
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy').parse(toDate),
      firstDate: fromDate == 'Choose Date'
          ? DateTime.now()
          : DateFormat('dd/MM/yyyy').parse(fromDate),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _onToDatePicked(pickedDate);
    }
  }

  void _onFromDatePicked(DateTime pickedDate) {
    DateTime toDateTime = toDate == 'Choose Date'
        ? DateTime.now()
        : DateFormat('dd/MM/yyyy').parse(toDate);

    if (pickedDate.isAfter(toDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("From Date cannot be later than To Date.")),
      );
      return;
    }

    setState(() {
      fromDate = formatDate(pickedDate);
    });
  }

  void _onToDatePicked(DateTime pickedDate) {
    DateTime fromDateTime = fromDate == 'Choose Date'
        ? DateTime.now()
        : DateFormat('dd/MM/yyyy').parse(fromDate);

    if (pickedDate.isBefore(fromDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("To Date cannot be earlier than From Date.")),
      );
      return;
    }

    setState(() {
      toDate = formatDate(pickedDate);
    });
  }

  @override
  void dispose() {
    Get.delete<ViewOrderController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View  Orders',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 10, bottom: 0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, right: 150.0, left: 150.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        isLoading
                            ? ShimmerCard(
                                height: 150,
                                borderRadius: BorderRadius.circular(16),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: isDarkMode
                                      ? LinearGradient(
                                          colors: [
                                            Colors.blueGrey.withOpacity(0.3),
                                            Colors.blueGrey.withOpacity(0.3),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF6B71FF),
                                            Color(0xFF57AEFE),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(children: [
                                    Row(
                                      children: [
                                        Text(widget.customerName.tr,
                                            style: theme.textTheme.headlineLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('From Date'.tr,
                                                  style: theme
                                                      .textTheme.bodySmall),
                                              const SizedBox(height: 6),
                                              GestureDetector(
                                                onTap: _pickFromDate,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isDarkMode
                                                        ? Colors
                                                            .blueGrey.shade900
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 8.0),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .calendar_month,
                                                            color: Colors.grey),
                                                        const SizedBox(
                                                            width: 4.0),
                                                        Text(fromDate,
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontSize:
                                                                        13)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('To Date'.tr,
                                                  style: theme
                                                      .textTheme.bodySmall),
                                              const SizedBox(height: 6),
                                              GestureDetector(
                                                onTap: _pickToDate,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isDarkMode
                                                        ? Colors
                                                            .blueGrey.shade900
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 8.0),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .calendar_month,
                                                            color: Colors.grey),
                                                        const SizedBox(
                                                            width: 4.0),
                                                        Text(toDate,
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontSize:
                                                                        13)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _onSearchButtonPressed,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 251, 134, 45),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  90), // Smaller border radius
                                            ),
                                            minimumSize: const Size(50, 40),
                                          ),
                                          child: isSearchLoading
                                              ? CircularProgressIndicator(
                                                  color: Colors.white)
                                              : const Icon(Icons.search,
                                                  color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ]),
                                ),
                              ),
                        const SizedBox(height: 10),
                        isLoading
                            ? _buildShimmerTable()
                            : _buildDynamicTable(
                                context, viewController.viewOrder),
                      ],
                    ),
                  )))
        ],
      ),
    );
  }

  Widget _buildDynamicTable(
      BuildContext context, RxList<ViewOrderDetails> data) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Obx(() {
      if (viewController.isLoading.value) {
        return _buildShimmerTable(); // Show shimmer effect while loading
      }

      if (data.isNotEmpty) {
        return Expanded(
          child: Column(
            children: [
              // Show Date Range Widget only when first entering the page
              if (!showSelectedDateWidget) _buildDateRangeWidget(),

              // Show Selected Date Widget only after search
              if (showSelectedDateWidget)
                _buildSelectedDateWidget(fromDate, toDate),

              // Data Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        // Build the header row directly in the table
                        TableRow(
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? LinearGradient(
                                    colors: [
                                      Colors.redAccent.shade400,
                                      Colors.pink.shade900,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF57AEFE),
                                      Color(0xFF6B71FF)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          ),
                          children: [
                            _buildHeaderCell("S.No", context),
                            _buildHeaderCell("Supplier", context),
                            _buildHeaderCell("Document Number", context),
                            _buildHeaderCell("Document Date", context),
                            _buildHeaderCell("Item", context),
                            _buildHeaderCell("Quantity Committed", context),
                            _buildHeaderCell("Quantity Fulfilled", context),
                            _buildHeaderCell("Quantity Billed", context),
                          ],
                        ),
                        ...data.map<TableRow>((orderDetail) {
                          return _buildTableRow1(
                            [
                              (data.indexOf(orderDetail) + 1).toString(),
                              orderDetail.supplier ?? "N/A",
                              orderDetail.documentNumber ?? "N/A",
                              orderDetail.documentDate ?? "N/A",
                              orderDetail.item ?? "N/A",
                              orderDetail.quantityCommitted?.toString() ??
                                  "N/A",
                              orderDetail.quantityFulfilled?.toString() ??
                                  "N/A",
                              orderDetail.quantityBilled?.toString() ?? "N/A",
                            ],
                            isHeader: false,
                            context: context,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Icon(
                  Icons.search_off,
                  size: 100,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 53, 51, 51),
                highlightColor: Colors.white,
                child: Text(
                  'No results found for last three days.\nPlease refine your search criteria.',
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 10, 10, 10),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildHeaderCell(String text, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  TableRow _buildTableRow1(List<String> data,
      {required bool isHeader, required BuildContext context}) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TableRow(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                colors: [
                  Colors.blueGrey,
                  Colors.grey[900]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFFEDFFFB), // Starting color (EDFFFB)
                  Color(0xFFFAF9FF), // Ending color (FAF9FF)
                  Color(0xFFEDFFFB), // Starting color (EDFFFB)
                  Color(0xFFFAF9FF), // Ending color (FAF9FF)
                ],
                begin: Alignment.topLeft, // Gradient starting point
                end: Alignment.bottomRight, // Gradient ending point
              ),
      ),
      children: data
          .map(
            (header) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                header,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateRangeWidget() {
    final startDate = viewController.startDate.value;
    final endDate = viewController.endDate.value;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'View Order From date: $startDate and To date: $endDate',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSelectedDateWidget(String fromDate, String toDate) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'View Order selected From date: $fromDate and To date: $toDate',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity, // Full width of the screen
      padding: const EdgeInsets.all(16.0), // Padding around the card
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[850]!
            : Colors.grey[300]!, // Background color for the card
        borderRadius: BorderRadius.circular(16), // Rounded corners for the card
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.black.withOpacity(0.1), // Light shadow
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(2, 2), // Shadow offset
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          12, // Adjust the number of rows based on your requirement
          (index) => Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4.0), // Padding between rows
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: 30, // Width for the "#" column
                    height: 20, // Adjust height as needed
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 16), // Spacing between columns
                  Container(
                    width: 60, // Width for the "Line" column
                    height: 20, // Adjust height as needed
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
