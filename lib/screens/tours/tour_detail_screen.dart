import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/tour_package.dart';
import '../../providers/trip_provider.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  final TourPackage tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  late DateTime _selectedDate;
  int _guestsCount = 1;
  late bool _guideToggle;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2026, 6, 25);
    _guideToggle = widget.tour.includesGuide;
  }

  double get _totalPrice {
    double singlePrice = widget.tour.price;
    if (_guideToggle && widget.tour.includesGuide) {
      singlePrice += widget.tour.guideFee;
    }
    return singlePrice * _guestsCount;
  }

  // Resolve coordinate markers for popular destinations
  List<LatLng> _getCoordinates() {
    final Map<String, LatLng> coordsMap = {
      'đà nẵng': const LatLng(16.0544, 108.2022),
      'hội an': const LatLng(15.8801, 108.3380),
      'huế': const LatLng(16.4637, 107.5908),
      'phú quốc': const LatLng(10.2899, 103.9840),
      'đà lạt': const LatLng(11.9404, 108.4583),
      'sapa': const LatLng(22.3364, 103.8438),
      'sa pa': const LatLng(22.3364, 103.8438),
      'hạ long': const LatLng(20.9501, 107.0733),
      'vịnh hạ long': const LatLng(20.9501, 107.0733),
      'hà nội': const LatLng(21.0285, 105.8542),
      'hồ chí minh': const LatLng(10.8231, 106.6297),
      'sài gòn': const LatLng(10.8231, 106.6297),
      'nha trang': const LatLng(12.2388, 109.1967),
    };

    final List<LatLng> points = [];
    for (final dest in widget.tour.destinations) {
      final key = dest.toLowerCase().trim();
      LatLng? match;
      coordsMap.forEach((name, coord) {
        if (key.contains(name) || name.contains(key)) {
          match = coord;
        }
      });
      if (match != null) {
        points.add(match!);
      }
    }

    // Default if no coordinates found
    if (points.isEmpty) {
      points.add(const LatLng(16.0544, 108.2022)); // Center at Da Nang
    }
    return points;
  }

  IconData _getInclusionIcon(String title) {
    final key = title.toLowerCase().trim();
    if (key.contains('khách sạn') || key.contains('hotel') || key.contains('phòng') || key.contains('nghỉ')) {
      return Icons.hotel_rounded;
    } else if (key.contains('ăn') || key.contains('food') || key.contains('sáng') || key.contains('trưa') || key.contains('tối') || key.contains('bữa')) {
      return Icons.flatware_rounded;
    } else if (key.contains('xe') || key.contains('đưa đón') || key.contains('bus') || key.contains('di chuyển') || key.contains('vận chuyển')) {
      return Icons.directions_bus_rounded;
    } else if (key.contains('vé') || key.contains('ticket') || key.contains('cổng') || key.contains('tham quan')) {
      return Icons.local_activity_rounded;
    } else if (key.contains('hướng dẫn') || key.contains('guide')) {
      return Icons.people_rounded;
    } else if (key.contains('bảo hiểm')) {
      return Icons.security_rounded;
    } else if (key.contains('nước') || key.contains('uống')) {
      return Icons.local_drink_rounded;
    }
    return Icons.check_circle_rounded;
  }

  // Smart itinerary description generator based on destinations including hour milestones
  List<Map<String, dynamic>> _generateItinerary() {
    final destinations = widget.tour.destinations;
    if (destinations.isEmpty) {
      return [
        {
          'day': 'Ngày 1',
          'title': 'Khởi hành & Khám phá hành trình',
          'desc': 'Bắt đầu chuyến du lịch đầy hứa hẹn. Xe và hướng dẫn viên đón Quý khách tại điểm hẹn, khởi hành tham quan các địa danh danh tiếng và làm thủ tục nhận phòng khách sạn nghỉ ngơi.',
          'milestones': [
            {'time': '08:00', 'event': 'Xe và HDV đón khách tại điểm hẹn, khởi hành.'},
            {'time': '12:00', 'event': 'Ăn trưa tại nhà hàng ẩm thực bản địa.'},
            {'time': '14:00', 'event': 'Làm thủ tục nhận phòng khách sạn & nghỉ ngơi.'},
            {'time': '18:00', 'event': 'Ăn tối ấm cúng và tự do khám phá.'},
          ]
        }
      ];
    }

    final List<Map<String, dynamic>> itinerary = [];
    for (int i = 0; i < destinations.length; i++) {
      final dest = destinations[i];
      if (i == 0) {
        itinerary.add({
          'day': 'Ngày 1',
          'title': 'Chào đón & Trải nghiệm $dest',
          'desc': 'Chào đón Quý khách tại điểm tập trung. Xe đưa Quý khách tham quan các thắng cảnh biểu tượng của $dest, tìm hiểu nét đẹp lịch sử văn hóa địa phương.',
          'milestones': [
            {'time': '08:30', 'event': 'Đón khách tại điểm hẹn, di chuyển đến điểm tham quan đầu tiên.'},
            {'time': '10:00', 'event': 'Khám phá danh lam thắng cảnh nổi bật tại $dest.'},
            {'time': '12:00', 'event': 'Thưởng thức bữa trưa đặc sản vùng miền.'},
            {'time': '14:30', 'event': 'Nhận phòng khách sạn, nghỉ ngơi tự do.'},
            {'time': '18:00', 'event': 'Bữa tối ngon miệng và dạo chơi phố phường về đêm.'},
          ]
        });
      } else {
        itinerary.add({
          'day': 'Ngày ${i + 1}',
          'title': 'Hành trình di sản tại $dest',
          'desc': 'Di chuyển khám phá mảnh đất $dest đầy quyến rũ và giàu bản sắc văn hóa.',
          'milestones': [
            {'time': '07:30', 'event': 'Dùng điểm tâm sáng buffet tại khách sạn.'},
            {'time': '09:00', 'event': 'Khởi hành hành trình khám phá chiều sâu $dest.'},
            {'time': '12:30', 'event': 'Nghỉ ngơi và dùng cơm trưa tại nhà hàng đặc sản.'},
            {'time': '15:00', 'event': 'Tham gia các hoạt động vui chơi giải trí địa phương.'},
            {'time': '18:30', 'event': 'Dùng bữa tối hải sản thịnh soạn, tự do tham quan phố đêm.'},
          ]
        });
      }
    }

    // Add a wrap-up day
    itinerary.add({
      'day': 'Ngày ${destinations.length + 1}',
      'title': 'Mua sắm đặc sản & Kết thúc hành trình',
      'desc': 'Thư giãn nghỉ ngơi, chuẩn bị hành lý trở về.',
      'milestones': [
        {'time': '07:30', 'event': 'Ăn sáng, dạo phố nhâm nhi cà phê sáng bình yên.'},
        {'time': '10:00', 'event': 'Tự do mua sắm các món quà lưu niệm ý nghĩa.'},
        {'time': '11:30', 'event': 'Làm thủ tục trả phòng khách sạn.'},
        {'time': '12:30', 'event': 'Bữa trưa nhẹ nhàng ấm cúng.'},
        {'time': '14:30', 'event': 'Xe tiễn đoàn ra sân bay/nhà ga, kết thúc tour tốt đẹp.'},
      ]
    });

    return itinerary;
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = _getCoordinates();
    final center = coordinates.first;
    final itinerary = _generateItinerary();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Parallax Header Image
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.primaryBlue,
                elevation: 0,
                leadingWidth: 70,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        width: 44,
                        height: 44,
                        color: Colors.black.withValues(alpha: 0.4),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    key: const ValueKey('tour_detail_actions'),
                    child: ClipOval(
                      child: Container(
                        width: 44,
                        height: 44,
                        color: Colors.black.withValues(alpha: 0.4),
                        child: IconButton(
                          icon: Icon(
                            widget.tour.isPopular ? Icons.favorite : Icons.favorite_border,
                            color: widget.tour.isPopular ? Colors.red : Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            // Quick interactive mock toast
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.tour.isPopular
                                      ? 'Đã xóa tour khỏi danh sách yêu thích'
                                      : 'Đã lưu tour vào danh sách yêu thích',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.tour.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      // Top dark overlay for actions visibility
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom gradient overlay for name legibility
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 160,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Popular badge and name
                      Positioned(
                        bottom: 30,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.tour.isPopular)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.stars, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'BÁN CHẠY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              widget.tour.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main Content Body
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      // A. Overview Info Row
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildOverviewItem(
                              Icons.access_time_filled_rounded,
                              'Thời gian',
                              widget.tour.duration,
                            ),
                            _buildOverviewDivider(),
                            _buildOverviewItem(
                              Icons.flight_takeoff_rounded,
                              'Khởi hành',
                              widget.tour.departure,
                            ),
                            _buildOverviewDivider(),
                            _buildOverviewItem(
                              Icons.map_rounded,
                              'Điểm đến',
                              '${widget.tour.destinations.length} Tỉnh thành',
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(height: 1, color: AppTheme.backgroundGray),
                      ),
                      const SizedBox(height: 20),

                      // Content Container inside body
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // B. Selection Section: Dates & Guests
                          const Text(
                            'Lịch trình & Đặt khách',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Date Picker Card
                              Expanded(
                                flex: 5,
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: AppTheme.primaryBlue,
                                              onPrimary: Colors.white,
                                              onSurface: AppTheme.textBlack,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryBlue, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Ngày đi', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                              const SizedBox(height: 2),
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Guests Stepper Card
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Decrement
                                      InkWell(
                                        onTap: () {
                                          if (_guestsCount > 1) {
                                            setState(() {
                                              _guestsCount--;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.backgroundGray,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.remove, size: 16, color: AppTheme.darkGray),
                                        ),
                                      ),
                                      // Value
                                      Column(
                                        children: [
                                          const Text('Số khách', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                          Text(
                                            '$_guestsCount',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      // Increment
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _guestsCount++;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.backgroundGray,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add, size: 16, color: AppTheme.darkGray),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // C. Description Section
                          const Text(
                            'Giới thiệu hành trình',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.tour.description,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // D. Guide Switch (If tour package includes dynamic guides)
                          if (widget.tour.includesGuide) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.backgroundGray,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.supervisor_account_rounded, color: AppTheme.primaryBlue, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Hướng dẫn viên đi kèm',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '+ \$${widget.tour.guideFee.toStringAsFixed(0)} / Khách',
                                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _guideToggle,
                                    activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
                                    activeThumbColor: AppTheme.primaryBlue,
                                    onChanged: (val) {
                                      setState(() {
                                        _guideToggle = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // E. Inclusions Grid (Dịch vụ bao gồm)
                          const Text(
                            'Dịch vụ đã bao gồm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: widget.tour.includes.length,
                            itemBuilder: (context, index) {
                              final item = widget.tour.includes[index];
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _getInclusionIcon(item),
                                        color: AppTheme.primaryBlue,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 12,
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
                          ),
                          const SizedBox(height: 28),

                          // F. Detailed Daily Itinerary
                          const Text(
                            'Lịch trình chi tiết từng ngày',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: itinerary.length,
                            itemBuilder: (context, index) {
                              final step = itinerary[index];
                              final isLast = index == itinerary.length - 1;
                              final milestones = step['milestones'] as List<Map<String, String>>;

                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left Column: Dot & Connecting Line
                                    Column(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppTheme.primaryBlue, width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                                blurRadius: 6,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isLast)
                                          Expanded(
                                            child: Container(
                                              width: 2,
                                              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    // Right Column: Day details card
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 20),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  step['day']!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryBlue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Icon(Icons.circle_notifications_rounded, color: AppTheme.primaryBlue, size: 16),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              step['title']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: AppTheme.textBlack,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              step['desc']!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(height: 1, color: AppTheme.backgroundGray),
                                            const SizedBox(height: 12),
                                            // Render detailed hourly milestones
                                            ...milestones.map((m) => Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      m['time']!,
                                                      style: const TextStyle(
                                                        color: AppTheme.primaryBlue,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 2),
                                                      child: Text(
                                                        m['event']!,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade800,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // G. Route Map
                          const Text(
                            'Vị trí & Lộ trình di chuyển',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: center,
                                  initialZoom: coordinates.length > 1 ? 9 : 12,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.onlinetravelagent',
                                  ),
                                  // Connect route paths if multiple destinations
                                  if (coordinates.length > 1)
                                    PolylineLayer(
                                      polylines: <Polyline<Object>>[
                                        Polyline(
                                          points: coordinates,
                                          strokeWidth: 4,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ],
                                    ),
                                  MarkerLayer(
                                    markers: coordinates.map((pt) {
                                      final int idx = coordinates.indexOf(pt);
                                      return Marker(
                                        point: pt,
                                        width: 32,
                                        height: 32,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const Icon(
                                              Icons.location_on_sharp,
                                              color: Colors.red,
                                              size: 32,
                                            ),
                                            Positioned(
                                              top: 2,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '${idx + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 120), // Bottom padding for sheet
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),

          // 3. Floating Bottom Purchase Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -6),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '\$${widget.tour.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'x $_guestsCount khách',
                                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${_totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 56,
                      width: 190,
                      child: ElevatedButton(
                        onPressed: _bookTour,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 3,
                          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Đặt Tour Ngay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textBlack),
        ),
      ],
    );
  }

  Widget _buildOverviewDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  void _bookTour() async {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final String guestsLabel = '$_guestsCount Người';

    final success = await ref.read(tripsProvider.notifier).bookTour(
          tourId: widget.tour.id,
          date: formattedDate,
          guests: guestsLabel,
          totalPrice: _totalPrice,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt tour thành công!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt tour thất bại.')),
        );
      }
    }
  }
}
