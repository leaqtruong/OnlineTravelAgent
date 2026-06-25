import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/exceptions.dart';
import '../core/theme/app_theme.dart';
import '../models/destination.dart';
import '../models/document_item.dart';
import '../models/flight.dart';
import '../models/trip.dart';
import '../models/hotel.dart';
import '../models/review.dart';
import '../models/room.dart';
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

  Future<Map<String, dynamic>> _putJson(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _delete(String path) async {
    final response = await http.delete(_uri(path), headers: _headers).timeout(AppTheme.apiTimeout);
    _throwIfError(response);
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

  // ── VNPAY Payment ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createVnpayPayment({required String tripId, required double amount, String? orderInfo, String? locale}) async {
    return _postJson('/api/payment/vnpay/create', {
      'tripId': tripId,
      'amount': amount,
      'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent',
      'locale': locale ?? 'vn',
    });
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String tripId) async {
    return _getJson('/api/payment/vnpay/status/$tripId');
  }

  // ── MoMo Payment ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createMomoPayment({required String tripId, required double amount, String? orderInfo}) async {
    return _postJson('/api/payment/momo/create', {
      'tripId': tripId,
      'amount': amount,
      'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent',
    });
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

  Future<Hotel> updatePartnerHotel(String id, Map<String, dynamic> data) async {
    final res = await _putJson('/api/partner/hotels/$id', data);
    return Hotel.fromJson(res);
  }

  Future<void> deletePartnerHotel(String id) async {
    await _delete('/api/partner/hotels/$id');
  }

  Future<TourPackage> updatePartnerTour(String id, Map<String, dynamic> data) async {
    final res = await _putJson('/api/partner/tours/$id', data);
    return TourPackage.fromJson(res);
  }

  Future<void> deletePartnerTour(String id) async {
    await _delete('/api/partner/tours/$id');
  }

  Future<Map<String, dynamic>> getPartnerStats() async {
    return await _getJson('/api/partner/stats');
  }

  Future<List<Room>> getPartnerHotelRooms(String hotelId) async {
    final data = await _getList('/api/partner/hotels/$hotelId/rooms');
    return data.whereType<Map<String, dynamic>>().map(Room.fromJson).toList();
  }

  Future<Room> createPartnerRoom(String hotelId, Map<String, dynamic> data) async {
    final res = await _postJson('/api/partner/hotels/$hotelId/rooms', data);
    return Room.fromJson(res);
  }

  Future<void> updatePartnerRoom(String hotelId, String roomId, Map<String, dynamic> data) async {
    await _putJson('/api/partner/hotels/$hotelId/rooms/$roomId', data);
  }

  Future<void> deletePartnerRoom(String hotelId, String roomId) async {
    await _delete('/api/partner/hotels/$hotelId/rooms/$roomId');
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    return ((raw as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  static void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['message']?.toString() ?? 'Lỗi không xác định (${response.statusCode})';
    } catch (_) {
      message = 'Lỗi server (${response.statusCode})';
    }
    throw ApiException(response.statusCode, message);
  }
}
