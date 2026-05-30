# Tài liệu thiết kế: Thiết kế lại trang Chuyến đi của tôi (My Trips Screen Redesign)

**Ngày**: 30/05/2026  
**Chủ đề**: Tái thiết kế toàn bộ UI/UX cho trang danh sách chuyến đi (`my_trips_screen.dart`) và widget thẻ chuyến đi (`trip_card.dart`) theo phong cách bento box cao cấp, hiện đại và đồng bộ với theme của ứng dụng.  
**Trạng thái**: Đã duyệt (Approved)

---

## 1. Mục tiêu (Goals)
Nâng cấp trang danh sách chuyến đi của người dùng (`my_trips_screen.dart`) từ giao diện phẳng đơn điệu thành một trang quản lý hành trình sang trọng, giàu tính tương tác. Màn hình mới sẽ sử dụng phong cách **Bento Card** hiện đại, kết hợp với thanh chuyển Tab viên nang mềm mại và giao diện trống đầy cảm hứng, mang lại trải nghiệm người dùng cao cấp chuẩn mobile-native.

---

## 2. Các Cải tiến Chính & Giải pháp Kỹ thuật
Chúng ta sẽ triển khai **Hướng tiếp cận 1A: Floating Capsule & Dynamic Bento Card** với các thành phần đột phá sau:

### A. Cá nhân hóa Header (Cinematic Header Block)
*   **Bố cục**: Sử dụng một hàng ngang (`Row`) thoáng đãng trên cùng của vùng an toàn (`SafeArea`).
*   **Chi tiết**:
    *   **Bên trái**: Tiêu đề lớn "Chuyến đi của tôi" (`fontSize: 30`, `fontWeight: FontWeight.bold`, màu `AppTheme.textBlack`). Dưới tiêu đề là subtitle chào mừng lấy tên thực tế từ profile của người dùng: `"Chào mừng trở lại, ${provider.profile.name.trim()}!"` (nếu không có tên sẽ hiện câu truyền cảm hứng *"Bắt đầu hành trình mới của bạn"*).
    *   **Bên phải**: Một hình tròn Avatar đại diện của người dùng với chữ cái đầu tiên viết hoa nổi bật trên nền gradient mịn, bao bọc bởi viền tròn phát sáng mờ.

### B. Thanh chuyển Tab Viên nang (Pill-shape Capsule TabBar)
*   **Cấu trúc**: Bọc widget `TabBar` bên trong một `Container` màu trắng sang trọng có chiều cao cố định 56px, đổ bóng mờ ảo.
*   **Đặc điểm**:
    *   Sử dụng thuộc tính `indicator` của TabBar với `BoxDecoration` để vẽ một viên nang xanh dương (`AppTheme.primaryBlue`) bo góc tròn 12px đè đằng sau tab đang chọn.
    *   Tự động cập nhật màu chữ chữ sang trắng khi được chọn và màu xám thanh lịch khi không được chọn.
    *   Loại bỏ hoàn toàn các gạch dưới lỗi thời, tạo trải nghiệm chuyển tab mượt mà.

### C. Thẻ chuyến đi Bento cao cấp (`widgets/trip_card.dart`)
*   **Kích thước**: Chiều cao thẻ cố định `142px` giúp bố trí nội dung gọn gàng, cân đối.
*   **Shadow**: Đổ bóng mềm mại dạng bento hiện đại: `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: Offset(0, 8))`.
*   **Ảnh đại diện (Bên trái)**:
    *   Ảnh có góc bo tròn sâu `20px` nằm vừa vặn bên trong thẻ chính.
    *   **Badge phân loại hành trình**: Tích hợp một thẻ nhãn nhỏ xinh đè lên góc trái ảnh:
        *   Nếu là tour tự thiết kế (`trip.isCustom == true`): Hiển thị thẻ *"Tự thiết kế"* màu vàng cam ấm áp.
        *   Nếu là tour cố định: Hiển thị thẻ *"Gói Tour"* màu xanh ngọc.
*   **Bố cục thông tin (Bên phải)**:
    *   Sử dụng cột dọc `Column` căn đều `MainAxisAlignment.spaceBetween`.
    *   **Tên chuyến đi**: Chữ to đậm 18px giới hạn tối đa 1 dòng kèm dấu ba chấm nếu quá dài.
    *   **Chi tiết lịch**: Row hiển thị lịch đi (`Icons.calendar_today_rounded`) và số khách (`Icons.people_rounded`) kèm các nhãn gọn gàng.
    *   **Địa điểm & Trạng thái**:
        *   Biểu tượng ghim màu xanh dương nổi bật kèm tên địa danh (`trip.location`) viết chữ xanh đậm.
        *   Badge trạng thái bo tròn ở góc phải: Xanh dương pastel cho "Sắp tới" và Xám pastel cho "Lịch sử".

### D. Giao diện trống đầy cảm hứng (Illustrated Empty State)
*   Hiển thị một khu vực được thiết kế cực đẹp khi không có chuyến đi nào trong danh sách:
    *   Icon `Icons.explore_rounded` màu xanh dương nhạt cỡ lớn (size 80).
    *   Tiêu đề nhạt: *"Sẵn sàng cho chuyến đi mới?"*
    *   Mô tả chi tiết: *"Bạn chưa có chuyến đi nào được lên lịch. Hãy bắt đầu lên kế hoạch cho hành trình tiếp theo của bạn ngay hôm nay."*
    *   Nút **"Khám phá ngay"** thiết kế bo góc, khi nhấn sẽ thực hiện đóng màn hình (`Navigator.pop(context)`) để đưa người dùng trở lại màn hình chính tìm kiếm.

---

## 3. Kiến trúc Dữ liệu & State
Màn hình được quản lý hoàn toàn tự động thông qua `Provider` lắng nghe các cached biến từ `TravelProvider`:
*   `provider.upcomingTrips`: Danh sách các chuyến đi sắp tới.
*   `provider.historyTrips`: Danh sách các chuyến đi trong lịch sử.

Các bài test sẽ được cập nhật/viết mới để đảm bảo biên dịch và hoạt động trơn tru.

---

## 4. Kế hoạch Kiểm thử & Xác minh (Verification Plan)
1.  **Giao diện trực quan**: Kiểm tra hiển thị header cá nhân hóa với Avatar, TabBar viên nang trượt mượt mà.
2.  **Thẻ Bento Card**: Kiểm tra ảnh đại diện hiển thị đúng góc bo, badge "Tự thiết kế/Gói Tour" hiển thị chuẩn xác dựa trên thuộc tính `isCustom`.
3.  **Tương tác Tab**: Bấm chọn giữa các Tab "Sắp tới" và "Lịch sử", dữ liệu chuyến đi lọc và hiển thị chính xác.
4.  **Tương tác Empty State**: Nếu danh sách trống, kiểm tra giao diện trống hiển thị đầy đủ và nút "Khám phá ngay" hoạt động bình thường.
