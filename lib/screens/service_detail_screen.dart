import 'package:flutter/material.dart';
import 'booking_new_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final double rating;
  const ServiceDetailScreen({super.key, required this.id, required this.title, required this.description, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.room_service, size: 80),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.star, color: Colors.amber), const SizedBox(width: 6), Text(rating.toString())]),
          const Spacer(),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingNewScreen(serviceId: id, serviceTitle: title))), child: const Text('Reservar el servicio')))
        ]),
      ),
    );
  }
}
