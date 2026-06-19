class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  @override
  String toString() => 'Không thể kết nối server. Kiểm tra lại mạng.';
}
