import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../checkout/checkout_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;
  final VoidCallback onBackClick;
  final VoidCallback onFavoriteClick;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
    required this.onBackClick,
    required this.onFavoriteClick,
  });

  void _navigateToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(destination: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroCacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();
    final thumbCacheWidth =
        (100 * MediaQuery.devicePixelRatioOf(context)).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Hero(
              tag: 'dest_image_${destination.name}',
              child: Image.asset(
                destination.imagePath,
                fit: BoxFit.cover,
                cacheWidth: heroCacheWidth,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onBackClick,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.chevron_left, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavoriteClick,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        destination.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            destination.isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination.name,
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 4),
                                  Text(
                                    destination.location,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoItem(Icons.star, destination.rating,
                            "(${destination.reviewsCount} Đánh giá)"),
                        _infoItem(Icons.access_time, destination.duration,
                            "Thời lượng"),
                        _infoItem(Icons.wb_cloudy, "24°C", "Thời tiết"),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Mô tả",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      destination.description.isNotEmpty
                          ? destination.description
                          : "Khám phá vẻ đẹp tuyệt vời của ${destination.name}. Một hành trình đáng nhớ đang chờ đợi bạn.",
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Tiện ích",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _facilityItem(Icons.wifi, "Wifi"),
                          const SizedBox(width: 20),
                          _facilityItem(Icons.flatware, "Bữa sáng"),
                          const SizedBox(width: 20),
                          _facilityItem(Icons.pool, "Hồ bơi"),
                          const SizedBox(width: 20),
                          _facilityItem(Icons.local_parking, "Gửi xe"),
                          const SizedBox(width: 20),
                          _facilityItem(Icons.fitness_center, "Gym"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Vị trí trên bản đồ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (destination.latitude != 0.0 && destination.longitude != 0.0)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                  destination.latitude, destination.longitude),
                              initialZoom: 13,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.onlinetravelagent',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(destination.latitude,
                                        destination.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text("Chưa có thông tin toạ độ", style: TextStyle(color: Colors.grey)),
                      ),
                    const SizedBox(height: 32),
                    const Text(
                      "Hình ảnh",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            destination.imagePath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            cacheWidth: thumbCacheWidth,
                            filterQuality: FilterQuality.low,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildReviewsSection(context),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Giá từ",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        "\$${destination.price}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _navigateToCheckout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Đặt ngay",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: Colors.amber),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _facilityItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final reviews = _getSampleReviews(destination.name);
    final double ratingVal = double.tryParse(destination.rating) ?? 4.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Đánh giá & Nhận xét",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Rating Summary Header Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  destination.rating,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    final isFilled = index < ratingVal.round();
                    return Icon(
                      Icons.star,
                      size: 16,
                      color: isFilled ? Colors.amber : Colors.grey.shade300,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  "${destination.reviewsCount} nhận xét",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Progress bars on the right
            Expanded(
              child: Column(
                children: [
                  _ratingProgressBar("5 sao", 0.85),
                  _ratingProgressBar("4 sao", 0.10),
                  _ratingProgressBar("3 sao", 0.03),
                  _ratingProgressBar("2 sao", 0.01),
                  _ratingProgressBar("1 sao", 0.01),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // List of Vertical Review Cards
        Column(
          children: reviews.map((review) => _buildReviewCard(review)).toList(),
        ),
      ],
    );
  }

  Widget _ratingProgressBar(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${(percentage * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, String> review) {
    final double ratingVal = double.tryParse(review['rating'] ?? '5.0') ?? 5.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(review['avatar']!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review['date']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final isFilled = index < ratingVal.round();
                  return Icon(
                    Icons.star,
                    size: 12,
                    color: isFilled ? Colors.amber : Colors.grey.shade200,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment']!,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                "Hữu ích",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getSampleReviews(String name) {
    final clean = name.toLowerCase().trim();
    if (clean.contains('đà lạt')) {
      return [
        {
          'name': 'Trần Minh Quân',
          'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop',
          'date': '3 ngày trước',
          'rating': '5.0',
          'comment': 'Đà Lạt mùa này lạnh tê tái rất thích hợp để nghỉ dưỡng. Khách sạn Mường Thanh ở vị trí trung tâm đi lại cực tiện, Hồ Xuân Hương thơ mộng lộng gió buổi tối tuyệt vời!',
        },
        {
          'name': 'Nguyễn Thảo Nguyên',
          'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop',
          'date': '1 tuần trước',
          'rating': '4.5',
          'comment': 'Đồ ăn đêm ở chợ Đà Lạt siêu ngon, bánh tráng nướng và sữa đậu nành nóng hổi giữa trời lạnh rất chill. Thác Datanla trượt máng hơi mạo hiểm nhưng rất phấn khích.',
        },
        {
          'name': 'Hoàng Bách',
          'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&fit=crop',
          'date': '2 tuần trước',
          'rating': '4.8',
          'comment': 'Thung Lũng Tình Yêu cảnh sắc lãng mạn ngập sắc hoa ôn đới. Chuyến đi cực kỳ đáng giá, chắc chắn sẽ quay lại cùng gia đình!',
        },
      ];
    } else if (clean.contains('phú quốc')) {
      return [
        {
          'name': 'Lê Hải Đăng',
          'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&fit=crop',
          'date': '2 ngày trước',
          'rating': '5.0',
          'comment': 'Đảo ngọc Phú Quốc biển trong xanh vắt ngắm rõ san hô. Tour đi cano 4 đảo xuất sắc, ngắm hoàng hôn rực rỡ ở Sunset Sanato là trải nghiệm đỉnh cao của chuyến đi.',
        },
        {
          'name': 'Phạm Khánh Linh',
          'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&fit=crop',
          'date': '1 tuần trước',
          'rating': '4.9',
          'comment': 'Resort 5 sao bãi biển riêng cát trắng mịn. Đồ ăn hải sản nướng thơm ngon, đặc biệt gỏi cá trích cuốn bánh tráng nướng vị thanh tao khó cưỡng.',
        },
        {
          'name': 'Đặng Quốc Huy',
          'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop',
          'date': '3 tuần trước',
          'rating': '4.7',
          'comment': 'Cáp treo vượt biển Hòn Thơm ngắm toàn cảnh các hòn đảo từ trên cao cực kỳ hùng vĩ. Trò chơi trượt nước ở Aquatopia vui nhộn!',
        },
      ];
    } else if (clean.contains('sapa') || clean.contains('sa pa')) {
      return [
        {
          'name': 'Nguyễn Tiến Đạt',
          'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop',
          'date': '5 ngày trước',
          'rating': '5.0',
          'comment': 'Chinh phục đỉnh Fansipan 3.143m ngắm thung lũng mây trôi bồng bềnh hùng vĩ. Khách sạn view núi tuyệt đẹp, buổi sáng dậy nhâm nhi tách trà nóng ngắm mây sương bay vô cùng thư giãn!',
        },
        {
          'name': 'Vũ Quỳnh Chi',
          'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop',
          'date': '1 tuần trước',
          'rating': '4.8',
          'comment': 'Trải nghiệm đi bộ trekking xuyên qua bản Cát Cát và thung lũng Mường Hoa rất thú vị. Buổi tối ăn lẩu cá tầm nóng hổi trong tiết trời lạnh buốt Sa Pa rất ngon miệng.',
        },
        {
          'name': 'Lê Minh Triết',
          'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&fit=crop',
          'date': '2 tuần trước',
          'rating': '4.7',
          'comment': 'Tắm lá thuốc người Dao Đỏ xong cơ thể sảng khoái, hết mỏi cơ. Người dân bản địa vô cùng thân thiện mến khách!',
        },
      ];
    } else if (clean.contains('hạ long') || clean.contains('halong')) {
      return [
        {
          'name': 'Đỗ Hoàng Long',
          'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&fit=crop',
          'date': '1 ngày trước',
          'rating': '5.0',
          'comment': 'Ngủ đêm trên du thuyền 5 sao lướt êm đềm giữa hàng ngàn đảo đá vôi là trải nghiệm thượng lưu. Thức dậy đón bình minh trên boong tàu tập Thái Cực Quyền vô cùng thanh tịnh.',
        },
        {
          'name': 'Nguyễn Phương Thảo',
          'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&fit=crop',
          'date': '1 tuần trước',
          'rating': '4.8',
          'comment': 'Chèo kayak luồn lách qua các hang động đá vôi tự nhiên vô cùng kì thú. Hải sản phục vụ trên tàu tươi ngon, nhân viên phục vụ cực kì tận tâm và lịch sự.',
        },
      ];
    } else {
      // Default / general destinations (Hội An, Hà Nội, Đà Nẵng, etc.)
      return [
        {
          'name': 'Nguyễn Tuấn Kiệt',
          'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop',
          'date': '4 ngày trước',
          'rating': '4.9',
          'comment': 'Địa điểm du lịch tuyệt vời mang đậm nét bản sắc văn hóa. Không gian phong cảnh lãng mạn, ẩm thực bản địa phong phú và người dân địa phương vô cùng mến khách!',
        },
        {
          'name': 'Mai Thu Trang',
          'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop',
          'date': '1 tuần trước',
          'rating': '4.8',
          'comment': 'Chuyến đi tổ chức rất trọn vẹn và an toàn. Hướng dẫn viên nhiệt tình hướng dẫn các điểm chụp hình đẹp và kể những câu chuyện lịch sử văn hóa vô cùng bổ ích.',
        },
      ];
    }
  }
}
