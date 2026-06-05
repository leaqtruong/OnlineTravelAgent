import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_package.dart';
import 'app_state_provider.dart';

final toursProvider = Provider<List<TourPackage>>((ref) {
  final bootstrap = ref.watch(bootstrapProvider).value;
  return bootstrap?.tourPackages ?? [];
});
