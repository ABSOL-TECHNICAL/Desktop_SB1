import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCard extends StatelessWidget {
  final String? title;
  final String? amount;
  final String? custname;
  final String? custid;
  final String? custnum;
  final double? screenWidth;
  final String? selectedRecord;
  final String? dropdownLabel;
  final String? hintText;
  final List<String>? dropdownItems;
  final void Function(String?)? onRecordTypeChanged;
  final String? fromDate;
  final String? toDate;
  final String? chooseDate;
  final String? textFieldLabel;
  final void Function(String)? onTextFieldChanged;
  final String? additionalDropdownLabel;
  final List<String>? additionalDropdownItems;
  final String? additionalSelectedRecord;
  final String? additionalHintText;
  final void Function(String?)? onAdditionalRecordTypeChanged;
  final void Function(DateTime)? onFromDatePicked;
  final void Function(DateTime)? onToDatePicked;

  const CustomCard({
    super.key,
    this.title,
    this.amount,
    this.custname,
    this.custid,
    this.custnum,
    this.screenWidth,
    this.selectedRecord,
    this.dropdownLabel,
    this.hintText,
    this.dropdownItems,
    this.onRecordTypeChanged,
    this.fromDate,
    this.toDate,
    this.chooseDate,
    this.textFieldLabel,
    this.onTextFieldChanged,
    this.additionalDropdownLabel,
    this.additionalDropdownItems,
    this.additionalSelectedRecord,
    this.onAdditionalRecordTypeChanged,
    this.additionalHintText,
    this.onFromDatePicked,
    this.onToDatePicked,
  });

  Future<void> _selectDate(
      BuildContext context, void Function(DateTime)? onDatePicked) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && onDatePicked != null) {
      onDatePicked(pickedDate); // Pass the picked date back
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final double fieldWidth =
        (screenWidth ?? MediaQuery.of(context).size.width) / 2 - 32;

    bool showFilterButton =
        (dropdownItems != null && dropdownItems!.isNotEmpty) ||
            (fromDate != null && toDate != null);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDarkMode
            ? LinearGradient(
                colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade900],
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (custname != null)
                      GestureDetector(
                        onTap: () async {
                          // Implement call action
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.blueGrey.shade900
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
            if (fromDate != null && toDate != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From Date'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: fieldWidth,
                          child: GestureDetector(
                            onTap: () {
                              _selectDate(context, onFromDatePicked);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.blueGrey.shade900
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7.0, horizontal: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month,
                                        color: Colors.grey),
                                    const SizedBox(width: 4.0),
                                    Text(fromDate ?? 'MM/DD/YYYY'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To Date'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: fieldWidth,
                          child: GestureDetector(
                            onTap: () {
                              _selectDate(context, onToDatePicked);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.blueGrey.shade900
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7.0, horizontal: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month,
                                        color: Colors.grey),
                                    const SizedBox(width: 4.0),
                                    Text(toDate ?? 'MM/DD/YYYY'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            if (dropdownItems != null && dropdownItems!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      hintText: hintText ?? '',
                      value: selectedRecord,
                      items: dropdownItems!,
                      context: context,
                      onChanged: onRecordTypeChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (showFilterButton)
                    ElevatedButton(
                      onPressed: () {
                        // Implement button action here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 251, 134, 45),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              90), // Smaller border radius
                        ),
                        minimumSize: Size(50, 40),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (additionalDropdownLabel != null &&
                  additionalDropdownItems != null &&
                  additionalDropdownItems!.isNotEmpty)
                _buildDropdownField(
                  hintText: additionalHintText ?? '',
                  value: additionalSelectedRecord,
                  items: additionalDropdownItems!,
                  context: context,
                  onChanged: onAdditionalRecordTypeChanged,
                ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10), // Reduced horizontal padding
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade200,
              width: isDarkMode ? 0.9 : 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              // Reduces the height of the dropdown button
              isExpanded: true,
              value:
                  selectedRecord, // Make sure this is bound to a reactive value

              hint: Text(
                'Select customer',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14, // Reduced font size
                ),
              ),
              onChanged: onChanged,
              items: items.isNotEmpty
                  ? items
                      .toSet()
                      .toList()
                      .map<DropdownMenuItem<String>>((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList()
                  : [],
              dropdownColor:
                  isDarkMode ? Colors.blueGrey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              itemHeight: 48.0,
            ),
          ),
        ),
      ],
    );
  }
}
