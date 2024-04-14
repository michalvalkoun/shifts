import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shifts/models/person.dart';
import 'package:shifts/shared/constants.dart';
import 'package:shifts/services/database.dart';
import 'package:shifts/shared/loading.dart';

class Personnel extends StatefulWidget {
  const Personnel({super.key});

  @override
  State<Personnel> createState() => _PersonnelState();
}

class _PersonnelState extends State<Personnel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text("Personál"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _showAddNameDialog(context),
        child: const Icon(Icons.add),
      ),
      body: _buildNameList(context),
    );
  }

  Widget _buildNameList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                color: secondaryColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 15),
                  title: Text(namesList[index], style: const TextStyle(fontSize: 18)),
                  trailing: SizedBox(
                    width: 80,
                    child: GestureDetector(
                      onTap: () {
                        final DatabaseServer databaseServer = DatabaseServer();
                        List<String> fullName = namesList[index].split(' ');
                        String name = fullName[0];
                        String surname = fullName[1];
                        databaseServer.deletePersonFromPersonnel(Person(name, surname)).then((_) => setState(() {}));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: const BorderRadius.horizontal(right: Radius.circular(9))),
                        child: const Icon(Icons.delete, color: Colors.black, size: 30),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddNameDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNameDialog();
      },
    ).then((person) {
      if (person != null) {
        final DatabaseServer firestoreService = DatabaseServer();
        firestoreService.addPersonToPersonnel(person).then((_) {
          setState(() {});
        });
      }
    });
  }
}

class AddNameDialog extends StatelessWidget {
  AddNameDialog({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Přidat personál'),
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Jméno'),
          ),
          TextField(
            controller: surnameController,
            decoration: const InputDecoration(labelText: 'Příjmení'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Zrušit', style: TextStyle(color: Colors.black))),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            final surname = surnameController.text.trim();
            if (name.isNotEmpty && surname.isNotEmpty) {
              Navigator.of(context).pop(Person(name, surname));
            }
          },
          child: const Text('Přidat', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
