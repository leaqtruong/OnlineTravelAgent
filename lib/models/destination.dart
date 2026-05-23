class Destination {
  final String name;
  final String location;
  final String rating;
  final String duration;
  final String imagePath;
  final bool isFavorite;
  final String description;
  final String price;
  final String reviewsCount;

  Destination({
    required this.name,
    required this.location,
    required this.rating,
    required this.duration,
    required this.imagePath,
    this.isFavorite = false,
    this.description = "",
    this.price = "",
    this.reviewsCount = "0",
  });

  Destination copyWith({
    String? name,
    String? location,
    String? rating,
    String? duration,
    String? imagePath,
    bool? isFavorite,
    String? description,
    String? price,
    String? reviewsCount,
  }) {
    return Destination(
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      price: price ?? this.price,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}
