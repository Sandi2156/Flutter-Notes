import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("LogIn"),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Center(
                  child: Column(
                    children: [
                      TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration:
                            const InputDecoration(hintText: "enter email here"),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: "enter passoword here"),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            final email = _email.text;
                            final password = _password.text;

                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);
                            print(userCredential);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == "user-not-found") {
                              print("user not found");
                            } else if (e.code == "wrong-password") {
                              print("wrong password");
                            }
                          } catch (e) {
                            print(e.runtimeType);
                          }
                        },
                        child: const Text("Log In"),
                      ),
                    ],
                  ),
                );
            }
            return const Text("Loading...");
          },
        ));
  }
}