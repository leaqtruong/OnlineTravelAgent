# Antigravity Handoff

## Bối cảnh

Mục tiêu của lượt làm việc này là rà lại các lỗi quan trọng trong `OnlineTravelAgent`, ưu tiên phần payment, auth/partner, admin schedule, realtime sync và một số chỗ Flutter đang dễ gây lỗi.

## Đã làm

### Backend

- Sửa `backend/src/controllers/payment.controller.ts`
  - Kiểm tra ownership của trip trước khi tạo/xem trạng thái payment.
  - Ràng buộc amount theo `trip.totalPrice` khi có dữ liệu.
  - Verify chữ ký và transaction reference cho luồng VNPAY/MoMo.
  - Trả lỗi rõ hơn khi config VNPAY thiếu.
- Sửa `backend/src/routes/payment.routes.ts`
  - Bỏ `optionalAuth` ở luồng status.
  - Thêm `POST /momo/ipn`.
- Sửa `backend/src/services/vnpay.service.ts`
  - Bỏ fallback secret hardcode.
  - Đọc config từ env và fail rõ nếu thiếu.
- Sửa `backend/src/controllers/auth.controller.ts`
  - Chặn tự nâng quyền partner mặc định, chỉ mở khi `ALLOW_SELF_PARTNER_SIGNUP=true`.
- Sửa `backend/src/routes/partner.routes.ts`
  - Thêm validate cho CRUD hotel/tour/room.
- Sửa `backend/src/controllers/partner.controller.ts`
  - Loại `id`/`partnerId` khỏi body update để giảm mass assignment.
- Sửa `backend/src/controllers/admin.controller.ts`
  - Siết update schedule item theo `tripId`.
  - Validate `HH:mm`, `title`, `status`.
  - Emit `schedule_updated` khi schedule đổi.
- Sửa `backend/src/server.ts`
  - Thêm `leave_trip_room` và `leave_tour_room`.

### Flutter

- Sửa `lib/services/travel_api_service.dart`
  - Encode query an toàn hơn.
  - Tắt offline queue cho `createVnpayPayment` và `createMomoPayment`.
- Sửa `lib/screens/checkout/checkout_screen.dart`
  - Luôn gửi `totalPrice` khi book.
- Sửa `lib/providers/trip_schedule_provider.dart`
  - Filter event realtime theo `tripId`.
  - Leave socket room khi dispose.
- Sửa `lib/providers/tour_provider.dart`
  - Filter event realtime theo `tourId`.
  - Leave socket room khi dispose.
- Sửa `lib/screens/my_trips/widgets/trip_schedule_timeline.dart`
  - Tính trạng thái milestone theo ngày hiện tại và giờ trong ngày.
- Sửa `lib/screens/my_trips/my_trips_screen.dart`
  - Sửa prefix filter cho trip tour/custom.

## Test đã chạy

- `flutter analyze` pass
- `flutter test` pass, `120/120`
- `npm run build` trong `backend` pass
- `npm test` trong `backend` pass, `24/24`
- `git diff --check` không có lỗi whitespace

## Đang dở / cần làm tiếp

Không còn yêu cầu nào bị bỏ sót! 🎉

### Việc đã hoàn thành ở lượt này:

1. Đã tắt offline queue cho các request tạo booking trong `lib/services/travel_api_service.dart`.
2. Đã thêm `requestId` / idempotency key ở backend cho các mutation tạo booking.
3. Đã chạy lại verify thành công:
   - `flutter analyze` pass
   - `flutter test` pass
   - `npm run build` pass
   - `npm test` pass
   - `git diff --check` pass
