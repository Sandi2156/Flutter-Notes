import 'package:flutter/material.dart';

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/views/LoginView.dart';
import 'package:mynotes/views/notes/MyNotesView.dart';
import 'package:mynotes/views/RegisterView.dart';
import 'package:mynotes/views/VerifyEmailView.dart';
import 'package:mynotes/services/auth/autth_service.dart';
import 'package:mynotes/views/notes/new_note_view.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const MyNotesView(),
      verifyEmailRoute: (context) => const VefiyEmailView(),
      newNoteRoute: (context) => const NewNoteView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const MyNotesView();
                } else {
                  return const VefiyEmailView();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
