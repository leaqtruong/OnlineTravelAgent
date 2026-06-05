import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';

import '../../providers/destination_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/tour_provider.dart';
import 'widgets/popular_destination_card.dart';
import '../flights/flight_search_screen.dart';
import '../tours/tours_screen.dart';
import '../custom_tour/custom_tour_stepper_screen.dart';
import '../notifications/notifications_screen.dart';
import '../destinations/destinations_screen.dart';
import '../food/food_screen.dart';
import '../hotels/hotels_screen.dart';
import '../tours/tour_detail_screen.dart';
import '../../models/tour_package.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(Destination) onDestinationClick;

  const DashboardScreen({super.key, required this.onDestinationClick});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Tất cả', 'Địa điểm', 'Khách sạn', 'Ẩm thực'];
    final visibleCategories = categories
        .where((category) => category != 'Máy bay')
        .toList();

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
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontSize: 32),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: AppTheme.primaryBlue,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
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
                            ref.read(searchQueryProvider.notifier).update(''),
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
                                    ref.read(searchQueryProvider.notifier).update('');
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
                child: Consumer(builder: (context, ref, child) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: visibleCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final category = visibleCategories[index];
                        final isSelected = ref.watch(selectedCategoryProvider) == category;
                        return GestureDetector(
                          onTap: () {
                            if (category == 'Khách sạn') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HotelsScreen(),
                                ),
                              );
} else if (category == 'Địa điểm') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DestinationsScreen(
        initialCategory: category,
      ),
    ),
  );
} else if (category == 'Ẩm thực') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FoodScreen(),
    ),
  );
                            } else {
                              ref.read(selectedCategoryProvider.notifier).update(category);
                            }
                          },
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
                child: Consumer(
                  builder: (context, ref, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Điểm đến',
                            value: ref.watch(destinationsProvider).length.toString(),
                            icon: Icons.place_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            title: 'Yêu thích',
                            value: ref.watch(favoritesProvider).length.toString(),
                            icon: Icons.favorite_border,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            title: 'Sắp tới',
                            value: ref.watch(tripsProvider).length.toString(),
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
                child: Consumer(
                  builder: (context, ref, _) {
                    final upcomingTrip = ref.watch(tripsProvider).isNotEmpty
                        ? ref.watch(tripsProvider).first
                        : null;
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
              // Checklist section removed per request
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Địa điểm phổ biến',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DestinationsScreen(
                              initialCategory: 'Địa điểm',
                            ),
                          ),
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
              Consumer(builder: (context, ref, child) {
                  if (ref.watch(filteredDestinationsProvider).isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Không tìm thấy địa điểm phù hợp'),
                      ),
                    );
                  }
                  final displayList = ref.watch(filteredDestinationsProvider).take(5).toList();
                  return SizedBox(
                    height: 240,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        if (index >= displayList.length) {
                          return const SizedBox.shrink();
                        }
                        return PopularDestinationCard(
                          destination: displayList[index],
                          onFavoriteClick: () => ref.read(destinationsProvider.notifier).toggleFavorite(displayList[index].id),
                          onClick: () =>
                              widget.onDestinationClick(displayList[index]),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Đề xuất tour',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ToursScreen(),
                          ),
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
              const SizedBox(height: 16),
              Consumer(builder: (context, ref, child) {
                  if (ref.watch(toursProvider).isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Không có đề xuất tour nào'),
                      ),
                    );
                  }
                  final displayList = ref.watch(toursProvider).take(5).toList();
                  return SizedBox(
                    height: 200,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        if (index >= displayList.length) {
                          return const SizedBox.shrink();
                        }
                        final tour = displayList[index];
                        return _RecommendedTourCard(
                          tour: tour,
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TourDetailScreen(tour: tour),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildTravelStoriesSection(),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomTourStepperScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text(
          'Tự Tạo Tour',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildTravelStoriesSection() {
    final stories = [
      {
        'name': 'Hồng Nhung',
        'avatar':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&fit=crop',
        'location': 'Sa Pa, VN',
        'comment':
            'Bản Cát Cát thật yên bình, mây mù phủ kín thung lũng mộng mơ vào sáng sớm!',
        'rating': '5.0',
        'image': 'assets/images/sapa_image.png',
      },
      {
        'name': 'Quốc Anh',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop',
        'location': 'Vịnh Hạ Long, VN',
        'comment':
            'Chèo thuyền kayak vượt qua Hang Luồn hoang sơ là một trải nghiệm không thể quên!',
        'rating': '4.9',
        'image': 'assets/images/halong_image.png',
      },
      {
        'name': 'Minh Huy',
        'avatar':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&fit=crop',
        'location': 'Đà Nẵng, VN',
        'comment':
            'Hoàng hôn trên Cầu Vàng rất hùng vĩ, mây núi hòa quyện say đắm lòng người.',
        'rating': '4.8',
        'image': 'assets/images/danang_image.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Cảm hứng du lịch',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final story = stories[index];
              return Container(
                width: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        story['image']!,
                        width: 90,
                        height: 166,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 90,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(story['avatar']!),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  story['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 10,
                                color: AppTheme.primaryBlue,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                story['location']!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              story['comment']!,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 11,
                                height: 1.4,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                story['rating']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
      ],
    );
  }

}

class _RecommendedTourCard extends StatelessWidget {
  final TourPackage tour;
  final VoidCallback onClick;

  const _RecommendedTourCard({required this.tour, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (166 * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 174,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      tour.imagePath,
                      height: 96,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: cacheWidth,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 96,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (tour.includesGuide)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Có HDV',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: -8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkGray,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        tour.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                tour.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.flight_takeoff,
                    color: Colors.blueAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Từ ${tour.departure}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${tour.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  if (tour.originalPrice != null)
                    Text(
                      '\$${tour.originalPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
