import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

/// A common TextField widget built over CupertinoTextField that ensures
/// project-wide design consistency. It handles standard border styling
/// and optional reactive focus coloring.
class CommonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final Widget? prefix;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final BoxDecoration? decoration;
  final void Function(PointerDownEvent)? onTapOutside;

  const CommonTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onSubmitted,
    this.onChanged,
    this.onTap,
    this.padding,
    this.style,
    this.placeholderStyle,
    this.prefix,
    this.suffix,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.decoration,
    this.onTapOutside,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (focusNode != null) {
      // If a focus node is provided, wrap with Obx for reactive border styling
      // Note: We use an internal RxBool to manage focus state without polluting controllers.
      final isFocused = false.obs;
      
      focusNode!.addListener(() {
        isFocused.value = focusNode!.hasFocus;
      });

      return Obx(() {
        return _buildField(isActive: isFocused.value);
      });
    }

    // Default static field if no focus node is provided
    return _buildField(isActive: false);
  }

  Widget _buildField({required bool isActive}) {
    return CupertinoTextField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: ColorConstants.primaryColor,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      readOnly: readOnly,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical ?? TextAlignVertical.center,
      onTapOutside: onTapOutside,
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: MySize.getWidth(12),
            vertical: MySize.getHeight(10), // Standardized padding
          ),
      prefix: prefix,
      suffix: suffix,
      placeholder: placeholder,
      placeholderStyle: placeholderStyle ??
          TextStyle(
            color: ColorConstants.grey600,
            fontSize: MySize.getHeight(12),
          ),
      style: style ??
          TextStyle(
            fontSize: MySize.getHeight(12),
            color: Colors.black,
          ),
      decoration: decoration ??
          BoxDecoration(
            color: readOnly ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(MySize.getHeight(8)),
            border: Border.all(
              color: isActive
                  ? ColorConstants.primaryColor
                  : Colors.grey.shade300,
              width: MySize.getWidth(1),
            ),
          ),
    );
  }
}
