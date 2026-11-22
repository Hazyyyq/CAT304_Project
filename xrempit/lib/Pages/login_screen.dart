import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Components/text_file_mng.dart';
import '../Components/button_mng.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> signUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (mounted) Navigator.pop(context); // Close loading dialog
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog

      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPassMessage();
      } else {
        wrongCredentialMessage();
      }
    }
  }

  void wrongCredentialMessage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AlertDialog(
        title: Text('Incorrect Credentials'),
      ),
    );
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AlertDialog(
        title: Text('Incorrect Email'),
      ),
    );
  }

  void wrongPassMessage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AlertDialog(
        title: Text('Incorrect Password'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'X',
                        style: TextStyle(color: Color(0xFFFF0000)),
                      ),
                      TextSpan(text: 'Rempit'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                TextFieldMng(
                  controller: emailCtrl,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                TextFieldMng(
                  controller: passCtrl,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                ButtonMng(
                  onTap: signUser,
                  text: "Sign In",
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not a member?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}