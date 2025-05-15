import 'package:flutter/material.dart';

class GlobalSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const GlobalSearchField({
    super.key,
    this.hintText = "Search here...",
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: Colors.blueAccent, size: 24),
        hintText: hintText,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: isDarkMode ? Colors.white : Colors.grey.shade600,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: isDarkMode ? Colors.white : Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
