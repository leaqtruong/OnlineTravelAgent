import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_schedule.dart';
import 'api_provider.dart';

final tripScheduleProvider = FutureProvider.family<TripSchedule, String>((ref, tripId) async {
  final apiService = ref.watch(apiProvider);
  return apiService.fetchTripSchedule(tripId);
});
