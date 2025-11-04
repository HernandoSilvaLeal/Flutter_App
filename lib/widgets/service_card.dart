import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final String? imageUrl;
  final String? heroTag;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.title, required this.subtitle, required this.rating, this.imageUrl, this.heroTag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((imageUrl ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                child: heroTag != null
                    ? Hero(
                        tag: heroTag!,
                        child: imageUrl!.startsWith('assets/')
                            ? Image.asset(
                                imageUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imageUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(height: 120),
                              ),
                      )
                    : (imageUrl!.startsWith('assets/')
                        ? Image.asset(
                            imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(height: 120),
                          )),
              )
            else
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.cleaning_services_outlined, size: 56),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [Icon(Icons.star, size: 16, color: Colors.amber), const SizedBox(width: 4), Text(rating.toString())])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
