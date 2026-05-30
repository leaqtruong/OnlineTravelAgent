# My Trips Screen Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the "My Trips" screen to be highly premium with bento-style card layouts, sliding pill-shaped TabBars, personalized headers, and a beautiful illustrative Empty State.

**Architecture:** We use a Scaffold with a soft AppTheme.backgroundGray background. The header combines profile metadata with a circular avatar. The TabBar is custom-wrapped inside a decorated Container to construct a Capsule trượt Pill interface. The TripCard is redesigned as a Bento card with 35% images, custom metadata lines (Calendar/People/Location), and colored pastel status badges.

**Tech Stack:** Flutter, Dart, Provider (travel_provider.dart), AppTheme, LatLng, intl.

---

### Task 1: Write Widget Test for My Trips Screen

**Files:**
- Create: `test/my_trips_screen_test.dart`

- [ ] **Step 1: Write the failing test**
  Create `test/my_trips_screen_test.dart` to assert that `MyTripsScreen` builds correctly, shows the personalized header, renders capsule tabs, renders the custom Bento `TripCard`s, and displays the modern empty state when trips list is empty.

  ```dart
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

      // Initially if no trips are present, check that the premium Empty State is displayed
      if (travelProvider.upcomingTrips.isEmpty) {
        expect(find.text('Bắt đầu hành trình mới'), findsOneWidget);
        expect(find.text('Khám phá ngay'), findsOneWidget);
      }
    });
  }
  ```

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/my_trips_screen_test.dart`
  Expected: FAIL (empty state text or elements mismatch old screen)

- [ ] **Step 3: Commit initial test**
  ```bash
  git add test/my_trips_screen_test.dart
  git commit -m "test: add widget tests for my trips screen redesign"
  ```

---

### Task 2: Redesign Trip Card (Bento Card Style)

**Files:**
- Modify: `lib/screens/my_trips/widgets/trip_card.dart`

- [ ] **Step 1: Replace old TripCard with premium Bento layout**
  Rewrite `lib/screens/my_trips/widgets/trip_card.dart` with a highly optimized Bento-style card.
  - Apply 24px border radius and soft `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: Offset(0, 8))`.
  - Display the image on the left occupying exactly 130px width with rounded corners of 20px.
  - Overlay an dynamic floating classification tag on top of the image (e.g. "Tự thiết kế" with a warm gradient if `trip.isCustom` is true, or "Gói Tour" with a soft cyan gradient if false).
  - Arrange details on the right inside an `Expanded` column with:
    - Bold destination title (size 18) capped to 1 line with ellipsis.
    - Inline metadata row: Calendar icon with date, a thin vertical divider, and People icon with guests count.
    - Bottom row: Location pin icon with location string in bold blue, and a pastel rounded status badge on the right ("Sắp tới" -> soft blue/blue text; "Lịch sử" -> soft grey/grey text).

- [ ] **Step 2: Verify compilation of the updated TripCard**
  Run: `flutter test test/my_trips_screen_test.dart`
  Expected: Compile successfully.

- [ ] **Step 3: Commit TripCard changes**
  ```bash
  git add lib/screens/my_trips/widgets/trip_card.dart
  git commit -m "feat: redesign trip card to a premium bento box style with custom image tags and status capsules"
  ```

---

### Task 3: Redesign My Trips Screen

**Files:**
- Modify: `lib/screens/my_trips/my_trips_screen.dart`

- [ ] **Step 1: Implement MyTripsScreen with premium Header, Capsule TabBar and Empty State**
  Rewrite `lib/screens/my_trips/my_trips_screen.dart` with a highly polished design.
  - Set the background of the screen Scaffold to `AppTheme.backgroundGray`.
  - Design a personalized top Header Row containing:
    - A spacious left column displaying "Chuyến đi của tôi" and subtitle `"Chào mừng trở lại, ${provider.profile.name}!"` (or dynamic slogan).
    - A modern circular user avatar on the right with a soft blue glowing shadow.
  - Custom-wrap the `TabBar` inside a clean decorated `Container` with white background, border radius 16, and small border. Style the `TabBar` indicator as a sliding capsule capsule `BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(12))` and style text colors accordingly.
  - Write a premium Empty State layout displaying:
    - Large soft blue `Icons.explore_rounded` (size 80).
    - Welcoming title: `"Bắt đầu hành trình mới"`.
    - Description encouraging the user to explore the world.
    - Elegant "Khám phá ngay" ElevatedButton with `AppTheme.primaryBlue` background, executing `Navigator.pop(context)` on tap to redirect the user back.

- [ ] **Step 2: Run all tests to verify they pass**
  Run: `flutter test`
  Expected: PASS

- [ ] **Step 3: Commit MyTripsScreen changes**
  ```bash
  git add lib/screens/my_trips/my_trips_screen.dart
  git commit -m "feat: redesign my trips screen with personalized header, capsule sliding tabs, and premium empty state"
  ```
