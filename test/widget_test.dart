// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:online_travel_agent/main.dart';
import 'package:online_travel_agent/providers/api_provider.dart';
import 'package:online_travel_agent/services/travel_api_service.dart';

class FakeTravelApiService extends TravelApiService {
  @override
  Future<BootstrapData> fetchBootstrap() async {
    return BootstrapData(
      categories: [],
      destinations: [],
      recommended: [],
      trips: [],
      documents: [],
      hotels: [],
      tourPackages: [],
    );
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(FakeTravelApiService()),
        ],
        child: const OnlineTravelAgentApp(),
      ),
    );

    // Verify that the app builds without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Unmount the widget tree to trigger dispose and cancel the periodic timer
    await tester.pumpWidget(const SizedBox());

    // Elapse time to let the remaining Future.delayed (3s) finish
    await tester.pump(const Duration(seconds: 5));
  });
}
