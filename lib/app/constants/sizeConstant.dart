import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySize {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late bool isMini;
  static double? safeWidth;
  static double? safeHeight;

  static late double scaleFactorWidth;
  static late double scaleFactorHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth =
        (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.android)
            ? _mediaQueryData.size.width
            : 390;
    screenHeight =
        (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.android)
            ? _mediaQueryData.size.height
            : _mediaQueryData.size.height;
    isMini = _mediaQueryData.size.height < 700;
    double _safeAreaWidth =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    double _safeAreaHeight =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeWidth = (screenWidth - _safeAreaWidth);
    safeHeight = (screenHeight - _safeAreaHeight);

    safeWidth = (screenWidth - _safeAreaWidth);
    safeHeight = (screenHeight - _safeAreaHeight);

    scaleFactorHeight = (safeHeight! / 748);
    if (scaleFactorHeight < 1) {
      double diff = (1 - scaleFactorHeight) * (1 - scaleFactorHeight);
      scaleFactorHeight += diff;
    }

    scaleFactorWidth = (safeWidth! / 360);

    if (scaleFactorWidth < 1) {
      double diff = (1 - scaleFactorWidth) * (1 - scaleFactorWidth);
      scaleFactorWidth += diff;
    }
  }

  static double getWidth(double size) {
    return (size * scaleFactorWidth);
  }

  static double getHeight(double size) {
    return (size * scaleFactorHeight);
  }
}

extension Spacing on () {
  static EdgeInsetsGeometry zero = EdgeInsets.zero;

  static EdgeInsetsGeometry only({
    double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
  }) {
    return EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
  }

  static EdgeInsetsGeometry fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return Spacing.only(bottom: bottom, top: top, right: right, left: left);
  }

  static EdgeInsetsGeometry all(double spacing) {
    return Spacing.only(
      bottom: spacing,
      top: spacing,
      right: spacing,
      left: spacing,
    );
  }

  static EdgeInsetsGeometry left(double spacing) {
    return Spacing.only(left: spacing);
  }

  static EdgeInsetsGeometry nLeft(double spacing) {
    return Spacing.only(top: spacing, bottom: spacing, right: spacing);
  }

  static EdgeInsetsGeometry top(double spacing) {
    return Spacing.only(top: spacing);
  }

  static EdgeInsetsGeometry nTop(double spacing) {
    return Spacing.only(left: spacing, bottom: spacing, right: spacing);
  }

  static EdgeInsetsGeometry right(double spacing) {
    return Spacing.only(right: spacing);
  }

  static EdgeInsetsGeometry nRight(double spacing) {
    return Spacing.only(top: spacing, bottom: spacing, left: spacing);
  }

  static EdgeInsetsGeometry bottom(double spacing) {
    return Spacing.only(bottom: spacing);
  }

  static EdgeInsetsGeometry nBottom(double spacing) {
    return Spacing.only(top: spacing, left: spacing, right: spacing);
  }

  static EdgeInsetsGeometry horizontal(double spacing) {
    return Spacing.only(left: spacing, right: spacing);
  }

  static x(double spacing) {
    return Spacing.only(left: spacing, right: spacing);
  }

  static xy(double xSpacing, double ySpacing) {
    return Spacing.only(
      left: xSpacing,
      right: xSpacing,
      top: ySpacing,
      bottom: ySpacing,
    );
  }

  static y(double spacing) {
    return Spacing.only(top: spacing, bottom: spacing);
  }

  static EdgeInsetsGeometry vertical(double spacing) {
    return Spacing.only(top: spacing, bottom: spacing);
  }

  static EdgeInsetsGeometry symmetric({
    double vertical = 0,
    double horizontal = 0,
  }) {
    return Spacing.only(
      top: vertical,
      right: horizontal,
      left: horizontal,
      bottom: vertical,
    );
  }

  static Widget height(double height) {
    return SizedBox(height: MySize.getHeight(height));
  }

  static Widget width(double width) {
    return SizedBox(width: MySize.getWidth(width));
  }
}

class Space {
  Space();

  static Widget height(double space) {
    return SizedBox(height: MySize.getHeight(space));
  }

  static Widget width(double space) {
    return SizedBox(width: MySize.getHeight(space));
  }
}

enum ShapeTypeFor { container, button }

class Shape {
  static dynamic circular(
    double radius, {
    ShapeTypeFor shapeTypeFor = ShapeTypeFor.container,
  }) {
    BorderRadius borderRadius = BorderRadius.all(
      Radius.circular(MySize.getHeight(radius)),
    );

    switch (shapeTypeFor) {
      case ShapeTypeFor.container:
        return borderRadius;
      case ShapeTypeFor.button:
        return RoundedRectangleBorder(borderRadius: borderRadius);
    }
  }

  static dynamic circularTop(
    double radius, {
    ShapeTypeFor shapeTypeFor = ShapeTypeFor.container,
  }) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.circular(MySize.getHeight(radius)),
      topRight: Radius.circular(MySize.getHeight(radius)),
    );
    switch (shapeTypeFor) {
      case ShapeTypeFor.container:
        return borderRadius;

      case ShapeTypeFor.button:
        return RoundedRectangleBorder(borderRadius: borderRadius);
    }
  }
}

bool isNullEmptyOrFalse(dynamic o) {
  if (o is Map<String, dynamic> || o is List<dynamic>) {
    return o == null || o.length == 0;
  }
  return o == null || false == o || "" == o || "null" == o;
}

bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

CachedNetworkImage getImageByLink({
  required String url,
  required double height,
  required double width,
  bool isLoading = false,
  bool colorFilter = false,
  String imagePlaceHolder = "",
  BoxFit boxFit = BoxFit.cover,
  Widget? image,
  BorderRadiusGeometry? borderRadius,
  Color? errorColor,
  Color borderColor = Colors.transparent,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    imageBuilder:
        (context, imageProvider) => Container(
          height: MySize.getHeight(height),
          width: MySize.getHeight(width),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            image: DecorationImage(
              image: imageProvider,
              fit: boxFit,
              colorFilter:
                  (colorFilter)
                      ? ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.6),
                        BlendMode.darken,
                      )
                      : null,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(0),
          ),
        ),
    errorListener: (value) {
      print("Error: $value");
    },
    placeholder:
        (context, url) =>
            (isLoading)
                ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: borderRadius ?? BorderRadius.circular(0),
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius ?? BorderRadius.circular(0),
                    child:
                        image ??
                        Image(
                          image: AssetImage(imagePlaceHolder),
                          height: MySize.getHeight(height),
                          width: MySize.getHeight(width),
                          fit: BoxFit.cover,
                          color: errorColor ?? null,
                        ),
                  ),
                )
                : Container(
                  height: MySize.getHeight(height),
                  width: MySize.getHeight(width),
                  decoration: BoxDecoration(
                    borderRadius: borderRadius ?? BorderRadius.circular(0),
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius ?? BorderRadius.circular(0),
                    child: LinearProgressIndicator(
                      color: Colors.grey.shade200,
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ),
    errorWidget:
        (context, url, error) => Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: borderRadius ?? BorderRadius.circular(0),
          ),
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(0),
            child:
                image ??
                Image(
                  image: AssetImage(imagePlaceHolder),
                  height: MySize.getHeight(height),
                  width: MySize.getHeight(width),
                  fit: BoxFit.cover,
                  color: errorColor ?? null,
                ),
          ),
        ),
  );
}

getSnackBar({
  required BuildContext context,
  String text = "",
  double size = 16,
  int duration = 500,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text, style: TextStyle(fontSize: MySize.getHeight(size))),
      duration: Duration(milliseconds: duration),
    ),
  );
}

void showDarkCupertinoErrorDialog(
  BuildContext context,
  String message, {
  String ButtonText = "OK",
  String title = "Error",
}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.systemRed,
        ),
        child: CupertinoAlertDialog(
          title: Text(title, style: TextStyle(color: CupertinoColors.white)),
          content: Text(
            message,
            style: TextStyle(color: CupertinoColors.systemGrey2),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                ButtonText,
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showGlassSnackbar({
  required BuildContext context,
  String message = "Please select an image to edit.",
  bool icon = false,
}) {
  Get.rawSnackbar(
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    borderRadius: 16,
    padding: EdgeInsets.zero,
    backgroundColor: Colors.transparent,
    duration: const Duration(seconds: 3),
    messageText: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              (icon == true)
                  ? Icon(Icons.info_outline, size: 24, color: Colors.white)
                  : SizedBox(),
              const SizedBox(width: 12),
              Expanded(
                child: Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
