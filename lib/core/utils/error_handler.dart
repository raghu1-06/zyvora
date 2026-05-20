import 'package:flutter/material.dart';

/// Production-safe error handling for Zyvora.
class ZyvoraErrorHandler {
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        duration: duration,
      ),
    );
  }

  static String formatErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) {
      final msg = error.toString();
      if (msg.startsWith('Exception: ')) {
        return msg.substring(11);
      }
      return msg;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    required BuildContext context,
    required String errorTitle,
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (!context.mounted) return null;
      showError(
        context,
        title: errorTitle,
        message: errorMessage ?? formatErrorMessage(e),
      );
      return null;
    }
  }
}

/// Validates input before saving.
class InputValidator {
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? validateLength(
    String? value, {
    required String fieldName,
    int minLength = 1,
    int maxLength = 255,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength character(s)';
    }
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    final error = validateLength(
      value,
      fieldName: 'Name',
      minLength: 1,
      maxLength: 100,
    );
    if (error != null) return error;

    if (value!.contains(RegExp(r'[<>:"/\\|?*]'))) {
      return 'Name contains invalid characters';
    }
    return null;
  }

  static String? validateSubjectName(String? value) {
    final error = validateLength(
      value,
      fieldName: 'Subject',
      minLength: 1,
      maxLength: 100,
    );
    return error;
  }

  static String trimAndValidate(String value, {required String fieldName}) {
    final trimmed = value.trim();
    final error = validateNotEmpty(trimmed, fieldName);
    if (error != null) {
      throw Exception(error);
    }
    return trimmed;
  }
}
