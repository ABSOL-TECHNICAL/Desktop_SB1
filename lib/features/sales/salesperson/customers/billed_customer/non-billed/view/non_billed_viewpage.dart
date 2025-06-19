import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
import 'package:impal_desktop/features/sales/salesperson/customers/billed_customer/non-billed/controller/nonbilled_controller.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/global/theme/widgets/shimmer_widget.dart';

class NonBilledScreen extends StatefulWidget {
  static const String routeName = '/NonBilledScreen';

  const NonBilledScreen({super.key});

  @override
  _NonBilledScreenState createState() => _NonBilledScreenState();
}

class _NonBilledScreenState extends State<NonBilledScreen> {
  NonbilledController _controller = Get.put(NonbilledController());
  bool isLoading = true;
  String searchQuery = '';
  String fromDate = 'Choose From Date';
  String toDate = 'Choose To Date';
  RxString fromdate = ''.obs;
  RxString todate = ''.obs;
  
  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print("Initializing NonbilledController...");
    _controller = Get.put(NonbilledController());

    print("Simulating loading state...");
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        print("Loading complete, isLoading set to false.");
      });
    });
    _controller.fetchNonBilled();
  }

  @override
  void dispose() {
    if (Get.isRegistered<NonbilledController>()) {
      print("Disposing NonbilledController...");
      Get.delete<NonbilledController>();
    } else {
      print("NonbilledController is not registered, no need to dispose.");
    }
    super.dispose();
    print("NonBilledScreen disposed.");
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      _currentPage = 1; // Reset to first page when searching
    });
  }

  List<dynamic> _filteredCustomers() {
    if (searchQuery.isEmpty) return _controller.nonbilledCustomer;
    return _controller.nonbilledCustomer.where((customer) {
      return customer["DealoreCode"]
              ?.toLowerCase()
              ?.contains(searchQuery.toLowerCase()) ??
          false ||
              customer["Address"]
                  ?.toLowerCase()
                  ?.contains(searchQuery.toLowerCase()) ??
          false;
    }).toList();
  }

  List<dynamic> _getPaginatedData(List<dynamic> fullData) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return fullData.sublist(
      startIndex,
      endIndex > fullData.length ? fullData.length : endIndex,
    );
  }

  Future<void> _pickFromDate() async {
    DateTime pickedDate;
    if (fromDate != 'Choose From Date') {
      pickedDate = DateFormat('dd/MM/yyyy').parse(fromDate);
    } else {
      pickedDate = DateTime.now();
    }

    DateTime? newPickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (newPickedDate != null) {
      _onFromDatePicked(newPickedDate);
    }
  }

  Future<void> _pickToDate() async {
    DateTime pickedDate;
    if (toDate != 'Choose To Date') {
      pickedDate = DateFormat('dd/MM/yyyy').parse(toDate);
    } else {
      pickedDate = DateTime.now();
    }

    DateTime? newPickedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (newPickedDate != null) {
      _onToDatePicked(newPickedDate);
    }
  }

  void _onFromDatePicked(DateTime pickedDate) {
    if (toDate != 'Choose To Date' &&
        pickedDate.isAfter(DateFormat('dd/MM/yyyy').parse(toDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("From Date cannot be later than To Date.")),
      );
      return;
    }

    setState(() {
      fromDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      _currentPage = 1; // Reset to first page when changing date
    });
  }

  void _onToDatePicked(DateTime pickedDate) {
    if (fromDate != 'Choose From Date' &&
        pickedDate.isBefore(DateFormat('dd/MM/yyyy').parse(fromDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("To Date cannot be earlier than From Date.")),
      );
      return;
    }

    setState(() {
      toDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      _currentPage = 1; // Reset to first page when changing date
    });
  }

  Widget _buildPaginationControls(int totalPages) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage = 1;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),

          // Page number input
          Container(
            width: 80,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: TextField(
              controller: TextEditingController(text: _currentPage.toString()),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value) ?? _currentPage;
                if (page >= 1 && page <= totalPages) {
                  setState(() {
                    _currentPage = page;
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                }
              },
            ),
          ),

          Text(
            'of $totalPages',
            style: theme.textTheme.bodyMedium,
          ),

          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage = totalPages;
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                : null,
          ),

          const SizedBox(width: 16),
          Text(
            'Total: $totalPages pages',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'UnBilled Details',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
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
                padding: const EdgeInsets.only(top: 16.0, right: 150.0, left: 150.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    isLoading
                        ? ShimmerCard(
                            height: 100,
                            borderRadius: BorderRadius.circular(16),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: isDarkMode
                                  ? LinearGradient(
                                      colors: [
                                        Colors.blueGrey.shade900,
                                        Colors.blueGrey.shade900
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [Color(0xFF6B71FF), Color(0xFF57AEFE)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Unbilled Customers  -  ".tr,
                                        style: theme.textTheme.headlineLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Obx(() {
                                        final filteredLength = _filteredCustomers().length;
                                        return Text(
                                          filteredLength.toString(),
                                          style: theme.textTheme.headlineLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'From Date',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            GestureDetector(
                                              onTap: _pickFromDate,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Colors.blueGrey.shade800
                                                      : Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.grey.shade300),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10.0, horizontal: 8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, color: Colors.grey),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      fromDate,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                              'To Date',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            GestureDetector(
                                              onTap: _pickToDate,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Colors.blueGrey.shade800
                                                      : Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.grey.shade300),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10.0, horizontal: 8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, color: Colors.grey),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      toDate,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            if (fromDate == 'Choose From Date' && toDate == 'Choose To Date') {
                                              await _controller.fetchNonBilled();
                                            } else if (fromDate != 'Choose From Date' && toDate != 'Choose To Date') {
                                              final from = DateFormat('dd/MM/yyyy').parse(fromDate);
                                              final to = DateFormat('dd/MM/yyyy').parse(toDate);
                                              
                                              await _controller.fetchNonBilled(
                                                fromDate: DateFormat('dd/MM/yyyy').format(from),
                                                toDate: DateFormat('dd/MM/yyyy').format(to),
                                              );
                                            } else {
                                              AppSnackBar.alert(message: "Please select both dates or none");
                                            }
                                          } catch (e) {
                                            AppSnackBar.alert(message: "Error: ${e.toString()}");
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 251, 134, 45),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(90),
                                          ),
                                          minimumSize: const Size(50, 45),
                                        ),
                                        child: Obx(() {
                                          return _controller.isLoading.value
                                              ? const SizedBox(
                                                  width: 24.0,
                                                  height: 24.0,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.0,
                                                  ),
                                                )
                                              : const Icon(Icons.search, color: Colors.white);
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(height: 15),
                    GlobalSearchField(
                      hintText: 'Search Customers...'.tr,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 10),
                  Obx(() {
  if (_controller.isLoading.value) {
    return _buildShimmerTable();
  } else if (_filteredCustomers().isEmpty) {
    return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 70),
                              Shimmer.fromColors(
                                baseColor: const Color.fromARGB(255, 53, 51, 51),
                                highlightColor: Colors.white,
                                child: Icon(
                                  Icons.search_off,
                                  size: 100,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Shimmer.fromColors(
                                baseColor: const Color.fromARGB(255, 53, 51, 51),
                                highlightColor: Colors.white,
                                child: Text(
                                  'No results found.\nPlease refine your search criteria.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    color: const Color.fromARGB(255, 10, 10, 10),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final filteredData = _filteredCustomers();
                        final paginatedData = _getPaginatedData(filteredData);
                        final totalPages = (filteredData.length / _itemsPerPage).ceil();

                         return Expanded(  // Added Expanded here
                       child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Container(
                                  padding: const EdgeInsets.all(3.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: 1000,
                                      child: Table(
                                        defaultColumnWidth: const IntrinsicColumnWidth(),
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              gradient: isDarkMode
                                                  ? LinearGradient(
                                                      colors: [
                                                        Colors.redAccent.shade400,
                                                        Colors.pink.shade900
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
                                              _buildHeaderCell("Customer code / Name", context),
                                              _buildHeaderCell("Address", context),
                                              _buildHeaderCell("Last Billed Date", context),
                                              _buildHeaderCell("Credit Limit", context),
                                            ],
                                          ),
                                          ...paginatedData
                                              .asMap()
                                              .entries
                                              .map<TableRow>((entry) {
                                            int index = entry.key;
                                            Map<String, dynamic> customer = entry.value;
                                            return _buildTableRow1(
                                              [
                                                ((_currentPage - 1) * _itemsPerPage + index + 1).toString(),
                                                customer["DealoreCode"] ?? "",
                                                customer["Address"] ?? "",
                                                customer["LastBillDate"] ?? "",
                                                customer["CreditAmount"] ?? "",
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
                              ),
                            ),
                            _buildPaginationControls(totalPages),
                          ],
                       ),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
    final isDarkMode = theme.brightness == Brightness.dark;

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
                  Color(0xFFEDFFFB),
                  Color(0xFFFAF9FF),
                  Color(0xFFEDFFFB),
                  Color(0xFFFAF9FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      children: data
          .map(
            (dataItem) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                dataItem,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildShimmerTable() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
              child: Container(
                height: 20,
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}