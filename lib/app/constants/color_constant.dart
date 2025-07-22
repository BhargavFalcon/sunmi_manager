import 'package:flutter/material.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

class ColorConstants {
  static const Color primaryColor = Color(0xFFf85168);
  static const Color bgColor = Color(0xFFFAFAFA);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xff424242);
  static const Color green = Color(0xff4CAF50);
  static const Color red = Color(0xFFF44336);

  static List<BoxShadow> get getShadow {
    return [
      BoxShadow(
        offset: const Offset(2, 2),
        color: Colors.black26,
        blurRadius: MySize.getHeight(2),
        spreadRadius: MySize.getHeight(2),
      ),
      BoxShadow(
        offset: const Offset(-1, -1),
        color: Colors.white.withValues(alpha: 0.8),
        blurRadius: MySize.getHeight(2),
        spreadRadius: MySize.getHeight(2),
      ),
    ];
  }

  static List<BoxShadow> get getShadow3 {
    return [
      BoxShadow(
        offset: const Offset(2, 2),
        color: Colors.black12,
        blurRadius: MySize.getHeight(0.5),
        spreadRadius: MySize.getHeight(0.5),
      ),
      BoxShadow(
        offset: const Offset(-1, -1),
        color: Colors.white.withValues(alpha: 0.8),
        blurRadius: MySize.getHeight(0.5),
        spreadRadius: MySize.getHeight(0.5),
      ),
    ];
  }

  static List<BoxShadow> get getShadow2 {
    return [
      BoxShadow(
        offset: Offset(MySize.getWidth(2), MySize.getHeight(2)),
        color: const Color(0xffAEAEC0).withOpacity(0.4),
        blurRadius: MySize.getHeight(4),
        spreadRadius: MySize.getWidth(1),
      ),
    ];
  }
}

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
