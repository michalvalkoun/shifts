import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shifts/models/my_user.dart';
import 'package:shifts/screens/authenticate/authenticate.dart';
import 'package:shifts/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);
    if (user == null) {
      return const Authenticate();
    } else {
      return const Home();
    }
  }
}
