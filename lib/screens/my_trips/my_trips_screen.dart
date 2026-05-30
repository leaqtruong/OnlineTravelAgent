import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';
import '../../providers/travel_provider.dart';
import 'trip_detail_screen.dart';
import 'widgets/trip_card.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: Consumer<TravelProvider>(
          builder: (context, provider, child) {
            final allTrips = provider.trips;
            final tours = provider.trips.where((t) => t.flightId == null && t.hotelId == null).toList();
            final hotels = provider.trips.where((t) => t.hotelId != null).toList();
            final flights = provider.trips.where((t) => t.flightId != null).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // A. Custom Header
                  const Text(
                    "Chuyến đi của tôi",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBlack,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // B. Capsule Styled Pill TabBar
                  Container(
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicator: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[500],
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: "Tất cả"),
                        Tab(text: "Gói Tour"),
                        Tab(text: "Khách sạn"),
                        Tab(text: "Vé máy bay"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // C. Tab Contents View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _tripList(allTrips),
                        _tripList(tours),
                        _tripList(hotels),
                        _tripList(flights),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tripList(List<Trip> filteredTrips) {
    if (filteredTrips.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: filteredTrips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      padding: const EdgeInsets.only(bottom: 24, top: 4),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final trip = filteredTrips[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailScreen(trip: trip),
              ),
            );
          },
          child: TripCard(trip: trip),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_rounded,
                size: 80,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Bắt đầu hành trình mới",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Bạn chưa có chuyến đi nào được lên lịch. Hãy bắt đầu lên kế hoạch cho hành trình tiếp theo của bạn ngay hôm nay để nhận những ưu đãi hấp dẫn nhất.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  // Pop back to explore destinations
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Khám phá ngay",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
