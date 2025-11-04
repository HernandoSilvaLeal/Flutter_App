import 'package:flutter/material.dart';
import 'booking_new_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final double rating;
  const ServiceDetailScreen({super.key, required this.id, required this.title, required this.description, required this.rating});

  // Helper to resolve asset or network image
  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink());
  }

  @override
  Widget build(BuildContext context) {
    // Try to get imageUrl from route args? But router passes fields only; expect image via ModalRoute args or fetch from Firestore if needed.
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final imageUrl = routeArgs?['imageUrl'] as String?;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title),
              background: Hero(
                tag: 'service-$id',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(imageUrl),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Row(children: [const Icon(Icons.star, color: Colors.amber), const SizedBox(width: 6), Text(rating.toString())]),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingNewScreen(serviceId: id, serviceTitle: title, serviceImage: imageUrl ?? ''))), child: const Text('Reservar el servicio')),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
