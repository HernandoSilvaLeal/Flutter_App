class Service {
  final String id;
  final String title;
  final String description;
  final String? imageUrl; // URL opcional del icono/imagen
  final double rating;

  Service({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.rating,
  });

  factory Service.fromMap(String id, Map<String, dynamic> m) => Service(
        id: id,
        title: m['title'] ?? '',
        description: m['description'] ?? '',
        imageUrl: m['imageUrl'] as String?,
        rating: (m['rating'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'rating': rating,
      };
}
