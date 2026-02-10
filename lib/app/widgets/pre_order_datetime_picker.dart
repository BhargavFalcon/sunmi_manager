import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/sizeConstant.dart';
import '../constants/translation_keys.dart';

class PreOrderDateTimePicker extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(DateTime date, TimeOfDay time) onSave;
  final VoidCallback onReset;

  const PreOrderDateTimePicker({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onSave,
    required this.onReset,
  });

  @override
  State<PreOrderDateTimePicker> createState() => _PreOrderDateTimePickerState();
}

class _PreOrderDateTimePickerState extends State<PreOrderDateTimePicker> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = widget.initialDate ?? DateTime.now();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(16)),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(MySize.getHeight(16)),
        width: MySize.getWidth(340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TranslationKeys.selectDateAndTime.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: MySize.getHeight(20),
                  ),
                ),
              ],
            ),
            SizedBox(height: MySize.getHeight(16)),
            const Divider(),
            SizedBox(height: MySize.getHeight(8)),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  size: MySize.getHeight(24),
                  color: Colors.grey,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  size: MySize.getHeight(24),
                  color: Colors.grey,
                ),
                titleTextStyle: TextStyle(
                  fontSize: MySize.getHeight(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                headerPadding: EdgeInsets.symmetric(
                  vertical: MySize.getHeight(8),
                ),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFF14E5E),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFFF14E5E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: const TextStyle(
                  color: Color(0xFFF14E5E),
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: TextStyle(
                  fontSize: MySize.getHeight(14),
                  color: Colors.black87,
                ),
                weekendTextStyle: TextStyle(
                  fontSize: MySize.getHeight(14),
                  color: Colors.black87,
                ),
                outsideDaysVisible: false,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: MySize.getHeight(12),
                ),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: MySize.getHeight(12),
                ),
              ),
              rowHeight: MySize.getHeight(40),
              headerVisible: true,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
            SizedBox(height: MySize.getHeight(16)),
            GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: const Color(0xFFF14E5E),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != _selectedTime) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MySize.getWidth(12),
                  vertical: MySize.getHeight(12),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.access_time_filled,
                      color: Colors.grey.shade600,
                      size: MySize.getHeight(18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MySize.getHeight(24)),
            SizedBox(height: MySize.getHeight(24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: MySize.getWidth(80),
                  height: MySize.getHeight(40),
                  child: TextButton(
                    onPressed: () {
                      widget.onReset();
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Text(
                      TranslationKeys.reset.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MySize.getWidth(8)),
                SizedBox(
                  width: MySize.getWidth(80),
                  height: MySize.getHeight(40),
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_selectedDay, _selectedTime);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF14E5E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(8),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      TranslationKeys.save.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
