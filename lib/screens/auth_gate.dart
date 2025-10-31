import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_router.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(body: Center(child: Text('Error: \\${snap.error}')));
        }
        if (snap.data == null) {
          // No logged → Login
          return const LoginScreen();
        }
        // Logged → Home
        return const HomeScreen();
      },
    );
  }
}
