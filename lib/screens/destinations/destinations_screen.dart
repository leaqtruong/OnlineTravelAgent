import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../destination_detail/destination_detail_screen.dart';
import '../../utils/app_utils.dart';

class DestinationsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const DestinationsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends ConsumerState<DestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'Popular'; // 'Popular', 'PriceAsc', 'PriceDesc', 'Rating'

  @override
  void initState() {
    super.initState();
    // Initialize provider search/category from widget fields or keep synchronized
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (widget.initialCategory != null) {
        ref.read(selectedCategoryProvider.notifier).update(widget.initialCategory!);
      }
      _searchController.text = ref.watch(searchQueryProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parseReviewsCount(String reviewsCount) => parseReviewsCount(reviewsCount);

  List<Destination> _getSortedAndFiltered(List<Destination> list) {
    final sorted = List<Destination>.from(list);
    if (_sortBy == 'PriceAsc') {
      sorted.sort((a, b) {
        final priceA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final priceB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return priceA.compareTo(priceB);
      });
    } else if (_sortBy == 'PriceDesc') {
      sorted.sort((a, b) {
        final priceA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final priceB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return priceB.compareTo(priceA);
      });
    } else if (_sortBy == 'Rating') {
      sorted.sort((a, b) {
        final ratingA = double.tryParse(a.rating) ?? 0.0;
        final ratingB = double.tryParse(b.rating) ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
    } else {
      // Popular (by reviews count)
      sorted.sort((a, b) {
        final countA = _parseReviewsCount(a.reviewsCount);
        final countB = _parseReviewsCount(b.reviewsCount);
        return countB.compareTo(countA);
      });
    }
    return sorted;
  }

  String _getSortLabel() => getSortLabel(_sortBy);

  void _resetFiltersOnExit() {

    ref.read(searchQueryProvider.notifier).update('');
    ref.read(selectedCategoryProvider.notifier).update('Tất cả');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _resetFiltersOnExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () {
              _resetFiltersOnExit();
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Khám Phá Địa Điểm',
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
            final sortedList = _getSortedAndFiltered(ref.watch(filteredDestinationsProvider));
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
                  onChanged: (text) => ref.read(searchQueryProvider.notifier).update(text),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20,
                    ),
                    hintText: 'Tìm kiếm địa điểm du lịch...',
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
                              ref.read(searchQueryProvider.notifier).update('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Results and Sorter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tìm thấy ${sortedList.length} địa điểm',
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
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Responsive Grid Layout
            Expanded(
              child: sortedList.isEmpty
                  ? _buildEmptyState(context)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: sortedList.length,
                      itemBuilder: (context, index) {
                        final destination = sortedList[index];
                        return _buildDestinationCard(context, destination);
                      },
                    ),
            ),
          ],
        );
          },
        ),
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, Destination destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(
              destination: destination,
              onBackClick: () => Navigator.pop(context),
              onFavoriteClick: () =>
                  ref.read(destinationsProvider.notifier).toggleFavorite(destination.id),
            ),
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
            // Image with Glass Price Tag & Floating Heart
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Hero(
                        tag: 'dest_image_${destination.name}',
                        child: Image.asset(
                          destination.imagePath,
                          fit: BoxFit.cover,
                          cacheWidth:
                              (MediaQuery.sizeOf(context).width /
                                      2 *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Price tag
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${destination.price}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  // Heart Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(destinationsProvider.notifier).toggleFavorite(
                          destination.id,
                        );
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: Icon(
                          destination.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: destination.isFavorite
                              ? Colors.red
                              : Colors.black87,
                          size: 18,
                        ),
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
                      destination.name,
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
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            destination.location,
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
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              destination.rating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          destination.duration,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
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
                Icons.travel_explore_outlined,
                size: 64,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chúng tôi không tìm thấy địa điểm nào phù hợp với bộ lọc hiện tại. Vui lòng thử tìm kiếm với cụm từ khác.',
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
                ref.read(searchQueryProvider.notifier).update('');
                ref.read(selectedCategoryProvider.notifier).update('Tất cả');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Đặt lại bộ lọc',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
