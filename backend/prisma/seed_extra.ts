import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Adding EXTRA rich data...");

  // --- Extra Destinations ---
  const extraDestinations = [
    {
      id: "hue",
      name: "Cố Đô Huế",
      location: "Thừa Thiên Huế, VN",
      rating: "4.7",
      duration: "3N/2Đ",
      imagePath: "assets/images/hue_image.jpg",
      description: "Quần thể di tích Cố đô Huế trầm mặc bên dòng sông Hương thơ mộng, mang đậm dấu ấn lịch sử triều Nguyễn.",
      price: "3200000",
      reviewsCount: "850",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 16.4637,
      longitude: 107.5909,
    },
    {
      id: "quynhon",
      name: "Quy Nhơn",
      location: "Bình Định, VN",
      rating: "4.6",
      duration: "3N/2Đ",
      imagePath: "assets/images/quynhon_image.jpg",
      description: "Thành phố biển xinh đẹp với bãi tắm Kỳ Co nước trong vắt như Maldives, Eo Gió hoang sơ lộng gió.",
      price: "3500000",
      reviewsCount: "620",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 13.7829,
      longitude: 109.2196,
    },
    {
      id: "hagiang",
      name: "Hà Giang",
      location: "Hà Giang, VN",
      rating: "4.9",
      duration: "4N/3Đ",
      imagePath: "assets/images/hagiang_image.jpg",
      description: "Cao nguyên đá Đồng Văn hùng vĩ, Mã Pí Lèng hiểm trở và những cánh đồng hoa tam giác mạch.",
      price: "4800000",
      reviewsCount: "1.2k",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 22.8233,
      longitude: 104.9836,
    },
    {
      id: "vungtau",
      name: "Vũng Tàu",
      location: "Bà Rịa - Vũng Tàu, VN",
      rating: "4.5",
      duration: "2N/1Đ",
      imagePath: "assets/images/vungtau_image.jpg",
      description: "Thành phố biển sôi động gần TP.HCM với bãi Sau sầm uất, ngọn hải đăng cổ kính.",
      price: "1500000",
      reviewsCount: "2.5k",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: false,
      latitude: 10.3459,
      longitude: 107.0842,
    },
    {
      id: "condao",
      name: "Côn Đảo",
      location: "Bà Rịa - Vũng Tàu, VN",
      rating: "4.8",
      duration: "3N/2Đ",
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Hòn đảo hoang sơ, mang đậm dấu ấn lịch sử. Biển xanh cát trắng tĩnh lặng tuyệt đối.",
      price: "4500000",
      reviewsCount: "950",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 8.6823,
      longitude: 106.6022,
    },
    {
      id: "phuyen",
      name: "Phú Yên",
      location: "Phú Yên, VN",
      rating: "4.7",
      duration: "3N/2Đ",
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Xứ hoa vàng trên cỏ xanh với Gành Đá Đĩa độc đáo, Mũi Điện đón bình minh sớm nhất VN.",
      price: "3600000",
      reviewsCount: "710",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 13.0886,
      longitude: 109.3245,
    },
    {
      id: "mocchau",
      name: "Mộc Châu",
      location: "Sơn La, VN",
      rating: "4.6",
      duration: "2N/1Đ",
      imagePath: "assets/images/mocchau_image.jpg",
      description: "Cao nguyên Mộc Châu mùa hoa cải trắng, hoa mận nở rợp trời. Không khí se lạnh thơ mộng.",
      price: "2200000",
      reviewsCount: "1.1k",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: false,
      latitude: 20.8524,
      longitude: 104.6401,
    },
    {
      id: "ninhthuan",
      name: "Ninh Thuận",
      location: "Ninh Thuận, VN",
      rating: "4.5",
      duration: "3N/2Đ",
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Vịnh Vĩnh Hy tuyệt đẹp, tháp Chàm rêu phong và những vườn nho trĩu quả.",
      price: "3200000",
      reviewsCount: "680",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: false,
      latitude: 11.5833,
      longitude: 108.9833,
    },
    {
      id: "bentre",
      name: "Bến Tre",
      location: "Bến Tre, VN",
      rating: "4.4",
      duration: "1N/0Đ",
      imagePath: "assets/images/hoian_image.webp",
      description: "Hành trình khám phá miệt vườn sông nước miền Tây, chèo xuồng ba lá dưới rặng dừa xanh.",
      price: "850000",
      reviewsCount: "420",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: false,
      latitude: 10.2443,
      longitude: 106.3756,
    },
    {
      id: "dalat-pine",
      name: "Rừng Thông Đà Lạt",
      location: "Lâm Đồng, VN",
      rating: "4.8",
      duration: "1N/0Đ",
      imagePath: "assets/images/dalat_image.jpg",
      description: "Trải nghiệm cắm trại ngắm mây giữa rừng thông ngoạn mục.",
      price: "1500000",
      reviewsCount: "2.1k",
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 11.9404,
      longitude: 108.4583,
    }
  ];

  for (const dest of extraDestinations) {
    // using upsert to avoid conflicts if script is run multiple times
    await prisma.destination.upsert({
      where: { id: dest.id },
      update: dest,
      create: dest,
    });
  }
  console.log(`  Added ${extraDestinations.length} Extra Destinations.`);

  // --- Extra Hotels ---
  const extraHotels = [
    {
      id: "ht-imperial-vt",
      name: "The Imperial Hotel Vung Tau",
      location: "Vũng Tàu, VN",
      latitude: 10.3392,
      longitude: 107.0911,
      rating: "4.7",
      imagePath: "assets/images/danang_image.png",
      description: "Khách sạn 5 sao mang phong cách kiến trúc Phục Hưng Châu Âu cổ điển.",
      priceFrom: 2800000,
      address: "159 Thùy Vân, Thắng Tam, Vũng Tàu",
      amenities: ["Bãi biển riêng", "Hồ bơi Hoàng Gia", "Beach Club", "Spa & Gym"],
    },
    {
      id: "ht-silkpath-hue",
      name: "Silk Path Grand Hue Hotel",
      location: "Thừa Thiên Huế, VN",
      latitude: 16.4621,
      longitude: 107.5925,
      rating: "4.8",
      imagePath: "assets/images/hanoi_image.png",
      description: "Khách sạn 5 sao mang đậm nét đài các cung đình Huế kết hợp nét kiến trúc Đông Dương.",
      priceFrom: 1950000,
      address: "02 Lê Lợi, TP Huế",
      amenities: ["Hồ bơi ngoài trời", "Chi Spa", "Nhà hàng Nam Phương", "Phòng xông hơi"],
    },
    {
      id: "ht-fcl-quynhon",
      name: "FLC City Hotel Beach Quy Nhon",
      location: "Bình Định, VN",
      latitude: 13.7745,
      longitude: 109.2272,
      rating: "4.6",
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Khách sạn đẳng cấp nằm ngay trung tâm thành phố với view trực diện biển Quy Nhơn.",
      priceFrom: 2100000,
      address: "Đường An Dương Vương, Quy Nhơn",
      amenities: ["Hồ bơi vô cực", "Sky Bar", "Spa trị liệu", "Khu vui chơi trẻ em"],
    },
    {
      id: "ht-pao-sapa",
      name: "Pao's Sapa Leisure Hotel",
      location: "Lào Cai, VN",
      latitude: 22.3312,
      longitude: 103.8455,
      rating: "4.7",
      imagePath: "assets/images/sapa_image.png",
      description: "Khách sạn 5 sao có thiết kế theo hình dáng ruộng bậc thang độc đáo, ôm trọn thung lũng Mường Hoa.",
      priceFrom: 2450000,
      address: "Đường Mường Hoa, Thị trấn Sapa",
      amenities: ["Bể bơi nước ấm trong nhà", "Phòng Gym view núi", "Mây Club Lounge", "A Lìn Spa"],
    },
    {
      id: "ht-amanoci",
      name: "Amanoi Resort",
      location: "Ninh Thuận, VN",
      latitude: 11.6667,
      longitude: 109.2000,
      rating: "5.0",
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Khu nghỉ dưỡng siêu sang, biệt lập trên sườn núi nhìn ra vịnh Vĩnh Hy, điểm đến của giới siêu giàu.",
      priceFrom: 25000000,
      address: "Vườn quốc gia Núi Chúa, Ninh Hải",
      amenities: ["Spa Pavilions trên hồ", "Biệt thự có hồ bơi riêng", "Yoga Pavilion", "Dịch vụ quản gia"],
    }
  ];

  for (const hotel of extraHotels) {
    await prisma.hotel.upsert({
      where: { id: hotel.id },
      update: hotel,
      create: hotel,
    });
  }
  console.log(`  Added ${extraHotels.length} Extra Hotels.`);

  // --- Extra Tour Packages ---
  const extraTours = [
    {
      id: "tour-hagiang-loop",
      name: "Hà Giang Loop 4N3Đ - Cực Bắc Tổ Quốc",
      description: "Chinh phục đèo Mã Pí Lèng, sông Nho Quế và cột cờ Lũng Cú. Trải nghiệm văn hóa H'Mông.",
      duration: "4N/3Đ",
      price: 3500000,
      imagePath: "assets/images/sapa_image.png",
      destinations: ["Quản Bạ", "Đồng Văn", "Mã Pí Lèng", "Lũng Cú"],
      includes: ["Xe máy", "Homestay", "Các bữa ăn", "Vé tham quan"],
      departure: "Hà Nội",
    },
    {
      id: "tour-hue-heritage",
      name: "Huế - Hành trình Di sản 3N2Đ",
      description: "Thăm Đại Nội, Lăng Minh Mạng, Khải Định và nghe Nhã nhạc trên sông Hương.",
      duration: "3N/2Đ",
      price: 2800000,
      imagePath: "assets/images/hanoi_image.png",
      destinations: ["Đại Nội Huế", "Lăng Minh Mạng", "Sông Hương"],
      includes: ["Khách sạn 4 sao", "Xe du lịch", "Vé thuyền rồng", "HDV"],
      departure: "TP.HCM",
    },
    {
      id: "tour-quynhon-phuyen",
      name: "Quy Nhơn - Phú Yên: Hoa Vàng Cỏ Xanh",
      description: "Khám phá Kỳ Co, Eo Gió, Gành Đá Đĩa và Mũi Điện trứ danh.",
      duration: "4N/3Đ",
      price: 4200000,
      imagePath: "assets/images/phuquoc_image.jpg",
      destinations: ["Kỳ Co", "Eo Gió", "Gành Đá Đĩa", "Mũi Điện"],
      includes: ["Khách sạn 3 sao", "Vé máy bay", "Ăn uống hải sản", "Xe đưa đón"],
      departure: "Hà Nội",
    },
    {
      id: "tour-condao-spiritual",
      name: "Côn Đảo - Miền Đất Thiêng 3N2Đ",
      description: "Viếng nghĩa trang Hàng Dương, thăm nhà tù Côn Đảo và nghỉ dưỡng tại bãi biển trong xanh.",
      duration: "3N/2Đ",
      price: 5500000,
      imagePath: "assets/images/phuquoc_image.jpg",
      destinations: ["Mộ cô Sáu", "Nhà tù Côn Đảo", "Bãi Đầm Trầu"],
      includes: ["Vé tàu cao tốc", "Khách sạn 3 sao", "Đồ lễ viếng", "HDV địa phương"],
      departure: "Vũng Tàu",
    },
    {
      id: "tour-mekong-delta",
      name: "Khám phá Miền Tây Sông Nước 2N1Đ",
      description: "Chợ nổi Cái Răng, lò kẹo dừa Bến Tre và nghe đờn ca tài tử.",
      duration: "2N/1Đ",
      price: 1800000,
      imagePath: "assets/images/hoian_image.webp",
      destinations: ["Mỹ Tho", "Bến Tre", "Cần Thơ"],
      includes: ["Thuyền tham quan", "Trái cây miệt vườn", "Khách sạn Cần Thơ", "Xe khách"],
      departure: "TP.HCM",
    }
  ];

  for (const tour of extraTours) {
    await prisma.tourPackage.upsert({
      where: { id: tour.id },
      update: tour,
      create: tour,
    });
  }
  console.log(`  Added ${extraTours.length} Extra Tour Packages.`);

  // --- Extra Flights ---
  const extraFlights = [
    {
      id: "fl-extra-1",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "HAN",
      arrival: "HUI",
      departureTime: "08:15",
      arrivalTime: "09:30",
      price: 1650000,
      duration: "1h 15m",
    },
    {
      id: "fl-extra-2",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "SGN",
      arrival: "UIH",
      departureTime: "10:45",
      arrivalTime: "11:55",
      price: 1150000,
      duration: "1h 10m",
    },
    {
      id: "fl-extra-3",
      airline: "Bamboo Airways",
      airlineLogo: "assets/images/bb_logo.png",
      departure: "SGN",
      arrival: "VCS",
      departureTime: "14:20",
      arrivalTime: "15:20",
      price: 1850000,
      duration: "1h 00m",
    },
    {
      id: "fl-extra-4",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "HAN",
      arrival: "TBB",
      departureTime: "16:00",
      arrivalTime: "17:40",
      price: 2100000,
      duration: "1h 40m",
    },
    {
      id: "fl-extra-5",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "SGN",
      arrival: "HAN",
      departureTime: "22:00",
      arrivalTime: "00:10",
      price: 850000,
      duration: "2h 10m",
    }
  ];

  for (const flight of extraFlights) {
    await prisma.flight.upsert({
      where: { id: flight.id },
      update: flight,
      create: flight,
    });
  }
  console.log(`  Added ${extraFlights.length} Extra Flights.`);

  console.log("🎉 EXTRA Seeding completed successfully!");
}

main()
  .catch((e) => {
    console.error("❌ EXTRA Seeding failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
