import 'package:flutter/material.dart';
import 'package:shifts/models/my_user.dart';
import 'package:shifts/services/auth.dart';
import 'package:shifts/shared/constants.dart';
import 'package:shifts/shared/loading.dart';

class SignIn extends StatefulWidget {
  const SignIn({required this.toggleView, super.key});
  final VoidCallback toggleView;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Loading();
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF5EA),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text("Směny", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            TextButton.icon(
              label: const Text("Registrace", style: TextStyle(color: Colors.white)),
              onPressed: () => widget.toggleView(),
              icon: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: email,
                  decoration: textInputDecoration.copyWith(hintText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Zadejte email";
                    return null;
                  },
                  onChanged: (e) {
                    setState(() {
                      email = e;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: password,
                  decoration: textInputDecoration.copyWith(hintText: "Heslo"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Zadejte heslo";
                    return null;
                  },
                  obscureText: true,
                  onChanged: (e) {
                    setState(() {
                      password = e;
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), backgroundColor: primaryColor, foregroundColor: Colors.white),
                  child: const Text("Přihlásit se", style: TextStyle(fontSize: 18)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => loading = true);
                      MyUser? result = await _auth.signInWithEmailAndPassword(email, password);
                      if (result == null) {
                        setState(() {
                          loading = false;
                          error = 'Zadejte platný email a heslo.';
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
