import 'package:flutter/material.dart';

import 'package:shifts/shared/constants.dart';
import 'package:shifts/shared/date_picker.dart';
import 'package:shifts/shared/schedule_table/schedule_header.dart';
import 'package:shifts/shared/schedule_table/schedule_table.dart';

class WeekSchedule extends StatefulWidget {
  const WeekSchedule({super.key});

  @override
  State<WeekSchedule> createState() => _WeekScheduleState();
}

class _WeekScheduleState extends State<WeekSchedule> {
  DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, 1);

  void updateDate(DateTime date) {
    setState(() {
      _date = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Týdenní rozpis"),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          DatePicker(updateDate),
          const SizedBox(height: 10),
          const ScheduleHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: ScheduleTable(_date, false),
            ),
          ),
        ],
      ),
    );
  }
}
