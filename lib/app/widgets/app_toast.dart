import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/color_constant.dart';

/// Common toast utility. Use instead of SnackBar everywhere.
/// - Success: light green background + success green text
/// - Error: light red background + red text
/// - Warning: light orange background + orange text
class AppToast {
  static const Duration _defaultDuration = Duration(seconds: 4);

  /// Light success background
  static const Color _successBg = Color(0xFFE8F5E9);

  /// Light error background
  static const Color _errorBg = Color(0xFFFFEBEE);

  /// Light warning background
  static const Color _warningBg = Color(0xFFFFF3E0);

  /// Show success toast (light green bg, success green text). Only [message] is shown, no title text.
  static void showSuccess(String message, {String? title}) {
    _show(
      message: message,
      backgroundColor: _successBg,
      textColor: ColorConstants.successGreen,
    );
  }

  /// Show error toast (light red bg, red text). Only [message] is shown, no title text.
  static void showError(String message, {String? title}) {
    _show(
      message: message,
      backgroundColor: _errorBg,
      textColor: Colors.red.shade800,
    );
  }

  /// Show warning toast (light orange bg, orange text). Only [message] is shown, no title text.
  static void showWarning(String message, {String? title}) {
    _show(
      message: message,
      backgroundColor: _warningBg,
      textColor: Colors.orange.shade800,
    );
  }

  /// Show toast with custom message and type. Only [message] is shown (no title text).
  static void show(
    String title,
    String message, {
    ToastType? type,
    bool isError = false,
    bool isWarning = false,
    Duration duration = _defaultDuration,
  }) {
    final ToastType resolved =
        type ??
        (isError
            ? ToastType.error
            : isWarning
            ? ToastType.warning
            : ToastType.success);
    switch (resolved) {
      case ToastType.success:
        showSuccess(message);
        break;
      case ToastType.error:
        showError(message);
        break;
      case ToastType.warning:
        showWarning(message);
        break;
    }
  }

  static void _show({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    Duration duration = _defaultDuration,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: duration.inSeconds.clamp(1, 10),
          backgroundColor: backgroundColor,
          textColor: textColor,
          fontSize: 22.0,
        );
      } catch (_) {}
    });
  }
}

enum ToastType { success, error, warning }
