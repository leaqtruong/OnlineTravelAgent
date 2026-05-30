class Trip {
  final String id;
  final String destination;
  final String location;
  final String date;
  final String guests;
  final String status;
  final String imagePath;
  final bool isUpcoming;
  final String? flightId;
  final String? hotelId;
  final String? roomId;
  final double? totalPrice;
  final bool isCustom;

  const Trip({
    required this.id,
    required this.destination,
    required this.location,
    required this.date,
    required this.guests,
    required this.status,
    required this.imagePath,
    this.isUpcoming = true,
    this.flightId,
    this.hotelId,
    this.roomId,
    this.totalPrice,
    this.isCustom = false,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      guests: json['guests']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      isUpcoming: json['isUpcoming'] == true,
      flightId: json['flightId']?.toString(),
      hotelId: json['hotelId']?.toString(),
      roomId: json['roomId']?.toString(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      isCustom: json['isCustom'] == true,
    );
  }
}
