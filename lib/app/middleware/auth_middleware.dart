import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../constants/api_constants.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if token exists
    final token = box.read<String>(ArgumentConstant.tokenKey);

    // If no token and trying to access protected route, redirect to login
    if (token == null || token.isEmpty) {
      // Allow access to login screen
      if (route == Routes.LOGIN_SCREEN) {
        return null;
      }
      // Redirect to login for all other routes
      return const RouteSettings(name: Routes.LOGIN_SCREEN);
    }

    // If token exists and trying to access login, redirect to home
    if (route == Routes.LOGIN_SCREEN) {
      return const RouteSettings(name: Routes.MAIN_HOME_SCREEN);
    }

    return null;
  }
}
