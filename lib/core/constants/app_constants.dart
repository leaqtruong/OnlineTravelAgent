class AppConstants {
  AppConstants._();

  // Categories
  static const String categoryAll = 'Tất cả';
  static const String categoryDestinations = 'Địa điểm';
  static const String categoryHotels = 'Khách sạn';
  static const String categoryFlights = 'Máy bay';
  static const String categoryFood = 'Ẩm thực';
  static const String categoryBeach = 'Bãi biển';

  // Trip Status
  static const String statusOngoing = 'Đang diễn ra';
  static const String statusOngoingEn = 'ongoing';
  static const String statusConfirmed = 'Đã xác nhận';
  static const String statusUpcoming = 'Sắp tới';
  static const String statusPending = 'Chờ thanh toán';

  // Default Categories List
  static const List<String> defaultCategories = [
    categoryAll,
    categoryDestinations,
    categoryHotels,
    categoryFlights,
    categoryFood,
  ];

  // Hidden Categories
  static const Set<String> hiddenCategories = {categoryBeach};
}
