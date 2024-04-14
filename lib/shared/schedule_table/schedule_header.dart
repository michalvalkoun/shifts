import 'package:flutter/material.dart';
import 'package:shifts/shared/constants.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  final double headerHeight = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1.5, color: Colors.grey),
        Row(
          children: [
            buildTitle("Datum", const Color(0xFFFFF5EA), flex: 2),
            Container(width: 1, height: headerHeight, color: Colors.grey),
            buildTitle(ShiftConstants.shiftNames[0], ShiftConstants.shiftColors["morning"]!, flex: 3),
            buildTitle(ShiftConstants.shiftNames[1], ShiftConstants.shiftColors["afternoon"]!, flex: 3),
            buildTitle(ShiftConstants.shiftNames[2], ShiftConstants.shiftColors["night"]!, flex: 3)
          ],
        ),
        Container(height: 1.5, color: Colors.grey),
      ],
    );
  }

  Widget buildTitle(String text, Color color, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: headerHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, border: Border.all(color: Colors.grey, width: 0.5)),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
