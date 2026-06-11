import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight.dart';
import 'api_provider.dart';

final flightsProvider = FutureProvider<List<Flight>>((ref) async {
  final api = ref.read(apiProvider);
  return api.searchFlights(null, null);
});
