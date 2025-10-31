import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../client/client_home.dart';
import '../provider/provider_home.dart';

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (_, s) {
        if (!s.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final data = s.data!.data();
        final role = (data as Map<String, dynamic>)['role'] as String;
        return role == 'provider' ? const ProviderHome() : const ClientHome();
      },
    );
  }
}
