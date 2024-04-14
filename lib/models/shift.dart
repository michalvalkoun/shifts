import 'person.dart';

enum ShiftType { morning, afternoon, night }

class Shift {
  final List<Person> people;

  Shift({required this.people});
}
