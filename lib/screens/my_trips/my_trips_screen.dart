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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = context.select<TravelProvider, List<Trip>>((p) => p.upcomingTrips);
    final history = context.select<TravelProvider, List<Trip>>((p) => p.historyTrips);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                "Chuyến đi của tôi",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryBlue,
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Sắp tới"),
                  Tab(text: "Lịch sử"),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _tripList(upcoming),
                    _tripList(history),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripList(List<Trip> filteredTrips) {
    if (filteredTrips.isEmpty) {
      return const Center(
        child: Text(
          "Chưa có chuyến đi nào",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredTrips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      padding: const EdgeInsets.only(bottom: 24),
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
}
