import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:online_travel_agent/models/tour_package.dart';
import 'package:online_travel_agent/providers/travel_provider.dart';
import 'package:online_travel_agent/screens/tours/tour_detail_screen.dart';

void main() {
  const testTour = TourPackage(
    id: 'test-1',
    name: 'Tour Khám Phá Đà Nẵng - Hội An',
    description: 'Hành trình tuyệt vời qua các di sản miền Trung.',
    imagePath: 'assets/images/danang.png',
    duration: '3 ngày 2 đêm',
    price: 150.0,
    originalPrice: 200.0,
    destinations: ['Đà Nẵng', 'Hội An'],
    includes: ['Khách sạn 3 sao', 'Bữa sáng', 'Xe đưa đón'],
    departure: 'Hà Nội',
    isPopular: true,
    includesGuide: true,
    guideFee: 50.0,
  );

  testWidgets('TourDetailScreen UI elements and interactions', (WidgetTester tester) async {
    // Set viewport size so all interactive elements are visible
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    final travelProvider = TravelProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TravelProvider>.value(
          value: travelProvider,
          child: const TourDetailScreen(tour: testTour),
        ),
      ),
    );

    // Verify basic tour details are rendered
    expect(find.text(testTour.name), findsOneWidget);
    expect(find.text('3 ngày 2 đêm'), findsOneWidget);
    expect(find.text('Hà Nội'), findsOneWidget);

    // Check dynamic pricing calculates correctly (Initially 1 guest + Guide: $150 + $50 = $200)
    expect(find.text('\$200'), findsOneWidget);

    // Tap decrement to verify guests count does not go below 1
    final decFinder = find.byIcon(Icons.remove);
    if (decFinder.evaluate().isNotEmpty) {
      await tester.tap(decFinder);
      await tester.pump();
      expect(find.text('\$200'), findsOneWidget);
    }

    // Tap increment to add guest (Should become 2 guests + Guide: ($150 + $50) * 2 = $400)
    final incFinder = find.byIcon(Icons.add);
    if (incFinder.evaluate().isNotEmpty) {
      await tester.tap(incFinder);
      await tester.pump();
      expect(find.text('\$400'), findsOneWidget);
    }
  });
}
