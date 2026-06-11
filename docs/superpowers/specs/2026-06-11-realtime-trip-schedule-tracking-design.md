# Tai lieu thiet ke: Realtime tracking lich trinh chuyen di

**Ngay**: 11/06/2026  
**Chu de**: Them chuc nang theo doi lich trinh realtime cho tour/dia diem sau khi khach da dang ky, hien thi trong trang "Chuyen di cua toi".  
**Trang thai**: Da duyet thiet ke tong the, cho user review spec truoc khi implementation.

---

## 1. Muc tieu

Them kha nang theo doi lich trinh chi tiet cho tung booking trong "Chuyen di cua toi", giup nguoi dung biet hom nay lam gi, di dau, vao luc may gio, moc nao da qua, moc nao dang dien ra va moc tiep theo la gi.

Chuc nang can ho tro ca tour va dia diem:

- Tour co lich trinh mau theo goi tour.
- Dia diem co lich trinh mau theo destination.
- Khi khach dang ky, backend copy lich trinh mau thanh lich trinh rieng cua booking.
- Admin co the chinh lich trinh rieng cua tung booking, doi trang thai moc, them ghi chu/thong bao thay doi cho khach.
- App Flutter tu tinh realtime dua tren ngay khoi hanh, ngay thu may trong hanh trinh va gio cua tung moc.

## 2. Huong tiep can da chon

Su dung huong **Template + ban copy theo booking**.

Backend se co 2 lop du lieu:

1. **Schedule template** gan voi `TourPackage` hoac `Destination`.
   Template dung lam lich trinh mau: ngay 1 di dau, 08:00 lam gi, 12:00 an o dau.

2. **Trip schedule** gan voi tung `Trip`.
   Khi khach dat tour/dia diem, backend copy template thanh lich trinh rieng cua booking. Sau do admin sua booking nay ma khong anh huong template hoac cac booking khac.

Huong nay phu hop hon viec hard-code trong Flutter vi du lieu co the duoc quan tri tu backend, tai su dung duoc cho nhieu booking, va van linh hoat khi lich trinh thuc te thay doi.

## 3. Pham vi

### Trong pham vi

- Them schema Prisma cho schedule template, trip schedule va schedule update.
- Them API client de app lay lich trinh booking.
- Them API admin de quan ly template va lich trinh tung booking.
- Copy template sang booking khi dat tour/dia diem.
- Them model Flutter cho schedule.
- Tao widget timeline dung chung cho tour va dia diem.
- Tich hop timeline vao `TourTripDetailScreen` va `PlaceTripDetailScreen`.
- Mo rong admin HTML hien co de sua lich trinh booking va template co ban.
- Them seed du lieu mau cho mot so tour/dia diem hien co.

### Ngoai pham vi giai doan nay

- WebSocket/push realtime that su.
- Push notification native.
- Phan quyen admin chi tiet.
- Toi uu conflict editing khi nhieu admin sua cung luc.
- Lich trinh cho booking flight-only hoac hotel-only, tru khi admin tao rieng cho booking do.

## 4. Thiet ke du lieu

### 4.1 Schedule template

Them model de luu template cho tour/dia diem:

- `ScheduleTemplate`
  - `id`
  - `name`
  - `sourceType`: `tour` hoac `destination`
  - `tourPackageId?`
  - `destinationId?`
  - `createdAt`
  - `updatedAt`

- `ScheduleTemplateDay`
  - `id`
  - `templateId`
  - `dayNumber`
  - `title?`

- `ScheduleTemplateItem`
  - `id`
  - `dayId`
  - `startTime`
  - `endTime?`
  - `title`
  - `description?`
  - `locationName?`
  - `latitude?`
  - `longitude?`
  - `sortOrder`

Rang buoc:

- Mot template chi gan voi mot trong hai nguon: tour hoac destination.
- `dayNumber` bat dau tu 1.
- `startTime` dung dinh dang `HH:mm`.
- Item trong ngay sap xep theo `sortOrder`, sau do `startTime`.

### 4.2 Trip schedule

Khi booking duoc tao, template duoc copy sang cac bang rieng cua trip:

- `TripScheduleDay`
  - `id`
  - `tripId`
  - `dayNumber`
  - `date?`
  - `title?`

- `TripScheduleItem`
  - `id`
  - `dayId`
  - `startTime`
  - `endTime?`
  - `title`
  - `description?`
  - `locationName?`
  - `latitude?`
  - `longitude?`
  - `sortOrder`
  - `statusOverride?`: `completed`, `ongoing`, `upcoming`, `cancelled`, `delayed`
  - `note?`
  - `updatedAt`

- `TripScheduleUpdate`
  - `id`
  - `tripId`
  - `message`
  - `createdAt`

`TripScheduleDay.date` co the duoc tinh tu ngay khoi hanh neu parse duoc `Trip.date`. Neu khong parse duoc, app van co the hien thi theo `dayNumber`, nhung realtime theo ngay se chi chinh xac khi booking co ngay bat dau hop le.

## 5. API backend

### Client API

`GET /api/trips/:id/schedule`

Tra ve lich trinh cua booking:

```json
{
  "tripId": "trip_tour_123",
  "days": [
    {
      "id": "day_1",
      "dayNumber": 1,
      "date": "2026-06-20",
      "title": "Ngay 1",
      "items": [
        {
          "id": "item_1",
          "startTime": "08:30",
          "endTime": null,
          "title": "Xe va HDV don khach",
          "description": "Don tai khach san trung tam.",
          "locationName": "Da Lat",
          "latitude": 11.9404,
          "longitude": 108.4583,
          "statusOverride": null,
          "note": null,
          "updatedAt": "2026-06-11T09:00:00.000Z"
        }
      ]
    }
  ],
  "updates": [
    {
      "id": "update_1",
      "message": "Lich tham quan duoc doi sang 14:30 do thoi tiet.",
      "createdAt": "2026-06-11T09:00:00.000Z"
    }
  ]
}
```

Neu booking chua co lich trinh, API tra ve `days: []` va `updates: []`.

### Admin API

`GET /api/admin/schedule-templates`  
Lay danh sach template.

`POST /api/admin/schedule-templates`  
Tao template cho `tourPackageId` hoac `destinationId`.

`PUT /api/admin/schedule-templates/:id`  
Cap nhat template va danh sach ngay/item.

`DELETE /api/admin/schedule-templates/:id`  
Xoa template.

`GET /api/admin/trips/:id/schedule`  
Admin xem lich trinh rieng cua booking.

`PUT /api/admin/trips/:id/schedule`  
Admin cap nhat ngay/item cua booking.

`POST /api/admin/trips/:id/schedule-updates`  
Admin them thong bao thay doi cho khach.

`DELETE /api/admin/trips/:id/schedule-updates/:updateId`  
Xoa thong bao neu can.

## 6. Luong dat chuyen di

### Dat tour

1. App goi `POST /api/tours/book`.
2. Backend tao `Trip`.
3. Backend tim template co `sourceType = tour` va `tourPackageId` tuong ung.
4. Neu co template, backend copy ngay/item sang `TripScheduleDay` va `TripScheduleItem`.
5. API tra ve `Trip`; app them vao danh sach "Chuyen di cua toi".

### Dat dia diem

1. App goi `POST /api/trips/book`.
2. Backend tao `Trip`.
3. Backend tim template co `sourceType = destination` va `destinationId` tuong ung.
4. Neu co template, backend copy sang lich trinh rieng cua trip.
5. Neu khong co template, booking van thanh cong va app hien empty state lich trinh.

### Dat custom tour

Custom tour duoc tao nhu hien tai. Neu co the suy ra destination/template tu du lieu nguoi dung chon thi backend copy template gan nhat; neu khong, lich trinh de trong va admin bo sung sau.

## 7. Realtime logic trong Flutter

Khong dung WebSocket trong giai doan dau. App tinh realtime tu du lieu backend va thoi gian thiet bi.

Trang chi tiet trip se:

- Load schedule khi mo man hinh.
- Refresh khi nguoi dung keo de refresh.
- Tu cap nhat trang thai hien thi moi 60 giay khi man hinh dang mo.

Trang thai item:

- Neu `statusOverride` co gia tri thi uu tien gia tri admin.
- Neu khong co override:
  - Item thuoc ngay truoc ngay hien tai: `completed`.
  - Item thuoc ngay sau ngay hien tai: `upcoming`.
  - Item trong ngay hien tai:
    - Moc truoc moc dang dien ra: `completed`.
    - Moc gan nhat co `startTime <= now`: `ongoing`.
    - Cac moc sau thoi diem hien tai: `upcoming`.
- Neu item co `statusOverride = cancelled` hoac `delayed`, UI hien thi badge rieng va note neu co.

Neu ngay cua trip khong parse duoc, app chi tinh realtime theo gio cua ngay dang chon khi trip dang co status `Dang dien ra`/`Ongoing`; cac trang thai khac hien theo upcoming/completed.

## 8. Flutter UI

Tao cac model:

- `TripSchedule`
- `TripScheduleDay`
- `TripScheduleItem`
- `TripScheduleUpdate`

Tao service/provider:

- `TravelApiService.fetchTripSchedule(String tripId)`
- `tripScheduleProvider(tripId)` hoac Notifier tuong duong theo pattern Riverpod hien co.

Tao widget dung chung:

- `TripScheduleTimeline`
  - Nhan `Trip`, `TripSchedule`.
  - Hien banner update moi nhat neu co.
  - Hien card "Hom nay" voi item dang dien ra hoac item tiep theo.
  - Hien chip ngay: `Ngay 1`, `Ngay 2`, ...
  - Hien timeline theo ngay voi icon completed/ongoing/upcoming/cancelled/delayed.

Tich hop:

- `TourTripDetailScreen`
  - Thay phan hard-code milestones hien tai bang data tu API.
  - Giu map route va thong tin tour hien co.
  - Neu API khong co lich trinh, co the fallback sang lich trinh sinh tu tour hien tai trong giai doan chuyen doi.

- `PlaceTripDetailScreen`
  - Them muc "Theo doi lich trinh" sau thong tin dat cho/trang thai dat cho.
  - Dung cung `TripScheduleTimeline`.

Empty state:

- "Chua co lich trinh chi tiet cho chuyen di nay."
- Neu la admin-controlled booking, co the hien text ngan "Lich trinh se duoc cap nhat truoc ngay khoi hanh."

## 9. Admin UI

Mo rong `backend/admin/index.html`.

### Quan ly booking schedule

Trong trang "Dat cho":

- Them nut "Lich trinh" cho moi booking.
- Mo modal/panel quan ly lich trinh booking.
- Hien cac ngay cua booking.
- Moi ngay hien danh sach item theo gio.
- Form item gom:
  - Ngay thu may
  - Gio bat dau
  - Gio ket thuc
  - Tieu de
  - Mo ta
  - Dia diem
  - Latitude/longitude
  - Trang thai override
  - Ghi chu
- Co nut them/sua/xoa item.
- Co khu "Thong bao cho khach" de them update/change note.

### Quan ly template

Trong modal sua tour/dia diem:

- Them khu "Lich trinh mau".
- Admin tao/sua cac ngay va item mau.
- Template chi anh huong booking moi. Booking da tao khong bi thay doi tru khi admin sua rieng booking do.

Neu can giu admin UI gon trong giai doan dau, uu tien lam day du cho "Dat cho" truoc, sau do them template editor vao tour/dia diem trong cung dot neu khong lam qua lon file HTML.

## 10. Error handling

- Neu API schedule loi, Flutter hien message ngan va cho retry.
- Neu item admin nhap sai gio `HH:mm`, backend tra 400.
- Neu template khong co nguon hop le, backend tra 400.
- Neu trip/template khong ton tai, backend tra 404.
- Booking khong fail chi vi khong co template; schedule rong la trang thai hop le.

## 11. Migration va seed

Can tao Prisma migration cho cac bang schedule moi.

Seed can them template cho it nhat:

- Da Lat tour
- Phu Quoc tour
- Sapa tour
- Ha Long tour
- Mot vai destination nhu Da Nang, Hoi An neu co du lieu san.

Seed trip mau nen co it nhat mot trip dang dien ra de kiem tra realtime "Hom nay" va "Dang dien ra".

## 12. Ke hoach kiem thu

Backend:

- `npm run build` trong `backend`.
- `npx prisma generate` neu migration thay doi Prisma client.
- Kiem tra API:
  - `GET /api/trips/:id/schedule`
  - admin template CRUD
  - admin trip schedule update

Flutter:

- `flutter analyze`.
- Chay app, mo "Chuyen di cua toi".
- Mo chi tiet tour va dia diem.
- Kiem tra timeline hien dung ngay/gio/trang thai.
- Kiem tra refresh sau khi admin sua lich trinh.

Manual flow:

1. Tao/sua template cho mot tour trong admin.
2. Dat tour trong app.
3. Mo booking trong "Chuyen di cua toi".
4. Xem lich trinh duoc copy tu template.
5. Admin sua mot moc gio va them thong bao.
6. Refresh app, xac nhan timeline va update banner thay doi.

## 13. Rui ro va quyet dinh ky thuat

- `Trip.date` hien la string, co nhieu dinh dang. Implementation can them helper parse ngay bat dau that than trong, hoac luu `date` cua `TripScheduleDay` khi copy template.
- `tour_trip_detail_screen.dart` dang co nhieu logic hard-code. Khi implement nen tach timeline ra widget/model rieng de giam file phinh to.
- Admin hien la single HTML file lon. Can sua co kiem soat, tranh refactor toan bo admin trong dot nay.
- Khong dung WebSocket o giai doan dau de tranh tang do phuc tap backend/client. Auto refresh 60 giay la du cho nhu cau tracking lich trinh theo gio.
