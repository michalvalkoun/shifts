import 'package:flutter/material.dart';

class ShiftConstants {
  static const List<String> shiftNames = ["Ranní", "Odpolední", "Noční"];
  static Map<String, Color> shiftColors = {"morning": const Color(0xFFFCAA67).withOpacity(0.7), "afternoon": const Color(0xFFA5D0A8).withOpacity(0.7), "night": const Color(0xFF807182).withOpacity(0.7)};
}

const primaryColor = Color(0xFF1A73B8);
const secondaryColor = Color(0xFFF4A770);
const backgroundColor = Color(0xFFFFF5EA);

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryColor, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  ),
);

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}
