import 'package:flutter/material.dart';

/// A production-safe text field that validates input
class SafeTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? helperText;
  final String? labelText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int minLines;
  final int? maxLines;
  final TextInputType keyboardType;
  final bool autofocus;
  final String fieldName;

  const SafeTextField({
    super.key,
    required this.controller,
    required this.fieldName,
    this.hintText,
    this.helperText,
    this.labelText,
    this.validator,
    this.maxLength = 255,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  });

  @override
  State<SafeTextField> createState() => _SafeTextFieldState();
}

class _SafeTextFieldState extends State<SafeTextField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    if (!mounted) return;

    final error = widget.validator?.call(widget.controller.text);
    if (error != _errorText) {
      setState(() => _errorText = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: _errorText,
        counterText: '',
      ),
    );
  }
}

/// A production-safe form dialog
class SafeFormDialog extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String fieldHint;
  final String? fieldHelper;
  final String? initialValue;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final TextInputType keyboardType;

  const SafeFormDialog({
    super.key,
    required this.title,
    required this.fieldLabel,
    required this.fieldHint,
    this.fieldHelper,
    this.initialValue,
    this.validator,
    this.maxLength = 255,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<SafeFormDialog> createState() => _SafeFormDialogState();
}

class _SafeFormDialogState extends State<SafeFormDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (!mounted) return;

    final error = widget.validator?.call(_controller.text);
    if (error != _errorText) {
      setState(() => _errorText = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: SafeTextField(
          controller: _controller,
          fieldName: widget.fieldLabel,
          labelText: widget.fieldLabel,
          hintText: widget.fieldHint,
          helperText: widget.fieldHelper,
          validator: widget.validator,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines ?? 1,
          keyboardType: widget.keyboardType,
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _errorText == null
              ? () => Navigator.pop(context, _controller.text.trim())
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Helper to show a safe form dialog with error handling
Future<String?> showSafeFormDialog(
  BuildContext context, {
  required String title,
  required String fieldLabel,
  required String fieldHint,
  String? fieldHelper,
  String? initialValue,
  String? Function(String?)? validator,
  int? maxLength,
  int? maxLines,
}) async {
  return showDialog<String>(
    context: context,
    builder: (ctx) => SafeFormDialog(
      title: title,
      fieldLabel: fieldLabel,
      fieldHint: fieldHint,
      fieldHelper: fieldHelper,
      initialValue: initialValue,
      validator: validator,
      maxLength: maxLength,
      maxLines: maxLines,
    ),
  );
}

/// Safe async button that prevents double-tap and shows loading
class SafeAsyncButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String label;
  final VoidCallback? onSuccess;
  final Function(dynamic)? onError;
  final Widget? child;
  final bool outlined;

  const SafeAsyncButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.onSuccess,
    this.onError,
    this.child,
    this.outlined = false,
  });

  @override
  State<SafeAsyncButton> createState() => _SafeAsyncButtonState();
}

class _SafeAsyncButtonState extends State<SafeAsyncButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
      if (!mounted) return;
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      widget.onError?.call(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.outlined) {
      return OutlinedButton(
        onPressed: _isLoading ? null : _handlePressed,
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : (widget.child ?? Text(widget.label)),
      );
    }

    return FilledButton(
      onPressed: _isLoading ? null : _handlePressed,
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : (widget.child ?? Text(widget.label)),
    );
  }
}
