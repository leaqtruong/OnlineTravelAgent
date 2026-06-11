import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/trip.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/tour_package.dart';
import '../models/document_item.dart';

class FallbackData {
  static List<Destination> foodDestinations() => [
    Destination(
      id: 'food-dalat-dem', name: 'Chợ Đêm Đà Lạt', location: 'Lâm Đồng, VN',
      rating: '4.6', duration: '1 buổi tối', imagePath: 'assets/images/dalat_image.jpg',
      description: 'Chợ đêm Đà Lạt là thiên đường ẩm thực đường phố với bánh tráng nướng, sữa đậu nành nóng, kem bơ, ốc hút và vô vàn đặc sản vùng cao nguyên.',
      price: '5', reviewsCount: '3.5k', category: 'Ẩm thực',
      latitude: 11.9415, longitude: 108.4374,
    ),
    Destination(
      id: 'food-hoian-cao-lau', name: 'Cao Lầu Hội An', location: 'Quảng Nam, VN',
      rating: '4.9', duration: '1 bữa', imagePath: 'assets/images/hoian_image.webp',
      description: 'Món Cao Lầu Hội An trứ danh với sợi mì dai ngon, thịt xá xíu thơm lừng và rau sống tươi mát - tinh hoa ẩm thực phố cổ không thể bỏ lỡ.',
      price: '3', reviewsCount: '5.2k', category: 'Ẩm thực',
      latitude: 15.8775, longitude: 108.3356,
    ),
    Destination(
      id: 'food-halong-haisan', name: 'Chợ Hải Sản Hạ Long', location: 'Quảng Ninh, VN',
      rating: '4.7', duration: '2 tiếng', imagePath: 'assets/images/halong_image.png',
      description: 'Chợ hải sản Hạ Long nổi tiếng với tôm hùm, cua hoàng đế, ghẹ xanh và các loại ốc biển tươi sống được đánh bắt trực tiếp từ vịnh.',
      price: '25', reviewsCount: '2.8k', category: 'Ẩm thực',
      latitude: 20.9553, longitude: 107.0791,
    ),
    Destination(
      id: 'food-sapa-thang-co', name: 'Thắng Cố Sapa', location: 'Lào Cai, VN',
      rating: '4.5', duration: '1 bữa', imagePath: 'assets/images/sapa_image.png',
      description: 'Thắng Cố - món súp đặc sản vùng cao Tây Bắc với thịt ngựa, thảo mộc bản địa và gia vị đặc trưng của đồng bào HMông tại khu chợ phiên Sapa.',
      price: '4', reviewsCount: '1.2k', category: 'Ẩm thực',
      latitude: 22.3365, longitude: 103.8439,
    ),
    Destination(
      id: 'food-danang-seafood', name: 'Đường Hải Sản Mỹ Khê', location: 'Đà Nẵng, VN',
      rating: '4.8', duration: '1 buổi tối', imagePath: 'assets/images/danang_image.png',
      description: 'Dọc bãi biển Mỹ Khê là thiên đường hải sản tươi sống với hàng chục nhà hàng nổi tiếng, đặc biệt là món bánh xèo tôm nhảy và bún chả cá.',
      price: '15', reviewsCount: '4.1k', category: 'Ẩm thực',
      latitude: 16.0617, longitude: 108.2488,
    ),
    Destination(
      id: 'food-phuquoc-nuoc-mam', name: 'Làng Nước Mắm Phú Quốc', location: 'Kiên Giang, VN',
      rating: '4.6', duration: '3 tiếng', imagePath: 'assets/images/phuquoc_image.jpg',
      description: 'Tham quan làng nước mắm Phú Quốc và thưởng thức gỏi cá trích, bún quậy Kiến Xây, nhum dầm - tinh hoa ẩm thực đảo ngọc.',
      price: '8', reviewsCount: '1.9k', category: 'Ẩm thực',
      latitude: 10.2745, longitude: 103.9610,
    ),
    Destination(
      id: 'food-nhatrang-bun-bo', name: 'Bún Bò Nha Trang', location: 'Khánh Hòa, VN',
      rating: '4.7', duration: '1 bữa', imagePath: 'assets/images/phuquoc_image.jpg',
      description: 'Bún bò Nha Trang khác biệt với nước dùng thanh ngọt từ xương ống, thịt bò thái mỏng và chả lụa tươi - hương vị làm say lòng thực khách.',
      price: '3', reviewsCount: '2.3k', category: 'Ẩm thực',
      latitude: 12.2451, longitude: 109.1943,
    ),
  ];

  static List<Destination> destinations() => [
    Destination(
      id: 'dalat', name: 'Đà Lạt', location: 'Lâm Đồng, VN',
      rating: '4.5', duration: '4N/5D', imagePath: 'assets/images/dalat_image.jpg',
      description: 'Đà Lạt là thành phố ngàn hoa với khí hậu ôn đới mát mẻ quanh năm. Nơi đây sở hữu cảnh sắc lãng mạn như Hồ Xuân Hương, Thung Lũng Tình Yêu, Thác Datanla và nền ẩm thực đêm cực kỳ hấp dẫn.',
      price: '199', reviewsCount: '820', category: 'Địa điểm',
      latitude: 11.9404, longitude: 108.4583,
    ),
    Destination(
      id: 'phuquoc', name: 'Đảo Phú Quốc', location: 'Kiên Giang, VN',
      rating: '4.8', duration: '3N/2Đ', imagePath: 'assets/images/phuquoc_image.jpg',
      description: 'Đảo ngọc Phú Quốc nổi tiếng với các bãi biển nguyên sơ như Bãi Sao, Bãi Khem. Trải nghiệm hoàng hôn rực rỡ, lặn biển ngắm rạn san hô, đi cáp treo vượt biển Hòn Thơm và thưởng thức gỏi cá trích đặc sản.',
      price: '250', reviewsCount: '1.5k', category: 'Địa điểm',
      latitude: 10.2270, longitude: 103.9670,
    ),
    Destination(
      id: 'hoian', name: 'Hội An', location: 'Quảng Nam, VN',
      rating: '4.9', duration: '2N/1Đ', imagePath: 'assets/images/hoian_image.webp',
      description: 'Phố cổ Hội An - Di sản Văn hóa Thế giới lung linh dưới ánh đèn lồng vào ban đêm. Du khách có thể thả hoa đăng trên sông Hoài, check-in Chùa Cầu cổ kính và thưởng thức Cao Lầu ngon nức tiếng.',
      price: '150', reviewsCount: '2.1k', category: 'Địa điểm',
      latitude: 15.8801, longitude: 108.3380,
    ),
    Destination(
      id: 'sapa', name: 'Sapa', location: 'Lào Cai, VN',
      rating: '4.7', duration: '3N/2Đ', imagePath: 'assets/images/sapa_image.png',
      description: 'Sapa ẩn hiện trong sương mờ với đỉnh Fansipan - nóc nhà Đông Dương hùng vĩ. Chiêm ngưỡng ruộng bậc thang tầng tầng lớp lớp tại Bản Cát Cát, thung lũng Mường Hoa và trải nghiệm văn hóa bản địa độc đáo.',
      price: '180', reviewsCount: '740', category: 'Địa điểm',
      latitude: 22.3364, longitude: 103.8438,
    ),
    Destination(
      id: 'halong', name: 'Vịnh Hạ Long', location: 'Quảng Ninh, VN',
      rating: '4.8', duration: '2N/1Đ', imagePath: 'assets/images/halong_image.png',
      description: 'Vịnh Hạ Long với hàng ngàn đảo đá vôi dựng đứng kỳ vĩ nổi lên từ làn nước xanh ngọc. Trải nghiệm ngủ đêm trên du thuyền 5 sao sang trọng, chèo kayak luồn qua hang luồn và ngắm toàn cảnh vịnh từ đỉnh Ti Tốp.',
      price: '220', reviewsCount: '3.2k', category: 'Địa điểm',
      latitude: 20.9754, longitude: 107.0474,
    ),
    Destination(
      id: 'ninhbinh', name: 'Tràng An', location: 'Ninh Bình, VN',
      rating: '4.7', duration: '2N/1Đ', imagePath: 'assets/images/hoian_image.webp',
      description: 'Quần thể danh thắng Tràng An ví như "Hạ Long trên cạn" với hệ thống hang động xuyên thủy kỳ ảo. Ngồi thuyền nan trôi theo dòng sông Sào Khê ngắm vách núi đá vôi dựng đứng và ghé thăm Hang Múa ngắm trọn thung lũng lúa vàng.',
      price: '110', reviewsCount: '680', category: 'Địa điểm',
      latitude: 20.2528, longitude: 105.9744,
    ),
    Destination(
      id: 'danang', name: 'Đà Nẵng', location: 'Đà Nẵng, VN',
      rating: '4.8', duration: '3N/2Đ', imagePath: 'assets/images/danang_image.png',
      description: 'Thành phố đáng sống bậc nhất với bãi biển Mỹ Khê cát trắng mịn, cầu Rồng phun lửa ấn tượng ban đêm. Khám phá Bà Nà Hills với Cầu Vàng nổi tiếng toàn cầu, Ngũ Hành Sơn huyền thoại và bán đảo Sơn Trà hoang sơ.',
      price: '160', reviewsCount: '1.8k', category: 'Địa điểm',
      latitude: 16.0544, longitude: 108.2022,
    ),
    ...foodDestinations(),
  ];

  static List<Destination> recommended() => [
    destinations()[2], destinations()[0], destinations()[3],
    destinations()[4], destinations()[6],
  ];

  static List<Trip> trips() => [
    Trip(id: 'local-trip-ongoing', destination: 'Đà Nẵng', location: 'Đà Nẵng, VN',
      date: '28/05/2026 - 02/06/2026', guests: '2 Người lớn', status: 'Đang diễn ra',
      imagePath: 'assets/images/danang_image.png', isUpcoming: true),
    Trip(id: 'local-trip-1', destination: 'Đảo Phú Quốc', location: 'Kiên Giang, VN',
      date: '20/05/2026 - 23/05/2026', guests: '2 Người lớn', status: 'Sắp tới',
      imagePath: 'assets/images/phuquoc_image.jpg', isUpcoming: true),
    Trip(id: 'local-trip-2', destination: 'Sapa', location: 'Lào Cai, VN',
      date: '15/12/2026 - 18/12/2026', guests: '2 Người lớn', status: 'Sắp tới',
      imagePath: 'assets/images/sapa_image.png', isUpcoming: true),
    Trip(id: 'local-trip-3', destination: 'Hội An', location: 'Quảng Nam, VN',
      date: '15/04/2026 - 17/04/2026', guests: '1 Người lớn', status: 'Đã đi',
      imagePath: 'assets/images/hoian_image.webp', isUpcoming: false),
  ];

  static List<DocumentItem> documents() => [
    DocumentItem(id: 'local-doc-1', title: 'Hộ chiếu', description: 'Hết hạn: 12/2030',
      icon: Icons.description, color: Color(0xFF176FF2), iconName: 'description', colorHex: '#176FF2'),
    DocumentItem(id: 'local-doc-2', title: 'Visa Việt Nam', description: 'Trạng thái: Đã duyệt',
      icon: Icons.assignment, color: Color(0xFF4CAF50), iconName: 'assignment', colorHex: '#4CAF50'),
    DocumentItem(id: 'local-doc-3', title: 'Vé máy bay khứ hồi', description: 'VJ-381 Sài Gòn - Đà Nẵng',
      icon: Icons.flight_takeoff, color: Color(0xFFE91E63), iconName: 'flight_takeoff', colorHex: '#E91E63'),
  ];

  static List<Hotel> hotels() => [
    Hotel(
      id: 'ht-vinpearl-nhatrang', name: 'Vinpearl Resort Nha Trang',
      location: 'Nha Trang, VN', latitude: 12.2118, longitude: 109.1592,
      rating: '4.8', imagePath: 'assets/images/phuquoc_image.jpg',
      description: 'Khu nghỉ dưỡng 5 sao đẳng cấp quốc tế tọa lạc trên đảo Hòn Tre, với bãi biển riêng và công viên giải trí VinWonders.',
      priceFrom: 150.0, address: 'Đảo Hòn Tre, Phường Vĩnh Nguyên, TP Nha Trang',
      amenities: const ['Hồ bơi ngoài trời', 'Spa chăm sóc sức khỏe', 'Bãi biển riêng', 'Nhà hàng buffet', 'Phòng Gym hiện đại'],
      rooms: [
        Room(id: 'rm-vp-1', hotelId: 'ht-vinpearl-nhatrang', name: 'Deluxe Ocean View',
          description: 'Phòng rộng 42m2 sang trọng với ban công lớn nhìn toàn cảnh vịnh Nha Trang xanh ngắt.',
          price: 150.0, capacity: 2, imagePath: 'assets/images/phuquoc_image.jpg',
          amenities: const ['Ban công riêng', 'Bồn tắm nằm', 'Minibar đầy đủ', 'Wifi tốc độ cao']),
        Room(id: 'rm-vp-2', hotelId: 'ht-vinpearl-nhatrang', name: 'Villa 3-Bedroom Pool Ocean',
          description: 'Biệt thự 3 phòng ngủ đẳng cấp có hồ bơi riêng biệt và lối đi thẳng ra bãi biển cát trắng.',
          price: 480.0, capacity: 6, imagePath: 'assets/images/phuquoc_image.jpg',
          amenities: const ['Hồ bơi riêng', 'Bếp gia đình rộng rãi', 'Sân tắm nắng', 'Dịch vụ quản gia riêng']),
      ]),
    Hotel(
      id: 'ht-muongthanh-dalat', name: 'Mường Thanh Holiday Đà Lạt',
      location: 'Lâm Đồng, VN', latitude: 11.9421, longitude: 108.4552,
      rating: '4.5', imagePath: 'assets/images/dalat_image.jpg',
      description: 'Nằm ngay trung tâm thành phố Đà Lạt, tầm nhìn tuyệt đẹp ra Hồ Xuân Hương và thành phố mộng mơ với phong cách hoàng gia.',
      priceFrom: 50.0, address: '42 Phan Bội Châu, Phường 2, TP Đà Lạt',
      amenities: const ['Hồ bơi nước ấm trong nhà', 'Dịch vụ Spa & Massage', 'Quầy Bar lãng mạn', 'Nhà hàng ẩm thực Á-Âu', 'Dịch vụ cho thuê xe tự lái'],
      rooms: [
        Room(id: 'rm-mt-1', hotelId: 'ht-muongthanh-dalat', name: 'Superior Double Room',
          description: 'Phòng đôi tiêu chuẩn ấm cúng mang phong cách cổ điển Pháp, trang bị máy sưởi.',
          price: 50.0, capacity: 2, imagePath: 'assets/images/dalat_image.jpg',
          amenities: const ['Cửa sổ lớn ngắm hồ', 'Hệ thống sưởi ấm', 'Ấm trà & Cà phê', 'Truyền hình cáp']),
        Room(id: 'rm-mt-2', hotelId: 'ht-muongthanh-dalat', name: 'Executive Suite Lakeview',
          description: 'Phòng Suite hoàng gia rộng rãi với phòng khách riêng biệt hướng thẳng ra Hồ Xuân Hương thơ mộng.',
          price: 90.0, capacity: 2, imagePath: 'assets/images/dalat_image.jpg',
          amenities: const ['View Hồ Xuân Hương trực diện', 'Phòng khách riêng', 'Trái cây chào mừng', 'Bồn tắm thủy lực']),
      ]),
    Hotel(
      id: 'ht-intercon-phuquoc', name: 'InterContinental Phu Quoc Long Beach',
      location: 'Kiên Giang, VN', latitude: 10.1581, longitude: 103.9875,
      rating: '4.9', imagePath: 'assets/images/phuquoc_image.jpg',
      description: 'Trải nghiệm kỳ nghỉ xa hoa tại Bãi Trường với các tiện ích đẳng cấp thế giới, bể bơi vô cực khổng lồ và cảnh hoàng hôn tuyệt đỉnh.',
      priceFrom: 200.0, address: 'Bãi Trường, Xã Dương Tơ, TP Phú Quốc',
      amenities: const ['Hồ bơi vô cực sát biển', 'Khu vui chơi trẻ em', 'Harnn Heritage Spa', 'Quầy bar Ink 360 cao nhất đảo', 'Phòng thể hình đẳng cấp'],
      rooms: [
        Room(id: 'rm-ic-1', hotelId: 'ht-intercon-phuquoc', name: 'Resort Classic Ocean View',
          description: 'Không gian nghỉ dưỡng thanh lịch mang hơi thở đại dương với cửa kính kịch trần ngắm hoàng hôn Bãi Trường.',
          price: 200.0, capacity: 2, imagePath: 'assets/images/phuquoc_image.jpg',
          amenities: const ['Bồn tắm đứng độc lập', 'Loa Bluetooth JBL', 'Minibar cao cấp', 'Máy pha cà phê Espresso']),
      ]),
    Hotel(
      id: 'ht-sapajade-hill', name: 'Sapa Jade Hill Resort & Spa',
      location: 'Lào Cai, VN', latitude: 22.3218, longitude: 103.8542,
      rating: '4.7', imagePath: 'assets/images/sapa_image.png',
      description: 'Khu nghỉ dưỡng sinh thái độc đáo ẩn mình giữa thung lũng Mường Hoa thơ mộng, với các biệt thự mái đá có lò sưởi ấm cúng.',
      priceFrom: 120.0, address: 'Khu du lịch Mường Hoa, Lao Chải, Sa Pa',
      amenities: const ['Hồ bơi nước nóng view thung lũng', 'Hồng Hoa Spa bản địa', 'Nhà hàng ẩm thực Tây Bắc', 'Lò sưởi củi tự nhiên', 'Tour đi bộ leo núi'],
      rooms: [
        Room(id: 'rm-sj-1', hotelId: 'ht-sapajade-hill', name: 'Deluxe Valley Bungalow',
          description: 'Bungalow xây dựng bằng gỗ thông và đá núi tự nhiên, ban công nhìn ra thung lũng Mường Hoa mờ sương.',
          price: 120.0, capacity: 2, imagePath: 'assets/images/sapa_image.png',
          amenities: const ['Ban công ngắm mây', 'Lò sưởi củi sưởi ấm', 'Bồn tắm bằng gỗ pơ-mu', 'Trà thảo mộc bản địa']),
        Room(id: 'rm-sj-2', hotelId: 'ht-sapajade-hill', name: 'Family Garden Villa 2-Bed',
          description: 'Biệt thự 2 phòng ngủ ấm cúng có sân vườn đầy hoa mận hoa đào, lý tưởng cho kỳ nghỉ gia đình.',
          price: 220.0, capacity: 4, imagePath: 'assets/images/sapa_image.png',
          amenities: const ['Sân vườn riêng biệt', 'Phòng khách ấm cúng', 'Lò sưởi đá sành điệu', 'Nhà bếp cơ bản']),
      ]),
    Hotel(
      id: 'ht-halong-plaza', name: 'Ha Long Plaza Hotel',
      location: 'Quảng Ninh, VN', latitude: 20.9575, longitude: 107.0733,
      rating: '4.6', imagePath: 'assets/images/halong_image.png',
      description: 'Tọa lạc tại trung tâm Bãi Cháy, khách sạn cung cấp tầm nhìn trực diện tuyệt đẹp ra Vịnh Hạ Long kỳ vĩ và cầu Bãi Cháy lung linh về đêm.',
      priceFrom: 85.0, address: 'Số 8 Đường Hạ Long, Phường Bãi Cháy, TP Hạ Long',
      amenities: const ['Bể bơi vô cực ngoài trời', 'Trung tâm thể thao & Massage', 'Lounge tầng thượng ngắm vịnh', 'Nhà hàng hải sản tươi sống', 'Dịch vụ phòng 24h'],
      rooms: [
        Room(id: 'rm-hl-1', hotelId: 'ht-halong-plaza', name: 'Superior Bay View Room',
          description: 'Phòng Superior hiện đại với cửa sổ lớn hướng biển nhìn ngắm các hòn đảo đá vôi nhấp nhô ngoài vịnh.',
          price: 85.0, capacity: 2, imagePath: 'assets/images/halong_image.png',
          amenities: const ['Tầm nhìn ngắm Vịnh biển', 'Bồn tắm sang trọng', 'Bàn làm việc lớn', 'Nước uống chào mừng']),
        Room(id: 'rm-hl-2', hotelId: 'ht-halong-plaza', name: 'Executive Suite Sea View',
          description: 'Phòng Suite cao cấp với diện tích vượt trội, trang thiết bị tối tân và đặc quyền sử dụng Executive Lounge.',
          price: 150.0, capacity: 2, imagePath: 'assets/images/halong_image.png',
          amenities: const ['Đặc quyền Lounge', 'Giường siêu lớn King-size', 'Bữa phụ & Rượu tối miễn phí', 'Dịch vụ là ủi miễn phí']),
      ]),
    Hotel(
      id: 'ht-phongnha-lake', name: 'Phong Nha Lake House Resort',
      location: 'Quảng Bình, VN', latitude: 17.5852, longitude: 106.2895,
      rating: '4.5', imagePath: 'assets/images/sapa_image.png',
      description: 'Khu nghỉ dưỡng sinh thái bình yên nằm bên hồ Đồng Bản thơ mộng, cửa ngõ tuyệt vời để thám hiểm hệ thống hang động Phong Nha.',
      priceFrom: 55.0, address: 'Thôn Khương Hà, Xã Hưng Trạch, Huyện Bố Trạch',
      amenities: const ['Hồ bơi ngoài trời sát hồ', 'Cho thuê thuyền Kayak miễn phí', 'Nhà hàng phong cách đồng quê', 'Bar ngoài trời', 'Tour thám hiểm hang động'],
      rooms: [
        Room(id: 'rm-pn-1', hotelId: 'ht-phongnha-lake', name: 'Lakefront Bungalow',
          description: 'Bungalow lợp mái lá truyền thống nằm ngay sát rìa nước hồ, ban công lộng gió thích hợp câu cá, thư giãn.',
          price: 55.0, capacity: 2, imagePath: 'assets/images/sapa_image.png',
          amenities: const ['Ban công sát mép nước', 'Võng thư giãn ngoài trời', 'Điều hòa nhiệt độ', 'Ấm đun nước']),
        Room(id: 'rm-pn-2', hotelId: 'ht-phongnha-lake', name: 'Family Lakeview Villa 2-Bed',
          description: 'Biệt thự gia đình rộng rãi nhìn ra toàn cảnh hồ Đồng Bản yên bình giữa núi rừng Phong Nha hoang sơ.',
          price: 100.0, capacity: 4, imagePath: 'assets/images/sapa_image.png',
          amenities: const ['Ban công hồ vô cực', 'Phòng sinh hoạt chung rộng', 'Khu đỗ xe riêng', 'Đồ ăn nhẹ chào mừng']),
      ]),
    Hotel(
      id: 'ht-metropole-hanoi', name: 'Sofitel Legend Metropole Hanoi',
      location: 'Hà Nội, VN', latitude: 21.0253, longitude: 105.8569,
      rating: '4.9', imagePath: 'assets/images/hanoi_image.png',
      description: 'Khách sạn cổ kính mang phong cách kiến trúc Pháp thuộc từ năm 1901. Trải nghiệm lịch sử xa hoa, hầm trú ẩn lịch sử và nét ẩm thực thượng hạng.',
      priceFrom: 260.0, address: '15 Ngô Quyền, Quận Hoàn Kiếm, Hà Nội',
      amenities: const ['Bể bơi nước nóng Le Club', 'Le Spa du Metropole', 'Hầm rượu cổ', 'Nhà hàng Pháp chuẩn Michelin', 'Quầy bar ngoài trời Angelina'],
      rooms: [
        Room(id: 'rm-mp-1', hotelId: 'ht-metropole-hanoi', name: 'Premium Luxury Opera Wing',
          description: 'Phòng ở phân khu Opera sang trọng với thiết kế tân cổ điển kết hợp tinh tế giữa văn hóa Pháp và Việt Nam.',
          price: 260.0, capacity: 2, imagePath: 'assets/images/hanoi_image.png',
          amenities: const ['Nội thất tân cổ điển Pháp', 'Giường MyBed siêu êm', 'Đồ tắm thương hiệu Hermes', 'Dịch vụ quản gia Legend']),
      ]),
    Hotel(
      id: 'ht-novotel-danang', name: 'Novotel Danang Premier Han River',
      location: 'Đà Nẵng, VN', latitude: 16.0792, longitude: 108.2238,
      rating: '4.8', imagePath: 'assets/images/danang_image.png',
      description: 'Khách sạn cao tầng hiện đại hàng đầu bên sông Hàn. Điểm ngắm pháo hoa quốc tế tuyệt đỉnh và sở hữu Sky36 - bar sân thượng cao nhất Đà Nẵng.',
      priceFrom: 110.0, address: '36 Bạch Đằng, Quận Hải Châu, Đà Nẵng',
      amenities: const ['Bể bơi vô cực ngắm sông Hàn', 'Sky36 Rooftop Bar', 'InBalance Spa', 'Nhà hàng ẩm thực quốc tế', 'Phòng tập Gym tối tân'],
      rooms: [
        Room(id: 'rm-nd-1', hotelId: 'ht-novotel-danang', name: 'Superior Han River View',
          description: 'Phòng Superior hiện đại tích hợp ban công ngắm trọn vẹn cảnh sông Hàn thơ mộng và các cây cầu lung linh.',
          price: 110.0, capacity: 2, imagePath: 'assets/images/danang_image.png',
          amenities: const ['Ban công ngắm Sông Hàn', 'Bàn làm việc công nghệ', 'Buồng tắm đứng vòi sen lớn', 'Két sắt an toàn']),
        Room(id: 'rm-nd-2', hotelId: 'ht-novotel-danang', name: 'Executive Suite River Panorama',
          description: 'Căn Suite góc sang trọng mở ra tầm nhìn toàn cảnh 180 độ sông Hàn và vịnh Đà Nẵng ở độ cao ấn tượng.',
          price: 180.0, capacity: 2, imagePath: 'assets/images/danang_image.png',
          amenities: const ['Góc nhìn toàn cảnh 180 độ', 'Đặc quyền Premier Lounge', 'Bồn tắm vô cực hướng sông', 'Hệ thống âm thanh Bluetooth']),
      ]),
  ];

  static List<TourPackage> tourPackages() => [
    TourPackage(
      id: 'tour-dalat-3n2d', name: 'Khám Phá Đà Lạt Mộng Mơ',
      description: 'Hành trình trọn gói 3 ngày 2 đêm tìm kiếm sự yên bình của Đà Lạt. Khám phá đỉnh Langbiang hùng vĩ, chèo thuyền Kayak trên Hồ Tuyền Lâm và tận hưởng tiệc nướng BBQ trong rừng thông mát lạnh.',
      imagePath: 'assets/images/dalat_image.jpg', duration: '3N/2Đ',
      price: 150.0, originalPrice: 199.0,
      destinations: ['Đà Lạt', 'Lâm Đồng'],
      includes: ['Vé máy bay khứ hồi khứ hồi', 'Khách sạn Mường Thanh 4 sao', 'Xe du lịch đưa đón', '3 bữa ăn chính đặc sản', 'Vé tham quan các điểm'],
      departure: 'SGN', isPopular: true,
    ),
    TourPackage(
      id: 'tour-phuquoc-4n3d', name: 'Phú Quốc Biển Xanh Gọi Mời',
      description: 'Nghỉ dưỡng trọn vẹn tại đảo ngọc Phú Quốc. Tour đi cano tham quan 4 đảo hoang sơ, lặn ngắm san hô bằng bình khí, vui chơi không giới hạn tại VinWonders & Safari và thưởng thức tiệc hải sản tối rực rỡ.',
      imagePath: 'assets/images/phuquoc_image.jpg', duration: '4N/3Đ',
      price: 299.0, originalPrice: 380.0,
      destinations: ['Phú Quốc', 'Kiên Giang'],
      includes: ['Vé máy bay khứ hồi', 'Resort InterContinental 5 sao', 'Cano thám hiểm 4 đảo', 'Buffet sáng mỗi ngày', 'Bảo hiểm du lịch trọn gói'],
      departure: 'HAN', isPopular: true,
    ),
    TourPackage(
      id: 'tour-sapa-3n2d', name: 'Khám Phá Sapa Hùng Vĩ Sương Mờ',
      description: 'Chinh phục đỉnh Fansipan 3.143m ngắm thung lũng mây trôi bồng bềnh. Tham quan bản cổ Bản Cát Cát của người H\'Mông, trải nghiệm tắm lá thuốc Dao Đỏ và thưởng thức lẩu cá tầm nóng hổi giữa tiết trời lạnh giá.',
      imagePath: 'assets/images/sapa_image.png', duration: '3N/2Đ',
      price: 135.0, originalPrice: 175.0,
      destinations: ['Sa Pa', 'Lào Cai'],
      includes: ['Xe giường nằm khứ hồi khứ hồi', 'Bungalow Sapa Jade Hill', 'Vé cáp treo Fansipan khứ hồi', 'Tắm lá thuốc người Dao', 'Ăn sáng buffet'],
      departure: 'HAN', isPopular: true,
    ),
    TourPackage(
      id: 'tour-halong-2n1d', name: 'Du Thuyền Vịnh Hạ Long 5 Sao',
      description: 'Kỳ nghỉ thượng lưu trên du thuyền 5 sao lướt êm đềm giữa hàng ngàn hòn đảo kỳ vĩ. Trải nghiệm lớp học nấu ăn trên boong tàu, chèo kayak khám phá Hang Luồn hoang sơ, tập Thái Cực Quyền đón bình minh rực rỡ.',
      imagePath: 'assets/images/halong_image.png', duration: '2N/1Đ',
      price: 179.0, originalPrice: 230.0,
      destinations: ['Hạ Long', 'Quảng Ninh'],
      includes: ['Xe Limousine đưa đón', 'Cabin Luxury ban công riêng', '4 bữa ăn hải sản thượng hạng', 'Chèo thuyền Kayak & Vé đò', 'Bảo hiểm hành trình'],
      departure: 'HAN', isPopular: true,
    ),
  ];
}
