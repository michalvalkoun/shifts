// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shifts/models/day.dart';
import 'package:shifts/models/person.dart';
import 'package:shifts/models/schedule.dart';
import 'package:shifts/models/shift.dart';

class DatabaseServer {
  // collection reference
  final CollectionReference _personnel = FirebaseFirestore.instance.collection('personnel');
  final CollectionReference _shiftsCollection = FirebaseFirestore.instance.collection('shifts');

  Future<void> addPersonToPersonnel(Person person) {
    return _personnel.add({
      'name': person.name,
      'surname': person.surname,
    }).then((value) {
      print("${person.name} ${person.surname} added successfully!");
    }).catchError((error) {
      print("Failed to add ${person.name} ${person.surname} : $error");
    });
  }

  Future<void> deletePersonFromPersonnel(Person person) {
    return _personnel.where('name', isEqualTo: person.name).where('surname', isEqualTo: person.surname).get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    }).then((_) {
      print("${person.name} ${person.surname} deleted successfully!");
    }).catchError((error) {
      print("Failed to delete ${person.name} ${person.surname}: $error");
    });
  }

  Future<void> addPersonToShift(DateTime date, ShiftType shift, Person person) async {
    String dateString = date.toIso8601String().split("T")[0];
    final DocumentReference shiftDocRef = _shiftsCollection.doc(dateString);

    final DocumentSnapshot shiftDoc = await shiftDocRef.get();
    if (!shiftDoc.exists) {
      try {
        await shiftDocRef.set(<String, dynamic>{});
        print("Document $dateString created for $shift shift");
      } catch (error) {
        print("Failed to create document $dateString for $shift shift: $error");
        return;
      }
    }

    _shiftsCollection
        .doc(dateString)
        .collection(_getShiftName(shift))
        .add({'name': person.name, 'surname': person.surname})
        .then((value) => print("${person.name} ${person.surname} added to $shift shift"))
        .catchError((error) => print("Failed to add ${person.name} ${person.surname} to $shift shift in $date: $error"));
  }

  Future<void> deletePersonFromShift(DateTime date, ShiftType shift, Person person) async {
    String dateString = date.toIso8601String().split("T")[0];
    return _shiftsCollection.doc(dateString).collection(_getShiftName(shift)).where('name', isEqualTo: person.name).where('surname', isEqualTo: person.surname).get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    }).then((_) {
      print("${person.name} ${person.surname} deleted from $shift shift on $date");
    }).catchError((error) {
      print("Failed to delete ${person.name} ${person.surname} from $shift shift on $date: $error");
    });
  }

  Future<Schedule> getSchedule() async {
    Map<DateTime, Day> daysMap = {};

    await _shiftsCollection.get().then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        DateTime date = DateTime.parse(doc.id);
        Shift morningShift = await _getShiftFromDocument(doc, ShiftType.morning);
        Shift afternoonShift = await _getShiftFromDocument(doc, ShiftType.afternoon);
        Shift nightShift = await _getShiftFromDocument(doc, ShiftType.night);

        Day day = Day(morning: morningShift, afternoon: afternoonShift, night: nightShift);
        daysMap[date] = day;
      }
    }).catchError((error) {
      print("Failed to get schedule data: $error");
    });

    return Schedule(days: daysMap);
  }

  Future<Shift> _getShiftFromDocument(DocumentSnapshot doc, ShiftType shiftType) async {
    String shiftName = _getShiftName(shiftType);
    List<Person> people = [];

    await doc.reference.collection(shiftName).get().then((QuerySnapshot querySnapshot) {
      for (var personDoc in querySnapshot.docs) {
        Person person = Person(personDoc['name'], personDoc['surname']);
        people.add(person);
      }
    });

    return Shift(people: people);
  }

  Future<List<Person>> getPeopleFromDateShift(DateTime date, ShiftType shift) async {
    List<Person> people = [];

    String shiftName = _getShiftName(shift);
    String dateString = date.toIso8601String().split("T")[0];

    await _shiftsCollection.doc(dateString).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        await documentSnapshot.reference.collection(shiftName).get().then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            Person person = Person(doc['name'], doc['surname']);
            people.add(person);
          }
        });
      } else {
        print('$dateString does not exist');
      }
    }).catchError((error) {
      print("Failed to get shift data: $error");
    });

    return people;
  }

  String _getShiftName(ShiftType shift) {
    switch (shift) {
      case ShiftType.morning:
        return 'morning';
      case ShiftType.afternoon:
        return 'afternoon';
      case ShiftType.night:
        return 'night';
      default:
        throw ArgumentError('Invalid shift type');
    }
  }

  Future<ShiftType?> getShiftFromDateName(DateTime date, Person person) async {
    String dateString = date.toIso8601String().split("T")[0];

    try {
      DocumentSnapshot documentSnapshot = await _shiftsCollection.doc(dateString).get();

      if (documentSnapshot.exists) {
        if (await _isPersonInShift(documentSnapshot, person, 'morning')) {
          return ShiftType.morning;
        } else if (await _isPersonInShift(documentSnapshot, person, 'afternoon')) {
          return ShiftType.afternoon;
        } else if (await _isPersonInShift(documentSnapshot, person, 'night')) {
          return ShiftType.night;
        }
      } else {
        print('$dateString does not exist');
        return null;
      }
    } catch (error) {
      print("Failed to get shift data: $error");
      return null;
    }
    return null;
  }

  Future<bool> _isPersonInShift(DocumentSnapshot documentSnapshot, Person person, String shiftType) async {
    try {
      QuerySnapshot querySnapshot = await documentSnapshot.reference.collection(shiftType).get();

      for (var doc in querySnapshot.docs) {
        Person shiftPerson = Person(doc['name'], doc['surname']);
        if (shiftPerson.name == person.name && shiftPerson.surname == person.surname) {
          return true;
        }
      }

      return false;
    } catch (error) {
      print("Error checking for person in $shiftType shift: $error");
      return false;
    }
  }
}
