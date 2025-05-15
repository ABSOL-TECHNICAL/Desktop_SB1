import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:impal_desktop/features/global/theme/controller/items_controller.dart';
import 'package:impal_desktop/features/global/theme/model/item_model.dart';

class SurplusStocksWidgets {
  static Widget buildSuggestionsList(
      GlobalItemsController globalItemsController,
      Function(GlobalitemDetail) onSelectPartNumber) {
    if (globalItemsController.globalItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: globalItemsController.globalItems.length,
          itemBuilder: (context, index) {
            GlobalitemDetail item = globalItemsController.globalItems[index];
            return ListTile(
              title: Text(item.itemName ?? ''),
              onTap: () => onSelectPartNumber(item),
            );
          },
        ),
      ),
    );
  }

  static Widget buildDescriptionSuggestionsList(
      GlobalItemsController globalItemsController,
      Function(GlobalitemDetail) onSelectDescription) {
    if (globalItemsController.globalItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: globalItemsController.globalItems.length,
          itemBuilder: (context, index) {
            GlobalitemDetail item = globalItemsController.globalItems[index];
            return ListTile(
              title: Text(item.desc ?? ''),
              onTap: () => onSelectDescription(item),
            );
          },
        ),
      ),
    );
  }

  static Widget buildShimmerTable(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          12,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
              child: Row(
                children: [
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 20),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 20),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static TableRow buildTableRow(List<String> headers, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return TableRow(
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
                  Color(0xFF6B71FF),
                  Color(0xFF6B71FF),
                  Color(0xFF57AEFE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      children: headers
          .map(
            (header) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                header,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  static TableRow buildTableRow1(List<String> headers, BuildContext context) {
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
      children: headers
          .map(
            (header) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                header,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
            ),
          )
          .toList(),
    );
  }

  static TableRow buildTableRow2(List<String> headers, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return TableRow(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                colors: [
                  Colors.blueGrey.shade700,
                  Colors.grey,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFFEAEFFF),
                  Color(0xFFFAF9FF),
                  Color(0xFFEAEFFF),
                  Color(0xFFFAF9FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      children: headers
          .map(
            (header) => Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                header,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
            ),
          )
          .toList(),
    );
  }

  static Widget buildDropdownField({
    required BuildContext context,
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white,
              width: isDarkMode ? 0.8 : 0.2,
            ),
          ),
          constraints: const BoxConstraints(maxHeight: 50),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hintText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor:
                  isDarkMode ? Colors.blueGrey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildTextField({
    required BuildContext context,
    required String label,
    required String hintText,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextEditingController? controller,
    bool enabled = true,
    required ValueChanged<bool> onFocusChange,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Focus(
      onFocusChange: (hasFocus) => onFocusChange(hasFocus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: enabled ? onChanged : (value) {},
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white : Colors.grey.shade100,
                  width: isDarkMode ? 0.8 : 0.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.black : Colors.white,
                  width: 0.2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: const BoxConstraints(maxHeight: 46),
            ),
          ),
        ],
      ),
    );
  }
}
