import cors from "cors";
import express from "express";
import prisma from "./prisma.js";
import { store } from "./store.js";

const app = express();
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

app.use(cors());
app.use(express.json());

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

app.get("/api/bootstrap", async (_, res) => {
  const data = await store.getBootstrap();
  res.json(data);
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
