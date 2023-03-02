import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          const Text("Verify your email"),
          TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text("click to verify")),
        ],
      ),
    );
  }
}
