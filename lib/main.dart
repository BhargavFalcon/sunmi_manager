import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/data/pusher_service.dart';
import 'app/routes/app_pages.dart';
import 'app/services/printer_service.dart';
import 'app/services/network_connectivity_service.dart';
import 'app/utils/locale_string.dart';
import 'app/utils/language_utils.dart';

final box = GetStorage();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
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
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _setDeviceOrientation(),
        );
        return UpgradeAlert(
          upgrader: Upgrader(),
          barrierDismissible: false,
          dialogStyle:
              defaultTargetPlatform == TargetPlatform.iOS
                  ? UpgradeDialogStyle.cupertino
                  : UpgradeDialogStyle.material,
          showIgnore: false,
          showLater: false,
          shouldPopScope: () => false,
          child: OrientationBuilder(
            builder:
                (context, orientation) => MediaQuery(
                  data: MediaQuery.of(context),
                  child: child ?? const SizedBox.shrink(),
                ),
          ),
        );
      },
    ),
  );
}

void _setDeviceOrientation() {
  try {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return;

    final shortestSide = MediaQueryData.fromView(views.first).size.shortestSide;
    final isTablet = shortestSide >= 600;

    SystemChrome.setPreferredOrientations(
      isTablet
          ? [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
          : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  } catch (e) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

Future<void> _initializeDateFormatting(Locale locale) async {
  try {
    await initializeDateFormatting(
      '${locale.languageCode}_${locale.countryCode}',
      null,
    );
  } catch (e) {
    try {
      await initializeDateFormatting('en_US', null);
    } catch (e2) {
      // ignore
    }
  }
}
