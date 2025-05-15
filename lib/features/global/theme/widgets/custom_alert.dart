import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onOk;
  final bool showOkButton;
  final VoidCallback? onDownload;
  final TextEditingController? textController; // Controller for TextField
  final String textFieldHint;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
    this.onOk,
    this.showOkButton = false,
    this.onDownload,
    this.textController,
    this.textFieldHint = "Enter reason here",
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: const Color(0xFF242424),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[700]),
              const SizedBox(height: 10),
              Text(
                message,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 17,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (textController != null) ...[
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: textFieldHint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onConfirm != null) ...[
                    const SizedBox(width: 8),
                    _buildButton('Yes', const Color(0xFF91C964), onConfirm!),
                  ],
                  if (onCancel != null) ...[
                    const SizedBox(width: 8),
                    _buildButton('No', Colors.red, onCancel!),
                  ],
                  if (showOkButton) ...[
                    const SizedBox(width: 8),
                    _buildButton('OK', const Color(0xFF91C964), onOk),
                  ],
                  if (onDownload != null) ...[
                    const SizedBox(width: 8),
                    _buildButton(
                        'Download', const Color(0xFF91C964), onDownload!),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback? onPressed) {
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
