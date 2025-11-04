import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingsSection extends StatelessWidget {
  const BookingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) return const SizedBox.shrink();
        if (!snap.hasData) return const SizedBox(height: 8);

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: const [Text('No hay servicios agendados.')]),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Mis reservas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, i) {
                  final b = docs[i].data();
                  final title = b['serviceTitle'] ?? '';
                  final image = b['serviceImage'] ?? '';
                  final dateStr = b['date'] ?? '';
                  DateTime? dt;
                  try {
                    dt = DateTime.parse(dateStr);
                  } catch (_) {}
                  final dateFmt = dt != null ? DateFormat.yMMMd().format(dt) : dateStr;

                  return Container(
                    width: 260,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.hardEdge,
                      child: Row(children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: image.toString().startsWith('assets/')
                              ? Image.asset(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())
                              : Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(dateFmt),
                            ]),
                          ),
                        )
                      ]),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: docs.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
