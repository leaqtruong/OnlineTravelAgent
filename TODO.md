# 🛠️ TODO & Cải Thiện Codebase (Ngày mai xử lý)

Dưới đây là danh sách các hạng mục cần tiếp tục tối ưu hoá và cải thiện cho dự án **OnlineTravelAgent** mà chúng ta chưa làm xong hôm nay:

## 1. 🌐 Đa Ngôn Ngữ (Localization - i18n)
- **Vấn đề:** Vẫn còn một số chuỗi text (string) tiếng Việt bị hardcode trực tiếp trong UI hoặc các class helper (ví dụ: `TourDetailHelpers.generateItinerary` đang chứa cứng các chuỗi như `"NgAy 1"`, `"KhYi hAnh & KhAm phA..."`). Ngoài ra do bị lỗi encoding nên text tiếng Việt đang hiển thị sai ký tự.
- **Giải pháp:** 
  - Thay thế toàn bộ các chuỗi này bằng `tr('key')` từ package `easy_localization`.
  - Cập nhật các file ngôn ngữ (ví dụ: `vi.json`, `en.json`) với đầy đủ các key bị thiếu.
  - Sửa lại các ký tự bị lỗi encoding trong `tour_detail_helpers.dart`.

## 2. 🧪 Tăng cường Integration Testing (End-to-End)
- **Vấn đề:** Hiện tại chúng ta đã có Widget Tests và Backend Unit Tests pass 100%. Tuy nhiên, thiếu các bài test luồng tích hợp (End-to-End).
- **Giải pháp:** 
  - Viết thêm E2E tests bằng package `integration_test` của Flutter.
  - Viết test mô phỏng luồng người dùng từ lúc Login -> Tìm Tour -> Đặt Tour -> Thanh Toán thành công để đảm bảo toàn bộ hệ thống hoạt động trơn tru với nhau.

## 3. 📶 Xử lý lỗi Mạng (Network Resilience)
- **Vấn đề:** `SyncService` (đồng bộ dữ liệu offline) hiện tại vẫn còn khả năng bị fail/crash nếu kết nối mạng của người dùng quá chập chờn.
- **Giải pháp:**
  - Áp dụng cơ chế **Exponential Backoff** (thử lại với thời gian tăng dần) khi gọi API bị lỗi.
  - Sử dụng package `retry` hoặc tự viết logic queue offline an toàn hơn.
  - Hiển thị UI thân thiện hơn cho người dùng khi mất mạng (không chỉ là Snackbar hiện lên rồi biến mất).

## 4. 🧹 Dọn dẹp Code thừa & Cảnh báo (Lints)
- Mặc dù `flutter analyze` đã gần như sạch sẽ, nhưng nếu thêm tính năng mới có thể sinh ra nợ kỹ thuật. Cần thường xuyên theo dõi các rules linting khắt khe hơn.
- Cân nhắc thêm các rule strict vào `analysis_options.yaml` để tự động chặn các code smell ngay từ lúc gõ code.

