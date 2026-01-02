import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'language_utils.dart';

class DateTimeFormatter {
  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';

    try {
      final dateTime = _parseDateTime(dateTimeString);
      if (dateTime == null) return dateTimeString;
      return formatDateTimeObject(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  static String formatDateTimeObject(DateTime dateTime) {
    try {
      Locale locale;
      try {
        locale = Get.locale ?? LanguageUtils.getLocaleFromCode('en');
      } catch (e) {
        locale = LanguageUtils.getLocaleFromCode('en');
      }

      final localeString = '${locale.languageCode}_${locale.countryCode}';

      try {
        final formatter = DateFormat('d MMM yyyy, hh:mm a', localeString);
        return formatter.format(dateTime);
      } catch (e) {
        try {
          final formatter = DateFormat('d MMM yyyy, hh:mm a', 'en_US');
          return formatter.format(dateTime);
        } catch (e2) {
          final formatter = DateFormat('d MMM yyyy, hh:mm a');
          return formatter.format(dateTime);
        }
      }
    } catch (e) {
      try {
        final formatter = DateFormat('d MMM yyyy, hh:mm a', 'en_US');
        return formatter.format(dateTime);
      } catch (e2) {
        final formatter = DateFormat('d MMM yyyy, hh:mm a');
        return formatter.format(dateTime);
      }
    }
  }

  static DateTime? _parseDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return _parseCustomFormat(dateTimeString);
    }
  }

  static DateTime? _parseCustomFormat(String dateTimeString) {
    if (!dateTimeString.contains(' ') || !dateTimeString.contains('-')) {
      return null;
    }

    final parts = dateTimeString.split(' ');
    if (parts.length < 2) return null;

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');

    if (dateParts.length != 3 || timeParts.length < 2) return null;

    try {
      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
      );
    } catch (e) {
      return null;
    }
  }
}
