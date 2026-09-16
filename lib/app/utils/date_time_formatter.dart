import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../main.dart';
import '../constants/api_constants.dart';
import 'branch_utils.dart';
import 'language_utils.dart';

class DateTimeFormatter {
  /// Single unified method to format any DateTime or date string
  /// in the restaurant timezone (or optional explicit [timezoneName]).
  static String formatDateTime(
    dynamic dateTimeOrString, {
    String? timezoneName,
    bool isTrueUtc = false,
  }) {
    return formatWithPatternInRestaurantTimezone(
      dateTimeOrString,
      'd MMM yyyy, hh:mm a',
      timezoneName: timezoneName,
      locale: _currentLocaleString(),
      isTrueUtc: isTrueUtc,
    );
  }

  static String formatDateOnly(String? dateTimeString, [String? timezoneName]) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    return formatWithPatternInRestaurantTimezone(
      dateTimeString,
      'dd-MM-yyyy',
      timezoneName: timezoneName,
      locale: _currentLocaleString(),
      fallback: dateTimeString,
    );
  }

  static String formatDayMonthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
  }

  static DateTime getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static String formatTimeOnly(String? dateTimeString, [String? timezoneName]) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    return formatWithPatternInRestaurantTimezone(
      dateTimeString,
      'hh:mm a',
      timezoneName: timezoneName,
      locale: _currentLocaleString(),
      fallback: dateTimeString,
    );
  }

  static String formatTseDateTime(
    String? dateTimeString, [
    String? timezoneName,
  ]) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    return formatWithPatternInRestaurantTimezone(
      dateTimeString,
      'dd.MM.yyyy HH:mm:ss',
      timezoneName: timezoneName,
      fallback: dateTimeString,
      isTrueUtc: true,
    );
  }

  static String formatReportDateTime(
    dynamic dateTimeOrString, [
    String? timezoneName,
  ]) {
    if (dateTimeOrString == null) return '—';
    return formatWithPatternInRestaurantTimezone(
      dateTimeOrString,
      'd MMM yyyy, HH:mm',
      timezoneName: timezoneName,
      fallback: dateTimeOrString.toString(),
    );
  }

  /// Same source as `dinematrics_manager`: `restaurant_timezone` in GetStorage
  /// or branch timezone from `BranchUtils.getDefaultBranchTimezone()`.
  static String? restaurantTimezoneNameFromStorage() {
    try {
      final tzName = box.read<String>(ArgumentConstant.restaurantTimezoneKey);
      if (tzName != null && tzName.trim().isNotEmpty) {
        return tzName.trim();
      }
    } catch (_) {}
    try {
      final tz = BranchUtils.getDefaultBranchTimezone();
      if (tz != null && tz.isNotEmpty) {
        box.write(ArgumentConstant.restaurantTimezoneKey, tz);
        return tz;
      }
    } catch (_) {}
    return null;
  }

  /// Current instant in restaurant TZ.
  static tz.TZDateTime nowInRestaurantTimezone([String? timezoneName]) {
    final tzName = timezoneName ?? restaurantTimezoneNameFromStorage();
    if (tzName != null && tzName.isNotEmpty) {
      try {
        final location = tz.getLocation(tzName);
        return tz.TZDateTime.now(location);
      } catch (_) {}
    }
    return tz.TZDateTime.now(tz.local);
  }

  /// Calendar "today" (midnight) in restaurant TZ for API queries and variables.
  static DateTime todayCalendarDateInRestaurantTimezone([String? timezoneName]) {
    final now = nowInRestaurantTimezone(timezoneName);
    return DateTime(now.year, now.month, now.day);
  }

  /// Converts a [DateTime] or ISO string [dateTimeOrString] into a [tz.TZDateTime]
  /// in the restaurant timezone (or null if parsing fails or timezone not configured).
  ///
  /// For order timestamps from Dinemetrics backend (where date/time are stored
  /// in the restaurant's local time, but serialized with trailing 'Z'), [isTrueUtc]
  /// defaults to false so that the local time components are preserved without
  /// double-adding timezone offsets.
  static tz.TZDateTime? toRestaurantTZDateTime(
    dynamic dateTimeOrString, [
    String? timezoneName,
    bool isTrueUtc = false,
  ]) {
    if (dateTimeOrString == null) return null;
    try {
      final tzName = timezoneName ?? restaurantTimezoneNameFromStorage();
      if (tzName != null && tzName.isNotEmpty) {
        final location = tz.getLocation(tzName);
        if (dateTimeOrString is tz.TZDateTime) {
          if (dateTimeOrString.location.name == location.name) {
            return dateTimeOrString;
          }
          return tz.TZDateTime.from(dateTimeOrString, location);
        }
        DateTime? dateTime;
        if (dateTimeOrString is DateTime) {
          dateTime = dateTimeOrString;
        } else if (dateTimeOrString is String) {
          if (dateTimeOrString.trim().isEmpty) return null;
          dateTime = _parseDateTime(dateTimeOrString);
        }
        if (dateTime == null) return null;

        final trimmedStr =
            dateTimeOrString is String ? dateTimeOrString.trim() : null;
        final isDateOnlyString =
            trimmedStr != null &&
            RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmedStr);
        final hasExplicitTimezone =
            trimmedStr != null &&
            (trimmedStr.endsWith('Z') ||
                trimmedStr.endsWith('z') ||
                RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(trimmedStr));

        if (isDateOnlyString) {
          return tz.TZDateTime(
            location,
            dateTime.year,
            dateTime.month,
            dateTime.day,
          );
        }

        if (isTrueUtc && (trimmedStr == null || hasExplicitTimezone)) {
          return tz.TZDateTime.from(
            dateTime.isUtc ? dateTime : dateTime.toUtc(),
            location,
          );
        }

        return tz.TZDateTime(
          location,
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
          dateTime.millisecond,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Formats a [dateTimeOrString] using [pattern] in restaurant timezone.
  static String formatWithPatternInRestaurantTimezone(
    dynamic dateTimeOrString,
    String pattern, {
    String? timezoneName,
    String? fallback,
    String? locale,
    bool isTrueUtc = false,
  }) {
    if (dateTimeOrString == null) return fallback ?? '';
    if (dateTimeOrString is String && dateTimeOrString.trim().isEmpty) {
      return fallback ?? '';
    }
    try {
      final tzDateTime = toRestaurantTZDateTime(
        dateTimeOrString,
        timezoneName,
        isTrueUtc,
      );
      if (tzDateTime != null) {
        return DateFormat(pattern, locale).format(tzDateTime);
      }
      DateTime? parsed;
      if (dateTimeOrString is DateTime) {
        parsed = dateTimeOrString;
      } else if (dateTimeOrString is String) {
        parsed = _parseDateTime(dateTimeOrString);
      }
      if (parsed != null) {
        return DateFormat(pattern, locale).format(parsed);
      }
    } catch (_) {}
    return fallback ?? (dateTimeOrString is String ? dateTimeOrString : '');
  }

  /// Direct delegation to single unified [formatDateTime] method
  static String formatDateTimeWithRestaurantTimezone(
    dynamic dateTimeOrString, {
    bool isTrueUtc = false,
  }) => formatDateTime(dateTimeOrString, isTrueUtc: isTrueUtc);

  static String formatDateTimeInTimezone(
    dynamic dateTimeOrString,
    String? timezoneName, {
    bool isTrueUtc = false,
  }) => formatDateTime(
    dateTimeOrString,
    timezoneName: timezoneName,
    isTrueUtc: isTrueUtc,
  );

  static String formatDateTimeObject(DateTime dateTime) =>
      formatDateTime(dateTime);

  static String _currentLocaleString() {
    final locale = _currentLocale();
    return '${locale.languageCode}_${locale.countryCode}';
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
      return DateTime.parse(dateTimeString);
    } catch (_) {
      final custom = _parseCustomFormat(dateTimeString);
      if (custom != null) return custom;
      final timeOnly = _parseTimeOnly(dateTimeString);
      if (timeOnly != null) return timeOnly;
      return _parseLongMonthFormat(dateTimeString);
    }
  }

  static DateTime? _parseTimeOnly(String str) {
    final trimmed = str.trim();
    if (!RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(trimmed)) return null;
    final parts = trimmed.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final s = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
    final now = nowInRestaurantTimezone();
    return DateTime(now.year, now.month, now.day, h, m, s);
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
