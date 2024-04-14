import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shifts/shared/constants.dart';

class DatePicker extends StatefulWidget {
  const DatePicker(this.updateDate, {super.key});
  final Function updateDate;
  @override
  State<DatePicker> createState() => _TimeState();
}

class _TimeState extends State<DatePicker> with SingleTickerProviderStateMixin {
  late int _selectedYear;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _date = DateTime(DateTime.now().year, DateTime.now().month);
  }

  Widget buildMonthButton(DateTime date) {
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: date.isAtSameMomentAs(_date) ? primaryColor : Colors.transparent,
          foregroundColor: date.isAtSameMomentAs(_date) ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() => _date = date);
          widget.updateDate(_date);
        },
        child: Text(DateFormat.MMM('cs').format(date)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.navigate_before_rounded),
              onPressed: () => setState(() => _selectedYear -= 1),
            ),
            Expanded(child: Center(child: Text(_selectedYear.toString(), style: const TextStyle(fontWeight: FontWeight.bold)))),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.navigate_next_rounded),
              onPressed: () => setState(() => _selectedYear += 1),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 1; i <= 6; i++) buildMonthButton(DateTime(_selectedYear, i)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 7; i <= 12; i++) buildMonthButton(DateTime(_selectedYear, i)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
