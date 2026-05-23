import 'package:flutter/material.dart';
import '../../models/trip.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/trip_card.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Trip> trips = [
    Trip(
      destination: "Đảo Phú Quốc",
      date: "20/05/2026 - 23/05/2026",
      status: "Sắp tới",
      imagePath: "assets/images/phuquoc_image.jpg",
      isUpcoming: true,
    ),
    Trip(
      destination: "Hội An",
      date: "15/04/2026 - 17/04/2026",
      status: "Đã đi",
      imagePath: "assets/images/hoian_image.webp",
      isUpcoming: false,
    ),
    Trip(
      destination: "Đà Lạt",
      date: "10/03/2026 - 14/03/2026",
      status: "Đã đi",
      imagePath: "assets/images/dalat_image.jpg",
      isUpcoming: false,
    ),
  ];

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
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
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
                    _tripList(trips.where((t) => t.isUpcoming).toList()),
                    _tripList(trips.where((t) => !t.isUpcoming).toList()),
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
    return ListView.separated(
      itemCount: filteredTrips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, index) {
        return TripCard(trip: filteredTrips[index]);
      },
    );
  }
}
