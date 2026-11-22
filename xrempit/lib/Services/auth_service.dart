import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import '../Pages/login_register_screen.dart';
import '../Admins/admin_home.dart';

import 'firestore_service.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.hasData) {
            final user = authSnapshot.data!;
            return FutureBuilder<DocumentSnapshot>(
              future: firestoreDb
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, docSnapshot) {
                if (docSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: BackButton(
                        onPressed: () async {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            // Signs out so StreamBuilder returns to LogOrRegScreen
                            await FirebaseAuth.instance.signOut();
                          }
                        },
                      ),
                    ),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("User data not found"),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                }

                final data = docSnapshot.data!.data() as Map<String, dynamic>;
                final role = data['role'] ?? 'user';

                if (role == 'admin') {
                  return AdminHomePage();
                } else {
                  return HomeScreen();
                }
              },
            );
          } else {
            return const LogOrRegScreen();
          }
        },
      ),
    );
  }
}