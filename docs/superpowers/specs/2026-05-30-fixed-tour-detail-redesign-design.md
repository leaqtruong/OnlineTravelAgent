# Tài liệu thiết kế: Thiết kế lại trang chi tiết Tour cố định (Fixed Tour Detail Redesign)

**Ngày**: 30/05/2026  
**Chủ đề**: Tối ưu hóa UI/UX cho trang chi tiết tour cố định (`tour_detail_screen.dart`) theo phong cách cao cấp, hiện đại và đồng bộ với theme chính của ứng dụng.  
**Trạng thái**: Đã duyệt (Approved)

---

## 1. Mục tiêu (Goals)
Thiết kế lại toàn bộ màn hình chi tiết tour cố định (`tour_detail_screen.dart`), chuyển từ một giao diện tĩnh đơn điệu thành một trang thông tin sinh động, giàu tính tương tác và mang lại cảm giác cao cấp nhất. Màn hình mới phải đồng bộ hoàn hảo với phong cách màu sắc (`AppTheme.primaryBlue`, `AppTheme.backgroundGray`) và cách bố trí của ứng dụng, đồng thời cung cấp đầy đủ các tính năng tương tác giúp tăng tỷ lệ chuyển đổi đặt tour.

---

## 2. Các Cải tiến Chính & Giải pháp Kỹ thuật
Chúng ta sẽ triển khai **Hướng tiếp cận 1: Thiết kế Cao cấp Cuộn liền mạch (Integrated Parallax Scroll)** với các tính năng đột phá sau:

### A. Parallax SliverAppBar & Glassmorphic Actions
*   **Visual**: Ảnh bìa kích thước lớn (`expandedHeight: 340`) với hiệu ứng trượt Parallax mượt mà khi cuộn trang. Dưới chân ảnh bìa có dải màu Gradient đen mờ chuyển tiếp mịn màng để nổi bật tiêu đề tour màu trắng.
*   **Floating Elements**: Nút Back hình tròn bọc trong lớp kính mờ (`BackdropFilter` và `CircleAvatar` mờ mịn) để giữ được tính tương phản cao trên bất kỳ bức ảnh nền nào. Thêm nút Yêu thích (`Favorite`) góc phải đồng bộ.
*   **Popular Badge**: Hiển thị thẻ gắn nhãn nổi bật như "Phổ biến" hoặc "Hot Deal" bằng màu vàng cam rực rỡ lơ lửng góc trên.

### B. Floating Overview Card (Thẻ Thông tin Tổng quan Nổi)
*   **Vị trí**: Đè nhẹ 50% lên phần chuyển tiếp giữa ảnh bìa và phần nội dung.
*   **Cấu trúc**: Card màu trắng tinh khiết, bo góc tròn 20px với hiệu ứng đổ bóng siêu mềm mại.
*   **Nội dung**: Gồm 3 cột thông tin nhanh với biểu tượng độc lập:
    1.  **Thời gian** (`duration`): Icon `Icons.access_time_rounded` màu xanh dương trên nền xám nhạt tròn.
    2.  **Khởi hành** (`departure`): Icon `Icons.flight_takeoff_rounded`.
    3.  **Điểm đến** (Số tỉnh thành): Icon `Icons.map_rounded`.

### C. Bộ chọn Ngày khởi hành & Số lượng Khách trực quan (Interactive Booking Widget)
*   **Chọn ngày**: Thay vì ngày tĩnh cố định `'25/06/2026'`, thiết kế một thẻ chọn lịch (`Departure Date`) trang nhã. Người dùng bấm vào sẽ kích hoạt Flutter `showDatePicker` với theme màu xanh dương đồng bộ.
*   **Đếm số khách (Guests Stepper)**: Tích hợp bộ đếm khách tăng/giảm (+/-) với thiết kế dạng nút tròn mềm mịn.
*   **Stateful updates**: Số lượng khách và ngày khởi hành được lưu vào state. Tổng giá tiền dưới thanh Bottom Sheet sẽ tự động nhân theo công thức: `Tổng tiền = (Giá tour + Phí hướng dẫn viên nếu bật) * Số lượng khách`.

### D. Trục Lịch trình Từng ngày Sinh động (Interactive Itinerary Timeline)
*   **Thuật toán tự động sinh lịch trình**: Sử dụng danh sách các tỉnh trong `widget.tour.destinations` để tự động xây dựng các thẻ lịch trình tương ứng từng ngày một cách tự nhiên.
*   **Visual**: Trục đường nối thẳng đứng dạng nét đứt hoặc nét liền phát sáng nhẹ màu xanh dương. Mỗi điểm mốc là một nút tròn biểu tượng lồng ghép tinh tế. Nội dung từng ngày hiển thị trong thẻ Card màu xám nhạt (`backgroundGray`) bo góc tròn 16px tạo điểm nhấn chiều sâu.

### E. Bản đồ Lộ trình Mini (Interactive Route Map)
*   **Tích hợp**: Sử dụng `FlutterMap` giống trang chi tiết điểm đến để vẽ bản đồ lộ trình di chuyển.
*   **Marker thông minh**: Tự động phân tích các tỉnh thành trong tour (Đà Nẵng, Phú Quốc, Sapa, Hạ Long...) để hiển thị Marker đỏ trên bản đồ cùng nét vẽ kết nối tuyến đường trực quan.

### F. Dịch vụ Bao gồm & Công tắc Hướng dẫn viên (Inclusions & Guide Toggle)
*   **Dịch vụ bao gồm (Inclusions Grid)**: Thiết kế dạng lưới 2 cột đẹp mắt với các Icon trực quan tương ứng (Ví dụ: khách sạn, ăn uống, xe đưa đón, vé tham quan) thay vì danh sách gạch đầu dòng đơn điệu.
*   **Công tắc Hướng dẫn viên (Guide Toggle)**: Dòng chuyển đổi `Switch.adaptive` tinh tế. Khi bật công tắc, phí hướng dẫn viên (`widget.tour.guideFee` nhân với số lượng khách) sẽ được cộng thêm vào tổng hóa đơn và hiển thị rõ ràng trên màn hình.

### G. Bottom Purchase Bar (Thanh Đặt Tour Cố định)
*   Thanh Bottom Sheet trắng tinh tế đổ bóng ngược lên trên.
*   Hiển thị chi tiết: Giá gốc (nếu có gạch bỏ), Nhãn "Tổng cộng", Số lượng khách đang chọn, và con số Tổng tiền nổi bật bằng màu `AppTheme.primaryBlue`.
*   Nút **"Đặt Tour Ngay"** lớn, bo góc 16px, hiệu ứng đổ bóng màu xanh dương, mang lại cảm xúc hành động mạnh mẽ cho người dùng.

---

## 3. Kiến trúc State & Dữ liệu (State Architecture)
Màn hình được quản lý thông qua `_TourDetailScreenState` với các biến trạng thái:
*   `DateTime _selectedDate`: Mặc định là `25/06/2026` hoặc ngày hiện tại + 7 ngày.
*   `int _guestsCount`: Số khách đặt tour (mặc định là `1`).
*   `bool _guideToggle`: Trạng thái bật/tắt dịch vụ Hướng dẫn viên kèm theo (mặc định theo `widget.tour.includesGuide`).

Hàm tính toán tổng tiền:
```dart
double get _totalPrice {
  double singlePrice = widget.tour.price;
  if (_guideToggle && widget.tour.includesGuide) {
    singlePrice += widget.tour.guideFee;
  }
  return singlePrice * _guestsCount;
}
```

---

## 4. Kế hoạch Kiểm thử & Xác minh (Verification Plan)
1.  **Giao diện trực quan**: Kiểm tra hiển thị ảnh bìa Parallax, các góc bo tròn phủ lên ảnh khi cuộn mượt mà.
2.  **Tương tác Date Picker**: Bấm chọn ngày, lịch mở ra, chọn ngày mới và cập nhật hiển thị chính xác.
3.  **Tương tác Khách (Stepper)**: Tăng/giảm số lượng khách, kiểm tra giới hạn không cho giảm xuống dưới 1, giá tiền tổng cộng ở Bottom cập nhật lập tức theo số khách.
4.  **Tương tác Guide Switch**: Bật/tắt công tắc HDV, kiểm tra giá tiền tổng cộng cộng thêm/trừ đi phí HDV tương ứng.
5.  **Bản đồ & Lịch trình**: Bản đồ mini hiển thị đúng vị trí điểm đến của tour. Trục hành trình hiển thị đúng số ngày khớp với số điểm đến.
6.  **Đặt tour thành công**: Bấm nút Đặt Tour, kiểm tra hiển thị SnackBar thông báo thành công và điều hướng trở lại màn hình trước.
