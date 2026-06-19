import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';
import '../../models/hotel.dart';
import '../../models/tour_package.dart';

class PartnerDashboardScreen extends ConsumerStatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  ConsumerState<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends ConsumerState<PartnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isPartner = false;
  
  List<Hotel> _hotels = [];
  List<TourPackage> _tours = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      final hotels = await api.getPartnerHotels();
      final tours = await api.getPartnerTours();
      setState(() {
        _hotels = hotels;
        _tours = tours;
        _isPartner = true;
      });
    } catch (e) {
      // Assuming 403 Forbidden means not a partner yet
      setState(() => _isPartner = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _becomePartner() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      await api.becomePartner();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký đối tác thành công!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi đăng ký đối tác')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createHotel() async {
    final api = ref.read(apiProvider);
    try {
      await api.createPartnerHotel({
        'name': 'Khách sạn Partner ${DateTime.now().second}',
        'location': 'Hà Nội',
        'address': 'Khu trung tâm',
        'priceFrom': 500000.0,
      });
      _loadData();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _createTour() async {
    final api = ref.read(apiProvider);
    try {
      await api.createPartnerTour({
        'name': 'Tour Đặc Biệt ${DateTime.now().second}',
        'description': 'Tour trải nghiệm do đối tác cung cấp.',
        'price': 1500000.0,
      });
      _loadData();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isPartner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trở thành Đối tác')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.handshake_rounded, size: 80, color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              const Text('Bạn chưa phải là đối tác', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Đăng ký để đăng bán dịch vụ của bạn trên OTA!'),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _becomePartner,
                child: const Text('Đăng ký ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(text: 'Khách sạn'),
            Tab(text: 'Tours'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHotelList(),
          _buildTourList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () {
          if (_tabController.index == 0) {
            _createHotel();
          } else {
            _createTour();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(_tabController.index == 0 ? 'Thêm Khách sạn' : 'Thêm Tour', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHotelList() {
    if (_hotels.isEmpty) {
      return const Center(child: Text('Chưa có khách sạn nào.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hotels.length,
      itemBuilder: (context, index) {
        final hotel = _hotels[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network('https://picsum.photos/seed/${hotel.id}/100/100', width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.hotel, size: 40)),
            ),
            title: Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${hotel.location} • ${hotel.priceFrom} VND'),
          ),
        );
      },
    );
  }

  Widget _buildTourList() {
    if (_tours.isEmpty) {
      return const Center(child: Text('Chưa có tour nào.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tours.length,
      itemBuilder: (context, index) {
        final tour = _tours[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network('https://picsum.photos/seed/${tour.id}/100/100', width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.tour, size: 40)),
            ),
            title: Text(tour.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${tour.duration} • ${tour.price} VND'),
          ),
        );
      },
    );
  }
}
