# Trip Detail Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the trip detail screens from My Trips into two premium pages: PlaceTripDetailScreen and TourTripDetailScreen, using Parallax Hero + DraggableScrollableSheet.

**Architecture:** Create 4 shared widgets (booking_info_card, booking_status_timeline, trip_action_buttons, trip_section_header), then build PlaceTripDetailScreen and TourTripDetailScreen on top. Update routing in my_trips_screen.dart to dispatch to the correct detail page.

**Tech Stack:** Flutter, Dart, FlutterMap, LatLng2, Provider

---

### Task 1: Create Shared Widgets

**Files:**
- Create: `lib/screens/my_trips/widgets/trip_section_header.dart`
- Create: `lib/screens/my_trips/widgets/booking_info_card.dart`
- Create: `lib/screens/my_trips/widgets/booking_status_timeline.dart`
- Create: `lib/screens/my_trips/widgets/trip_action_buttons.dart`

- [ ] **Step 1: Create `trip_section_header.dart`**

```dart
import 'package:flutter/material.dart';

class TripSectionHeader extends StatelessWidget {
  final String title;
  const TripSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

- [ ] **Step 2: Create `booking_info_card.dart`**

A card showing date, guests, booking code, and optional total price. Takes `Trip` as input.

```dart
import 'package:flutter/material.dart';
import '../../../models/trip.dart';

class BookingInfoCard extends StatelessWidget {
  final Trip trip;
  const BookingInfoCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final bookingCode = 'BK-${trip.id.toUpperCase().hashCode.toString().substring(0, 6)}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row(Icons.calendar_today, 'Ngày đi', trip.date),
          const SizedBox(height: 12),
          _row(Icons.person, 'Hành khách', trip.guests),
          const SizedBox(height: 12),
          _row(Icons.confirmation_num_outlined, 'Mã đặt chỗ', bookingCode),
          if (trip.totalPrice != null) ...[
            const SizedBox(height: 12),
            _row(Icons.payments_outlined, 'Tổng thanh toán', '\$${trip.totalPrice!.toStringAsFixed(0)}'),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF555555)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Create `booking_status_timeline.dart`**

A horizontal timeline with 4 steps. Takes `trip.status` to determine highlight level.

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BookingStatusTimeline extends StatelessWidget {
  final String status;
  const BookingStatusTimeline({super.key, required this.status});

  int get _activeStep {
    final s = status.toLowerCase();
    if (s == 'đã đi' || s == 'hoàn thành' || s == 'completed') return 4;
    if (s == 'đang diễn ra' || s == 'ongoing') return 3;
    if (s == 'đã xác nhận' || s == 'confirmed' || s == 'sắp tới') return 2;
    return 1; // Đã đặt
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Đã đặt', 'Xác nhận', 'Diễn ra', 'Hoàn thành'];
    final active = _activeStep;
    return Row(
      children: List.generate(labels.length, (i) {
        final step = i + 1;
        final isActive = step <= active;
        final isLast = i == labels.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppTheme.primaryBlue : Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? AppTheme.primaryBlue : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: step < active ? AppTheme.primaryBlue : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 4: Create `trip_action_buttons.dart`**

Four circular action buttons: Support, Invoice, Share, Cancel.

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TripActionButtons extends StatelessWidget {
  const TripActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _btn(context, Icons.support_agent, 'Hỗ trợ'),
        _btn(context, Icons.receipt_long, 'Hóa đơn'),
        _btn(context, Icons.share_outlined, 'Chia sẻ'),
        _btn(context, Icons.cancel_outlined, 'Hủy vé'),
      ],
    );
  }

  Widget _btn(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label — Tính năng đang phát triển')),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Commit shared widgets**

```
git add lib/screens/my_trips/widgets/trip_section_header.dart lib/screens/my_trips/widgets/booking_info_card.dart lib/screens/my_trips/widgets/booking_status_timeline.dart lib/screens/my_trips/widgets/trip_action_buttons.dart
git commit -m "feat: add shared widgets for trip detail screens"
```

---

### Task 2: Create PlaceTripDetailScreen

**Files:**
- Create: `lib/screens/my_trips/place_trip_detail_screen.dart`

- [ ] **Step 1: Create PlaceTripDetailScreen**

Full implementation with: Hero image, DraggableScrollableSheet, header with status badge, quick stats, booking info card, status timeline, map, facilities, action buttons, reviews section.

Key structure:
```dart
Scaffold(
  body: Stack(
    children: [
      // Hero image (45% height)
      Positioned(top: 0, ..., child: Image.asset(trip.imagePath)),
      // Back + Share buttons
      SafeArea(child: Row(...)),
      // DraggableScrollableSheet
      DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (ctx, controller) => Container(
          // White, rounded top corners
          child: ListView(
            controller: controller,
            children: [
              // Drag handle
              // Header: destination name + status badge
              // Quick stats row (rating, duration, weather)
              // Booking info card
              // Status timeline
              // Map (FlutterMap)
              // Facilities
              // Action buttons
              // Reviews
            ],
          ),
        ),
      ),
    ],
  ),
)
```

The screen looks up coordinates from TravelProvider.destinations by matching trip.destination name.

- [ ] **Step 2: Run `flutter analyze` to verify no errors**

Run: `flutter analyze lib/screens/my_trips/place_trip_detail_screen.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```
git add lib/screens/my_trips/place_trip_detail_screen.dart
git commit -m "feat: create PlaceTripDetailScreen with premium Parallax+Sheet layout"
```

---

### Task 3: Create TourTripDetailScreen

**Files:**
- Create: `lib/screens/my_trips/tour_trip_detail_screen.dart`

- [ ] **Step 1: Create TourTripDetailScreen**

Full implementation with: Hero image + tour badge, DraggableScrollableSheet, header with tour name + departure, quick stats (duration, departure, destinations count), booking info, status timeline, itinerary timeline (vertical), route map with multiple markers, inclusions grid, price card, action buttons.

Key differences from PlaceTripDetailScreen:
- Looks up TourPackage from TravelProvider.tourPackages by matching trip.destination
- Itinerary timeline: vertical, one entry per destination in tour
- Map: multiple markers + polyline connecting destinations
- Inclusions grid: 2-column grid with icon+text from tour.includes
- Price card: original price (strikethrough) + actual price + total

- [ ] **Step 2: Run `flutter analyze` to verify no errors**

Run: `flutter analyze lib/screens/my_trips/tour_trip_detail_screen.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```
git add lib/screens/my_trips/tour_trip_detail_screen.dart
git commit -m "feat: create TourTripDetailScreen with itinerary, route map and price breakdown"
```

---

### Task 4: Update Routing in my_trips_screen.dart

**Files:**
- Modify: `lib/screens/my_trips/my_trips_screen.dart`

- [ ] **Step 1: Update imports and routing logic**

Add imports for PlaceTripDetailScreen and TourTripDetailScreen. In _tripList's GestureDetector onTap, replace the single TripDetailScreen navigation with conditional routing:

```dart
onTap: () {
  final isTour = trip.isCustom ||
      trip.id.startsWith('trip_tour_') ||
      trip.id.startsWith('trip_custom_');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => isTour
          ? TourTripDetailScreen(trip: trip)
          : PlaceTripDetailScreen(trip: trip),
    ),
  );
},
```

- [ ] **Step 2: Run `flutter test` to verify no regressions**

Run: `flutter test`
Expected: All tests passed

- [ ] **Step 3: Commit**

```
git add lib/screens/my_trips/my_trips_screen.dart
git commit -m "feat: route tour trips to TourTripDetailScreen, place trips to PlaceTripDetailScreen"
```

---

### Task 5: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests passed

- [ ] **Step 2: Run flutter analyze on entire project**

Run: `flutter analyze`
Expected: No issues found (or pre-existing issues only)

- [ ] **Step 3: Manual smoke test checklist**
- Open My Trips → tap a Place trip → PlaceTripDetailScreen opens with hero image, draggable sheet, all sections
- Open My Trips → tap a Tour trip → TourTripDetailScreen opens with hero image, tour badge, itinerary, map
- Verify DraggableSheet scrolls smoothly
- Verify status timeline highlights correct step
- Verify map shows markers
- Verify back button navigates correctly
