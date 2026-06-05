import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/travel_api_service.dart';

final apiProvider = Provider<TravelApiService>((ref) {
  return TravelApiService();
});
