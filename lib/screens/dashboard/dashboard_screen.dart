import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';

import '../../providers/travel_provider.dart';
import 'widgets/popular_destination_card.dart';
import 'widgets/recommended_destination_card.dart';
import '../flights/flight_search_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(Destination) onDestinationClick;

  const DashboardScreen({super.key, required this.onDestinationClick});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.read<TravelProvider>().categories;
    final visibleCategories = categories.where((category) => category != 'Máy bay').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, User!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          'Bạn muốn đi đâu?',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 32),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.notifications_none,
                        color: AppTheme.primaryBlue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      return TextField(
                        controller: _searchController,
                        onChanged: (text) =>
                            context.read<TravelProvider>().setSearchQuery(text),
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          hintText: 'Tìm kiếm hoạt động',
                          hintStyle: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<TravelProvider>()
                                        .setSearchQuery('');
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: Selector<TravelProvider, String>(
                  selector: (_, provider) => provider.selectedCategory,
                  builder: (context, selectedCategory, child) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: visibleCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final category = visibleCategories[index];
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () => context
                              .read<TravelProvider>()
                              .setSelectedCategory(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.backgroundGray
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlightSearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF176FF2), Color(0xFF196EEE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF176FF2).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flight_takeoff,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đặt vé máy bay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tìm chuyến bay giá rẻ nhất',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<TravelProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Điểm đến',
                            value: provider.destinations.length.toString(),
                            icon: Icons.place_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            title: 'Yêu thích',
                            value: provider.favorites.length.toString(),
                            icon: Icons.favorite_border,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            title: 'Sắp tới',
                            value: provider.upcomingTrips.length.toString(),
                            icon: Icons.flight_takeoff,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<TravelProvider>(
                  builder: (context, provider, _) {
                    final upcomingTrip = provider.upcomingTrips.isNotEmpty ? provider.upcomingTrips.first : null;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: upcomingTrip == null
                          ? const Text(
                              'Bạn chưa có chuyến đi sắp tới. Hãy đặt ngay một hành trình mới.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            )
                          : Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kế hoạch gần nhất: ${upcomingTrip.destination}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        upcomingTrip.date,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEAF2FF), Color(0xFFF7FAFF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD8E6FF)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mẹo hôm nay: Đặt chuyến trước 2-3 tuần để có giá tốt hơn và nhiều khung giờ đẹp.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3B4A66),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Xu hướng tuần này',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _trendCard(
                        icon: Icons.weekend,
                        title: 'City Break 48h',
                        subtitle: 'Hà Nội, Đà Nẵng, Sài Gòn',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _trendCard(
                        icon: Icons.spa,
                        title: 'Nghỉ dưỡng chill',
                        subtitle: 'Biển xanh, resort yên tĩnh',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Checklist nhanh',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _ChecklistChip(
                        icon: Icons.badge_outlined, label: 'CCCD/Hộ chiếu'),
                    SizedBox(width: 10),
                    _ChecklistChip(
                        icon: Icons.credit_card, label: 'Thẻ thanh toán'),
                    SizedBox(width: 10),
                    _ChecklistChip(
                        icon: Icons.local_hospital_outlined,
                        label: 'Thuốc cơ bản'),
                    SizedBox(width: 10),
                    _ChecklistChip(
                        icon: Icons.wb_sunny_outlined, label: 'Kem chống nắng'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phổ biến',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        context.read<TravelProvider>().setSearchQuery('');
                        context.read<TravelProvider>().setSelectedCategory(
                              'Tất cả',
                            );
                      },
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Selector<TravelProvider, List<Destination>>(
                selector: (_, provider) => provider.filteredDestinations,
                builder: (context, destinations, child) {
                  if (destinations.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Không tìm thấy địa điểm phù hợp'),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 240,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: destinations.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        if (index >= destinations.length) {
                          return const SizedBox.shrink();
                        }
                        return PopularDestinationCard(
                          destination: destinations[index],
                          onFavoriteClick: () => context
                              .read<TravelProvider>()
                              .toggleFavorite(destinations[index].id),
                          onClick: () =>
                              widget.onDestinationClick(destinations[index]),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Đề xuất',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Selector<TravelProvider, List<Destination>>(
                selector: (_, provider) => provider.filteredRecommended,
                builder: (context, recommended, child) {
                  if (recommended.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Không tìm thấy đề xuất phù hợp'),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: recommended.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        if (index >= recommended.length) {
                          return const SizedBox.shrink();
                        }
                        return RecommendedDestinationCard(
                          destination: recommended[index],
                          onClick: () =>
                              widget.onDestinationClick(recommended[index]),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _trendCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ChecklistChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChecklistChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
