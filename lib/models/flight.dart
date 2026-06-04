class Flight {
  final String id;
  final String airline;
  final String airlineLogo;
  final String departure;
  final String arrival;
  final String departureTime;
  final String arrivalTime;
  final int price;
  final String duration;

  Flight({
    required this.id,
    required this.airline,
    required this.airlineLogo,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.duration,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id']?.toString() ?? '',
      airline: json['airline']?.toString() ?? '',
      airlineLogo: json['airlineLogo']?.toString() ?? '',
      departure: json['departure']?.toString() ?? '',
      arrival: json['arrival']?.toString() ?? '',
      departureTime: json['departureTime']?.toString() ?? '',
      arrivalTime: json['arrivalTime']?.toString() ?? '',
      price: json['price'] as int? ?? 0,
      duration: json['duration']?.toString() ?? '',
    );
  }
}
