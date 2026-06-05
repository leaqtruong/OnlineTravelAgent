import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/destination.dart';
import '../models/document_item.dart';
import '../models/flight.dart';
import '../models/trip.dart';
import '../models/user_profile.dart';
import '../models/hotel.dart';
import '../models/tour_package.dart';

class BootstrapData {
  final List<String> categories;
  final List<Destination> destinations;
  final List<Destination> recommended;
  final List<Trip> trips;
  final UserProfile profile;
  final List<DocumentItem> documents;
  final List<Hotel> hotels;
  final List<TourPackage> tourPackages;

  BootstrapData({
    required this.categories,
    required this.destinations,
    required this.recommended,
    required this.trips,
    required this.profile,
    required this.documents,
    required this.hotels,
    required this.tourPackages,
  });
}

class TravelApiService {
  TravelApiService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl();

  final String _baseUrl;

  static String _defaultBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await http.get(_uri(path)).timeout(const Duration(seconds: 10));
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patchJson(String path, Map<String, dynamic> body) async {
    final response = await http.patch(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
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
      profile: UserProfile.fromJson(data['profile'] as Map<String, dynamic>),
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
    final data = await _postJson('/api/trips/book', {
      'destinationId': destinationId,
      'date': date,
      'guests': guests,
      'totalPrice': ?totalPrice,
    });
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
    final response = await http.get(_uri('/api/flights/search$query')).timeout(const Duration(seconds: 10));
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

  Future<UserProfile> updateProfile({required String name, required String email}) async {
    final data = await _putJson('/api/profile', {'name': name, 'email': email});
    return UserProfile.fromJson(data);
  }

  Future<DocumentItem> addDocument({required String title, required String description, required String icon, required String color}) async {
    final data = await _postJson('/api/documents', {
      'title': title, 'description': description, 'icon': icon, 'color': color,
    });
    return DocumentItem.fromJson(data);
  }

  Future<Trip> bookHotel({required String roomId, required String checkIn, required String checkOut, required String guests}) async {
    final data = await _postJson('/api/hotels/book', {
      'roomId': roomId, 'checkIn': checkIn, 'checkOut': checkOut, 'guests': guests,
    });
    return Trip.fromJson(data);
  }

  Future<Trip> bookTour({required String tourId, required String date, required String guests, double? totalPrice}) async {
    final data = await _postJson('/api/tours/book', {
      'tourId': tourId, 'date': date, 'guests': guests,
      'totalPrice': ?totalPrice,
    });
    return Trip.fromJson(data);
  }

  Future<Trip> createCustomTour({
    required String destination, required String location, required String date,
    required String guests, required String imagePath,
    List<String>? flightIds, List<String>? hotelIds, String? roomId, double? totalPrice,
  }) async {
    final data = await _postJson('/api/trips/custom-tour', {
      'destination': destination, 'location': location, 'date': date,
      'guests': guests, 'imagePath': imagePath,
      'flightIds': ?flightIds,
      'hotelIds': ?hotelIds,
      'roomId': ?roomId,
      'totalPrice': ?totalPrice,
    });
    return Trip.fromJson(data);
  }

  Future<Map<String, dynamic>> _putJson(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
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
