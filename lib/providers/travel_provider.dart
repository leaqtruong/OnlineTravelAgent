import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../models/document_item.dart';
import '../models/trip.dart';
import '../models/user_profile.dart';
import '../services/travel_api_service.dart';

class TravelProvider with ChangeNotifier {
  TravelProvider({TravelApiService? apiService})
      : _api = apiService ?? TravelApiService() {
    initialize();
  }

  final TravelApiService _api;

  final List<Destination> _destinations = [];
  final List<Destination> _recommended = [];
  final List<Trip> _trips = [];
  final List<DocumentItem> _documents = [];
  List<String> _categories = const [
    'Tất cả',
    'Địa điểm',
    'Khách sạn',
    'Bãi biển',
    'Máy bay',
    'Ẩm thực',
  ];

  Destination? _selectedDestination;
  UserProfile _profile = const UserProfile(name: 'User', email: '');
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String? _errorMessage;
  bool _isLoading = true;
  bool _isBusy = false;

  late List<Destination> _destinationsView =
      UnmodifiableListView(_destinations);
  late List<Destination> _recommendedView = UnmodifiableListView(_recommended);
  late List<Trip> _tripsView = UnmodifiableListView(_trips);
  late List<DocumentItem> _documentsView = UnmodifiableListView(_documents);

  List<Trip>? _upcomingTripsCache;
  List<Trip>? _historyTripsCache;
  List<Destination>? _favoritesCache;
  List<Destination>? _filteredDestinationsCache;
  List<Destination>? _filteredRecommendedCache;

  String _lastFilterQuery = '';
  String _lastFilterCategory = 'Tất cả';

  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  Destination? get selectedDestination => _selectedDestination;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  UserProfile get profile => _profile;
  List<String> get categories => _categories;

  List<DocumentItem> get documents => _documentsView;
  List<Destination> get destinations => _destinationsView;
  List<Destination> get recommended => _recommendedView;
  List<Trip> get trips => _tripsView;

  List<Trip> get upcomingTrips {
    _upcomingTripsCache ??= UnmodifiableListView(
      _trips.where((t) => t.isUpcoming).toList(growable: false),
    );
    return _upcomingTripsCache!;
  }

  List<Trip> get historyTrips {
    _historyTripsCache ??= UnmodifiableListView(
      _trips.where((t) => !t.isUpcoming).toList(growable: false),
    );
    return _historyTripsCache!;
  }

  List<Destination> get favorites {
    _favoritesCache ??= UnmodifiableListView(
      _destinations.where((d) => d.isFavorite).toList(growable: false),
    );
    return _favoritesCache!;
  }

  List<Destination> get filteredDestinations {
    _refreshFilterIfNeeded();
    _filteredDestinationsCache ??= UnmodifiableListView(
      _destinations.where(_destinationMatchesFilters).toList(growable: false),
    );
    return _filteredDestinationsCache!;
  }

  List<Destination> get filteredRecommended {
    _refreshFilterIfNeeded();
    _filteredRecommendedCache ??= UnmodifiableListView(
      _recommended.where(_destinationMatchesFilters).toList(growable: false),
    );
    return _filteredRecommendedCache!;
  }

  bool _destinationMatchesFilters(Destination d) {
    final query = _lastFilterQuery;
    final matchesSearch = query.isEmpty ||
        d.name.toLowerCase().contains(query) ||
        d.location.toLowerCase().contains(query);
    final matchesCategory =
        _lastFilterCategory == 'Tất cả' || d.category == _lastFilterCategory;
    return matchesSearch && matchesCategory;
  }

  void _refreshFilterIfNeeded() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    if (_lastFilterQuery == normalizedQuery &&
        _lastFilterCategory == _selectedCategory) {
      return;
    }
    _lastFilterQuery = normalizedQuery;
    _lastFilterCategory = _selectedCategory;
    _filteredDestinationsCache = null;
    _filteredRecommendedCache = null;
  }

  void _syncBaseViews() {
    _destinationsView = UnmodifiableListView(_destinations);
    _recommendedView = UnmodifiableListView(_recommended);
    _tripsView = UnmodifiableListView(_trips);
    _documentsView = UnmodifiableListView(_documents);
  }

  void _invalidateDerivedCaches({bool includeTrips = false}) {
    _favoritesCache = null;
    _filteredDestinationsCache = null;
    _filteredRecommendedCache = null;
    if (includeTrips) {
      _upcomingTripsCache = null;
      _historyTripsCache = null;
    }
  }

  Future<void> initialize({bool force = false}) async {
    if (_isBusy) {
      return;
    }
    if (!force && _destinations.isNotEmpty) {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _isBusy = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bootstrap = await _api.fetchBootstrap();
      _destinations
        ..clear()
        ..addAll(bootstrap.destinations);
      _recommended
        ..clear()
        ..addAll(bootstrap.recommended);
      _trips
        ..clear()
        ..addAll(bootstrap.trips);
      _documents
        ..clear()
        ..addAll(bootstrap.documents);
      _categories =
          bootstrap.categories.isEmpty ? _categories : bootstrap.categories;
      _profile = bootstrap.profile;

      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
    } catch (e) {
      _errorMessage = 'Không kết nối được backend. Đang dùng dữ liệu local.';
      if (_destinations.isEmpty) {
        _loadFallbackData();
      }
      debugPrint('initialize error: $e');
    } finally {
      _isBusy = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDestination(Destination? destination) {
    if (_selectedDestination?.id == destination?.id) {
      return;
    }
    _selectedDestination = destination;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) {
      return;
    }
    _searchQuery = query;
    _refreshFilterIfNeeded();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }
    _selectedCategory = category;
    _refreshFilterIfNeeded();
    notifyListeners();
  }

  Future<void> toggleFavorite(String destinationId) async {
    final destinationIndex =
        _destinations.indexWhere((d) => d.id == destinationId);
    if (destinationIndex == -1) {
      return;
    }

    final current = _destinations[destinationIndex];
    final targetValue = !current.isFavorite;
    _setFavoriteLocal(destinationId, targetValue);
    _syncBaseViews();
    _invalidateDerivedCaches();
    notifyListeners();

    try {
      await _api.setFavorite(destinationId, targetValue);
    } catch (_) {
      _setFavoriteLocal(destinationId, current.isFavorite);
      _syncBaseViews();
      _invalidateDerivedCaches();
      notifyListeners();
    }
  }

  Future<bool> bookSelectedDestination({String? date, String? guests}) async {
    final destination = _selectedDestination;
    if (destination == null) {
      return false;
    }

    try {
      final trip = await _api.bookTrip(
          destinationId: destination.id, date: date, guests: guests);
      _trips.insert(0, trip);
      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bookFlight({required String flightId, required String date, required String guests}) async {
    try {
      final trip = await _api.bookFlight(flightId: flightId, date: date, guests: guests);
      _trips.insert(0, trip);
      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProfile(
      {required String name, required String email}) async {
    try {
      final updated = await _api.updateProfile(name: name, email: email);
      _profile = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addDocument({
    required String title,
    required String description,
    String icon = 'description',
    String color = '#176FF2',
  }) async {
    try {
      final doc = await _api.addDocument(
        title: title,
        description: description,
        icon: icon,
        color: color,
      );
      _documents.insert(0, doc);
      _syncBaseViews();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setFavoriteLocal(String destinationId, bool isFavorite) {
    final destinationIndex =
        _destinations.indexWhere((d) => d.id == destinationId);
    if (destinationIndex != -1) {
      _destinations[destinationIndex] =
          _destinations[destinationIndex].copyWith(isFavorite: isFavorite);
    }

    final recommendedIndex =
        _recommended.indexWhere((d) => d.id == destinationId);
    if (recommendedIndex != -1) {
      _recommended[recommendedIndex] =
          _recommended[recommendedIndex].copyWith(isFavorite: isFavorite);
    }

    if (_selectedDestination?.id == destinationId) {
      _selectedDestination =
          _selectedDestination!.copyWith(isFavorite: isFavorite);
    }
  }

  void _loadFallbackData() {
    _destinations
      ..clear()
      ..addAll(
        [
          Destination(
            id: 'dalat',
            name: 'Đà Lạt',
            location: 'Lâm Đồng, VN',
            rating: '4.1',
            duration: '4N/5D',
            imagePath: 'assets/images/dalat_image.jpg',
            description:
                'Đà Lạt là thành phố ngàn hoa với khí hậu mát mẻ quanh năm. Đây là địa điểm lý tưởng cho các cặp đôi và gia đình muốn tìm kiếm sự yên bình.',
            price: '199',
            reviewsCount: '355',
            category: 'Địa điểm',
            latitude: 11.9404,
            longitude: 108.4583,
          ),
          Destination(
            id: 'phuquoc',
            name: 'Đảo Phú Quốc',
            location: 'Kiên Giang, VN',
            rating: '4.5',
            duration: '2N/3D',
            imagePath: 'assets/images/phuquoc_image.jpg',
            description:
                'Phú Quốc nổi tiếng với những bãi biển xanh ngắt và cát trắng mịn. Du khách có thể thưởng thức hải sản tươi ngon và tham gia các hoạt động lặn ngắm san hô.',
            price: '250',
            reviewsCount: '1.2k',
            category: 'Bãi biển',
            latitude: 10.2270,
            longitude: 103.9670,
          ),
          Destination(
            id: 'hoian',
            name: 'Hội An',
            location: 'Quảng Nam, VN',
            rating: '4.8',
            duration: '2N/1Đ',
            imagePath: 'assets/images/hoian_image.webp',
            description:
                'Phố cổ Hội An là di sản văn hóa thế giới với những con phố đèn lồng lung linh.',
            price: '150',
            reviewsCount: '800',
            category: 'Địa điểm',
            latitude: 15.8801,
            longitude: 108.3380,
          ),
        ],
      );

    _recommended
      ..clear()
      ..addAll(
        [
          _destinations[2],
          _destinations[0],
        ],
      );

    _trips
      ..clear()
      ..addAll(
        [
          Trip(
            id: 'local-trip-1',
            destination: 'Đảo Phú Quốc',
            location: 'Kiên Giang, VN',
            date: '20/05/2026 - 23/05/2026',
            guests: '2 Người lớn',
            status: 'Sắp tới',
            imagePath: 'assets/images/phuquoc_image.jpg',
            isUpcoming: true,
          ),
        ],
      );

    _documents
      ..clear()
      ..addAll(
        [
          DocumentItem(
            id: 'local-doc-1',
            title: 'Hộ chiếu',
            description: 'Hết hạn: 12/2030',
            icon: Icons.description,
            color: const Color(0xFF176FF2),
            iconName: 'description',
            colorHex: '#176FF2',
          ),
        ],
      );

    _profile = const UserProfile(
      name: 'Nguyễn Văn A',
      email: 'vanya.traveler@email.com',
    );

    _syncBaseViews();
    _invalidateDerivedCaches(includeTrips: true);
  }
}
