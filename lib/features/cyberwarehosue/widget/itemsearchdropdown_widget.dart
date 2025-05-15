import 'package:flutter/material.dart';
import 'dart:async';

class SearchableDropdownWidget extends StatefulWidget {
  final String label;
  final List<String> items; // List of item names or item numbers
  final ValueChanged<String?> onItemSelected;
  final FocusNode focusNode;

  const SearchableDropdownWidget({
    super.key,
    required this.label,
    required this.items,
    required this.onItemSelected,
    required this.focusNode,
  });

  @override
  SearchableDropdownWidgetState createState() =>
      SearchableDropdownWidgetState();
}

class SearchableDropdownWidgetState extends State<SearchableDropdownWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounce; // To prevent auto selection on partial typing

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = widget.focusNode;

    // Add listener to handle focus and clear the text field when focus is gained
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration.zero, () {
          // Optional: Clear text when focus is gained
          _controller.clear();
        });
      }
    });

    // Set focus programmatically on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel(); // Cancel debounce timer
    super.dispose();
  }

    // Method to automatically populate the text field when a match is found
  void autoSelectItem(String typedValue) {
    // Filter items that match the typed value (case-insensitive)
    final matchingItems = widget.items
        .where((item) => item.toLowerCase().contains(typedValue.toLowerCase()))
        .toList();

    // Only auto-fill if exactly one match is found and typed value is at least 5 characters long
    if (matchingItems.isNotEmpty && typedValue.length >= 5) {
      if (matchingItems.length == 1) {
        // If there is exactly one match, auto-fill the text field
        setState(() {
          _controller.text = matchingItems.first; // Auto-fill with the first (and only) match
        });
        widget.onItemSelected(matchingItems.first); // Trigger item selection callback

        // Close the dropdown by removing focus
        FocusScope.of(context).requestFocus(FocusNode()); // Remove focus to hide the dropdown
      } else {
        // Optionally, allow the user to keep typing if there are multiple matches
        print('Multiple items match. Continue typing.');
      }
    } else {
      // Optionally, handle the case where no matches are found or the typed value is too short
      print('No matching items or less than 5 characters typed.');
    }



       // Add listener to handle focus and clear the text field when focus is gained
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration.zero, () {
          // Optional: Clear text when focus is gained
          _controller.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              // If input is empty, return the whole list of items, otherwise filter based on the input
              if (textEditingValue.text.isEmpty && _focusNode.hasFocus) {
                return widget.items;
              }
              return widget.items.where((item) => item
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (selectedItem) {
              widget.onItemSelected(selectedItem);
              // Close the dropdown after selection
              FocusScope.of(context).requestFocus(FocusNode()); // Remove focus to hide the dropdown
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              // Assigning the controller and focusNode from Autocomplete to local state
              _controller = controller;
              _focusNode = focusNode;

             return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
             child:  TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search ${widget.label}',
                  suffixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: widget.label,
                  labelStyle: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontSize: 16, color: Colors.white),
                ),
                style:theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                // style: const TextStyle(color: Colors.white),
                onChanged: (text) {
                  // Cancel any previous debounce timer
                  _debounce?.cancel();

                  // Start a new debounce timer to trigger auto-selection after the user stops typing
                  _debounce = Timer(const Duration(milliseconds: 1500), () {
                    // Call the autoSelectItem method after the delay
                    autoSelectItem(text);
                  });
                },
             ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: MediaQuery.of(context).size.height * 0.5,
                    color: Colors.black,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);

                        return InkWell(
                          onTap: () {
                            // Automatically populate text when an option is selected
                            _controller.text = option;
                            widget.onItemSelected(option); // Call the selection callback

                            // Close the dropdown by removing focus
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              option,
                              style:theme.textTheme.bodyLarge?.copyWith(color: Colors.white, fontSize: 16),
                              // style: const TextStyle(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
     ),);
}
}
