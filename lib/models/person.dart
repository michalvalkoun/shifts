class Person {
  final String name;
  final String surname;
  Person(this.name, this.surname);
  factory Person.fromFullName(String fullName) {
    var splitName = fullName.split(' ');
    return Person(splitName[0], splitName[1]);
  }
  String getFullName() {
    return "$name $surname";
  }
}
