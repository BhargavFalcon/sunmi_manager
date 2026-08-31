import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  static String formatDateOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      final dateTime = _parseDateTime(dateTimeString);
      if (dateTime == null) return dateTimeString;
      final locale = _currentLocale();
      final localeString = '${locale.languageCode}_${locale.countryCode}';
      return DateFormat('dd-MM-yyyy', localeString).format(dateTime);
    } catch (_) {
      return dateTimeString;
    }
  }

  static String formatTimeOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      final dateTime = _parseDateTime(dateTimeString);
      if (dateTime == null) return dateTimeString;
      final locale = _currentLocale();
      final localeString = '${locale.languageCode}_${locale.countryCode}';
      return DateFormat('hh:mm a', localeString).format(dateTime);
    } catch (_) {
      return dateTimeString;
    }
  }

  static String formatDateTimeWithRestaurantTimezone(String? dateTimeString) {
    return formatDateTime(dateTimeString);
  }

  static String formatDateTimeInTimezone(
    String? dateTimeString,
    String? timezoneName,
  ) {
    return formatDateTime(dateTimeString);
  }

  static String formatDateTimeObject(DateTime dateTime) {
    final formatter = _dateFormat();
    return formatter.format(dateTime);
  }

  static DateFormat _dateFormat() {
    final locale = _currentLocale();
    final localeString = '${locale.languageCode}_${locale.countryCode}';
    try {
      return DateFormat('d MMM yyyy, hh:mm a', localeString);
    } catch (_) {
      try {
        return DateFormat('d MMM yyyy, hh:mm a', 'en_US');
      } catch (_) {
        return DateFormat('d MMM yyyy, hh:mm a');
      }
    }
  }

  static Locale _currentLocale() {
    try {
      final locale = Get.locale;
      if (locale != null) return locale;
      final language = LanguageUtils.getLanguage();
      return LanguageUtils.getLocaleFromCode(language);
    } catch (_) {
      return LanguageUtils.getLocaleFromCode('en');
    }
  }

  static DateTime? _parseDateTime(String dateTimeString) {
    try {
      final dt = DateTime.parse(dateTimeString);
      return DateTime(
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
      );
    } catch (_) {
      final custom = _parseCustomFormat(dateTimeString);
      if (custom != null) return custom;
      return _parseLongMonthFormat(dateTimeString);
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
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseLongMonthFormat(String dateTimeString) {
    final patterns = [
      'MMMM d, yyyy hh:mm a',
      'MMMM d, yyyy h:mm a',
      'MMMM d,yyyy hh:mm a',
      'MMMM d,yyyy h:mm a',
      'MMM d, yyyy hh:mm a',
      'MMM d, yyyy h:mm a',
      'MMM d,yyyy hh:mm a',
      'MMM d,yyyy h:mm a',
    ];
    for (final pattern in patterns) {
      try {
        return DateFormat(pattern, 'en_US').parse(dateTimeString);
      } catch (_) {}
    }
    return null;
  }
}
