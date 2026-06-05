import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import 'app_state_provider.dart';
import 'api_provider.dart';

class TripNotifier extends Notifier<List<Trip>> {
  @override
  List<Trip> build() {
    final bootstrap = ref.watch(bootstrapProvider).value;
    return bootstrap?.trips ?? [];
  }

  void addTrip(Trip trip) {
    state = [trip, ...state];
  }

  Future<bool> bookTrip({String? destinationId, String? date, String? guests, double? totalPrice}) async {
    if (destinationId == null) return false;
    try {
      final trip = await ref.read(apiProvider).bookTrip(
        destinationId: destinationId,
        date: date,
        guests: guests,
        totalPrice: totalPrice,
      );
      addTrip(trip);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bookFlight({required String flightId, required String date, required String guests}) async {
    try {
      final trip = await ref.read(apiProvider).bookFlight(
        flightId: flightId, date: date, guests: guests
      );
      addTrip(trip);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bookHotel({required String roomId, required String checkIn, required String checkOut, required String guests}) async {
    try {
      final trip = await ref.read(apiProvider).bookHotel(
        roomId: roomId, checkIn: checkIn, checkOut: checkOut, guests: guests
      );
      addTrip(trip);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bookTour({required String tourId, required String date, required String guests, double? totalPrice}) async {
    try {
      final trip = await ref.read(apiProvider).bookTour(
        tourId: tourId, date: date, guests: guests, totalPrice: totalPrice
      );
      addTrip(trip);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createCustomTour({
    required String destination, required String location, required String date,
    required String guests, required String imagePath,
    List<String>? flightIds, List<String>? hotelIds, String? roomId, double? totalPrice,
  }) async {
    try {
      final trip = await ref.read(apiProvider).createCustomTour(
        destination: destination, location: location, date: date,
        guests: guests, imagePath: imagePath, flightIds: flightIds,
        hotelIds: hotelIds, roomId: roomId, totalPrice: totalPrice
      );
      addTrip(trip);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final tripsProvider = NotifierProvider<TripNotifier, List<Trip>>(TripNotifier.new);

// Derived Providers
final ongoingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((t) => t.status.toLowerCase() == 'đang diễn ra' || t.status.toLowerCase() == 'ongoing').toList();
});

final upcomingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((t) => t.isUpcoming && t.status.toLowerCase() != 'đang diễn ra' && t.status.toLowerCase() != 'ongoing').toList();
});

final historyTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((t) => !t.isUpcoming && t.status.toLowerCase() != 'đang diễn ra' && t.status.toLowerCase() != 'ongoing').toList();
});
