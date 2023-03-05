import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/autth_service.dart';

class VefiyEmailView extends StatefulWidget {
  const VefiyEmailView({super.key});

  @override
  State<VefiyEmailView> createState() => _VefiyEmailViewState();
}

class _VefiyEmailViewState extends State<VefiyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify"),
      ),
      body: Column(
        children: [
          const Text(
              "We've already sent you an email. please open to verify your email"),
          const Text(
              "If you haven't received a verification mail, click on it to get a verification mail"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
              Navigator.of(context).pushNamed(loginRoute);
            },
            child: const Text("click to verify"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
