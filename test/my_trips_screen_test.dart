import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:online_travel_agent/models/trip.dart';
import 'package:online_travel_agent/providers/travel_provider.dart';
import 'package:online_travel_agent/screens/my_trips/my_trips_screen.dart';
import 'package:online_travel_agent/screens/my_trips/widgets/trip_card.dart';

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
    expect(find.text('Đang diễn ra'), findsAtLeastNWidgets(1));
    expect(find.text('Sắp tới'), findsAtLeastNWidgets(1));
    expect(find.text('Lịch sử'), findsAtLeastNWidgets(1));

    // Dynamically check whether empty state or list cards are loaded based on provider data
    if (travelProvider.ongoingTrips.isEmpty &&
        travelProvider.upcomingTrips.isEmpty &&
        travelProvider.historyTrips.isEmpty) {
      expect(find.text('Bắt đầu hành trình mới'), findsOneWidget);
      expect(find.text('Khám phá ngay'), findsOneWidget);
    } else {
      expect(find.byType(TripCard), findsWidgets);
    }
  });
}
