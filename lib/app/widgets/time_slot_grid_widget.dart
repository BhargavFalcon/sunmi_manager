import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

class TimeSlotGridWidget extends StatelessWidget {
  const TimeSlotGridWidget({
    super.key,
    required this.sectionTitle,
    required this.timeSlots,
    required this.selectedSectionTitle,
    required this.selectedTimeSlot,
    required this.onSlotSelected,
    this.checkingSectionTitle,
    this.checkingSlot,
    this.itemsPerRow = 4,
    this.spacing,
  });

  final String sectionTitle;
  final List<String> timeSlots;
  final String selectedSectionTitle;
  final String selectedTimeSlot;
  final void Function(String title, String slot) onSlotSelected;
  final String? checkingSectionTitle;
  final String? checkingSlot;
  final int itemsPerRow;
  final double? spacing;

  double get _spacing => spacing ?? MySize.getWidth(6);

  bool _isSelected(String slot) =>
      selectedSectionTitle == sectionTitle && selectedTimeSlot == slot;

  bool _isChecking(String slot) =>
      checkingSectionTitle != null &&
      checkingSlot != null &&
      checkingSectionTitle == sectionTitle &&
      checkingSlot == slot;

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final itemWidth =
            (availableWidth - (_spacing * (itemsPerRow - 1))) / itemsPerRow;

        final rows = <Widget>[];
        for (int i = 0; i < timeSlots.length; i += itemsPerRow) {
          final rowItems = <Widget>[];
          for (int j = 0; j < itemsPerRow && i + j < timeSlots.length; j++) {
            final slot = timeSlots[i + j];
            final selected = _isSelected(slot);
            final checking = _isChecking(slot);
            if (j > 0) rowItems.add(SizedBox(width: _spacing));
            rowItems.add(
              SizedBox(
                width: itemWidth,
                child: GestureDetector(
                  onTap:
                      checking
                          ? null
                          : () => onSlotSelected(sectionTitle, slot),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(2),
                      vertical: MySize.getHeight(8),
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? ColorConstants.primaryColor.withValues(
                                alpha: 0.1,
                              )
                              : Colors.white,
                      border: Border.all(
                        color:
                            selected
                                ? ColorConstants.primaryColor
                                : ColorConstants.grey9E9E9E,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    ),
                    child: Center(
                      child:
                          checking
                              ? const CupertinoActivityIndicator(radius: 10)
                              : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  slot,
                                  style: TextStyle(
                                    fontSize: MySize.getHeight(11),
                                    color:
                                        selected
                                            ? ColorConstants.primaryColor
                                            : Colors.black,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            );
          }
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: MySize.getHeight(6)),
              child: Row(children: rowItems),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

class TimeSlotSectionWidget extends StatelessWidget {
  const TimeSlotSectionWidget({
    super.key,
    required this.sectionTitle,
    required this.timeSlots,
    required this.selectedSectionTitle,
    required this.selectedTimeSlot,
    required this.onSlotSelected,
    this.checkingSectionTitle,
    this.checkingSlot,
    this.titleStyle,
  });

  final String sectionTitle;
  final List<String> timeSlots;
  final String selectedSectionTitle;
  final String selectedTimeSlot;
  final void Function(String title, String slot) onSlotSelected;
  final String? checkingSectionTitle;
  final String? checkingSlot;
  final TextStyle? titleStyle;

  static TextStyle defaultTitleStyle() => TextStyle(
    color: Colors.black,
    fontSize: MySize.getHeight(14),
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(sectionTitle, style: titleStyle ?? defaultTitleStyle()),
        SizedBox(height: MySize.getHeight(8)),
        TimeSlotGridWidget(
          sectionTitle: sectionTitle,
          timeSlots: timeSlots,
          selectedSectionTitle: selectedSectionTitle,
          selectedTimeSlot: selectedTimeSlot,
          onSlotSelected: onSlotSelected,
          checkingSectionTitle: checkingSectionTitle,
          checkingSlot: checkingSlot,
        ),
      ],
    );
  }
}
