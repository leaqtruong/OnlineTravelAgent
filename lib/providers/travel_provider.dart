import 'dart:collection';

import 'package:flutter/material.dart';

import '../data/fallback_data.dart';
import '../models/destination.dart';
import '../models/document_item.dart';
import '../models/trip.dart';
import '../models/user_profile.dart';
import '../models/hotel.dart';
import '../models/tour_package.dart';
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
  final List<Hotel> _hotels = [];
  final List<TourPackage> _tourPackages = [];

  static const List<String> _defaultCategories = [
    'Tất cả',
    'Địa điểm',
    'Khách sạn',
    'Máy bay',
    'Ẩm thực',
  ];

  static const Set<String> _hiddenCategories = {'Bãi biển'};

  List<String> _categories = _defaultCategories;

  Destination? _selectedDestination;
  UserProfile _profile = const UserProfile(name: 'User', email: '');
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String? _errorMessage;
  bool _isLoading = true;
  bool _isBusy = false;

  late List<Destination> _destinationsView = UnmodifiableListView(
    _destinations,
  );
  late List<Destination> _recommendedView = UnmodifiableListView(_recommended);
  late List<Trip> _tripsView = UnmodifiableListView(_trips);
  late List<DocumentItem> _documentsView = UnmodifiableListView(_documents);
  late List<Hotel> _hotelsView = UnmodifiableListView(_hotels);
  late List<TourPackage> _tourPackagesView = UnmodifiableListView(
    _tourPackages,
  );

  List<Trip>? _ongoingTripsCache;
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
  List<Hotel> get hotels => _hotelsView;
  List<TourPackage> get tourPackages => _tourPackagesView;

  static List<String> _orderedCategories(List<String> categories) {
    if (categories.isEmpty) {
      return _defaultCategories;
    }

    final remaining = LinkedHashSet<String>.of(
      categories.where((category) => !_hiddenCategories.contains(category)),
    );
    return [
      for (final category in _defaultCategories)
        if (remaining.remove(category)) category,
      ...remaining,
    ];
  }

  List<Trip> get ongoingTrips {
    _ongoingTripsCache ??= UnmodifiableListView(
      _trips.where((t) => t.status.toLowerCase() == 'đang diễn ra' || t.status.toLowerCase() == 'ongoing').toList(growable: false),
    );
    return _ongoingTripsCache!;
  }

  List<Trip> get upcomingTrips {
    _upcomingTripsCache ??= UnmodifiableListView(
      _trips.where((t) => t.isUpcoming && t.status.toLowerCase() != 'đang diễn ra' && t.status.toLowerCase() != 'ongoing').toList(growable: false),
    );
    return _upcomingTripsCache!;
  }

  List<Trip> get historyTrips {
    _historyTripsCache ??= UnmodifiableListView(
      _trips.where((t) => !t.isUpcoming && t.status.toLowerCase() != 'đang diễn ra' && t.status.toLowerCase() != 'ongoing').toList(growable: false),
    );
    return _historyTripsCache!;
  }

  List<Destination> get favorites {
    _favoritesCache ??= UnmodifiableListView(
      _destinations.where((d) => d.isFavorite).toList(growable: false),
    );
    return _favoritesCache!;
  }

  List<Destination> get foodDestinations {
    return UnmodifiableListView(
      _destinations.where((d) => d.category == 'Ẩm thực').toList(growable: false),
    );
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
    final matchesSearch =
        query.isEmpty ||
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
    _hotelsView = UnmodifiableListView(_hotels);
    _tourPackagesView = UnmodifiableListView(_tourPackages);
  }

  void _invalidateDerivedCaches({bool includeTrips = false}) {
    _favoritesCache = null;
    _filteredDestinationsCache = null;
    _filteredRecommendedCache = null;
    if (includeTrips) {
      _ongoingTripsCache = null;
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
      _hotels
        ..clear()
        ..addAll(bootstrap.hotels);
      _tourPackages
        ..clear()
        ..addAll(bootstrap.tourPackages);
      _categories = _orderedCategories(bootstrap.categories);
      _profile = bootstrap.profile;

      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
    } catch (e) {
      _errorMessage = 'Không kết nối được backend. Đang dùng dữ liệu local.';
      _loadFallbackData();
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
    final destinationIndex = _destinations.indexWhere(
      (d) => d.id == destinationId,
    );
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

  Future<bool> bookSelectedDestination({String? date, String? guests, double? totalPrice}) async {
    final destination = _selectedDestination;
    if (destination == null) {
      return false;
    }

    try {
      final trip = await _api.bookTrip(
        destinationId: destination.id,
        date: date,
        guests: guests,
        totalPrice: totalPrice,
      );
      _trips.insert(0, trip);
      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bookFlight({
    required String flightId,
    required String date,
    required String guests,
  }) async {
    try {
      final trip = await _api.bookFlight(
        flightId: flightId,
        date: date,
        guests: guests,
      );
      _trips.insert(0, trip);
      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bookHotel({
    required String roomId,
    required String checkIn,
    required String checkOut,
    required String guests,
  }) async {
    try {
      final trip = await _api.bookHotel(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
      );
      _trips.insert(0, trip);
      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bookTour({
    required String tourId,
    required String date,
    required String guests,
    double? totalPrice,
  }) async {
    try {
      final trip = await _api.bookTour(
        tourId: tourId,
        date: date,
        guests: guests,
        totalPrice: totalPrice,
      );
      _trips.insert(0, trip);
      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createCustomTour({
    required String destination,
    required String location,
    required String date,
    required String guests,
    required String imagePath,
    List<String>? flightIds,
    List<String>? hotelIds,
    String? roomId,
    double? totalPrice,
  }) async {
    try {
      final trip = await _api.createCustomTour(
        destination: destination,
        location: location,
        date: date,
        guests: guests,
        imagePath: imagePath,
        flightIds: flightIds,
        hotelIds: hotelIds,
        roomId: roomId,
        totalPrice: totalPrice,
      );
      _trips.insert(0, trip);
      _syncBaseViews();
      _invalidateDerivedCaches(includeTrips: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
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
    final destinationIndex = _destinations.indexWhere(
      (d) => d.id == destinationId,
    );
    if (destinationIndex != -1) {
      _destinations[destinationIndex] = _destinations[destinationIndex]
          .copyWith(isFavorite: isFavorite);
    }

    final recommendedIndex = _recommended.indexWhere(
      (d) => d.id == destinationId,
    );
    if (recommendedIndex != -1) {
      _recommended[recommendedIndex] = _recommended[recommendedIndex].copyWith(
        isFavorite: isFavorite,
      );
    }

    if (_selectedDestination?.id == destinationId) {
      _selectedDestination = _selectedDestination!.copyWith(
        isFavorite: isFavorite,
      );
    }
  }

  void _loadFallbackData() {
    _destinations
      ..clear()
      ..addAll(FallbackData.destinations());
    _recommended
      ..clear()
      ..addAll(FallbackData.recommended());
    _trips
      ..clear()
      ..addAll(FallbackData.trips());
    _documents
      ..clear()
      ..addAll(FallbackData.documents());
    _profile = FallbackData.profile();
    _hotels
      ..clear()
      ..addAll(FallbackData.hotels());
    _tourPackages
      ..clear()
      ..addAll(FallbackData.tourPackages());

    _syncBaseViews();
    _invalidateDerivedCaches(includeTrips: true);
  }
}
