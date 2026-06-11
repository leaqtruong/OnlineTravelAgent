import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_package.dart';
import 'app_state_provider.dart';

final toursProvider = Provider<List<TourPackage>>((ref) {
  final bootstrap = ref.watch(bootstrapProvider).value;
  return bootstrap?.tourPackages ?? [];
});

class TourFavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String tourId) {
    if (state.contains(tourId)) {
      state = {...state}..remove(tourId);
    } else {
      state = {...state, tourId};
    }
  }

  bool isFavorite(String tourId) => state.contains(tourId);
}

final tourFavoritesProvider = NotifierProvider<TourFavoritesNotifier, Set<String>>(
  TourFavoritesNotifier.new,
);
