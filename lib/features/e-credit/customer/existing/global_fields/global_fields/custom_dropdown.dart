import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/snack_bar.dart';
 
class CustomDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<T>? items;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemLabel;
  final bool showDropdown;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? textController;
  final VoidCallback? onTextTap;
  final bool required;
  final Future<void> Function()? fetchData;
    final String? Function(String?)? validator;
   
 
  
  const CustomDropdown({
    super.key,
    this.hint,
    this.label,
    this.value,
    this.items,
    this.onChanged,
    this.onTap,
    this.itemLabel,
    this.readOnly = false,
    this.required = false,
    this.showDropdown = true,
    this.textController,
    this.onTextTap,
    this.fetchData,
       this.validator,
          
  });
 
  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}
 
class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  List<T>? filteredItems;
  bool isDropdownOpen = false;
  late TextEditingController _controller;
    bool hasError = false;
    String? errorMessage;
 
  @override
  void initState() {
    super.initState();
    filteredItems = widget.items ?? [];
    _controller = widget.textController ?? TextEditingController();
 
    if (widget.value != null && widget.itemLabel != null) {
      _controller.text = widget.itemLabel!(widget.value as T);
    }
  }
 
 
  void _filterItems(String query) {
    setState(() {
      filteredItems = widget.items
          ?.where((item) => widget.itemLabel!(item)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      isDropdownOpen = filteredItems != null && filteredItems!.isNotEmpty;
    });
  }
 
  void _selectItem(T item) {
    setState(() {
      _controller.text = widget.itemLabel!(item);
      isDropdownOpen = false;
    });
 
    widget.onChanged?.call(item);
  }
 
  Future<void> _handleTap() async {
    if (widget.fetchData != null) {
      await widget.fetchData!();
    }
 
    if (!mounted) return;
 
    setState(() {
      isDropdownOpen = true;
    });
 
    widget.onTextTap?.call();
  }
  void validate() {
    setState(() {
      hasError = widget.required && (_controller.text.isEmpty || widget.value == null);
      errorMessage = hasError ? 'This field is required' : null;
    });
  }

 
  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label!,
                    // style: const TextStyle(
                    //   fontSize: 14,
                    //   fontWeight: FontWeight.bold,
                    //   color: Colors.black,
                    // ),
                     style:theme.textTheme.bodyLarge?.copyWith( fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,)
                  ),
                  if (widget.required)
                     TextSpan(
                      text: ' *',
                        style:theme.textTheme.bodyLarge?.copyWith(  fontSize: 14,
                         fontWeight: FontWeight.bold,
                         color: Colors.red,)
                      // style: TextStyle(
                      //   fontSize: 14,
                      //   fontWeight: FontWeight.bold,
                      //   color: Colors.red,
                      // ),
                    ),
                ],
              ),
            ),
          ),
        TextField(
          controller: _controller,
          readOnly: widget.readOnly,
          onChanged: _filterItems,
          decoration: InputDecoration(
            hintText: widget.hint ?? "Select...",
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: _outlinedBorder(Colors.grey),
            enabledBorder: _outlinedBorder(Colors.grey),
            focusedBorder: _outlinedBorder(Colors.blue),
            filled: true,
            fillColor: Colors.white,
             errorText: hasError ? errorMessage : null,
            errorStyle: const TextStyle(fontSize: 12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            suffixIcon: widget.showDropdown
                ? GestureDetector(
                    onTap: () async {
                      if (!isDropdownOpen) {
                        await _handleTap(); // Fetch data and open dropdown
                      } else {
                        setState(() {
                          isDropdownOpen =
                              false; // Close dropdown if already open
                        });
                      }
                    },
                    child: Icon(
                      isDropdownOpen
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                    ),
                  )
                : null,
            isDense: true,
          ),
          onTap: _handleTap,
        ),
        if (isDropdownOpen)
          Container(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 600),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white,
             border: Border.all(
      color: hasError ? Colors.red : Colors.grey,
      width: hasError ? 2 : 1,
    ),
              borderRadius: BorderRadius.circular(5),
                
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredItems!.length,
              itemBuilder: (context, index) {
                final item = filteredItems![index];
                return ListTile(
                  title: Text(widget.itemLabel!(item)),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () => _selectItem(item),
                );
              },
            ),
          ),
      ],
    );
  }
 
  OutlineInputBorder _outlinedBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
  
}
 
Widget buildDropdown<T>({
  String? label,
  required Rx<T?> selectedValue,
  required List<T> items,
  required String Function(T) itemLabel,
  required Future<void> Function() fetchData,
  required bool showDropdown,
  String? Function()? fallbackValue,
  void Function(T?)? onChanged,
  bool required = false,
  bool autoFetch = false,
  bool readOnly = false,

  
}) {
  return Obx(() {
    final textController = TextEditingController(
      text: selectedValue.value != null
          ? itemLabel(selectedValue.value as T)
          : fallbackValue?.call() ?? '',
    );
 
    return GestureDetector(
      onTap: () async {
        if (readOnly) {
          AppSnackBar.alert(
              message: "This field can only be edited by the Head Office.");
        } else {
          await fetchData(); // Fetch data first
          selectedValue.refresh(); // Ensure dropdown updates
        }
      },
      child: AbsorbPointer(
        absorbing: readOnly,
        child: CustomDropdown<T>(
          label: label,
          hint: 'Enter...',
          value: selectedValue.value,
          items: items,
          itemLabel: itemLabel,
          onChanged: readOnly
              ? null
              : (newValue) async {
                  if (newValue != null) {
                    selectedValue.value = newValue;
                    onChanged?.call(newValue);
                    if (autoFetch) await fetchData();
                  }
                },
          required: required,
          showDropdown: showDropdown && items.isNotEmpty,
          textController: textController,
          onTextTap: readOnly
              ? null
              : () async {
                  await fetchData();
                  selectedValue
                      .refresh(); // Refresh to trigger dropdown visibility
                },
          fetchData: fetchData,
          onTap: readOnly
              ? null
              : () async {
                  await fetchData();
                  selectedValue.refresh(); // Ensure dropdown opens on tap
                },
        ),
      ),
    );
  });
}
 
 