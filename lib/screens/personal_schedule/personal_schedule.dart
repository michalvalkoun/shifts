import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shifts/models/person.dart';
import 'package:shifts/services/database.dart';
import 'package:shifts/shared/constants.dart';
import 'package:shifts/shared/loading.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shifts/models/shift.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalSchedule extends StatefulWidget {
  const PersonalSchedule({super.key});

  @override
  State<PersonalSchedule> createState() => _PersonalScheduleState();
}

class _PersonalScheduleState extends State<PersonalSchedule> {
  String _storedName = '';
  final Map<DateTime, ShiftType> shifts = {
    DateTime(2024, 4, 8): ShiftType.morning,
    DateTime(2024, 4, 9): ShiftType.afternoon,
    DateTime(2024, 4, 10): ShiftType.morning,
    DateTime(2024, 4, 11): ShiftType.afternoon,
    DateTime(2024, 4, 12): ShiftType.night,
    DateTime(2024, 4, 15): ShiftType.morning,
    DateTime(2024, 4, 16): ShiftType.morning,
    DateTime(2024, 4, 17): ShiftType.afternoon,
    DateTime(2024, 4, 18): ShiftType.afternoon,
    DateTime(2024, 4, 19): ShiftType.morning,
  };
  @override
  void initState() {
    super.initState();
    _checkStoredName();
  }

  Future<void> _getStoredName(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _storedName = prefs.getString('selected_name') ?? '');
  }

  Future<void> _checkStoredName() async {
    await _getStoredName(context);
    if (_storedName.isEmpty || _storedName == '') {
      await _showNameSelectionDialog(context, _storedName);
      await _getStoredName(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Column(children: [
          const Text("Osobní rozpis"),
          Text(_storedName, style: const TextStyle(fontSize: 12)),
        ]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search_rounded),
            onPressed: () async {
              await _showNameSelectionDialog(context, _storedName);
              if (context.mounted) await _getStoredName(context);
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: DateTime.now(),
            daysOfWeekHeight: 20,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            locale: "cs_CS",
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, focusedDay) => buildCalendarElement(context, day),
              defaultBuilder: (context, day, focusedDay) => buildCalendarElement(context, day),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Legend("Ranní", ShiftConstants.shiftColors["morning"]!),
                  const SizedBox(height: 10),
                  Legend("Odpolední", ShiftConstants.shiftColors["afternoon"]!),
                  const SizedBox(height: 10),
                  Legend("Noční", ShiftConstants.shiftColors["night"]!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCalendarElement(BuildContext context, DateTime date) {
    DateTime now = DateTime.now();
    bool today = now.year == date.year && now.month == date.month && now.day == date.day;
    final text = date.day.toString();
    return FutureBuilder<Color>(
      future: calendarElement(date),
      builder: (context, snapshot) {
        Color? color;
        if (snapshot.connectionState == ConnectionState.waiting) {
          color = backgroundColor;
        } else if (snapshot.hasError) {
          color = backgroundColor;
        } else {
          color = snapshot.data;
        }
        return Container(
          color: backgroundColor,
          padding: EdgeInsets.all(today ? 0.5 : 1),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: color, border: today ? Border.all(width: 1.5) : null),
            child: Center(child: Text(text)),
          ),
        );
      },
    );
  }

  Future<Color> calendarElement(DateTime date) async {
    final DatabaseServer firestoreService = DatabaseServer();
    ShiftType? shift = await firestoreService.getShiftFromDateName(date, Person.fromFullName(_storedName));

    switch (shift) {
      case ShiftType.morning:
        return ShiftConstants.shiftColors["morning"]!;
      case ShiftType.afternoon:
        return ShiftConstants.shiftColors["afternoon"]!;
      case ShiftType.night:
        return ShiftConstants.shiftColors["night"]!;
      default:
        return backgroundColor;
    }
  }
}

_showNameSelectionDialog(BuildContext context, String? storedName) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => NameSelectionDialogWidget(storedName: storedName),
  );
}

class NameSelectionDialogWidget extends StatefulWidget {
  final String? storedName;

  const NameSelectionDialogWidget({super.key, this.storedName});

  @override
  State<NameSelectionDialogWidget> createState() => _NameSelectionDialogWidgetState();
}

class _NameSelectionDialogWidgetState extends State<NameSelectionDialogWidget> {
  late String _selectedName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vyber jméno'),
      backgroundColor: backgroundColor,
      content: SizedBox(
        height: 500,
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('personnel').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Chyba: ${snapshot.error}'));
            }

            List<String> namesList = [];
            if (snapshot.data != null) {
              namesList = snapshot.data!.docs.map((doc) => '${doc['name']} ${doc['surname']}').toList();
            }

            return ListView.builder(
              itemCount: namesList.length,
              itemBuilder: (context, index) {
                bool isSelected = namesList[index] == widget.storedName;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: isSelected ? const BorderSide(width: 2, color: Colors.black26) : BorderSide.none,
                    ),
                    borderOnForeground: true,
                    child: ListTile(
                      dense: true,
                      titleTextStyle: isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null,
                      textColor: Colors.black,
                      tileColor: isSelected ? primaryColor.withOpacity(0.4) : secondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      title: Text(namesList[index]),
                      onTap: () {
                        _selectedName = namesList[index];
                        _saveSelectedName(_selectedName);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveSelectedName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_name', name);
  }
}

class Legend extends StatelessWidget {
  const Legend(this.title, this.color, {super.key});
  final Color color;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color,
      ),
      child: Text(title),
    );
  }
}
