import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shifts/models/my_user.dart';
import 'package:shifts/models/person.dart';
import 'package:shifts/models/shift.dart';
import 'package:shifts/screens/change_schedule/change_schedule.dart';
import 'package:shifts/screens/personnel/personnel.dart';
import 'package:shifts/screens/week_schedule/week_schedule.dart';
import 'package:shifts/screens/personal_schedule/personal_schedule.dart';
import 'package:shifts/services/auth.dart';
import 'package:shifts/services/database.dart';
import 'package:shifts/shared/app_version.dart';
import 'package:shifts/shared/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  String _storedName = '';
  String _shiftName = '';

  void _getStoredNameShiftName(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _storedName = prefs.getString('selected_name') ?? '');

    if (_storedName == '') return;
    DateTime nextDay = DateTime(DateTime.now().year, DateTime.now().add(const Duration(days: 1)).day);
    final DatabaseServer databaseServer = DatabaseServer();
    ShiftType? shiftType = await databaseServer.getShiftFromDateName(nextDay, Person.fromFullName(_storedName));
    setState(() {
      switch (shiftType) {
        case ShiftType.morning:
          _shiftName = 'ranní';
          break;
        case ShiftType.afternoon:
          _shiftName = 'odpolední';
          break;
        case ShiftType.night:
          _shiftName = 'noční';
          break;
        default:
          _shiftName = 'volno';
      }
    });
  }

  @override
  void initState() {
    _getStoredNameShiftName(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text("Směny"),
        centerTitle: true,
        leading: Image.asset('assets/app_icon.png'),
        actions: [
          TextButton.icon(
            label: const Text("Odhlásit", style: TextStyle(color: Colors.white)),
            onPressed: () async => await _auth.signOut(),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          if (_storedName.isNotEmpty) InfoText(_storedName, _shiftName),
          const SizedBox(height: 50),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton("Odobní rozpis", Icons.perm_contact_calendar_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalSchedule())).then((value) => _getStoredNameShiftName(context))),
                    CustomButton("Týdenní rozpis", Icons.calendar_month_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WeekSchedule()))),
                  ],
                ),
                const SizedBox(height: 30),
                if (user?.uid == "7KhB498kr9WdFcGIAfj7xlDfIBj2")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton("Změny rozpisu", Icons.edit_calendar_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeSchedule()))),
                      CustomButton("Personál", Icons.emoji_people, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Personnel()))),
                    ],
                  ),
              ],
            ),
          ),
          const AppVersion(),
        ],
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  const InfoText(this.name, this.shiftName, {super.key});
  final String name;
  final String shiftName;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Text("$name zítra máš $shiftName", style: const TextStyle(fontSize: 20, color: Colors.black)),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton(this.name, this.icon, this.nav, {super.key});
  final String name;
  final IconData icon;
  final Function nav;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 10,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => nav(),
        child: Column(
          children: [
            Icon(icon, size: 50),
            Text(name, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
