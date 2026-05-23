import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/destination.dart';
import '../../providers/travel_provider.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/popular_destination_card.dart';
import 'widgets/recommended_destination_card.dart';

class DashboardScreen extends StatefulWidget {
  final Function(Destination) onDestinationClick;

  const DashboardScreen({super.key, required this.onDestinationClick});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = "Địa điểm";
  final List<String> categories = ["Địa điểm", "Khách sạn", "Máy bay", "Ẩm thực"];

  @override
  Widget build(BuildContext context) {
    final travelProvider = Provider.of<TravelProvider>(context);
    final destinations = travelProvider.destinations;
    final recommended = travelProvider.recommended;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Xin chào, User!",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      Text(
                        "Bạn muốn đi đâu?",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, size: 28, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGray,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "Tìm kiếm hoạt động",
                      style: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Categories
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.backgroundGray : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Popular Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Phổ biến",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Xem tất cả",
                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    return PopularDestinationCard(
                      destination: destinations[index],
                      onFavoriteClick: () => travelProvider.toggleFavorite(destinations[index].name),
                      onClick: () => widget.onDestinationClick(destinations[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Recommended Section
              const Text(
                "Đề xuất",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    return RecommendedDestinationCard(
                      destination: recommended[index],
                      onClick: () => widget.onDestinationClick(recommended[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
