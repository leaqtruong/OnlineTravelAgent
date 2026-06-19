import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_theme.dart';
import '../models/destination.dart';
import '../models/document_item.dart';
import '../models/flight.dart';
import '../models/trip.dart';
import '../models/hotel.dart';
import '../models/review.dart';
import '../models/tour_package.dart';
import '../models/trip_schedule.dart';

class BootstrapData {
  final List<String> categories;
  final List<Destination> destinations;
  final List<Destination> recommended;
  final List<Trip> trips;
  final List<DocumentItem> documents;
  final List<Hotel> hotels;
  final List<TourPackage> tourPackages;

  BootstrapData({
    required this.categories,
    required this.destinations,
    required this.recommended,
    required this.trips,
    required this.documents,
    required this.hotels,
    required this.tourPackages,
  });
}

class TravelApiService {
  TravelApiService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl();

  final String _baseUrl;
  String? token;

  static String _defaultBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await http.get(_uri(path), headers: _headers).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getList(String path) async {
    final response = await http.get(_uri(path), headers: _headers).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patchJson(String path, Map<String, dynamic> body) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<BootstrapData> fetchBootstrap() async {
    final data = await _getJson('/api/bootstrap');
    return BootstrapData(
      categories: ((data['categories'] as List?) ?? []).cast<String>().toList(growable: false),
      destinations: _parseList(data['destinations'], Destination.fromJson),
      recommended: _parseList(data['recommended'], Destination.fromJson),
      trips: _parseList(data['trips'], Trip.fromJson),
      documents: _parseList(data['documents'], DocumentItem.fromJson),
      hotels: _parseList(data['hotels'], Hotel.fromJson),
      tourPackages: _parseList(data['tourPackages'], TourPackage.fromJson),
    );
  }

  Future<Destination> setFavorite(String destinationId, bool isFavorite) async {
    final data = await _patchJson('/api/destinations/$destinationId/favorite', {'isFavorite': isFavorite});
    return Destination.fromJson(data);
  }

  Future<Trip> bookTrip({required String destinationId, String? date, String? guests, double? totalPrice}) async {
    final body = <String, dynamic>{
      'destinationId': destinationId,
      'date': date,
      'guests': guests,
    };
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _postJson('/api/trips/book', body);
    return Trip.fromJson(data);
  }

  Future<List<Flight>> searchFlights(String? departure, String? arrival) async {
    String query = '';
    if (departure != null && arrival != null) {
      query = '?departure=$departure&arrival=$arrival';
    } else if (departure != null) {
      query = '?departure=$departure';
    } else if (arrival != null) {
      query = '?arrival=$arrival';
    }
    final response = await http.get(_uri('/api/flights/search$query'), headers: _headers).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    final List<dynamic> raw = jsonDecode(response.body);
    return raw.map((e) => Flight.fromJson(e)).toList();
  }

  Future<Trip> bookFlight({required String flightId, required String date, required String guests}) async {
    final data = await _postJson('/api/trips/book-flight', {
      'flightId': flightId, 'date': date, 'guests': guests,
    });
    return Trip.fromJson(data);
  }

  Future<DocumentItem> addDocument({required String title, required String description, required String icon, required String color}) async {
    final data = await _postJson('/api/documents', {
      'title': title, 'description': description, 'icon': icon, 'color': color,
    });
    return DocumentItem.fromJson(data);
  }

  Future<bool> deleteDocument(String documentId) async {
    final response = await http.delete(_uri('/api/documents/$documentId'), headers: _headers).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return true;
  }

  Future<ReviewResponse> getReviews({required String targetType, required String targetId}) async {
    final data = await _getJson('/api/reviews?targetType=$targetType&targetId=$targetId');
    return ReviewResponse.fromJson(data);
  }

  Future<Review> createReview({required String targetType, required String targetId, required int rating, required String comment}) async {
    final data = await _postJson('/api/reviews', {
      'targetType': targetType, 'targetId': targetId, 'rating': rating, 'comment': comment,
    });
    return Review.fromJson(data);
  }

  Future<bool> deleteReview(String reviewId) async {
    final response = await http.delete(
      _uri('/api/reviews/$reviewId'),
      headers: _headers,
    ).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return true;
  }

  Future<Trip> bookHotel({required String roomId, required String checkIn, required String checkOut, required String guests}) async {
    final data = await _postJson('/api/hotels/book', {
      'roomId': roomId, 'checkIn': checkIn, 'checkOut': checkOut, 'guests': guests,
    });
    return Trip.fromJson(data);
  }

  Future<Trip> bookTour({required String tourId, required String date, required String guests, double? totalPrice}) async {
    final body = <String, dynamic>{
      'tourId': tourId, 'date': date, 'guests': guests,
    };
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _postJson('/api/tours/book', body);
    return Trip.fromJson(data);
  }

  Future<Trip> createCustomTour({
    required String destination, required String location, required String date,
    required String guests, required String imagePath,
    List<String>? flightIds, List<String>? hotelIds, String? roomId, double? totalPrice,
  }) async {
    final body = <String, dynamic>{
      'destination': destination, 'location': location, 'date': date,
      'guests': guests, 'imagePath': imagePath,
    };
    if (flightIds != null) body['flightIds'] = flightIds;
    if (hotelIds != null) body['hotelIds'] = hotelIds;
    if (roomId != null) body['roomId'] = roomId;
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _postJson('/api/trips/custom-tour', body);
    return Trip.fromJson(data);
  }

  Future<TripSchedule> fetchTripSchedule(String tripId) async {
    final data = await _getJson('/api/trips/$tripId/schedule');
    return TripSchedule.fromJson(data);
  }

  Future<Map<String, dynamic>> checkPromoCode(String code) async {
    final response = await http.get(_uri('/api/promo-codes/check?code=$code'), headers: _headers).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Auth ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    return await _postJson('/api/auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> register({required String name, required String email, required String password}) async {
    return await _postJson('/api/auth/register', {'name': name, 'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> becomePartner() async {
    return await _postJson('/api/auth/become-partner', {});
  }

  Future<List<Hotel>> getPartnerHotels() async {
    final data = await _getList('/api/partner/hotels');
    return _parseList(data, Hotel.fromJson);
  }

  Future<Hotel> createPartnerHotel(Map<String, dynamic> data) async {
    final res = await _postJson('/api/partner/hotels', data);
    return Hotel.fromJson(res);
  }

  Future<List<TourPackage>> getPartnerTours() async {
    final data = await _getList('/api/partner/tours');
    return _parseList(data, TourPackage.fromJson);
  }

  Future<TourPackage> createPartnerTour(Map<String, dynamic> data) async {
    final res = await _postJson('/api/partner/tours', data);
    return TourPackage.fromJson(res);
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    return ((raw as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  static void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception('API error ${response.statusCode}: ${response.body}');
  }
}
