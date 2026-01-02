import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../main.dart';
import '../constants/api_constants.dart';
import '../model/RestaurantDetailsModel.dart';

class LanguageUtils {
  static String getDefaultLanguageFromApi() {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData != null && storedData is Map<String, dynamic>) {
        final restaurantModel = RestaurantModel.fromJson(storedData);
        final branches = restaurantModel.data?.branches;
        if (branches != null && branches.isNotEmpty) {
          final branch = branches.first;
          if (branch.defaultLanguage != null &&
              branch.defaultLanguage!.isNotEmpty) {
            return branch.defaultLanguage!;
          }
        }
      }
    } catch (e) {
      // If error, use default 'en'
    }
    return 'en';
  }

  static String getLanguage() {
    return box.read(ArgumentConstant.selectedLanguageKey) ??
        getDefaultLanguageFromApi();
  }

  static Locale getLocaleFromCode(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return const Locale('en', 'US');
      case 'da':
        return const Locale('da', 'DK');
      case 'de':
        return const Locale('de', 'DE');
      case 'nl':
        return const Locale('nl', 'NL');
      default:
        return const Locale('en', 'US');
    }
  }

  static Future<Locale> updateLocale(String languageCode) async {
    final locale = getLocaleFromCode(languageCode);
    await _initializeDateFormattingForLocale(locale);
    Get.updateLocale(locale);
    return locale;
  }

  static Future<void> _initializeDateFormattingForLocale(Locale locale) async {
    try {
      final localeString = '${locale.languageCode}_${locale.countryCode}';
      await initializeDateFormatting(localeString, null);
    } catch (e) {
      try {
        await initializeDateFormatting('en_US', null);
      } catch (e2) {
        // If initialization fails, DateFormat will use default locale
      }
    }
  }

  static String getFlagEmoji(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return '🇺🇸';
      case 'da':
        return '🇩🇰';
      case 'de':
        return '🇩🇪';
      case 'nl':
        return '🇳🇱';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'it':
        return '🇮🇹';
      default:
        return '🇺🇸';
    }
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return 'English';
      case 'da':
        return 'Dansk';
      case 'de':
        return 'Deutsch';
      case 'nl':
        return 'Nederlands';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'it':
        return 'Italiano';
      default:
        return 'English';
    }
  }

  static String? getFlagUrlFromApi(String languageCode) {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData != null && storedData is Map<String, dynamic>) {
        final restaurantModel = RestaurantModel.fromJson(storedData);
        final branches = restaurantModel.data?.branches;
        if (branches != null && branches.isNotEmpty) {
          final branch = branches.first;
          if (branch.language != null &&
              branch.language!.languageCode?.toLowerCase() ==
                  languageCode.toLowerCase()) {
            return branch.language!.flagUrl;
          }
        }
      }
    } catch (e) {
      // If error, return null
    }
    return null;
  }
}
