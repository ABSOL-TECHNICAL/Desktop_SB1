import 'package:flutter/material.dart';

class TextAreaWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller; // Optional controller
  final bool readOnly; // Add the readOnly property to make it optional
  final bool enabled; // Make enabled property available
  final TextInputType? keyboardType; // Optional keyboardType parameter
  final ValueChanged<String>? onChanged; // Optional onChanged callback
  final TextAlign? textAlign; // Optional text alignment
  final int? maxLines; // Set max lines for textarea functionality
  final int? minLines; // Set min lines for textarea functionality

  const TextAreaWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.controller, // Optional controller
    this.readOnly = false, // Default to false if not provided
    this.enabled = true, // Default to true if not provided
    this.keyboardType, // Optional parameter
    this.onChanged, // Optional onChanged callback
    this.textAlign = TextAlign.left, // Default to left alignment
    this.maxLines = 5, // Default max lines for textarea
    this.minLines = 1,
    required int maxlines, // Default min lines for textarea
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 18), // Increased vertical padding
      child: TextField(
        controller: controller, // Use the provided controller
        readOnly: readOnly, // Apply the readOnly property
        enabled: enabled, // Use the enabled property
        keyboardType:
            keyboardType ?? TextInputType.multiline, // Multiline keyboard
        onChanged: onChanged, // Add the onChanged callback here
        textAlign: textAlign ?? TextAlign.left, // Apply text alignment
        maxLines: maxLines, // Apply max lines for textarea behavior
        minLines: minLines, // Apply min lines for textarea behavior
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12), // Increased padding inside the field
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white), // Sharp borders
            borderRadius: BorderRadius.circular(8), // Slight border radius
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.white), // Border color when enabled
            borderRadius: BorderRadius.circular(8), // Slight border radius
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.white), // Border color when disabled
            borderRadius: BorderRadius.circular(8), // Slight border radius
          ),
          labelText: label,
          labelStyle: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 16), // Slightly larger font size for label
          hintText: hintText,
          hintStyle: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 16), // Slightly larger font size for hint text
          fillColor: readOnly && !enabled
              ? const Color.fromARGB(255, 26, 25, 25)
              : null, // Light ash grey when read-only and disabled
          filled: readOnly &&
              !enabled, // Fill the field with color when read-only and disabled
        ),
        style:theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
        cursorColor: Colors.white,
      ),
    );
  }
}
