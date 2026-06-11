# Realtime Trip Schedule Tracking Implementation Plan

> Note: The `writing-plans` skill requested by the brainstorming workflow is not available in this session, so this plan is written directly from the approved spec.

**Goal:** Add realtime schedule tracking for registered tour/place trips. Users can open "Chuyen di cua toi" and see what happens today, where to go, at what time, current activity, next activity, and admin updates.

**Architecture:** Use schedule templates for `TourPackage` and `Destination`, copy templates into per-booking trip schedules when a `Trip` is created, and render trip schedules in Flutter with client-side realtime status calculation. Admin can edit templates and per-trip schedules, add item status overrides, and publish update notes.

**Tech Stack:** Flutter, Dart, Riverpod, Express, TypeScript, Prisma, PostgreSQL, single-file admin HTML.

---

### Task 1: Add Prisma Schedule Schema

**Files:**
- Modify: `backend/prisma/schema.prisma`

- [ ] **Step 1: Add schedule template models**
  Add `ScheduleTemplate`, `ScheduleTemplateDay`, and `ScheduleTemplateItem`.
  - Template supports `sourceType`, optional `tourPackageId`, optional `destinationId`, and timestamps.
  - Template days belong to a template.
  - Template items belong to a template day and contain `startTime`, `endTime`, title, description, location, coordinates, and `sortOrder`.

- [ ] **Step 2: Add trip schedule models**
  Add `TripScheduleDay`, `TripScheduleItem`, and `TripScheduleUpdate`.
  - Trip schedule days belong to `Trip`.
  - Trip schedule items belong to a trip schedule day.
  - Item override statuses support `completed`, `ongoing`, `upcoming`, `cancelled`, and `delayed`.
  - Schedule updates belong to `Trip`.

- [ ] **Step 3: Add relations and indexes**
  Add relations from `Trip`, `TourPackage`, and `Destination` where useful.
  Add indexes on template source ids, trip ids, day numbers, and item sort order.

- [ ] **Step 4: Generate Prisma client**
  Run from `backend`:
  ```bash
  npx prisma generate
  ```

---

### Task 2: Add Backend Schedule Utilities

**Files:**
- Create: `backend/src/services/schedule.service.ts`
- Modify: `backend/src/store.ts`

- [ ] **Step 1: Implement template lookup**
  Add helpers to find a template by tour package id or destination id.

- [ ] **Step 2: Implement date parsing**
  Add a conservative helper to parse the first date from `Trip.date`.
  Support current app-style dates such as `20/05/2026 - 23/05/2026`.
  If parsing fails, keep `TripScheduleDay.date` null.

- [ ] **Step 3: Implement copy-template-to-trip**
  Add a service function that receives `tripId`, template id, and optional trip start date.
  It creates `TripScheduleDay` and `TripScheduleItem` rows in a transaction.

- [ ] **Step 4: Wire copy into booking flows**
  Update:
  - `store.bookTour`
  - `store.createTrip`
  - best-effort `store.createCustomTour`

  Booking must still succeed if no template exists.

---

### Task 3: Add Client Schedule API

**Files:**
- Modify: `backend/src/controllers/client.controller.ts`
- Modify: `backend/src/routes/client.routes.ts`
- Modify: `backend/src/store.ts` or `backend/src/services/schedule.service.ts`

- [ ] **Step 1: Add schedule fetch service**
  Implement `getTripSchedule(tripId)` returning:
  - `tripId`
  - ordered `days`
  - ordered `items`
  - latest `updates`

- [ ] **Step 2: Add controller method**
  Add `clientController.getTripSchedule`.
  Return 404 if the trip does not exist.
  Return empty `days` and `updates` if the trip exists without schedule.

- [ ] **Step 3: Add route**
  Add:
  ```ts
  clientRouter.get("/trips/:id/schedule", clientController.getTripSchedule);
  ```

---

### Task 4: Add Admin Schedule API

**Files:**
- Modify: `backend/src/schemas/admin.schema.ts`
- Modify: `backend/src/controllers/admin.controller.ts`
- Modify: `backend/src/routes/admin.routes.ts`

- [ ] **Step 1: Add Zod schemas**
  Add schemas for:
  - schedule template create/update
  - template day/item payloads
  - trip schedule update payloads
  - schedule update note payload

- [ ] **Step 2: Add template CRUD**
  Add admin controller methods:
  - `getScheduleTemplates`
  - `createScheduleTemplate`
  - `updateScheduleTemplate`
  - `deleteScheduleTemplate`

- [ ] **Step 3: Add trip schedule admin endpoints**
  Add admin controller methods:
  - `getTripSchedule`
  - `updateTripSchedule`
  - `createTripScheduleUpdate`
  - `deleteTripScheduleUpdate`

- [ ] **Step 4: Register routes**
  Add:
  ```ts
  adminRouter.get("/schedule-templates", adminController.getScheduleTemplates);
  adminRouter.post("/schedule-templates", validate(adminScheduleTemplateSchema), adminController.createScheduleTemplate);
  adminRouter.put("/schedule-templates/:id", validate(adminScheduleTemplateSchema), adminController.updateScheduleTemplate);
  adminRouter.delete("/schedule-templates/:id", adminController.deleteScheduleTemplate);
  adminRouter.get("/trips/:id/schedule", adminController.getTripSchedule);
  adminRouter.put("/trips/:id/schedule", validate(adminTripScheduleSchema), adminController.updateTripSchedule);
  adminRouter.post("/trips/:id/schedule-updates", validate(adminTripScheduleUpdateSchema), adminController.createTripScheduleUpdate);
  adminRouter.delete("/trips/:id/schedule-updates/:updateId", adminController.deleteTripScheduleUpdate);
  ```

---

### Task 5: Seed Schedule Templates

**Files:**
- Modify: `backend/prisma/seed.ts`

- [ ] **Step 1: Clear schedule tables in safe order**
  Delete trip schedule updates/items/days and template items/days/templates before dependent rows if needed.

- [ ] **Step 2: Seed templates**
  Add templates for:
  - Da Lat tour
  - Phu Quoc tour
  - Sapa tour
  - Ha Long tour
  - at least one destination template such as Da Nang or Hoi An

- [ ] **Step 3: Seed at least one ongoing trip schedule**
  Ensure sample data includes a trip with status `Dang dien ra` or `Ongoing` and schedule data that can show a current or next activity.

---

### Task 6: Add Flutter Schedule Models And API

**Files:**
- Create: `lib/models/trip_schedule.dart`
- Modify: `lib/services/travel_api_service.dart`

- [ ] **Step 1: Add Dart models**
  Create:
  - `TripSchedule`
  - `TripScheduleDay`
  - `TripScheduleItem`
  - `TripScheduleUpdate`

  Include robust `fromJson` parsing and default empty collections.

- [ ] **Step 2: Add API method**
  Add:
  ```dart
  Future<TripSchedule> fetchTripSchedule(String tripId)
  ```
  It calls `/api/trips/$tripId/schedule`.

- [ ] **Step 3: Handle empty and failed responses**
  Empty schedules should render cleanly.
  API failures should be surfaced to provider/UI for retry.

---

### Task 7: Add Flutter Schedule Provider And Realtime Logic

**Files:**
- Create: `lib/providers/trip_schedule_provider.dart`
- Create: `lib/screens/my_trips/widgets/trip_schedule_timeline.dart`

- [ ] **Step 1: Add schedule provider**
  Use Riverpod to load schedule by trip id.
  Support refresh when the detail screen is pulled/refreshed or reopened.

- [ ] **Step 2: Add realtime status helper**
  Implement status calculation:
  - admin `statusOverride` wins
  - previous days are completed
  - future days are upcoming
  - current day uses `startTime <= now`
  - `cancelled` and `delayed` render as special states

- [ ] **Step 3: Add auto-refresh tick**
  Detail screens should rebuild schedule status every 60 seconds while visible.
  Data refetch can stay manual/route-entry based; visual status can tick locally.

- [ ] **Step 4: Build shared timeline widget**
  `TripScheduleTimeline` shows:
  - update banner for newest admin update
  - "Hom nay" summary card
  - day chips
  - timeline item cards
  - empty state and error retry state

---

### Task 8: Integrate Schedule UI Into Trip Detail Screens

**Files:**
- Modify: `lib/screens/my_trips/tour_trip_detail_screen.dart`
- Modify: `lib/screens/my_trips/place_trip_detail_screen.dart`

- [ ] **Step 1: Replace hard-coded tour milestone UI**
  In `TourTripDetailScreen`, replace hard-coded milestones with `TripScheduleTimeline`.
  Keep existing map, tour info, inclusions, and price sections.

- [ ] **Step 2: Add schedule UI to place detail**
  In `PlaceTripDetailScreen`, add "Theo doi lich trinh" section after booking/status info.
  Use the same `TripScheduleTimeline`.

- [ ] **Step 3: Preserve fallback behavior**
  If API returns no schedule, render empty state instead of crashing.

---

### Task 9: Extend Admin UI

**Files:**
- Modify: `backend/admin/index.html`

- [ ] **Step 1: Add schedule button to trip rows**
  In the "Dat cho" table, add a "Lich trinh" action button beside view/delete.

- [ ] **Step 2: Add trip schedule modal**
  Modal supports:
  - loading trip schedule
  - adding/editing/removing days and items
  - editing start/end time, title, description, location, coordinates, status override, and note
  - saving via `PUT /api/admin/trips/:id/schedule`

- [ ] **Step 3: Add update notes panel**
  Admin can add a message via `POST /api/admin/trips/:id/schedule-updates`.
  Existing updates are listed and can be deleted.

- [ ] **Step 4: Add basic template editor**
  Add schedule template editing for tour/destination records.
  If the HTML file becomes too large, keep booking schedule editing complete first and implement template editing with a compact modal.

---

### Task 10: Verification

- [ ] **Step 1: Backend build**
  Run:
  ```bash
  cd backend
  npm run build
  ```

- [ ] **Step 2: Prisma generation**
  Run:
  ```bash
  cd backend
  npx prisma generate
  ```

- [ ] **Step 3: Flutter analysis**
  Run:
  ```bash
  flutter analyze
  ```

- [ ] **Step 4: Flutter tests**
  Run:
  ```bash
  flutter test
  ```

- [ ] **Step 5: Manual smoke test**
  - Start backend.
  - Start Flutter app.
  - Open "Chuyen di cua toi".
  - Open tour booking and verify schedule timeline.
  - Open place booking and verify schedule timeline.
  - Edit schedule from admin.
  - Refresh app and verify updated item/update banner.

