// CustomTextContainer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextContainer extends StatefulWidget {
  final String label;
  final String? value;
  final bool readOnly;
  final bool required;
  final TextEditingController? controller;
  final String? hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool autoFetch;
  final Future<String> Function()? fetchDataCallback;
  final Color? backgroundColor;
  final Widget? suffixIcon;
  final bool hasError;

  const CustomTextContainer({
    super.key,
    this.label = '',
    this.value,
    this.readOnly = false,
    this.required = false,
    this.hint,
    this.onTap,
    this.onChanged,
    this.controller,
    this.inputFormatters,
    this.autoFetch = false,
    this.fetchDataCallback,
    this.backgroundColor,
    this.suffixIcon,
    this.hasError = false,
  });

  @override
  _CustomTextContainerState createState() => _CustomTextContainerState();
}

class _CustomTextContainerState extends State<CustomTextContainer> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
    
    if (widget.controller == null) {
      _controller.addListener(() {
        widget.onChanged?.call(_controller.text);
      });
    }

    if (widget.autoFetch && widget.fetchDataCallback != null) {
      fetchDataAndUpdate();
    }
  }

  @override
  void didUpdateWidget(CustomTextContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.value != widget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  Future<void> fetchDataAndUpdate() async {
    if (widget.fetchDataCallback == null) return;
    String fetchedData = await widget.fetchDataCallback!();
    if (mounted) {
      setState(() {
        _controller.text = fetchedData;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (widget.required)
                    TextSpan(
                      text: ' *',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: widget.hasError ? 60 : 40,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: _outlinedBorder(widget.hasError ? Colors.red : Colors.grey),
              enabledBorder: _outlinedBorder(widget.hasError ? Colors.red : Colors.grey),
              focusedBorder: _outlinedBorder(widget.hasError ? Colors.red : Colors.blue, width: 2),
              errorBorder: _outlinedBorder(Colors.red),
              focusedErrorBorder: _outlinedBorder(Colors.red),
              errorText: widget.hasError ? 'This field is required' : null,
              errorStyle: const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              hintText: widget.hint ?? 'Enter...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: widget.backgroundColor ?? Colors.white,
              suffixIcon: widget.suffixIcon,
            ),
            inputFormatters: widget.inputFormatters ??
                [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z0-9._%+-@ ]*$'),
                  ),
                ],
            onTap: () {
              widget.onTap?.call();
              fetchDataAndUpdate();
            },
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _outlinedBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}