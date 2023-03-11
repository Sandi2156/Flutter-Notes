import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/MenuAction.dart';
import 'package:mynotes/services/auth/autth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class MyNotesView extends StatefulWidget {
  const MyNotesView({super.key});

  @override
  State<MyNotesView> createState() => _MyNotesViewState();
}

class _MyNotesViewState extends State<MyNotesView> {
  String get userEmail => AuthService.firebase().currentUser!.email!;
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Notes"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final isWannaLogOut = await showLogoutDialog(context);
                    if (isWannaLogOut) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                    break;
                  default:
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("log out"),
                )
              ],
            )
          ],
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text("waiting for all notes...");
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are you sure ?"),
        actions: [
          TextButton(
            onPressed: () => {Navigator.of(context).pop(false)},
            child: const Text("cancel"),
          ),
          TextButton(
            onPressed: () => {Navigator.of(context).pop(true)},
            child: const Text("sign out"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
