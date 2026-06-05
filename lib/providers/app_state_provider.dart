import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/travel_api_service.dart';
import 'api_provider.dart';

final bootstrapProvider = FutureProvider<BootstrapData>((ref) async {
  final api = ref.watch(apiProvider);
  return api.fetchBootstrap();
});

// A provider for the categories list (static from bootstrap)
final categoriesProvider = Provider<List<String>>((ref) {
  final bootstrap = ref.watch(bootstrapProvider).value;
  if (bootstrap == null || bootstrap.categories.isEmpty) {
    return ['Tất cả', 'Địa điểm', 'Khách sạn', 'Máy bay', 'Ẩm thực'];
  }
  
  // Replicate the filtering logic from the old travel_provider
  final defaultCategories = ['Tất cả', 'Địa điểm', 'Khách sạn', 'Máy bay', 'Ẩm thực'];
  final hiddenCategories = {'Bãi biển'};
  final remaining = bootstrap.categories.where((c) => !hiddenCategories.contains(c)).toSet();
  
  final result = <String>[];
  for (final category in defaultCategories) {
    if (remaining.remove(category)) {
      result.add(category);
    }
  }
  result.addAll(remaining);
  return result;
});
