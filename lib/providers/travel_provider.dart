import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/destination.dart';

class TravelProvider with ChangeNotifier {
  final List<Destination> _destinations = [
    Destination(
      name: "Đà Lạt",
      location: "Lâm Đồng, VN",
      rating: "4.1",
      duration: "4N/5D",
      imagePath: "assets/images/dalat_image.jpg",
      description: "Đà Lạt là thành phố ngàn hoa với khí hậu mát mẻ quanh năm. Đây là địa điểm lý tưởng cho các cặp đôi và gia đình muốn tìm kiếm sự yên bình.",
      price: "199",
      reviewsCount: "355",
    ),
    Destination(
      name: "Đảo Phú Quốc",
      location: "Kiên Giang, VN",
      rating: "4.5",
      duration: "2N/3D",
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Phú Quốc nổi tiếng với những bãi biển xanh ngắt và cát trắng mịn. Du khách có thể thưởng thức hải sản tươi ngon và tham gia các hoạt động lặn ngắm san hô.",
      price: "250",
      reviewsCount: "1.2k",
    ),
    Destination(
      name: "Hội An",
      location: "Quảng Nam, VN",
      rating: "4.8",
      duration: "2N/1Đ",
      imagePath: "assets/images/hoian_image.webp",
      description: "Phố cổ Hội An là di sản văn hóa thế giới với những con phố đèn lồng lung linh và nền ẩm thực phong phú, mang đậm dấu ấn lịch sử.",
      price: "150",
      reviewsCount: "800",
    ),
  ];

  final List<Destination> _recommended = [
    Destination(
      name: "Hội An",
      location: "Quảng Nam, VN",
      rating: "4.8",
      duration: "2N/1Đ",
      imagePath: "assets/images/hoian_image.webp",
      description: "Phố cổ Hội An là di sản văn hóa thế giới.",
      price: "150",
      reviewsCount: "800",
    ),
    Destination(
      name: "Đà Lạt",
      location: "Lâm Đồng, VN",
      rating: "4.9",
      duration: "2N/1Đ",
      imagePath: "assets/images/dalat_image.jpg",
      description: "Thành phố sương mù lãng mạn.",
      price: "199",
      reviewsCount: "355",
    ),
    Destination(
      name: "Đảo Phú Quốc",
      location: "Kiên Giang, VN",
      rating: "4.5",
      duration: "2N/3D",
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Thiên đường nghỉ dưỡng.",
      price: "250",
      reviewsCount: "1.2k",
    ),
  ];

  Destination? _selectedDestination;

  // Cache danh sách — tránh tạo list mới mỗi lần getter được gọi
  late List<Destination> _unmodifiableDestinations = UnmodifiableListView(_destinations);
  late List<Destination> _unmodifiableRecommended = UnmodifiableListView(_recommended);
  List<Destination>? _cachedFavorites;

  List<Destination> get destinations => _unmodifiableDestinations;
  List<Destination> get recommended => _unmodifiableRecommended;
  List<Destination> get favorites {
    _cachedFavorites ??= UnmodifiableListView(
      _destinations.where((d) => d.isFavorite),
    );
    return _cachedFavorites!;
  }
  Destination? get selectedDestination => _selectedDestination;

  void selectDestination(Destination? destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  void toggleFavorite(String name) {
    final index = _destinations.indexWhere((d) => d.name == name);
    if (index != -1) {
      _destinations[index] = _destinations[index].copyWith(isFavorite: !_destinations[index].isFavorite);
    }

    final recIndex = _recommended.indexWhere((d) => d.name == name);
    if (recIndex != -1) {
      _recommended[recIndex] = _recommended[recIndex].copyWith(isFavorite: !_recommended[recIndex].isFavorite);
    }

    if (_selectedDestination?.name == name) {
      _selectedDestination = _selectedDestination!.copyWith(isFavorite: !_selectedDestination!.isFavorite);
    }

    // Invalidate caches khi data thay đổi
    _unmodifiableDestinations = UnmodifiableListView(_destinations);
    _unmodifiableRecommended = UnmodifiableListView(_recommended);
    _cachedFavorites = null;

    notifyListeners();
  }
}
