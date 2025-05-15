// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';

// class CustomDropDownField extends StatelessWidget {
//   final String label;
//   final String hint;
//   final bool isRequired;
//   final List<String> items;
//   final String? value;
//   final Function(String?)? onChanged;
//   final String? errorText;

//   const CustomDropDownField({
//     super.key,
//     required this.label,
//     required this.hint,
//     required this.isRequired,
//     required this.items,
//     this.value,
//     this.onChanged,
//     this.errorText,
//   });

//   @override
//   Widget build(BuildContext context) {
//      final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//             // style: const TextStyle(
//             //   fontSize: 12,
//             //   fontWeight: FontWeight.bold,
//             //   color: Colors.black,
//             // ),
//             style:theme.textTheme.bodyLarge?.copyWith( fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black,),
//             children: [
//               if (isRequired)
//                  TextSpan(
//                   text: ' *',
//                   style:theme.textTheme.bodyLarge?.copyWith( color: Colors.red, fontSize: 15),
//                   // style: TextStyle(color: Colors.red, fontSize: 15),
                  
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 3),
//         SizedBox(
//           height: 40,
//           child: DropdownSearch<String>(
//             selectedItem: value,
//             items: items,
//             popupProps: PopupProps.menu(
//               showSearchBox: true,
//               fit: FlexFit.loose,
//               menuProps: MenuProps(
//                 backgroundColor: Colors.white,
//                 elevation: 2,
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(5)),
//                 ),
//               ),
//               searchFieldProps: TextFieldProps(
//                 style: const TextStyle(fontSize: 12),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   hintText: "Search...",
//                   contentPadding:
//                       const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                   border: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.grey, width: 1),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.grey, width: 1),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide:
//                         const BorderSide(color: Colors.blue, width: 1.5),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//               ),
//               itemBuilder: (context, item, isSelected) => Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//                 child: Text(
//                   item,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             ),
//             dropdownDecoratorProps: DropDownDecoratorProps(
//               dropdownSearchDecoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 hintText: hint,
//                 hintStyle: const TextStyle(fontSize: 12),
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                 border: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.grey, width: 1),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.grey, width: 1),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.blue, width: 1.5),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//             ),
//             dropdownBuilder: (context, selectedItem) => Padding(
//               padding: const EdgeInsets.only(top: 3),
//               child: Text(
//                 selectedItem ?? hint,
//                 style: const TextStyle(fontSize: 13),
//                 textAlign: TextAlign.left,
//               ),
//             ),
//             onChanged: onChanged,
//             validator: (value) {
//               if (isRequired && (value == null || value.isEmpty)) {
//                 return 'Please select $label';
//               }
//               return null;
//             },
            
            
//           ),
          
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomDropDownField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isRequired;
  final List<String> items;
  final String? value;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CustomDropDownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.isRequired,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  _CustomDropDownFieldState createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  late FocusNode _focusNode;
  bool hasError = false;
  String? currentValue;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    currentValue = widget.value;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Call this method from parent to focus this field
  void focus() {
    _focusNode.requestFocus();
  }

  // Validate method to check for errors
  String? validate() {
    final error = widget.validator != null
        ? widget.validator!(currentValue)
        : (widget.isRequired && (currentValue == null || currentValue!.isEmpty))
            ? 'Please select ${widget.label}'
            : null;
    setState(() {
      hasError = error != null;
    });
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with fixed size, color changes on error
        RichText(
          text: TextSpan(
            text: widget.label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color:  Colors.black,
            ),
            children: [
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height:hasError? 60: 40,
          child: DropdownSearch<String>(
            selectedItem: currentValue,
            items: widget.items,
            // focusNode: _focusNode,
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              menuProps: MenuProps(
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              searchFieldProps: TextFieldProps(
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search...",
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: widget.hint,
                hintStyle: const TextStyle(fontSize: 12),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            onChanged: (val) {
              setState(() {
                currentValue = val;
              });
              if (widget.onChanged != null) widget.onChanged!(val);
            },
            validator: (value) {
              final error = widget.validator != null
                  ? widget.validator!(value)
                  : (widget.isRequired && (value == null || value.isEmpty))
                      ? 'Please select ${widget.label}'
                      : null;
              setState(() {
                hasError = error != null;
              });
              return error;
            },
          ),
        ),
      ],
    );
  }
}