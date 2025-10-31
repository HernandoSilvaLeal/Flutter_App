import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/services_seed.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});
  @override
  State<ClientHome> createState() => _S();
}

class _S extends State<ClientHome> {
  Map<String, String>? _svc;
  DateTime _dt = DateTime.now().add(const Duration(hours: 2));

  Future<void> _pick() async {
    final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)), initialDate: _dt);
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dt));
    if (t == null) return;
    setState(() => _dt = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _create() async {
    if (_svc == null) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('appointments').add({
      'clientId': uid,
      'providerId': '',
      'serviceId': _svc!['id'],
      'serviceName': _svc!['name'],
      'status': 'pending',
      'scheduledFor': Timestamp.fromDate(_dt),
      'createdAt': FieldValue.serverTimestamp(),
      'notes': null,
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita creada')));
  }

  @override
  Widget build(BuildContext c) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final q = FirebaseFirestore.instance.collection('appointments').where('clientId', isEqualTo: uid).orderBy('scheduledFor').snapshots();
    return Scaffold(
        appBar: AppBar(title: const Text('Cliente – Servicios'), actions: [
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))
        ]),
        body: Column(children: [
          DropdownButton<Map<String, String>>(value: _svc, hint: const Text('Selecciona un servicio'),
              items: servicesSeed.map((s) => DropdownMenuItem(value: s, child: Text(s['name']!))).toList(), onChanged: (v) => setState(() => _svc = v)),
          TextButton.icon(onPressed: _pick, icon: const Icon(Icons.calendar_month), label: Text(DateFormat('EEE dd/MM, HH:mm').format(_dt))),
          FilledButton(onPressed: _create, child: const Text('Agendar cita')),
          const Divider(),
          Expanded(child: StreamBuilder<QuerySnapshot>(stream: q, builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            final docs = s.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('Sin citas'));
            return ListView(children: docs.map((d) {
              final a = d.data() as Map<String, dynamic>;
              final when = (a['scheduledFor'] as Timestamp).toDate();
              return ListTile(title: Text('${a['serviceName']} – ${a['status']}'), subtitle: Text(DateFormat('dd/MM HH:mm').format(when)));
            }).toList());
          }))
        ]));
  }
}
