import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> seedServicesOnce(BuildContext context) async {
    final col = FirebaseFirestore.instance.collection('services');

    final samples = [
      {'id': 'svc_basic', 'title': 'Servicio básico', 'description': 'Limpieza general del hogar', 'rating': 3},
      {'id': 'svc_full', 'title': 'Servicio completo', 'description': 'Turno completo con todo incluido', 'rating': 4},
      {'id': 'svc_kitchen', 'title': 'Servicio de cocina', 'description': 'Ayudante / limpieza de cocina', 'rating': 3},
      {'id': 'svc_custom', 'title': 'Servicio personalizado', 'description': 'Arma tu servicio a medida', 'rating': 5},
    ];

    for (final s in samples) {
      await col.doc(s['id'] as String).set({
        'title': s['title'],
        'description': s['description'],
        'rating': s['rating'],
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicios sembrados (idempotente)')));
    }
  }

  @override
  Widget build(BuildContext context) {
  final col = FirebaseFirestore.instance.collection('services').orderBy('title').limit(12);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        actions: [
          IconButton(onPressed: () => seedServicesOnce(context), icon: const Icon(Icons.download)),
          IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.myBookings), icon: const Icon(Icons.calendar_month)),
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.snapshots(),
        builder: (context, snap) {
          // Debug info to diagnose waiting/permission issues
          debugPrint('Home services -> state=${snap.connectionState} hasData=${snap.hasData} hasError=${snap.hasError}');

          if (snap.hasError) {
            return Center(child: Text('Error cargando servicios:\n${snap.error}', textAlign: TextAlign.center));
          }

          // Timeout suave: si está en waiting por más de 5s, mostramos CTA para seed
          if (snap.connectionState == ConnectionState.waiting) {
            return FutureBuilder<bool>(
              future: Future.delayed(const Duration(seconds: 5), () => true),
              builder: (_, t) {
                if (t.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _EmptyWithSeed(
                  message: 'Aún no hay datos o la conexión tarda.\nPrueba sembrar servicios.',
                  onSeed: () => seedServicesOnce(context),
                );
              },
            );
          }

          final docs = snap.data?.docs ?? const [];
          if (docs.isEmpty) {
            return _EmptyWithSeed(message: 'No hay servicios todavía.', onSeed: () => seedServicesOnce(context));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .9),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final id = docs[i].id;
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.serviceDetail, arguments: {
                    'id': id,
                    'title': d['title'] ?? '',
                    'description': d['description'] ?? '',
                    'rating': (d['rating'] ?? 0).toDouble(),
                  });
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                          child: Image.network(
                            (d['imageUrl'] ?? '') as String,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(height: 120),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text((d['description'] ?? '') as String, maxLines: 3, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyWithSeed extends StatelessWidget {
  final String message;
  final VoidCallback onSeed;

  const _EmptyWithSeed({required this.message, required this.onSeed, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: onSeed, child: const Text('Cargar servicios de ejemplo')),
      ]),
    );
  }
}
