import cors from "cors";
import express from "express";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import prisma from "./prisma.js";
import { store } from "./store.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

app.use(cors());
app.use(express.json());

// Serve admin panel at root
app.use(express.static(join(__dirname, "../admin")));

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

app.get("/api/bootstrap", async (_, res) => {
  const data = await store.getBootstrap();
  res.json(data);
  console.log("=============================================");
  console.log("✅ [BACKEND] Đã gửi dữ liệu từ Database cho ứng dụng Flutter thành công!");
  console.log("=============================================");
});

app.get("/api/favorites", async (_, res) => {
  const data = await store.getFavorites();
  res.json(data);
});

app.patch("/api/destinations/:id/favorite", async (req, res) => {
  const id = req.params.id;
  const isFavorite = req.body?.isFavorite;
  const updated = await store.updateFavorite(id, isFavorite);
  if (!updated) {
    res.status(404).json({ message: "Destination not found" });
    return;
  }
  res.json(updated);
});

app.get("/api/trips", async (req, res) => {
  const type = typeof req.query.type === "string" ? req.query.type : undefined;
  const data = await store.getTrips(type);
  res.json(data);
});

app.post("/api/trips/book", async (req, res) => {
  const { destinationId, date, guests, totalPrice } = req.body || {};

  if (typeof destinationId !== "string" || destinationId.trim().length === 0) {
    res.status(400).json({ message: "destinationId is required" });
    return;
  }

  const trip = await store.createTrip(destinationId, date, guests, totalPrice);
  if (!trip) {
    res.status(404).json({ message: "Destination not found" });
    return;
  }
  res.status(201).json(trip);
});

app.get("/api/flights/search", async (req, res) => {
  const departure = typeof req.query.departure === "string" ? req.query.departure : undefined;
  const arrival = typeof req.query.arrival === "string" ? req.query.arrival : undefined;
  const data = await store.searchFlights(departure, arrival);
  res.json(data);
});

app.post("/api/trips/book-flight", async (req, res) => {
  const flightId = req.body?.flightId;
  const date = req.body?.date;
  const guests = req.body?.guests;

  if (typeof flightId !== "string" || flightId.trim().length === 0) {
    res.status(400).json({ message: "flightId is required" });
    return;
  }

  const trip = await store.bookFlightTrip(flightId, date || "", guests || "");
  if (!trip) {
    res.status(404).json({ message: "Flight not found" });
    return;
  }
  res.status(201).json(trip);
});

app.get("/api/profile", async (_, res) => {
  const data = await store.getProfile();
  res.json(data);
});

app.put("/api/profile", async (req, res) => {
  const name = req.body?.name;
  const email = req.body?.email;
  const profile = await store.updateProfile(name, email);
  res.json(profile);
});

app.get("/api/documents", async (_, res) => {
  const data = await store.getDocuments();
  res.json(data);
});

app.post("/api/documents", async (req, res) => {
  const title = req.body?.title;
  const description = req.body?.description;
  const icon = req.body?.icon;
  const color = req.body?.color;

  if (
    typeof title !== "string" ||
    typeof description !== "string" ||
    typeof icon !== "string" ||
    typeof color !== "string" ||
    title.trim().length === 0 ||
    description.trim().length === 0 ||
    icon.trim().length === 0 ||
    color.trim().length === 0
  ) {
    res.status(400).json({ message: "title, description, icon and color are required" });
    return;
  }

  const doc = await store.createDocument(title, description, icon, color);
  res.status(201).json(doc);
});

// --- Hotels ---
app.get("/api/hotels", async (req, res) => {
  const location = typeof req.query.location === "string" ? req.query.location : undefined;
  const data = await store.getHotels(location);
  res.json(data);
});

app.get("/api/hotels/search", async (req, res) => {
  const q = typeof req.query.q === "string" ? req.query.q : "";
  const data = await store.searchHotels(q);
  res.json(data);
});

app.get("/api/hotels/:id", async (req, res) => {
  const data = await store.getHotelById(req.params.id);
  if (!data) {
    res.status(404).json({ message: "Hotel not found" });
    return;
  }
  res.json(data);
});

app.post("/api/hotels/book", async (req, res) => {
  const { roomId, checkIn, checkOut, guests } = req.body || {};
  if (!roomId || !checkIn || !checkOut || !guests) {
    res.status(400).json({ message: "roomId, checkIn, checkOut, and guests are required" });
    return;
  }
  const trip = await store.bookHotel(roomId, checkIn, checkOut, guests);
  if (!trip) {
    res.status(404).json({ message: "Room not found" });
    return;
  }
  res.status(201).json(trip);
});

// --- Tours ---
app.get("/api/tours", async (_, res) => {
  const data = await store.getTours();
  res.json(data);
});

app.get("/api/tours/:id", async (req, res) => {
  const data = await store.getTourById(req.params.id);
  if (!data) {
    res.status(404).json({ message: "Tour not found" });
    return;
  }
  res.json(data);
});

app.post("/api/tours/book", async (req, res) => {
  const { tourId, date, guests, totalPrice } = req.body || {};
  if (!tourId || !date || !guests) {
    res.status(400).json({ message: "tourId, date, and guests are required" });
    return;
  }
  const trip = await store.bookTour(tourId, date, guests, totalPrice);
  if (!trip) {
    res.status(404).json({ message: "Tour not found" });
    return;
  }
  res.status(201).json(trip);
});

// --- Custom Tour ---
app.post("/api/trips/custom-tour", async (req, res) => {
  const { destination, location, date, guests, imagePath, flightId, hotelId, roomId, totalPrice } = req.body || {};
  if (!destination || !location || !date || !guests || !imagePath) {
    res.status(400).json({ message: "Missing required fields" });
    return;
  }
  try {
    const trip = await store.createCustomTour({
      destination,
      location,
      date,
      guests,
      imagePath,
      flightId,
      hotelId,
      roomId,
      totalPrice,
    });
    res.status(201).json(trip);
  } catch (error) {
    res.status(500).json({ message: "Failed to create custom tour" });
  }
});

// ========== ADMIN ENDPOINTS ==========

// --- Admin: Stats ---
app.get("/api/admin/stats", async (_, res) => {
  const [destinations, hotels, flights, tours, tripsUpcoming, tripsHistory] = await Promise.all([
    prisma.destination.count(),
    prisma.hotel.count(),
    prisma.flight.count(),
    prisma.tourPackage.count(),
    prisma.trip.count({ where: { isUpcoming: true } }),
    prisma.trip.count({ where: { isUpcoming: false } }),
  ]);
  res.json({ destinations, hotels, flights, tours, tripsUpcoming, tripsHistory });
});

// --- Admin: Destinations CRUD ---
app.get("/api/admin/destinations", async (_, res) => {
  const data = await prisma.destination.findMany({ orderBy: { name: "asc" } });
  res.json(data);
});

app.post("/api/admin/destinations", async (req, res) => {
  const { id, name, location, category, rating, duration, imagePath, description, price, reviewsCount, isFavorite, isRecommended, latitude, longitude } = req.body || {};
  if (!name || !location) { res.status(400).json({ message: "name and location are required" }); return; }
  const dest = await prisma.destination.create({
    data: {
      id: id || `dest-${Date.now()}`,
      name, location,
      category: category || "Địa điểm",
      rating: rating || "4.0",
      duration: duration || "2N/1Đ",
      imagePath: imagePath || "",
      description: description || "",
      price: price || "0",
      reviewsCount: reviewsCount || "0",
      isFavorite: isFavorite ?? false,
      isRecommended: isRecommended ?? false,
      latitude: latitude ?? null,
      longitude: longitude ?? null,
    },
  });
  res.status(201).json(dest);
});

app.put("/api/admin/destinations/:id", async (req, res) => {
  const { id } = req.params;
  const { name, location, category, rating, duration, imagePath, description, price, reviewsCount, isFavorite, isRecommended, latitude, longitude } = req.body || {};
  const dest = await prisma.destination.update({
    where: { id },
    data: { name, location, category, rating, duration, imagePath, description, price, reviewsCount, isFavorite, isRecommended, latitude, longitude },
  });
  res.json(dest);
});

app.delete("/api/admin/destinations/:id", async (req, res) => {
  await prisma.destination.delete({ where: { id: req.params.id } });
  res.json({ ok: true });
});

// --- Admin: Hotels CRUD ---
app.get("/api/admin/hotels", async (_, res) => {
  const data = await prisma.hotel.findMany({ include: { rooms: true }, orderBy: { name: "asc" } });
  res.json(data);
});

app.post("/api/admin/hotels", async (req, res) => {
  const { id, name, location, address, rating, imagePath, description, priceFrom, amenities, latitude, longitude } = req.body || {};
  if (!name || !location) { res.status(400).json({ message: "name and location are required" }); return; }
  const hotel = await prisma.hotel.create({
    data: {
      id: id || `hotel-${Date.now()}`,
      name, location,
      address: address || "",
      rating: rating || "4.0",
      imagePath: imagePath || "",
      description: description || "",
      priceFrom: priceFrom || 0,
      amenities: amenities || [],
      latitude: latitude ?? null,
      longitude: longitude ?? null,
    },
  });
  res.status(201).json(hotel);
});

app.put("/api/admin/hotels/:id", async (req, res) => {
  const { name, location, address, rating, imagePath, description, priceFrom, amenities, latitude, longitude } = req.body || {};
  const hotel = await prisma.hotel.update({
    where: { id: req.params.id },
    data: { name, location, address, rating, imagePath, description, priceFrom, amenities, latitude, longitude },
  });
  res.json(hotel);
});

app.delete("/api/admin/hotels/:id", async (req, res) => {
  await prisma.room.deleteMany({ where: { hotelId: req.params.id } });
  await prisma.hotel.delete({ where: { id: req.params.id } });
  res.json({ ok: true });
});

// --- Admin: Flights CRUD ---
app.get("/api/admin/flights", async (_, res) => {
  const data = await prisma.flight.findMany({ orderBy: { airline: "asc" } });
  res.json(data);
});

app.post("/api/admin/flights", async (req, res) => {
  const { id, airline, airlineLogo, departure, arrival, departureTime, arrivalTime, price, duration } = req.body || {};
  if (!airline || !departure || !arrival) { res.status(400).json({ message: "airline, departure and arrival are required" }); return; }
  const flight = await prisma.flight.create({
    data: {
      id: id || `fl-${Date.now()}`,
      airline,
      airlineLogo: airlineLogo || "",
      departure,
      arrival,
      departureTime: departureTime || "",
      arrivalTime: arrivalTime || "",
      price: price || 0,
      duration: duration || "",
    },
  });
  res.status(201).json(flight);
});

app.put("/api/admin/flights/:id", async (req, res) => {
  const { airline, airlineLogo, departure, arrival, departureTime, arrivalTime, price, duration } = req.body || {};
  const flight = await prisma.flight.update({
    where: { id: req.params.id },
    data: { airline, airlineLogo, departure, arrival, departureTime, arrivalTime, price, duration },
  });
  res.json(flight);
});

app.delete("/api/admin/flights/:id", async (req, res) => {
  await prisma.flight.delete({ where: { id: req.params.id } });
  res.json({ ok: true });
});

// --- Admin: Tours CRUD ---
app.get("/api/admin/tours", async (_, res) => {
  const data = await prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } });
  res.json(data);
});

app.post("/api/admin/tours", async (req, res) => {
  const { id, name, description, imagePath, duration, price, originalPrice, destinations, includes, departure, isPopular, includesGuide, guideFee } = req.body || {};
  if (!name) { res.status(400).json({ message: "name is required" }); return; }
  const tour = await prisma.tourPackage.create({
    data: {
      id: id || `tour-${Date.now()}`,
      name,
      description: description || "",
      imagePath: imagePath || "",
      duration: duration || "",
      price: price || 0,
      originalPrice: originalPrice ?? null,
      destinations: destinations || [],
      includes: includes || [],
      departure: departure || "",
      isPopular: isPopular ?? false,
      includesGuide: includesGuide ?? true,
      guideFee: guideFee ?? 50,
    },
  });
  res.status(201).json(tour);
});

app.put("/api/admin/tours/:id", async (req, res) => {
  const { name, description, imagePath, duration, price, originalPrice, destinations, includes, departure, isPopular, includesGuide, guideFee } = req.body || {};
  const tour = await prisma.tourPackage.update({
    where: { id: req.params.id },
    data: { name, description, imagePath, duration, price, originalPrice, destinations, includes, departure, isPopular, includesGuide, guideFee },
  });
  res.json(tour);
});

app.delete("/api/admin/tours/:id", async (req, res) => {
  await prisma.tourPackage.delete({ where: { id: req.params.id } });
  res.json({ ok: true });
});

// --- Admin: Trips ---
app.get("/api/admin/trips", async (_, res) => {
  const data = await prisma.trip.findMany({ orderBy: { createdAt: "desc" } });
  res.json(data);
});

app.put("/api/admin/trips/:id", async (req, res) => {
  const { status, isUpcoming } = req.body || {};
  const trip = await prisma.trip.update({
    where: { id: req.params.id },
    data: { status, isUpcoming },
  });
  res.json(trip);
});

app.delete("/api/admin/trips/:id", async (req, res) => {
  await prisma.trip.delete({ where: { id: req.params.id } });
  res.json({ ok: true });
});

// --- Admin: Categories CRUD ---
app.get("/api/admin/categories", async (_, res) => {
  const data = await prisma.category.findMany({ orderBy: { name: "asc" } });
  res.json(data);
});

app.post("/api/admin/categories", async (req, res) => {
  const { name } = req.body || {};
  if (!name) { res.status(400).json({ message: "name is required" }); return; }
  const cat = await prisma.category.create({ data: { name } });
  res.status(201).json(cat);
});

app.delete("/api/admin/categories/:id", async (req, res) => {
  await prisma.category.delete({ where: { id: req.params.id } });
  res.json({ ok: true });
});

// ========================================

const server = app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});

// Graceful shutdown
async function shutdown() {
  console.log("\n🔌 Shutting down gracefully...");
  server.close();
  await prisma.$disconnect();
  console.log("✅ Database disconnected. Goodbye!");
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
