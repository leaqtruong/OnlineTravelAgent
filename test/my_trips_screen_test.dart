import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:online_travel_agent/models/trip.dart';
import 'package:online_travel_agent/providers/travel_provider.dart';
import 'package:online_travel_agent/screens/my_trips/my_trips_screen.dart';

void main() {
  testWidgets('MyTripsScreen UI elements and empty states', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    final travelProvider = TravelProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TravelProvider>.value(
          value: travelProvider,
          child: const MyTripsScreen(),
        ),
      ),
    );

    // Verify header titles are loaded
    expect(find.text('Chuyến đi của tôi'), findsOneWidget);

    // Verify Tab items are loaded
    expect(find.text('Sắp tới'), findsOneWidget);
    expect(find.text('Lịch sử'), findsOneWidget);

    // Check that our premium Empty State is displayed (since local bootstrap is mocked/stubbed and has no trips under widget test environment)
    expect(find.text('Bắt đầu hành trình mới'), findsOneWidget);
    expect(find.text('Khám phá ngay'), findsOneWidget);
  });
}
