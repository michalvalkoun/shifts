import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shifts/models/day.dart';
import 'package:shifts/models/person.dart';
import 'package:shifts/models/schedule.dart';
import 'package:shifts/models/shift.dart';
import 'package:shifts/services/database.dart';
import 'package:shifts/shared/constants.dart';
import 'package:shifts/shared/loading.dart';

class ScheduleTable extends StatefulWidget {
  const ScheduleTable(this.dateMonth, this.editable, {super.key});
  final DateTime dateMonth;
  final bool editable;

  @override
  State<ScheduleTable> createState() => _ScheduleTableState();
}

class _ScheduleTableState extends State<ScheduleTable> {
  @override
  Widget build(BuildContext context) {
    final DatabaseServer firestoreService = DatabaseServer();
    return FutureBuilder(
        future: firestoreService.getSchedule(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading();
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Error"));
          } else {
            return buildMonth(widget.dateMonth, snapshot.data!);
          }
        });
  }

  Widget buildWeeksAndDays() {
    List<Widget> weeks = [];
    DateTime firstDayOfMonth = DateTime(widget.dateMonth.year, widget.dateMonth.month, 1);
    DateTime lastDayOfMonth = DateTime(widget.dateMonth.year, widget.dateMonth.month + 1, 0);
    DateTime firstDayOfCurrentWeek = firstDayOfMonth;

    while (firstDayOfCurrentWeek.isBefore(lastDayOfMonth)) {
      List<Widget> daysInWeek = [];

      for (int i = 0; i < 7; i++) {
        if (firstDayOfCurrentWeek.isBefore(firstDayOfMonth) || firstDayOfCurrentWeek.isAfter(lastDayOfMonth)) {
          daysInWeek.add(Container());
        } else {
          daysInWeek.add(
            Expanded(
              child: Center(
                child: Text('${firstDayOfCurrentWeek.day}', style: const TextStyle(fontSize: 18)),
              ),
            ),
          );
        }

        firstDayOfCurrentWeek = firstDayOfCurrentWeek.add(const Duration(days: 1));
      }

      weeks.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: daysInWeek,
          ),
        ),
      );
    }

    return Column(
      children: weeks,
    );
  }

  Widget buildMonth(DateTime monthStart, Schedule schedule) {
    List<Widget> weeks = [];
    DateTime date;
    int dayOfWeek = monthStart.weekday;

    if (dayOfWeek >= DateTime.monday && dayOfWeek <= DateTime.friday) {
      date = monthStart.subtract(Duration(days: monthStart.weekday - 1));
    } else {
      date = monthStart.add(Duration(days: 8 - monthStart.weekday));
    }
    do {
      weeks.add(buildWeek(date, schedule));
      date = date.add(const Duration(days: 7));
    } while (date.month == monthStart.month);

    return Column(children: weeks);
  }

  Widget buildWeek(DateTime date, Schedule schedule) {
    return Column(children: [
      for (int i = 0; i < 5; i++) buildRow(date.add(Duration(days: i)), schedule),
      Container(height: 1.5, color: Colors.grey),
    ]);
  }

  Widget buildRow(DateTime date, Schedule schedule) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          buildDateColumn(date),
          Container(width: 1, color: Colors.grey),
          for (int j = 0; j < 3; j++) buildShiftColumn(date, ShiftType.values[j], schedule),
        ],
      ),
    );
  }

  Widget buildDateColumn(DateTime date) {
    return Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSameDay(DateTime.now(), date) ? secondaryColor : backgroundColor,
          border: Border.all(color: Colors.grey, width: 0.5),
        ),
        child: Text(
          "${DateFormat.E('cs').format(date)}\n${DateFormat.Md('cs').format(date)}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildShiftColumn(DateTime date, ShiftType shiftType, Schedule schedule) {
    final containerColor = isSameDay(DateTime.now(), date) ? secondaryColor.withOpacity(0.2) : null;
    Day? day = schedule.days[date];
    List<Person> people = [];
    if (day == null) {
      people = List<Person>.empty();
    } else {
      switch (shiftType) {
        case ShiftType.morning:
          people = day.morning.people;
          break;
        case ShiftType.afternoon:
          people = day.afternoon.people;
          break;
        case ShiftType.night:
          people = day.night.people;
          break;
      }
    }
    List<String> fullNames = people.map((e) => e.surname).toList();
    return Expanded(
      flex: 3,
      child: GestureDetector(
        onTap: widget.editable ? () => _showAddNameToShift(context, date, shiftType) : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: containerColor, border: Border.all(color: Colors.grey, width: 0.5)),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Text(formatShiftNames(fullNames), textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSpacer() {
    return Column(
      children: [
        Container(height: 50, color: Colors.grey.shade200),
        Container(height: 1.5, color: Colors.grey),
      ],
    );
  }

  String formatShiftNames(List<String> names) {
    if (names.isEmpty) return "";
    List<String> sortedNames = List.from(names)..sort();
    return sortedNames.join('\n');
  }

  Future<void> _showAddNameToShift(BuildContext context, DateTime date, ShiftType shiftType) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNameToShiftDialog(date, shiftType);
      },
    ).then((person) {
      setState(() {});
    });
  }
}

class AddNameToShiftDialog extends StatefulWidget {
  const AddNameToShiftDialog(this.date, this.shiftType, {super.key});
  final DateTime date;
  final ShiftType shiftType;

  @override
  State<AddNameToShiftDialog> createState() => _AddNameToShiftDialogState();
}

class _AddNameToShiftDialogState extends State<AddNameToShiftDialog> {
  @override
  Widget build(BuildContext context) {
    final DatabaseServer firestoreService = DatabaseServer();

    return AlertDialog(
      title: const Text('Směna'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Odejít', style: TextStyle(color: Colors.black))),
        ElevatedButton(
          onPressed: () => _showNameSelectionDialog(context, widget.date, widget.shiftType),
          child: const Text('Přidat', style: TextStyle(color: Colors.black)),
        ),
      ],
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      content: SizedBox(
        height: 500,
        width: double.maxFinite,
        child: FutureBuilder<List<Person>>(
          future: firestoreService.getPeopleFromDateShift(widget.date, widget.shiftType),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Chyba: ${snapshot.error}'));
            }

            List<String> namesList = [];
            if (snapshot.data != null) {
              namesList = snapshot.data!.map((e) => e.getFullName()).toList();
            }

            return ListView.builder(
              itemCount: namesList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    borderOnForeground: true,
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(left: 15),
                      dense: true,
                      textColor: Colors.black,
                      tileColor: secondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      title: Text(namesList[index], style: const TextStyle(fontSize: 17)),
                      trailing: SizedBox(
                        width: 60,
                        child: GestureDetector(
                          onTap: () {
                            final DatabaseServer databaseServer = DatabaseServer();
                            List<String> fullName = namesList[index].split(' ');
                            String name = fullName[0];
                            String surname = fullName[1];

                            databaseServer.deletePersonFromShift(widget.date, widget.shiftType, Person(name, surname)).then((_) => setState(() {}));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: const BorderRadius.horizontal(right: Radius.circular(9))),
                            child: const Icon(Icons.delete, color: Colors.black, size: 25),
                          ),
                        ),
                      ),
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

  Future<void> _showNameSelectionDialog(BuildContext context, DateTime date, ShiftType shiftType) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NameSelectionDialogWidget();
      },
    ).then((person) async {
      if (person != null) {
        final DatabaseServer firestoreService = DatabaseServer();
        await firestoreService.addPersonToShift(date, shiftType, person).then((_) {
          setState(() {});
        });
      }
    });
  }
}

class NameSelectionDialogWidget extends StatefulWidget {
  const NameSelectionDialogWidget({super.key});

  @override
  State<NameSelectionDialogWidget> createState() => _NameSelectionDialogWidgetState();
}

class _NameSelectionDialogWidgetState extends State<NameSelectionDialogWidget> {
  final DatabaseServer firestoreService = DatabaseServer();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vyber jméno'),
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    borderOnForeground: true,
                    child: ListTile(
                      dense: true,
                      textColor: Colors.black,
                      tileColor: secondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      title: Text(namesList[index]),
                      onTap: () {
                        final name = namesList[index].split(' ')[0];
                        final surname = namesList[index].split(' ')[1];
                        if (name.isNotEmpty && surname.isNotEmpty) {
                          Navigator.of(context).pop(Person(name, surname));
                        }
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
}
