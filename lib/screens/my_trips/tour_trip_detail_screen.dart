import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';
import '../../models/tour_package.dart';
import '../../providers/destination_provider.dart';
import '../../providers/tour_provider.dart';
import 'widgets/booking_info_card.dart';
import 'widgets/booking_status_timeline.dart';
import 'widgets/trip_action_buttons.dart';
import 'widgets/trip_section_header.dart';

class TourTripDetailScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const TourTripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TourTripDetailScreen> createState() => _TourTripDetailScreenState();
}

class _TourTripDetailScreenState extends ConsumerState<TourTripDetailScreen> {
  int _selectedDayIndex = 0;
  
  // Custom Time simulation for testing
  int? _simulatedHour;
  int? _simulatedMinute;
  bool _showSimulatePanel = false;

  TourPackage? _findTourPackage(WidgetRef ref) {
    final tourPackages = ref.watch(toursProvider);
    final name = widget.trip.destination.toLowerCase().trim();
    try {
      return tourPackages.firstWhere(
        (t) => t.name.toLowerCase().trim() == name,
      );
    } catch (_) {
      return null;
    }
  }

  Color _statusColor() {
    final s = widget.trip.status.toLowerCase();
    if (s == 'đang diễn ra' || s == 'ongoing') return const Color(0xFFFF9800);
    if (widget.trip.isUpcoming) return AppTheme.primaryBlue;
    return Colors.grey;
  }

  Color _statusBgColor() {
    final s = widget.trip.status.toLowerCase();
    if (s == 'đang diễn ra' || s == 'ongoing') {
      return const Color(0xFFFF9800).withValues(alpha: 0.1);
    }
    if (widget.trip.isUpcoming) {
      return AppTheme.primaryBlue.withValues(alpha: 0.08);
    }
    return Colors.grey.withValues(alpha: 0.1);
  }

  LinearGradient _getClassificationGradient() {
    if (widget.trip.isCustom) {
      return const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Map<int, List<Map<String, dynamic>>> _getMilestonesForTour(String tourName, int totalDays) {
    final clean = tourName.toLowerCase().trim();
    if (clean.contains('đà lạt')) {
      return {
        0: [
          {'time': '08:30', 'event': 'Xe & HDV đón khách khởi hành tour.', 'desc': 'Đón tại Khách sạn Mường Thanh Đà Lạt.'},
          {'time': '10:00', 'event': 'Check-in Quảng trường Lâm Viên.', 'desc': 'Thưởng thức cafe nóng ngắm Hồ Xuân Hương yên bình.'},
          {'time': '12:00', 'event': 'Ăn trưa lẩu gà lá é Tao Đàn.', 'desc': 'Thưởng thức ẩm thực đặc sắc nổi tiếng Đà Lạt.'},
          {'time': '14:30', 'event': 'Khám phá Thác Datanla hoang sơ.', 'desc': 'Trải nghiệm máng trượt xuyên qua những cánh rừng thông.'},
          {'time': '18:00', 'event': 'Tự do dạo chơi Chợ Đêm Đà Lạt.', 'desc': 'Thưởng thức bánh tráng nướng, sữa đậu nành nóng hổi.'},
        ],
        1: [
          {'time': '08:00', 'event': 'Dùng buffet sáng nóng hổi tại resort.', 'desc': 'Chuẩn bị năng lượng cho ngày khám phá thứ hai.'},
          {'time': '09:30', 'event': 'Khám phá Đường Hầm Đất Sét.', 'desc': 'Chiêm ngưỡng các công trình điêu khắc độc đáo.'},
          {'time': '12:00', 'event': 'Ăn trưa cơm lam gà nướng đồi thông.', 'desc': 'Bữa trưa đậm chất núi rừng Tây Nguyên.'},
          {'time': '14:00', 'event': 'Chinh phục đỉnh Langbiang huyền thoại.', 'desc': 'Ngắm toàn cảnh Đà Lạt từ trên cao bằng xe Jeep.'},
          {'time': '18:00', 'event': 'Giao lưu văn hóa cồng chiêng.', 'desc': 'Uống rượu cần, ăn thịt nướng bên lửa trại bập bùng.'},
        ],
        2: [
          {'time': '08:00', 'event': 'Ăn sáng tại khách sạn, nhâm nhi cafe.', 'desc': 'Tận hưởng làn sương mù buổi sớm mai thơ mộng.'},
          {'time': '09:30', 'event': 'Mua sắm các món đặc sản làm quà.', 'desc': 'Ghé cửa hàng mứt, hoa quả sấy, dâu tây tươi.'},
          {'time': '11:30', 'event': 'Làm thủ tục trả phòng khách sạn.', 'desc': 'Kiểm tra hành lý cẩn thận trước khi ra về.'},
          {'time': '13:00', 'event': 'Xe tiễn đoàn ra sân bay Liên Khương.', 'desc': 'Chào tạm biệt Đà Lạt mộng mơ, kết thúc hành trình.'},
        ],
      };
    } else if (clean.contains('phú quốc')) {
      return {
        0: [
          {'time': '09:00', 'event': 'Đón đoàn tại sân bay Phú Quốc.', 'desc': 'Xe đưa đoàn về Resort InterContinental làm thủ tục gửi hành lý.'},
          {'time': '10:30', 'event': 'Khám phá Dinh Cậu linh thiêng.', 'desc': 'Biểu tượng văn hóa tín ngưỡng của ngư dân hải đảo.'},
          {'time': '12:00', 'event': 'Ăn trưa đặc sản gỏi cá trích Phú Quốc.', 'desc': 'Món ngon nức tiếng không thể bỏ qua tại bãi biển.'},
          {'time': '14:30', 'event': 'Làm thủ tục nhận phòng Resort nghỉ ngơi.', 'desc': 'Bơi lội tự do tại hồ bơi vô cực sát bờ biển cát trắng.'},
          {'time': '18:00', 'event': 'Ngắm hoàng hôn tuyệt mỹ tại Ink 360 Bar.', 'desc': 'Quầy bar cao nhất Phú Quốc ngắm nhìn đại dương lãng mạn.'},
        ],
        1: [
          {'time': '08:00', 'event': 'Dùng điểm tâm buffet tại resort.', 'desc': 'Nạp năng lượng cho ngày phiêu lưu biển đảo.'},
          {'time': '09:00', 'event': 'Cano cao tốc đưa đoàn khám phá 4 đảo.', 'desc': 'Ghé thăm các hòn đảo hoang sơ xinh đẹp phía Nam.'},
          {'time': '11:30', 'event': 'Trải nghiệm lặn ngắm rạn san hô tự nhiên.', 'desc': 'Ngắm thế giới đại dương đầy sắc màu tại hòn Móng Tay.'},
          {'time': '13:00', 'event': 'Bữa trưa hải sản thịnh soạn tại hòn Mây Rút.', 'desc': 'Thưởng thức mực nướng trứ danh bên hàng dừa xanh mát.'},
          {'time': '18:00', 'event': 'Ăn tối hải sản BBQ tối bên bờ biển rộng.', 'desc': 'Bữa tối lãng mạn lộng gió biển Phú Quốc.'},
        ],
        2: [
          {'time': '08:00', 'event': 'Thưởng thức cafe sáng bên bãi biển.', 'desc': 'Đi dạo đón ánh bình minh dịu mát.'},
          {'time': '09:30', 'event': 'Check-in Grand World Phú Quốc.', 'desc': 'Khám phá thành phố không ngủ, đi thuyền trên sông Venice.'},
          {'time': '12:00', 'event': 'Dùng cơm trưa ẩm thực đường phố.', 'desc': 'Thưởng thức bún quậy Kiến Xây trứ danh.'},
          {'time': '15:00', 'event': 'Khám phá Safari Vinpearl ngắm thú hoang dã.', 'desc': 'Mô hình xe nhốt người thả thú độc đáo thú vị.'},
          {'time': '18:30', 'event': 'Dùng bữa tối hải sản thịnh soạn.', 'desc': 'Bữa tối phong phú cùng gia đình tại nhà hàng sang trọng.'},
        ],
        3: [
          {'time': '08:00', 'event': 'Bơi lội và dùng điểm tâm sáng buffet.', 'desc': 'Tận hưởng ngày cuối cùng tại resort.'},
          {'time': '10:00', 'event': 'Tham quan nhà thùng sản xuất nước mắm.', 'desc': 'Tìm hiểu công nghệ ủ chượp cá cơm truyền thống Phú Quốc.'},
          {'time': '12:00', 'event': 'Làm thủ tục check-out trả phòng.', 'desc': 'Thu dọn hành lý chuẩn bị di chuyển.'},
          {'time': '13:30', 'event': 'Xe đón tiễn đoàn ra sân bay Phú Quốc.', 'desc': 'Kết thúc kỳ nghỉ Phú Quốc 4 ngày 3 đêm đầy ắp niềm vui.'},
        ],
      };
    } else if (clean.contains('sapa') || clean.contains('sa pa')) {
      return {
        0: [
          {'time': '08:00', 'event': 'Xe Limousine đón đoàn khởi hành đi Sapa.', 'desc': 'Bắt đầu hành trình qua cao tốc Hà Nội - Lào Cai.'},
          {'time': '11:00', 'event': 'Nhận phòng tại Bungalow Sapa Jade Hill.', 'desc': 'Thưởng trà ngắm mây ngàn thung lũng Mường Hoa.'},
          {'time': '12:00', 'event': 'Dùng cơm trưa lẩu cá tầm đặc sản Tây Bắc.', 'desc': 'Lẩu ấm cúng giữa không khí lạnh mát lạnh của Sapa.'},
          {'time': '14:30', 'event': 'Trekking tham quan Bản Cát Cát hoang sơ.', 'desc': 'Tìm hiểu nếp sống và văn hóa của đồng bào người H\'Mông.'},
          {'time': '18:00', 'event': 'Ăn tối đồ nướng Sapa thơm ngon.', 'desc': 'Tự do khám phá nhà thờ đá mờ sương rực rỡ.'},
        ],
        1: [
          {'time': '08:00', 'event': 'Ăn sáng buffet ấm cúng giữa mây mù.', 'desc': 'Thưởng thức ly trà gừng mật ong nóng hổi.'},
          {'time': '09:30', 'event': 'Chinh phục đỉnh cáp treo Fansipan 3.143m.', 'desc': 'Vượt mây ngắm nhìn toàn cảnh nóc nhà Đông Dương vĩ đại.'},
          {'time': '12:30', 'event': 'Ăn trưa buffet phong phú tại ga cáp treo.', 'desc': 'Nạp năng lượng sau hành trình tham quan.'},
          {'time': '15:00', 'event': 'Tham quan núi Hàm Rồng tuyệt mỹ.', 'desc': 'Ghé cổng trời, vườn lan rực rỡ sắc màu Tây Bắc.'},
          {'time': '18:00', 'event': 'Trải nghiệm tắm lá thuốc Dao Đỏ thảo mộc.', 'desc': 'Thư giãn cơ thể cực kỳ sảng khoái sau ngày trekking.'},
        ],
        2: [
          {'time': '08:00', 'event': 'Dùng điểm tâm sáng, ngắm bình minh.', 'desc': 'Tận hưởng ngày cuối mát mẻ bên sườn đồi.'},
          {'time': '09:30', 'event': 'Tham quan Bản Tả Phìn yên bình.', 'desc': 'Ghé thăm tu viện cổ kính và khám phá văn hóa người Dao đỏ.'},
          {'time': '12:00', 'event': 'Làm thủ tục trả phòng khách sạn.', 'desc': 'Chuẩn bị hành trang di chuyển.'},
          {'time': '13:00', 'event': 'Mua sắm đặc sản hạt dẻ Sapa làm quà.', 'desc': 'Chọn mua các sản phẩm thổ cẩm độc đáo làm kỷ niệm.'},
          {'time': '15:00', 'event': 'Xe đón đoàn tiễn ra sân bay/nhà ga ra về.', 'desc': 'Kết thúc chuyến đi Sapa hùng vĩ tốt đẹp.'},
        ],
      };
    } else if (clean.contains('hạ long') || clean.contains('halong')) {
      return {
        0: [
          {'time': '09:00', 'event': 'Limousine đón đoàn từ điểm hẹn khởi hành.', 'desc': 'Di chuyển nhanh qua cao tốc Hà Nội - Hải Phòng.'},
          {'time': '11:30', 'event': 'Check-in lên du thuyền 5 sao sang trọng.', 'desc': 'Thưởng thức trà chào mừng và nghe phổ biến quy tắc an toàn.'},
          {'time': '12:15', 'event': 'Dùng cơm trưa hải sản thượng hạng.', 'desc': 'Tàu nhổ neo trôi qua hàng ngàn hòn đảo kỳ vĩ của Vịnh.'},
          {'time': '14:30', 'event': 'Chèo thuyền Kayak tham quan Hang Luồn bí hiểm.', 'desc': 'Tự do thám hiểm mặt nước xanh ngọc tuyệt đẹp.'},
          {'time': '16:30', 'event': 'Tham gia lớp học cuộn nem truyền thống.', 'desc': 'Thưởng thức tiệc trà chiều ngắm hoàng hôn buông xuống vịnh.'},
          {'time': '18:30', 'event': 'Bữa tối ẩm thực hải sản biển thượng hạng.', 'desc': 'Bữa tối đẳng cấp lãng mạn giữa đại dương bao la.'},
        ],
        1: [
          {'time': '06:15', 'event': 'Tập dưỡng sinh Thái Cực Quyền đón bình minh.', 'desc': 'Bắt đầu ngày mới dẻo dai khỏe khoắn trên boong tàu.'},
          {'time': '07:30', 'event': 'Dùng điểm tâm sáng nhẹ nhàng.', 'desc': 'Thưởng thức trà, cafe và bánh mì ngọt nóng hổi.'},
          {'time': '09:00', 'event': 'Khám phá Đảo Ti Tốp vách đá dựng đứng.', 'desc': 'Tắm biển trên bãi cát trắng hoặc leo đỉnh ngắm toàn cảnh vịnh.'},
          {'time': '10:30', 'event': 'Thực hiện trả phòng cabin du thuyền.', 'desc': 'Dùng bữa trưa buffet sớm khi tàu quay về bến cảng.'},
          {'time': '12:00', 'event': 'Xe đón tiễn đoàn trở về Hà Nội.', 'desc': 'Kết thúc hải trình du thuyền Vịnh Hạ Long 5 sao trọn vẹn.'},
        ],
      };
    }

    // Default Fallback
    final fallback = <int, List<Map<String, dynamic>>>{};
    for (int d = 0; d < totalDays; d++) {
      fallback[d] = [
        {'time': '08:00', 'event': 'Dùng buffet sáng và tập trung đoàn.', 'desc': 'Bắt đầu ngày thứ ${d + 1} của hành trình du lịch.'},
        {'time': '09:30', 'event': 'Di chuyển tham quan các địa điểm biểu tượng.', 'desc': 'Hướng dẫn viên thuyết minh lịch sử văn hóa.'},
        {'time': '12:00', 'event': 'Ăn trưa cơm văn phòng đặc sản địa phương.', 'desc': 'Thưởng thức bữa trưa ấm cúng cùng đoàn.'},
        {'time': '14:30', 'event': 'Trải nghiệm hoạt động vui chơi giải trí.', 'desc': 'Tự do bơi lội nghỉ ngơi hoặc mua sắm.'},
        {'time': '18:00', 'event': 'Bữa tối lãng mạn cùng ban nhạc sống.', 'desc': 'Tự do dạo chơi phố đêm cảm nhận không khí địa phương.'},
      ];
    }
    return fallback;
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    final hr = int.tryParse(parts[0]) ?? 0;
    final mn = int.tryParse(parts[1]) ?? 0;
    return hr * 60 + mn;
  }

  String _getMilestoneStatus(List<Map<String, dynamic>> milestones, int index) {
    final statusLower = widget.trip.status.toLowerCase();
    if (statusLower == 'đã đi' || statusLower == 'hoàn thành' || statusLower == 'completed') {
      return 'completed';
    }
    if (statusLower == 'sắp tới' && (_simulatedHour == null || _simulatedMinute == null)) {
      return 'upcoming';
    }

    // Process real-time or simulated tracking
    int currentMinutes;
    if (_simulatedHour != null && _simulatedMinute != null) {
      currentMinutes = _simulatedHour! * 60 + _simulatedMinute!;
    } else {
      final now = TimeOfDay.now();
      currentMinutes = now.hour * 60 + now.minute;
    }

    // Find the currently active index
    int activeIndex = -1;
    for (int i = 0; i < milestones.length; i++) {
      final mMin = _timeToMinutes(milestones[i]['time'] as String);
      if (currentMinutes >= mMin) {
        activeIndex = i;
      }
    }

    if (index < activeIndex) {
      return 'completed';
    } else if (index == activeIndex) {
      return 'ongoing';
    } else {
      return 'upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourPackage = _findTourPackage(ref);
    final destinations = ref.watch(destinationsProvider);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroCacheWidth =
        (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round();

    // Map Route Processing
    final List<LatLng> points = [];
    final List<Marker> markers = [];
    if (tourPackage != null) {
      for (final destName in tourPackage.destinations) {
        try {
          final d = destinations.firstWhere(
            (dest) => dest.name.toLowerCase().trim().contains(destName.toLowerCase().trim()) ||
                destName.toLowerCase().trim().contains(dest.name.toLowerCase().trim())
          );
          if (d.latitude != 0.0 && d.longitude != 0.0) {
            final latLng = LatLng(d.latitude, d.longitude);
            points.add(latLng);
            markers.add(
              Marker(
                point: latLng,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 36),
              ),
            );
          }
        } catch (_) {}
      }
    } else {
      try {
        final d = destinations.firstWhere(
          (dest) => dest.name.toLowerCase().trim() == widget.trip.destination.toLowerCase().trim()
        );
        if (d.latitude != 0.0 && d.longitude != 0.0) {
          final latLng = LatLng(d.latitude, d.longitude);
          points.add(latLng);
          markers.add(
            Marker(
              point: latLng,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 36),
            ),
          );
        }
      } catch (_) {}
    }

    final LatLng centerPoint;
    if (points.isNotEmpty) {
      double sumLat = 0;
      double sumLng = 0;
      for (final p in points) {
        sumLat += p.latitude;
        sumLng += p.longitude;
      }
      centerPoint = LatLng(sumLat / points.length, sumLng / points.length);
    } else {
      centerPoint = const LatLng(10.7769, 106.7009); // HCMC
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // A. Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.trip.imagePath,
                  fit: BoxFit.cover,
                  cacheWidth: heroCacheWidth,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey.shade300),
                ),
                // Premium overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // B. Back + Share buttons & Floating Classification Badge
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _floatingButton(
                        icon: Icons.chevron_left,
                        onTap: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              gradient: _getClassificationGradient(),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.trip.isCustom ? 'Tự thiết kế' : 'Gói Tour',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _floatingButton(
                            icon: Icons.share_outlined,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chia sẻ — Tính năng đang phát triển'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // C. DraggableScrollableSheet
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header: destination name + status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trip.destination,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textBlack,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.flight_takeoff_rounded,
                                      size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Khởi hành từ: ${tourPackage?.departure ?? "SGN"}',
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusBgColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.trip.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem(
                          Icons.access_time_rounded,
                          tourPackage?.duration ?? '3N/2Đ',
                          'Thời lượng',
                        ),
                        _infoItem(
                          Icons.flight_takeoff_rounded,
                          tourPackage?.departure ?? 'SGN',
                          'Khởi hành',
                        ),
                        _infoItem(
                          Icons.map_rounded,
                          '${tourPackage?.destinations.length ?? 1} Điểm đến',
                          'Lộ trình',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Booking Info Card
                    const TripSectionHeader(title: 'Thông tin đặt chỗ'),
                    BookingInfoCard(trip: widget.trip),
                    const SizedBox(height: 28),

                    // Booking Status Timeline
                    const TripSectionHeader(title: 'Trạng thái đặt chỗ'),
                    BookingStatusTimeline(status: widget.trip.status),
                    const SizedBox(height: 28),

                    // Lịch trình Tour (Itinerary Timeline with Real-Time Tracking)
                    _buildItineraryTimelineSection(tourPackage),
                    const SizedBox(height: 28),

                    // Bản đồ lộ trình
                    const TripSectionHeader(title: 'Bản đồ lộ trình'),
                    _buildRouteMap(points, markers, centerPoint),
                    const SizedBox(height: 28),

                    // Dịch vụ bao gồm
                    const TripSectionHeader(title: 'Dịch vụ bao gồm'),
                    _buildInclusionsGrid(tourPackage),
                    const SizedBox(height: 28),

                    // Thông tin giá
                    const TripSectionHeader(title: 'Thông tin giá'),
                    _buildPriceCard(tourPackage),
                    const SizedBox(height: 28),

                    // Action Buttons
                    const TripSectionHeader(title: 'Hành động'),
                    const TripActionButtons(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _floatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87),
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
          child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildItineraryTimelineSection(TourPackage? tourPackage) {
    final List<String> destinations = tourPackage?.destinations ?? [widget.trip.destination];
    final totalDays = destinations.length;
    final milestonesData = _getMilestonesForTour(widget.trip.destination, totalDays);
    final isOngoingTrip = widget.trip.status.toLowerCase() == 'đang diễn ra' || widget.trip.status.toLowerCase() == 'ongoing';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TripSectionHeader(title: 'Lịch trình Tour'),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSimulatePanel = !_showSimulatePanel;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _showSimulatePanel ? AppTheme.primaryBlue.withValues(alpha: 0.08) : Colors.white,
                  border: Border.all(color: _showSimulatePanel ? AppTheme.primaryBlue : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 14, color: _showSimulatePanel ? AppTheme.primaryBlue : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Giả lập',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _showSimulatePanel ? AppTheme.primaryBlue : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Real-time tracking status banner if ongoing or simulated
        if (isOngoingTrip || _simulatedHour != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _simulatedHour != null
                        ? '⚡ Chế độ giả lập: Đang chạy ở lúc ${_simulatedHour.toString().padLeft(2, '0')}:${(_simulatedMinute ?? 0).toString().padLeft(2, '0')}'
                        : '⚡ Đang tự động theo dõi lịch trình theo thời gian thực tế',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Time simulation control panel (collapsible)
        if (_showSimulatePanel) _buildSimulationControlPanel(milestonesData),

        // Day Selector ( capsule chips )
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(totalDays, (index) {
              final isSelected = _selectedDayIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      'Ngày ${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Detailed Timeline Milestones list for the selected day
        _buildMilestonesTimeline(milestonesData[_selectedDayIndex] ?? []),
      ],
    );
  }

  Widget _buildSimulationControlPanel(Map<int, List<Map<String, dynamic>>> milestonesData) {
    final List<Map<String, dynamic>> selectOptions = [
      {'label': 'Sáng sớm (07:00)', 'hour': 7, 'min': 0},
      {'label': 'Đón khách (08:45)', 'hour': 8, 'min': 45},
      {'label': 'Hoạt động sáng (10:30)', 'hour': 10, 'min': 30},
      {'label': 'Giờ ăn trưa (12:30)', 'hour': 12, 'min': 30},
      {'label': 'Hoạt động chiều (15:00)', 'hour': 15, 'min': 0},
      {'label': 'Bữa tối (19:00)', 'hour': 19, 'min': 0},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn mốc giờ để thử nghiệm Real-Time Tracking:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectOptions.map((opt) {
              final isCurrent = _simulatedHour == opt['hour'] && _simulatedMinute == opt['min'];
              return ChoiceChip(
                label: Text(opt['label'] as String, style: TextStyle(fontSize: 11, color: isCurrent ? Colors.white : Colors.black87)),
                selected: isCurrent,
                selectedColor: AppTheme.primaryBlue,
                backgroundColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _simulatedHour = opt['hour'] as int;
                      _simulatedMinute = opt['min'] as int;
                    } else {
                      _simulatedHour = null;
                      _simulatedMinute = null;
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (_simulatedHour != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _simulatedHour = null;
                    _simulatedMinute = null;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.red),
                label: const Text('Reset về Giờ thực tế', style: TextStyle(fontSize: 11, color: Colors.red)),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildMilestonesTimeline(List<Map<String, dynamic>> milestones) {
    if (milestones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text('Chưa có thông tin lộ trình chi tiết cho ngày này.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: List.generate(milestones.length, (index) {
        final m = milestones[index];
        final isLast = index == milestones.length - 1;
        final status = _getMilestoneStatus(milestones, index);

        Color timelineColor;
        Widget nodeWidget;

        if (status == 'completed') {
          timelineColor = Colors.green;
          nodeWidget = Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 10, color: Colors.white),
          );
        } else if (status == 'ongoing') {
          timelineColor = const Color(0xFFFF9800);
          nodeWidget = const PulsingIndicator();
        } else {
          timelineColor = Colors.grey.shade300;
          nodeWidget = Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verticle timeline axis
              Column(
                children: [
                  const SizedBox(height: 4),
                  nodeWidget,
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: timelineColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Time milestone card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: status == 'ongoing'
                        ? const Color(0xFFFFF3E0) // Warm orange-ish tint for active
                        : AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: status == 'ongoing'
                          ? const Color(0xFFFFB74D)
                          : Colors.grey.withValues(alpha: 0.05),
                      width: status == 'ongoing' ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            m['time'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: status == 'ongoing' ? const Color(0xFFE65100) : AppTheme.primaryBlue,
                            ),
                          ),
                          if (status == 'ongoing')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.bolt, size: 10, color: Colors.white),
                                  SizedBox(width: 2),
                                  Text(
                                    'Đang diễn ra',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          else if (status == 'completed')
                            const Text(
                              'Đã qua',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m['event'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: status == 'upcoming' ? Colors.grey.shade700 : AppTheme.textBlack,
                        ),
                      ),
                      if (m['desc'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          m['desc'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: status == 'upcoming' ? Colors.grey.shade500 : Colors.grey.shade700,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRouteMap(List<LatLng> points, List<Marker> markers, LatLng centerPoint) {
    if (points.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Chưa có thông tin toạ độ lộ trình',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: centerPoint,
            initialZoom: points.length >= 2 ? 8 : 12,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.onlinetravelagent',
            ),
            if (points.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: AppTheme.primaryBlue,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }

  Widget _buildInclusionsGrid(TourPackage? tourPackage) {
    final List<String> inclusions = tourPackage?.includes ?? [
      'Khách sạn 4 sao',
      'Ăn uống trọn gói',
      'Xe đưa đón hiện đại',
      'Vé tham quan các điểm',
      'Bảo hiểm du lịch',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: inclusions.length,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 64,
      ),
      itemBuilder: (context, index) {
        final item = inclusions[index];
        IconData icon = Icons.check_circle_outline_rounded;
        final lower = item.toLowerCase();
        if (lower.contains('khách sạn') || lower.contains('resort') || lower.contains('bungalow') || lower.contains('cabin') || lower.contains('ks')) {
          icon = Icons.hotel_rounded;
        } else if (lower.contains('ăn') || lower.contains('bữa') || lower.contains('buffet') || lower.contains('uống')) {
          icon = Icons.restaurant_rounded;
        } else if (lower.contains('xe') || lower.contains('bus') || lower.contains('limousine') || lower.contains('cano') || lower.contains('đưa đón')) {
          icon = Icons.directions_bus_rounded;
        } else if (lower.contains('vé') || lower.contains('đò') || lower.contains('cáp treo')) {
          icon = Icons.confirmation_num_rounded;
        } else if (lower.contains('bảo hiểm') || lower.contains('tắm') || lower.contains('y tế')) {
          icon = Icons.health_and_safety_rounded;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceCard(TourPackage? tourPackage) {
    final double price = tourPackage?.price ?? (widget.trip.totalPrice ?? 150.0);
    final double? originalPrice = tourPackage?.originalPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (originalPrice != null && originalPrice > price) ...[
            Row(
              children: [
                Text(
                  '\$${originalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${((originalPrice - price) / originalPrice * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giá vé người lớn',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          if (widget.trip.totalPrice != null) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng thanh toán',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                Text(
                  '\$${widget.trip.totalPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Glowing Pulsing bolt indicator for ongoing events
class PulsingIndicator extends StatefulWidget {
  const PulsingIndicator({super.key});

  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.35);
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFF9800),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.6 - (_controller.value * 0.4)),
                blurRadius: 8 * scale,
                spreadRadius: 3 * _controller.value,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.bolt, size: 10, color: Colors.white),
        );
      },
    );
  }
}
