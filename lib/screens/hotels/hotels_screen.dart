import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/hotel.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/sort_bottom_sheet.dart';
import 'hotel_detail_screen.dart';
import '../../utils/app_utils.dart';

class HotelsScreen extends ConsumerStatefulWidget {
  const HotelsScreen({super.key});

  @override
  ConsumerState<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends ConsumerState<HotelsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'Tất cả';
  String _sortBy = 'Popular'; // 'Popular', 'Rating', 'PriceAsc', 'PriceDesc'

  final List<String> _cities = const [
    'Tất cả',
    'Đà Lạt',
    'Nha Trang',
    'Phú Quốc',
    'Sapa',
    'Hạ Long',
    'Hà Nội',
    'Đà Nẵng',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hotel> _getFilteredAndSorted(List<Hotel> rawHotels, String searchQuery) {
    // 1. Filter by search query
    List<Hotel> filtered = rawHotels.where((hotel) {
      final nameMatches = hotel.name.toLowerCase().contains(searchQuery.toLowerCase());
      final locationMatches = hotel.location.toLowerCase().contains(searchQuery.toLowerCase());
      return nameMatches || locationMatches;
    }).toList();

    // 2. Filter by selected city chip
    if (_selectedCity != 'Tất cả') {
      filtered = filtered.where((hotel) {
        return hotel.location.toLowerCase().contains(_selectedCity.toLowerCase());
      }).toList();
    }

    // 3. Sort
    if (_sortBy == 'PriceAsc') {
      filtered.sort((a, b) => a.priceFrom.compareTo(b.priceFrom));
    } else if (_sortBy == 'PriceDesc') {
      filtered.sort((a, b) => b.priceFrom.compareTo(a.priceFrom));
    } else if (_sortBy == 'Rating') {
      filtered.sort((a, b) {
        final rA = double.tryParse(a.rating) ?? 0.0;
        final rB = double.tryParse(b.rating) ?? 0.0;
        return rB.compareTo(rA);
      });
    } else {
      // Default: Popular (Sort by rating or default seed order)
      filtered.sort((a, b) {
        final rA = double.tryParse(a.rating) ?? 0.0;
        final rB = double.tryParse(b.rating) ?? 0.0;
        return rB.compareTo(rA);
      });
    }

    return filtered;
  }

  String _getSortLabel() => getSortLabel(_sortBy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            ref.read(hotelSearchQueryProvider.notifier).update('');
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Khách Sạn Nổi Bật',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppTheme.primaryBlue),
            onPressed: () => _showSortBottomSheet(context),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final searchQuery = ref.watch(hotelSearchQueryProvider);
          final finalHotels = _getFilteredAndSorted(ref.watch(hotelsProvider), searchQuery);
          return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (text) => ref.read(hotelSearchQueryProvider.notifier).update(text),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Tìm khách sạn, địa điểm...',
                  hintStyle: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(hotelSearchQueryProvider.notifier).update('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // City Filter Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _cities.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final city = _cities[index];
                final isSelected = _selectedCity == city;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCity = city;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.backgroundGray,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        city,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sorter & Results Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm thấy ${finalHotels.length} khách sạn',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSortBottomSheet(context),
                  child: Row(
                    children: [
                      Text(
                        _getSortLabel(),
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Hotels Grid View
          Expanded(
            child: finalHotels.isEmpty
                ? _buildEmptyState(context)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: finalHotels.length,
                    itemBuilder: (context, index) {
                      final hotel = finalHotels[index];
                      return _buildHotelGridCard(context, hotel);
                    },
                  ),
          ),
        ],
      );
        },
      ),
    );
  }

  Widget _buildHotelGridCard(BuildContext context, Hotel hotel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotel: hotel),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Overlaid Glass Price Tag
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Hero(
                        // Use a hotel-specific hero tag (by id) to avoid collisions when names duplicate
                        tag: 'hotel_image_${hotel.id}',
                        child: Image.asset(
                          hotel.imagePath,
                          fit: BoxFit.cover,
                          cacheWidth: (MediaQuery.sizeOf(context).width / 2 * MediaQuery.devicePixelRatioOf(context)).round(),
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.hotel, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Glass Price Tag
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${hotel.priceFrom.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '/đêm',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info text block
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppTheme.primaryBlue),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hotel.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 3),
                            Text(
                              hotel.rating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Chi tiết',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hotel_outlined,
                size: 64,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không tìm thấy khách sạn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chúng tôi không tìm thấy khách sạn nào phù hợp với bộ lọc hiện tại. Vui lòng thử tìm kiếm khác.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                ref.read(hotelSearchQueryProvider.notifier).update('');
                setState(() {
                  _selectedCity = 'Tất cả';
                  _sortBy = 'Popular';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Đặt lại bộ lọc',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    SortBottomSheet.show(context,
      currentSort: _sortBy,
      onSortChanged: (code) => setState(() => _sortBy = code),
      options: const [
        SortOption('Popular', 'Phổ biến nhất', Icons.insights),
        SortOption('Rating', 'Đánh giá tốt nhất', Icons.star),
        SortOption('PriceAsc', 'Giá từ thấp đến cao', Icons.trending_up),
        SortOption('PriceDesc', 'Giá từ cao đến thấp', Icons.trending_down),
      ],
    );
  }
}
