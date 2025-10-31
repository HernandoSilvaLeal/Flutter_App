import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderHome extends StatelessWidget {
  const ProviderHome({super.key});
  Future<void> _upd(String id, Map<String, dynamic> data) async =>
      FirebaseFirestore.instance.collection('appointments').doc(id).update(data);

  @override
  Widget build(BuildContext c) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pending = FirebaseFirestore.instance.collection('appointments').where('status', isEqualTo: 'pending').where('providerId', whereIn: ['', uid]).orderBy('scheduledFor').snapshots();

    final mine = FirebaseFirestore.instance.collection('appointments').where('providerId', isEqualTo: uid).where('status', whereIn: ['accepted', 'pending']).orderBy('scheduledFor').snapshots();

    return Scaffold(
        appBar: AppBar(title: const Text('Prestador – Citas'), actions: [
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))
        ]),
        body: Column(children: [
          const Padding(padding: EdgeInsets.all(8), child: Text('Pendientes', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: StreamBuilder<QuerySnapshot>(stream: pending, builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            final docs = s.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('Sin pendientes'));
            return ListView(children: docs.map((d) {
              final a = d.data() as Map<String, dynamic>;
              final when = (a['scheduledFor'] as Timestamp).toDate();
              return ListTile(
                title: Text(a['serviceName']),
                subtitle: Text('${DateFormat('dd/MM HH:mm').format(when)} · cliente ${a['clientId'].toString().substring(0, 6)}'),
                trailing: Wrap(spacing: 8, children: [
                  IconButton(onPressed: () => _upd(d.id, {'providerId': uid, 'status': 'accepted'}), icon: const Icon(Icons.check)),
                  IconButton(onPressed: () => _upd(d.id, {'status': 'rejected'}), icon: const Icon(Icons.close)),
                ]),
              );
            }).toList());
          })),
          const Divider(),
          const Padding(padding: EdgeInsets.all(8), child: Text('Mis citas', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: StreamBuilder<QuerySnapshot>(stream: mine, builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            final docs = s.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('Sin citas'));
            return ListView(children: docs.map((d) {
              final a = d.data() as Map<String, dynamic>;
              final when = (a['scheduledFor'] as Timestamp).toDate();
              return ListTile(title: Text('${a['serviceName']} – ${a['status']}'), subtitle: Text(DateFormat('dd/MM HH:mm').format(when)));
            }).toList());
          })),
        ]));
  }
}
