class Trip {
  final String id;
  final String destination;
  final String location;
  final String date;
  final String guests;
  final String status;
  final String imagePath;
  final bool isUpcoming;
  final double totalAmount;
  final String currency;

  Trip({
    required this.id,
    required this.destination,
    required this.location,
    required this.date,
    this.guests = "1 Người lớn",
    required this.status,
    required this.imagePath,
    required this.isUpcoming,
    this.totalAmount = 0.0,
    this.currency = 'USD',
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Vietnam',
      date: json['date']?.toString() ?? '',
      guests: json['guests']?.toString() ?? '1 Người lớn',
      status: json['status']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      isUpcoming: json['isUpcoming'] == true,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
    );
  }
}
