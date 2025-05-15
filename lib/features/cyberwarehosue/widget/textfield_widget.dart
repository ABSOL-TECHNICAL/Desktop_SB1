import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool readOnly;
  final bool enabled;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextAlign? textAlign;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
    this.textAlign = TextAlign.left,
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
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: label,
          labelStyle: theme.textTheme.headlineLarge
              ?.copyWith(color: Colors.black, fontSize: 16),
          hintText: hintText,
          hintStyle: theme.textTheme.headlineLarge
              ?.copyWith(color: Colors.black, fontSize: 14),
          fillColor: readOnly ? Colors.grey.shade300 : null,
          filled: readOnly,
        ),
          style:theme.textTheme.bodyLarge?.copyWith( color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
           cursorColor: Colors.black,
      ),
    );
  }
}
