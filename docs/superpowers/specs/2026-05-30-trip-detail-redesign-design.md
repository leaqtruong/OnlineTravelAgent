# Thiết kế lại Trang Chi tiết Chuyến đi từ My Trips

**Ngày**: 30/05/2026
**Trạng thái**: Đã duyệt (Approved)

---

## 1. Mục tiêu

Thiết kế lại hoàn toàn trải nghiệm khi người dùng bấm vào một chuyến đi từ trang "Chuyến đi của tôi". Tách thành 2 trang riêng biệt:

- **`PlaceTripDetailScreen`** — cho các chuyến đi loại Địa điểm
- **`TourTripDetailScreen`** — cho các chuyến đi loại Tour/Custom Tour

Cả hai trang đều tuân theo phong cách **Parallax Hero + DraggableScrollableSheet**, đồng bộ với `DestinationDetailScreen` hiện tại. Giữ nguyên bảng màu `AppTheme.primaryBlue` (#176FF2), nền trắng/xám nhạt, sạch sẽ, hiện đại.

---

## 2. Routing Logic (tại `my_trips_screen.dart`)

Khi bấm vào một `TripCard`:

```dart
if (trip.isCustom || trip.id.startsWith('trip_tour_') || trip.id.startsWith('trip_custom_')) {
  // → Mở TourTripDetailScreen
} else {
  // → Mở PlaceTripDetailScreen
}
```

---

## 3. Trang chi tiết Địa điểm (`PlaceTripDetailScreen`)

File: `lib/screens/my_trips/place_trip_detail_screen.dart`

### Cấu trúc Layout

```
┌─────────────────────────────────────┐
│  HERO IMAGE (45% màn hình)          │
│  ┌──────┐              ┌──────────┐ │
│  │ Back │              │  Share   │ │
│  └──────┘              └──────────┘ │
│                                     │
│                                     │
├─────────────────────────────────────┤
│ DraggableScrollableSheet            │
│ ┌─────────────────────────────────┐ │
│ │  Drag Handle Bar                │ │
│ │                                 │ │
│ │  ▸ Tên điểm đến  [Status Badge]│ │
│ │  ▸ 📍 Vị trí                   │ │
│ │                                 │ │
│ │  ┌─────┬──────┬──────┐          │ │
│ │  │ ⭐  │  ⏱   │  🌤  │          │ │
│ │  │Rate │Time  │ Temp │          │ │
│ │  └─────┴──────┴──────┘          │ │
│ │                                 │ │
│ │  ── Thông tin đặt chỗ ──       │ │
│ │  📅 Ngày đi: ...               │ │
│ │  👥 Hành khách: ...             │ │
│ │  🔖 Mã đặt chỗ: BK-XXXXXX     │ │
│ │                                 │ │
│ │  ── Trạng thái Booking ──      │ │
│ │  ●──●──◎──○                     │ │
│ │  Đặt  Xác  Diễn  Hoàn         │ │
│ │       nhận  ra    thành        │ │
│ │                                 │ │
│ │  ── Vị trí trên bản đồ ──     │ │
│ │  ┌─────────────────────────┐   │ │
│ │  │     FlutterMap          │   │ │
│ │  │        📍               │   │ │
│ │  └─────────────────────────┘   │ │
│ │                                 │ │
│ │  ── Tiện ích ──                │ │
│ │  [Wifi] [Bữa sáng] [Hồ bơi]  │ │
│ │                                 │ │
│ │  ── Hành động ──               │ │
│ │  (Hỗ trợ)(Hóa đơn)(Chia sẻ)  │ │
│ │  (Hủy vé)                      │ │
│ │                                 │ │
│ │  ── Đánh giá & Nhận xét ──    │ │
│ │  [Review cards...]              │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Các thành phần chi tiết

#### A. Hero Image (Ảnh bìa)
- Chiếm 45% chiều cao màn hình
- `Image.asset(trip.imagePath, fit: BoxFit.cover)`
- Nút Back (góc trái) và Share (góc phải) bọc trong container trắng mờ `Colors.white.withOpacity(0.9)`, bo góc 12px
- Không dùng Hero animation (vì không có shared element với TripCard)

#### B. DraggableScrollableSheet
- `initialChildSize: 0.6`, `minChildSize: 0.6`, `maxChildSize: 0.95`
- Container trắng, bo góc trên 32px
- Drag handle bar nhỏ (40x4px, xám nhạt, bo tròn) ở trên cùng

#### C. Header Row
- Tên điểm đến: `fontSize: 28, fontWeight: FontWeight.bold`
- Location row: Icon `location_on` màu xanh + text xám
- Status badge góc phải: chip bo tròn 12px với màu theo trạng thái:
  - Đang diễn ra: nền cam nhạt, text cam
  - Sắp tới: nền xanh nhạt, text xanh
  - Đã đi/Lịch sử: nền xám nhạt, text xám

#### D. Quick Stats Row (3 cột)
- Giống `_infoItem` trong `DestinationDetailScreen`
- 3 mục: Đánh giá (⭐), Thời lượng (⏱), Thời tiết (🌤 24°C)
- Icon trên nền `backgroundGray` bo tròn 12px

#### E. Thông tin Đặt chỗ (Booking Info Card)
- Container nền `Color(0xFFF5F7FA)` bo tròn 16px, padding 16px
- 3 dòng thông tin dạng icon + label + value:
  - `calendar_today` → Ngày đi → `trip.date`
  - `person` → Hành khách → `trip.guests`
  - `confirmation_num_outlined` → Mã đặt chỗ → `BK-{hash}`
- Nếu `trip.totalPrice != null`: thêm dòng giá tổng cộng

#### F. Booking Status Timeline (Trục trạng thái)
- Timeline ngang 4 bước: **Đã đặt → Đã xác nhận → Đang diễn ra → Hoàn thành**
- Logic highlight dựa trên `trip.status`:
  - "Sắp tới" / "Đã xác nhận" → highlight đến bước 2
  - "Đang diễn ra" / "Ongoing" → highlight đến bước 3
  - "Đã đi" / "Hoàn thành" → highlight tất cả 4 bước
  - Mặc định → highlight bước 1
- Visual: Nút tròn 12px (xanh = đã qua, xám = chưa đến) nối bằng đường kẻ ngang
- Text label dưới mỗi nút, fontSize 10

#### G. Bản đồ (FlutterMap)
- Container chiều cao 200px, bo tròn 16px, viền xám nhạt
- Lookup tọa độ từ danh sách destinations trong provider dựa trên `trip.destination` hoặc `trip.location`
- Nếu không tìm thấy tọa độ → hiển thị placeholder "Chưa có thông tin tọa độ"

#### H. Tiện ích (Facilities)
- Scroll ngang, giống `DestinationDetailScreen`
- 5 mục cố định: Wifi, Bữa sáng, Hồ bơi, Gửi xe, Gym
- Icon trên nền `backgroundGray` bo tròn 12px

#### I. Action Buttons (Nút hành động)
- Row 4 nút tròn: Hỗ trợ, Hóa đơn, Chia sẻ, Hủy vé
- Thiết kế: icon trên nền `Color(0xFFF5F7FA)`, shape tròn, viền xám nhạt
- Text label dưới icon, fontSize 12

#### J. Đánh giá & Nhận xét
- Tái sử dụng logic reviews từ `DestinationDetailScreen._getSampleReviews()`
- Rating summary header (điểm lớn + progress bars)
- Danh sách review cards

---

## 4. Trang chi tiết Tour (`TourTripDetailScreen`)

File: `lib/screens/my_trips/tour_trip_detail_screen.dart`

### Cấu trúc Layout

```
┌─────────────────────────────────────┐
│  HERO IMAGE (45% màn hình)          │
│  ┌──────┐  [Gói Tour]  ┌──────────┐│
│  │ Back │               │  Share   ││
│  └──────┘               └──────────┘│
├─────────────────────────────────────┤
│ DraggableScrollableSheet            │
│ ┌─────────────────────────────────┐ │
│ │  Drag Handle                    │ │
│ │                                 │ │
│ │  ▸ Tên tour      [Status Badge]│ │
│ │  ▸ ✈ Khởi hành từ: SGN        │ │
│ │                                 │ │
│ │  ┌─────┬──────┬──────┐          │ │
│ │  │ ⏱   │  ✈   │  📍  │          │ │
│ │  │Time │Depart│Dest  │          │ │
│ │  └─────┴──────┴──────┘          │ │
│ │                                 │ │
│ │  ── Thông tin đặt chỗ ──       │ │
│ │  📅 Ngày khởi hành: ...        │ │
│ │  👥 Hành khách: ...             │ │
│ │  🔖 Mã đặt chỗ: BK-XXXXXX     │ │
│ │  💰 Tổng thanh toán: $XXX      │ │
│ │                                 │ │
│ │  ── Trạng thái Booking ──      │ │
│ │  ●──●──◎──○                     │ │
│ │                                 │ │
│ │  ── Lịch trình Tour ──         │ │
│ │  │ Ngày 1: Điểm đến A          │ │
│ │  │   Khám phá ...               │ │
│ │  │ Ngày 2: Điểm đến B          │ │
│ │  │   Trải nghiệm ...           │ │
│ │                                 │ │
│ │  ── Bản đồ lộ trình ──        │ │
│ │  ┌─────────────────────────┐   │ │
│ │  │  FlutterMap + markers   │   │ │
│ │  └─────────────────────────┘   │ │
│ │                                 │ │
│ │  ── Dịch vụ bao gồm ──       │ │
│ │  ┌──────────┬──────────┐       │ │
│ │  │ 🏨 KS    │ 🍽 Ăn uống│       │ │
│ │  │ 🚌 Xe    │ 🎫 Vé    │       │ │
│ │  └──────────┴──────────┘       │ │
│ │                                 │ │
│ │  ── Thông tin giá ──           │ │
│ │  Giá gốc: $380 (gạch bỏ)      │ │
│ │  Giá tour: $299                │ │
│ │  Tổng cộng: $299               │ │
│ │                                 │ │
│ │  ── Hành động ──               │ │
│ │  (Hỗ trợ)(Hóa đơn)(Chia sẻ)  │ │
│ │  (Hủy vé)                      │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Các thành phần chi tiết

#### A. Hero Image
- Giống PlaceTripDetailScreen
- Thêm badge "Gói Tour" (hoặc "Tự thiết kế" nếu `trip.isCustom`) nổi góc trên phải ảnh
- Badge dùng gradient (teal cho Tour, cam cho Custom) giống `TripCard._getClassificationGradient()`

#### B. Header Row
- Tên tour: `fontSize: 28, fontWeight: FontWeight.bold`
- Dòng phụ: `✈ Khởi hành từ: {departure}` — text xanh dương
- Status badge giống PlaceTripDetailScreen

#### C. Quick Stats Row (3 cột)
- Thời lượng (`duration`): Icon `access_time_rounded`
- Khởi hành (`departure`): Icon `flight_takeoff_rounded`
- Số điểm đến: Icon `map_rounded`, giá trị = `destinations.length`

#### D. Thông tin Đặt chỗ
- Giống Place nhưng thêm dòng tổng thanh toán nếu có `totalPrice`

#### E. Booking Status Timeline
- Giống hệt PlaceTripDetailScreen

#### F. Lịch trình Tour (Itinerary Timeline)
- Trục dọc với nét liền màu xanh nhạt (`primaryBlue.withOpacity(0.2)`)
- Mỗi ngày là một node:
  - Nút tròn 10px xanh dương trên trục
  - Tiêu đề: "Ngày {i}: {destination}" — bold, fontSize 15
  - Mô tả ngắn auto-generated: "Khám phá và trải nghiệm tại {destination}"
  - Card nền `backgroundGray` bo tròn 12px
- Số ngày lấy từ `tour.destinations.length`
- Nếu không có thông tin tour (chỉ có Trip object) → hiển thị 1 mục "Toàn bộ hành trình"

#### G. Bản đồ Lộ trình
- FlutterMap chiều cao 200px
- Lookup tọa độ cho TỪNG điểm đến trong tour
- Nhiều marker đỏ + polyline kết nối (nếu ≥ 2 điểm)
- Zoom fit bounds để chứa tất cả markers

#### H. Dịch vụ bao gồm (Inclusions Grid)
- Grid 2 cột, gap 12px
- Mỗi mục: icon tròn xanh + text mô tả
- Lấy từ `tour.includes` nếu có, nếu không → hiển thị mặc định
- Icon mapping: khách sạn → `hotel`, ăn uống → `restaurant`, xe → `directions_bus`, vé → `confirmation_num`, bảo hiểm → `health_and_safety`

#### I. Thông tin giá (Price Card)
- Container nền `backgroundGray` bo tròn 16px
- Nếu có `originalPrice` > `price`: hiển thị giá gốc gạch bỏ + % giảm giá
- Giá thực tế: lớn, bold, màu `primaryBlue`
- Tổng cộng (nếu có `totalPrice` từ trip): lớn nhất, bold

#### J. Action Buttons
- Giống hệt PlaceTripDetailScreen

---

## 5. Dữ liệu Tour lookup

Khi mở `TourTripDetailScreen`, cần tra cứu thông tin tour đầy đủ từ `TravelProvider.tourPackages` dựa trên tên trip (`trip.destination` match với `tour.name`). Nếu không tìm thấy tour tương ứng → hiển thị với dữ liệu cơ bản từ Trip object.

---

## 6. Shared Widgets

Các widget dùng chung giữa 2 trang nên được tách ra `lib/screens/my_trips/widgets/`:

- `booking_info_card.dart` — Card thông tin đặt chỗ
- `booking_status_timeline.dart` — Timeline trạng thái ngang
- `trip_action_buttons.dart` — 4 nút hành động
- `trip_section_header.dart` — Tiêu đề section thống nhất (fontSize 20, bold)

---

## 7. Kế hoạch Kiểm thử

1. **Routing**: Bấm trip loại Tour → mở TourTripDetailScreen. Bấm trip loại Place → mở PlaceTripDetailScreen.
2. **Hero Image**: Ảnh hiển thị đúng, scroll mượt, DraggableSheet kéo lên/xuống.
3. **Status Timeline**: Highlight đúng bước dựa trên `trip.status`.
4. **Bản đồ**: Marker hiển thị đúng vị trí. Tour có nhiều markers.
5. **Tour Lookup**: Tour trips hiển thị đúng lịch trình, dịch vụ, giá.
6. **Action Buttons**: Bấm mỗi nút hiện SnackBar thông báo tương ứng.
7. **Responsive**: Layout không bị tràn/overflow trên các kích thước màn hình khác nhau.
