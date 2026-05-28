import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/destination.dart';
import '../models/document_item.dart';
import '../models/flight.dart';
import '../models/trip.dart';
import '../models/user_profile.dart';

class BootstrapData {
  final List<String> categories;
  final List<Destination> destinations;
  final List<Destination> recommended;
  final List<Trip> trips;
  final UserProfile profile;
  final List<DocumentItem> documents;

  BootstrapData({
    required this.categories,
    required this.destinations,
    required this.recommended,
    required this.trips,
    required this.profile,
    required this.documents,
  });
}

class TravelApiService {
  TravelApiService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl();

  final String _baseUrl;

  static String _defaultBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<BootstrapData> fetchBootstrap() async {
    final response = await http.get(_uri('/api/bootstrap'));
    _throwIfError(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return BootstrapData(
      categories: ((data['categories'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(growable: false),
      destinations: _parseDestinations(data['destinations']),
      recommended: _parseDestinations(data['recommended']),
      trips: _parseTrips(data['trips']),
      profile: UserProfile.fromJson(data['profile'] as Map<String, dynamic>),
      documents: _parseDocuments(data['documents']),
    );
  }

  Future<Destination> setFavorite(String destinationId, bool isFavorite) async {
    final response = await http.patch(
      _uri('/api/destinations/$destinationId/favorite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isFavorite': isFavorite}),
    );
    _throwIfError(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Destination.fromJson(data);
  }

  Future<Trip> bookTrip({required String destinationId, String? date, String? guests}) async {
    final response = await http.post(
      _uri('/api/trips/book'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'destinationId': destinationId,
        'date': date,
        'guests': guests,
      }),
    );
    _throwIfError(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
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
    
    final response = await http.get(_uri('/api/flights/search$query'));
    _throwIfError(response);
    final List<dynamic> raw = jsonDecode(response.body);
    return raw.map((e) => Flight.fromJson(e)).toList();
  }

  Future<Trip> bookFlight({required String flightId, required String date, required String guests}) async {
    final response = await http.post(
      _uri('/api/trips/book-flight'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'flightId': flightId,
        'date': date,
        'guests': guests,
      }),
    );
    _throwIfError(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Trip.fromJson(data);
  }

  Future<UserProfile> updateProfile(
      {required String name, required String email}) async {
    final response = await http.put(
      _uri('/api/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );
    _throwIfError(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<DocumentItem> addDocument({
    required String title,
    required String description,
    required String icon,
    required String color,
  }) async {
    final response = await http.post(
      _uri('/api/documents'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'icon': icon,
        'color': color,
      }),
    );
    _throwIfError(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DocumentItem.fromJson(data);
  }

  static List<Destination> _parseDestinations(dynamic raw) {
    return ((raw as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Destination.fromJson)
        .toList(growable: false);
  }

  static List<Trip> _parseTrips(dynamic raw) {
    return ((raw as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Trip.fromJson)
        .toList(growable: false);
  }

  static List<DocumentItem> _parseDocuments(dynamic raw) {
    return ((raw as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(DocumentItem.fromJson)
        .toList(growable: false);
  }

  static void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('API error ${response.statusCode}: ${response.body}');
  }
}
