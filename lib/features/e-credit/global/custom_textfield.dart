// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class CustomTextFormField extends StatefulWidget {
//   final String? label;
//   final String? hint;
//   final bool? isRequired;
//   final TextEditingController? controller;
//   final TextInputType? keyboardType;
//   final int? maxLength;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final bool readOnly;
//   final bool toUpperCase;
//   final VoidCallback? onEditingComplete;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? errorText;

//   const CustomTextFormField({
//     super.key,
//     this.label,
//     this.hint,
//     this.isRequired,
//     this.controller,
//     this.keyboardType,
//     this.maxLength,
//     this.validator,
//     this.onChanged,
//     this.readOnly = false,
//     this.onEditingComplete,
//     this.inputFormatters,
//     this.toUpperCase = false,
//     this.errorText,
//   });

//   @override
//   _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
// }

// class _CustomTextFormFieldState extends State<CustomTextFormField> {
//   String? errorText;
//   bool showError = false;

//   void validateInput(String value) {
//     setState(() {
//       if (widget.validator != null) {
//         errorText = widget.validator!(value);
//         showError = errorText != null;
//       } else if (widget.isRequired == true && value.isEmpty) {
//         errorText = 'This field is required';
//         showError = true;
//       } else {
//         errorText = null;
//         showError = false;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (errorText != null)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 4.0),
//             child: Text(
//               errorText!,
//               style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red, fontSize: 12),
//             ),
//           ),
//         RichText(
//           text: TextSpan(
//             text: widget.label ?? '',
//             style: theme.textTheme.bodyLarge?.copyWith(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//             children: [
//               if (widget.isRequired ?? false)
//                 TextSpan(
//                   text: ' *',
//                   style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red, fontSize: 15),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 3),
//         SizedBox(
//           height: 40,
//           child: TextFormField(
//             controller: widget.controller,
//             keyboardType: widget.keyboardType ?? TextInputType.emailAddress,
//             maxLength: widget.maxLength,
//             readOnly: widget.readOnly,
//             style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
//             inputFormatters: widget.inputFormatters,
//             decoration: InputDecoration(
//               hintText: widget.hint,
//               errorStyle: const TextStyle(color: Colors.red),
//               counterText: "",
//               filled: true,
//               fillColor: widget.readOnly ? const Color(0xFFEAE8E8) : Colors.white,
//               contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: showError ? Colors.red : Colors.grey,
//                   width: 1,
//                 ),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: showError ? Colors.red : Colors.grey,
//                   width: 1,
//                 ),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: showError ? Colors.red : Colors.blue,
//                   width: 1.5,
//                 ),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red, width: 1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red, width: 1.5),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             validator: (value) {
//               if (widget.validator != null) {
//                 final error = widget.validator!(value);
//                 if (error != null) {
//                   setState(() {
//                     showError = true;
//                     errorText = error;
//                   });
//                   return error;
//                 }
//               }
//               if (widget.isRequired == true && (value == null || value.isEmpty)) {
//                 setState(() {
//                   showError = true;
//                   errorText = 'This field is required';
//                 });
//                 return 'This field is required';
//               }
//               setState(() {
//                 showError = false;
//                 errorText = null;
//               });
//               return null;
//             },
//             onChanged: (value) {
//               final transformedValue = widget.toUpperCase
//                   ? value.toUpperCase()
//                   : value;

//               if (widget.controller != null) {
//                 widget.controller!.value = TextEditingValue(
//                   text: transformedValue,
//                   selection: TextSelection.collapsed(offset: transformedValue.length),
//                 );
//               }

//               validateInput(transformedValue);

//               if (widget.onChanged != null) {
//                 widget.onChanged!(transformedValue);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class CustomTextFormField extends StatefulWidget {
//   final String? label;
//   final String? hint;
//   final bool? isRequired;
//   final TextEditingController? controller;
//   final TextInputType? keyboardType;
//   final int? maxLength;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final bool readOnly;
//   final bool toUpperCase;
//   final VoidCallback? onEditingComplete;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? errorText;

//   const CustomTextFormField({
//     super.key,
//     this.label,
//     this.hint,
//     this.isRequired,
//     this.controller,
//     this.keyboardType,
//     this.maxLength,
//     this.validator,
//     this.onChanged,
//     this.readOnly = false,
//     this.onEditingComplete,
//     this.inputFormatters,
//     this.toUpperCase = false,
//     this.errorText,
//   });

//   @override
//   _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
// }

// class _CustomTextFormFieldState extends State<CustomTextFormField> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: widget.label ?? '',
//             style: theme.textTheme.bodyLarge?.copyWith(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//             children: [
//               if (widget.isRequired ?? false)
//                 TextSpan(
//                   text: ' *',
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     color: Colors.red,
//                     fontSize: 15,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 3),
//         SizedBox(
//           height: 40,
//           child: TextFormField(
//             controller: widget.controller,
//             keyboardType: widget.keyboardType ?? TextInputType.text,
//             maxLength: widget.maxLength,
//             readOnly: widget.readOnly,
//             style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
//             inputFormatters: widget.inputFormatters,
//             decoration: InputDecoration(
//               hintText: widget.hint,
//               counterText: "",
//               filled: true,
//               fillColor: widget.readOnly ? const Color(0xFFEAE8E8) : Colors.white,
//               contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.grey, width: 1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.blue, width: 1.5),
//                 borderRadius: BorderRadius.circular(5),
//               ),              
//               errorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red, width: 1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.red, width: 1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//             validator: (value) {
//               if (widget.validator != null) {
//                 return widget.validator!(value);
//               }
//               if ((widget.isRequired ?? false) && (value == null || value.isEmpty)) {
//                 return 'This field is required';
//               }
//               return null;
//             },
//             onChanged: (value) {
//               final transformedValue = widget.toUpperCase
//                   ? value.toUpperCase()
//                   : value;

//               if (widget.controller != null) {
//                 widget.controller!.value = TextEditingValue(
//                   text: transformedValue,
//                   selection: TextSelection.collapsed(offset: transformedValue.length),
//                 );
//               }

//               if (widget.onChanged != null) {
//                 widget.onChanged!(transformedValue);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final bool? isRequired;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final bool toUpperCase;
  final VoidCallback? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  

 

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.isRequired,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onEditingComplete,
    this.inputFormatters,
    this.toUpperCase = false,
    this.errorText,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final FocusNode _focusNode = FocusNode();
  bool hasError = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Method to externally request focus
  void focus() {
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          RichText(
            text: TextSpan(
              text: widget.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color:  Colors.black,
              ),
              children: [
                if (widget.isRequired ?? false)
                  TextSpan(
                    text: ' *',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        if (widget.label != null) const SizedBox(height: 4),
        SizedBox(
          height:hasError ?60: 40,
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            keyboardType: widget.keyboardType ?? TextInputType.text,
            maxLength: widget.maxLength,
            readOnly: widget.readOnly,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              hintText: widget.hint,
              counterText: "",
              filled: true,
              fillColor: widget.readOnly ? const Color(0xFFEAE8E8) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.blue,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onFieldSubmitted: (_) {
              setState(() {
                hasError = widget.validator?.call(widget.controller?.text) != null ||
                    (widget.isRequired ?? false && (widget.controller?.text.isEmpty ?? true));
              });
            },
            validator: (value) {
              String? error;
              if (widget.validator != null) {
                error = widget.validator!(value);
              } else if ((widget.isRequired ?? false) && (value == null || value.isEmpty)) {
                error = 'This field is required';
              }

              setState(() {
                hasError = error != null;
              });
              return error;
            },
            onChanged: (value) {
              final transformedValue = widget.toUpperCase ? value.toUpperCase() : value;
              if (widget.controller != null) {
                widget.controller!.value = TextEditingValue(
                  text: transformedValue,
                  selection: TextSelection.collapsed(offset: transformedValue.length),
                );
              }
              if (widget.onChanged != null) {
                widget.onChanged!(transformedValue);
              }
              if (value.isNotEmpty && hasError) {
                setState(() {
                  hasError = false;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}