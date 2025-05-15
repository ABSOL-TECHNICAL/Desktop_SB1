import 'package:flutter/material.dart';

class DropdownWidget extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  const DropdownWidget({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    List<String> uniqueItems = items.toSet().toList();
    String? selectedValue = uniqueItems.contains(value) ? value : null;
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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
          label: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style:theme.textTheme.bodyLarge?.copyWith(fontSize: 16,
                    color: Colors.black,),
                 
                ),
                if (isRequired)
                   TextSpan(
                    text: ' *',
                    
                  style:theme.textTheme.bodyLarge?.copyWith(  color: Colors.red,
                      fontWeight: FontWeight.bold,),
                   
                  ),
              ],
            ),
          ),
        ),
        value: selectedValue,
        items: uniqueItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
               style:theme.textTheme.bodyLarge?.copyWith( color: Colors.black, fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text(
          'Select $label',
         style:theme.textTheme.bodyLarge?.copyWith( color: Colors.black, fontSize: 14),
        ),
        dropdownColor: Colors.white,
        isExpanded: true,
      ),
    );
  }
}
