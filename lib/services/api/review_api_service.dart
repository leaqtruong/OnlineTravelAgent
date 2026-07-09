import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import '../../models/review.dart';
import 'api_http_client.dart';

class ReviewApiService {
  final ApiHttpClient _client;
  ReviewApiService(this._client);

  Future<ReviewResponse> getReviews({required String targetType, required String targetId}) async {
    final data = await _client.getJson(_client.pathWithQuery('/api/reviews', {'targetType': targetType, 'targetId': targetId}));
    return ReviewResponse.fromJson(data);
  }

  Future<Review> createReview({required String targetType, required String targetId, required int rating, required String comment}) async {
    final data = await _client.postJson('/api/reviews', {'targetType': targetType, 'targetId': targetId, 'rating': rating, 'comment': comment});
    return Review.fromJson(data);
  }

  Future<bool> deleteReview(String reviewId) async {
    await _client.ensureTokenLoaded();
    return _client.safeCall(() async {
      final response = await http.delete(_client.uri('/api/reviews/$reviewId'), headers: _client.headers).timeout(AppTheme.apiTimeout);
      _client.throwIfError(response);
      return true;
    });
  }
}
