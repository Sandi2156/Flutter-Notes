import 'package:flutter/material.dart';

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/utils/show_eror_dialog.dart';

import 'dart:developer' as devtools show log;
import 'package:mynotes/services/auth/autth_service.dart';

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
      appBar: AppBar(title: const Text("Login")),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "enter email here"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "enter passoword here"),
          ),
          TextButton(
            onPressed: () async {
              try {
                final email = _email.text;
                final password = _password.text;

                final userCredential = await AuthService.firebase().logIn(
                  email: email,
                  password: password,
                );

                devtools.log(userCredential.toString());

                final user = AuthService.firebase().currentUser;
                if (user != null && user.isEmailVerified) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else if (user != null) {
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  "user not found",
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  "wrong password",
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  "Error: Authentication",
                );
              }
            },
            child: const Text("Log In"),
          ),
          TextButton(
              onPressed: () => {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute, (route) => false)
                  },
              child: const Text("Don't have an account, Register here !"))
        ],
      ),
    );
  }
}
