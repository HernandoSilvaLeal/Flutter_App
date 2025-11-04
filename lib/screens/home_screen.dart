import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_router.dart';
import '../widgets/service_card.dart';
import '_bookings_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // mantenemos la función de seed que escribe en Firestore pero no la usamos
  Future<void> seedServicesOnce(BuildContext context) async {
    final col = FirebaseFirestore.instance.collection('services');
    try {
      final samples = [
        {
          'id': 'svc_basico',
          'title': 'Servicio Básico',
          'description': 'Limpieza básica para espacios pequeños',
          'rating': 4.6,
          'imageUrl': 'assets/imagen_servicio_basico.png'
        },
        {
          'id': 'svc_completo',
          'title': 'Servicio Completo',
          'description': 'Limpieza profunda y desinfección',
          'rating': 4.9,
          'imageUrl': 'assets/imagen_servicio_completo.png'
        },
        {
          'id': 'svc_cocina',
          'title': 'Limpieza de Cocina',
          'description': 'Especializada en áreas de cocina y hornos',
          'rating': 4.7,
          'imageUrl': 'assets/imagen_servicio_cocina.png'
        },
        {
          'id': 'svc_personalizado',
          'title': 'Servicio Personalizado',
          'description': 'Ajustamos el servicio a tus necesidades',
          'rating': 4.8,
          'imageUrl': 'assets/imagen_servicio_personalizado.png'
        }
      ];

      for (final s in samples) {
        final doc = col.doc(s['id'] as String);
        await doc.set({
          'title': s['title'],
          'description': s['description'],
          'rating': s['rating'],
          'imageUrl': s['imageUrl'],
        }, SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicios de ejemplo cargados')));
    } catch (e, st) {
      debugPrint('Error seedServicesOnce: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al sembrar: $e')));
    }
  }

  // Lista local de servicios (no toca Firestore)
  List<Map<String, String>> _localServices = [];

  void _loadLocalServices() {
    setState(() {
      _localServices = [
        {'id': 'l1', 'title': 'Servicio Básico', 'image': 'assets/imagen_servicio_basico.png'},
        {'id': 'l2', 'title': 'Servicio Personalizado', 'image': 'assets/imagen_servicio_personalizado.png'},
        {'id': 'l3', 'title': 'Servicio Cocina', 'image': 'assets/imagen_servicio_cocina.png'},
        {'id': 'l4', 'title': 'Servicio Completo', 'image': 'assets/imagen_servicio_completo.png'},
        {'id': 'l5', 'title': 'Servicio especial 1', 'image': 'assets/imagen_servicio_personalizado.png'},
        {'id': 'l6', 'title': 'Servicio especial 2', 'image': 'assets/imagen_servicio_basico.png'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('services');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Servicios'),
        actions: [
          IconButton(onPressed: _loadLocalServices, icon: const Icon(Icons.download)),
          IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.myBookings), icon: const Icon(Icons.calendar_month)),
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // Bookings section at top
          BookingsSection(),
          Expanded(
            child: _localServices.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .8),
                      itemCount: _localServices.length,
                      itemBuilder: (context, i) {
                        final s = _localServices[i];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.bookingNew, arguments: {
                              'serviceId': s['id']!,
                              'serviceTitle': s['title']!,
                              'serviceImage': s['image']!,
                            });
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Image.asset(
                                    s['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(s['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: col.orderBy('title').snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Error cargando servicios:\n${snap.error}', textAlign: TextAlign.center));
                      }

                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snap.data?.docs ?? const [];
                      if (docs.isEmpty) {
                        return _EmptyWithSeed(message: 'No hay servicios todavía.', onSeed: _loadLocalServices);
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .9),
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final d = docs[i].data();
                          final id = docs[i].id;
                          return ServiceCard(
                            heroTag: 'service-$id',
                            title: d['title'] ?? '(sin título)',
                            subtitle: d['description'] ?? '',
                            rating: (d['rating'] ?? 4.5).toDouble(),
                            imageUrl: d['imageUrl'] ?? '',
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.bookingNew, arguments: {
                                'serviceId': id,
                                'serviceTitle': d['title'] ?? '',
                                'serviceImage': d['imageUrl'] ?? ''
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
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
