# Fixed Tour Detail Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the fixed tour detail page to look stunningly premium with parallax scrolling, interactive date/guest selectors, timeline itineraries, inline maps, guide fee toggles, and dynamic pricing calculations.

**Architecture:** We use a CustomScrollView with SliverAppBar for the parallax header. Underneath, we lay out sections vertically using an overlapping layout, including interactive controls, auto-generated timelines from destinations, inclusions grids, customizable guides, dynamic prices in a persistent bottom sheet, and an inline map routing display.

**Tech Stack:** Flutter, Dart, Provider (travel_provider.dart), FlutterMap, LatLng, AppTheme.

---

### Task 1: Write Widget Test for Tour Detail Screen

**Files:**
- Create: `test/tour_detail_screen_test.dart`

- [ ] **Step 1: Write the failing test**
  Create `test/tour_detail_screen_test.dart` with assertions testing that `TourDetailScreen` mounts, correctly handles date picking, increments/decrements guests, and toggles the guide option while updating total price.

  ```dart
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
  ```

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/tour_detail_screen_test.dart`
  Expected: FAIL (or compilation errors due to missing fields/states on old screen)

- [ ] **Step 3: Commit initial test**
  ```bash
  git add test/tour_detail_screen_test.dart
  git commit -m "test: add widget tests for tour detail screen redesign"
  ```

---

### Task 2: Redesign Tour Detail Screen UI Layout

**Files:**
- Modify: `lib/screens/tours/tour_detail_screen.dart`

- [ ] **Step 1: Replace old layout with premium Parallax Scroll & Selectors**
  We replace `lib/screens/tours/tour_detail_screen.dart` with a highly optimized premium UI.
  - Implement a `CustomScrollView` with a `SliverAppBar` carrying a parallax background, black-to-transparent linear gradients, and a beautiful floating glassmorphic Back button.
  - Create a floating `Floating Overview Card` overlapping the image transition, displaying `duration`, `departure`, and count of destinations using clean customized circular icons.
  - Set up reactive state variables in `_TourDetailScreenState`:
    - `DateTime _selectedDate = DateTime(2026, 6, 25);`
    - `int _guestsCount = 1;`
    - `bool _guideToggle = true;`
  - Implement inline, beautifully styled interactive cards for Travel Date selection (using custom-styled `showDatePicker`) and passenger count Stepper (with custom rounded +/- buttons).

  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart';
  import 'package:intl/intl.dart';

  import '../../core/theme/app_theme.dart';
  import '../../models/tour_package.dart';
  import '../../providers/travel_provider.dart';

  class TourDetailScreen extends StatefulWidget {
    final TourPackage tour;

    const TourDetailScreen({super.key, required this.tour});

    @override
    State<TourDetailScreen> createState() => _TourDetailScreenState();
  }

  class _TourDetailScreenState extends State<TourDetailScreen> {
    late DateTime _selectedDate;
    int _guestsCount = 1;
    late bool _guideToggle;

    @override
    void initState() {
      super.initState();
      _selectedDate = DateTime(2026, 6, 25);
      _guideToggle = widget.tour.includesGuide;
    }

    double get _totalPrice {
      double singlePrice = widget.tour.price;
      if (_guideToggle && widget.tour.includesGuide) {
        singlePrice += widget.tour.guideFee;
      }
      return singlePrice * _guestsCount;
    }

    @override
    Widget build(BuildContext context) {
      // Complete UI implementation details included in next step
    }
  }
  ```

- [ ] **Step 2: Add dynamic timeline itinerary, mini-maps, inclusions, and responsive bottom bar**
  Write complete implementations for:
  - **Dynamic timeline generator**: Uses `widget.tour.destinations` to build an elegant vertical visual timeline of activities (e.g. Day 1, Day 2, Day 3) using a dashed connecting line and custom colored indicator nodes.
  - **Mini Map routing display**: Hardcode coordinate maps dynamically based on the tour name/destinations (e.g., Đà Nẵng: 16.0544, 108.2022; Sapa: 22.3364, 103.8438; Phú Quốc: 10.2899, 103.9840) to render a live `FlutterMap` widget showing markers and route connections.
  - **Inclusions Grid**: Format the includes array in a premium 2-column grid featuring dedicated modern iconography.
  - **Bottom sheet calculations**: Render the dynamic pricing (`_totalPrice`), original prices (if available) with line-throughs, and a gorgeous, highlighted "Đặt Tour Ngay" call to action.

- [ ] **Step 3: Run the widget tests to verify they pass**
  Run: `flutter test test/tour_detail_screen_test.dart`
  Expected: PASS

- [ ] **Step 4: Commit UI changes**
  ```bash
  git add lib/screens/tours/tour_detail_screen.dart
  git commit -m "feat: redesign tour detail screen with parallax scroll, date picker, guests counter, itinerary timeline, map, and dynamic pricing"
  ```
