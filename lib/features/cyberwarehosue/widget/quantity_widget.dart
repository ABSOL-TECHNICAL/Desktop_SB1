import 'package:flutter/material.dart';

class QuantityWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool readOnly;
  final bool enabled;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextAlign? textAlign;
  final Color? fillColor;

  const QuantityWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
    this.textAlign = TextAlign.left,
    this.fillColor, // Include fillColor in constructor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: onChanged,
        textAlign: textAlign ?? TextAlign.left,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: label,
          labelStyle: theme.textTheme.headlineLarge
              ?.copyWith(color: Colors.white, fontSize: 16),
          hintText: hintText,
          hintStyle: theme.textTheme.headlineLarge
              ?.copyWith(color: Colors.white, fontSize: 16),
          fillColor: fillColor, // Apply the custom fill color here
          filled: fillColor != null, // Fill only if fillColor is provided
        ),
        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
        cursorColor: Colors.white,
      ),
    );
  }
}
