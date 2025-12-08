import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/data/pusher_service.dart';
import 'app/routes/app_pages.dart';
import 'app/services/printer_service.dart';

final box = GetStorage();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize services
  Get.put(PrinterService(), permanent: true);
  final pusherService = PusherService();
  await pusherService.initPusher();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        fontFamily: GoogleFonts.rubik().fontFamily,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      builder: (context, child) {
        // Ensure MaterialApp overlay is ready for Get.snackbar
        return MediaQuery(
          data: MediaQuery.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ),
  );
}
