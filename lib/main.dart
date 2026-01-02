import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/data/pusher_service.dart';
import 'app/routes/app_pages.dart';
import 'app/services/printer_service.dart';
import 'app/services/network_connectivity_service.dart';
import 'app/utils/locale_string.dart';
import 'app/utils/language_utils.dart';

final box = GetStorage();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  await GetStorage.init();

  Get.put(PrinterService(), permanent: true);
  Get.put(NetworkConnectivityService(), permanent: true);
  final pusherService = PusherService();
  await pusherService.initPusher();

  final language = LanguageUtils.getLanguage();
  final locale = LanguageUtils.getLocaleFromCode(language);

  await _initializeDateFormatting(locale);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      translations: LocaleString(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        fontFamily: GoogleFonts.rubik().fontFamily,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ),
  );
}

Future<void> _initializeDateFormatting(Locale locale) async {
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
