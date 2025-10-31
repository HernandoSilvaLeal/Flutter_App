import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final q = FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: uid);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: StreamBuilder<QuerySnapshot>(stream: q.snapshots(), builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('Sin reservas'));
        return ListView(children: docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final formatted = DateFormat('dd/MM/yyyy').format(date);
          final title = data['serviceTitle'] ?? '';
          return ListTile(title: Text('$formatted — $title'), subtitle: Text('${data['startTime']} - ${data['endTime']}'));
        }).toList());
      }),
    );
  }
}
