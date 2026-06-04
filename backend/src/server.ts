import crypto from "crypto";
import cors from "cors";
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { store } from "./store.js";

const app = express();
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

app.use(cors());
app.use(express.json());

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use("/admin", express.static(path.join(__dirname, "../../admin-dashboard")));

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

app.get("/api/bootstrap", async (_, res) => {
  try {
    const data = await store.getBootstrap();
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.get("/api/favorites", async (_, res) => {
  try {
    const data = await store.getFavorites();
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.patch("/api/destinations/:id/favorite", async (req, res) => {
  const id = req.params.id;
  const isFavorite = req.body?.isFavorite;
  try {
    const updated = await store.updateFavorite(id, isFavorite);
    if (!updated) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.json(updated);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.delete("/api/trips/:id", async (req, res) => {
  const id = req.params.id;
  try {
    const deleted = await store.deleteTrip(id);
    if (!deleted) {
      res.status(404).json({ message: "Trip not found" });
      return;
    }
    res.json({ message: "Cancelled" });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.get("/api/trips", async (req, res) => {
  const type = typeof req.query.type === "string" ? req.query.type : undefined;
  try {
    const data = await store.getTrips(type);
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.post("/api/trips/book", async (req, res) => {
  const destinationId = req.body?.destinationId;
  const date = req.body?.date;
  const guests = req.body?.guests;
  const totalAmount = typeof req.body?.totalAmount === "number" ? req.body.totalAmount : undefined;
  const currency = typeof req.body?.currency === "string" ? req.body.currency : undefined;

  if (typeof destinationId !== "string" || destinationId.trim().length === 0) {
    res.status(400).json({ message: "destinationId is required" });
    return;
  }

  try {
    const trip = await store.createTrip(destinationId, date, guests, totalAmount, currency);
    if (!trip) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.status(201).json(trip);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.get("/api/flights/search", async (req, res) => {
  const departure = typeof req.query.departure === "string" ? req.query.departure : undefined;
  const arrival = typeof req.query.arrival === "string" ? req.query.arrival : undefined;
  try {
    const data = await store.searchFlights(departure, arrival);
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.post("/api/trips/book-flight", async (req, res) => {
  const flightId = req.body?.flightId;
  const date = req.body?.date;
  const guests = req.body?.guests;
  const totalAmount = typeof req.body?.totalAmount === "number" ? req.body.totalAmount : undefined;
  const currency = typeof req.body?.currency === "string" ? req.body.currency : undefined;

  if (typeof flightId !== "string" || flightId.trim().length === 0) {
    res.status(400).json({ message: "flightId is required" });
    return;
  }

  try {
    const trip = await store.bookFlightTrip(flightId, date || "", guests || "", totalAmount, currency);
    if (!trip) {
      res.status(404).json({ message: "Flight not found" });
      return;
    }
    res.status(201).json(trip);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.get("/api/profile", async (_, res) => {
  try {
    const data = await store.getProfile();
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.put("/api/profile", async (req, res) => {
  const name = req.body?.name;
  const email = req.body?.email;
  try {
    const profile = await store.updateProfile(name, email);
    res.json(profile);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.get("/api/documents", async (_, res) => {
  try {
    const data = await store.getDocuments();
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
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

  try {
    const doc = await store.createDocument(title, description, icon, color);
    res.status(201).json(doc);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

// ─── ADMIN API ENDPOINTS ───────────────────────────────────────────────────────

// 1. Destinations CRUD
app.get("/api/destinations", async (_, res) => {
  try {
    const data = await store.getDestinations();
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.post("/api/destinations", async (req, res) => {
  const { id, name, location, latitude, longitude, rating, duration, imagePath, description, price, reviewsCount, category } = req.body;
  if (!id || !name || !location || !price) {
    res.status(400).json({ message: "id, name, location, and price are required" });
    return;
  }
  const newDest = {
    id,
    name,
    location,
    latitude: typeof latitude === "number" ? latitude : undefined,
    longitude: typeof longitude === "number" ? longitude : undefined,
    rating: rating || "5.0",
    duration: duration || "3N/2Đ",
    imagePath: imagePath || "assets/images/dalat_image.jpg",
    description: description || "",
    price: String(price),
    reviewsCount: reviewsCount || "0",
    category: category || "Địa điểm",
    isFavorite: false,
    isRecommended: false
  };
  try {
    const result = await store.addDestination(newDest);
    res.status(201).json(result);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.put("/api/destinations/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const updated = await store.updateDestination(id, req.body);
    if (!updated) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.json(updated);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.delete("/api/destinations/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const deleted = await store.deleteDestination(id);
    if (!deleted) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.json({ message: "Destination deleted" });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

// 2. Flights CRUD
app.get("/api/flights", async (_, res) => {
  try {
    const data = await store.getFlights();
    res.json(data);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.post("/api/flights", async (req, res) => {
  const { id, airline, airlineLogo, departure, arrival, departureTime, arrivalTime, price, duration } = req.body;
  if (!id || !airline || !departure || !arrival || typeof price !== "number") {
    res.status(400).json({ message: "id, airline, departure, arrival, and numeric price are required" });
    return;
  }
  const newFlight = {
    id,
    airline,
    airlineLogo: airlineLogo || "assets/images/vna_logo.png",
    departure,
    arrival,
    departureTime: departureTime || "00:00",
    arrivalTime: arrivalTime || "00:00",
    price,
    duration: duration || "1h 00m",
  };
  try {
    const result = await store.addFlight(newFlight);
    res.status(201).json(result);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.put("/api/flights/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const updated = await store.updateFlight(id, req.body);
    if (!updated) {
      res.status(404).json({ message: "Flight not found" });
      return;
    }
    res.json(updated);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

app.delete("/api/flights/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const deleted = await store.deleteFlight(id);
    if (!deleted) {
      res.status(404).json({ message: "Flight not found" });
      return;
    }
    res.json({ message: "Flight deleted" });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

// 3. Trips CRUD (updating status/details)
app.put("/api/trips/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const updated = await store.updateTrip(id, req.body);
    if (!updated) {
      res.status(404).json({ message: "Trip not found" });
      return;
    }
    res.json(updated);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
});

// ─── VNPAY Configuration ───────────────────────────────────────────────────────
const VNPAY_CONFIG = {
  vnp_TmnCode: "JYKVVFIV",
  vnp_HashSecret: "HGDF3AQT9WD7IF36CX0PXVQ943F7PL35",
  vnp_Url: "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html",
  vnp_ReturnUrl: "http://localhost:3000/api/payment/vnpay/return",
  vnp_IpnUrl: "http://localhost:3000/api/payment/vnpay/ipn",
};

function sortObject(obj: Record<string, string>): Record<string, string> {
  const sorted: Record<string, string> = {};
  const keys = Object.keys(obj).sort();
  for (const key of keys) {
    sorted[key] = obj[key];
  }
  return sorted;
}

function createVNPayPaymentUrl(
  amountVnd: number,
  orderInfo: string,
  txnRef: string,
): string {
  const date = new Date();
  const pad2 = (n: number) => n.toString().padStart(2, "0");
  const createDate = `${date.getFullYear()}${pad2(date.getMonth() + 1)}${pad2(date.getDate())}${pad2(date.getHours())}${pad2(date.getMinutes())}${pad2(date.getSeconds())}`;

  const expireDate = new Date(date.getTime() + 15 * 60 * 1000);
  const expDate = `${expireDate.getFullYear()}${pad2(expireDate.getMonth() + 1)}${pad2(expireDate.getDate())}${pad2(expireDate.getHours())}${pad2(expireDate.getMinutes())}${pad2(expireDate.getSeconds())}`;

  const params: Record<string, string> = {
    vnp_Version: "2.1.0",
    vnp_Command: "pay",
    vnp_TmnCode: VNPAY_CONFIG.vnp_TmnCode,
    vnp_Amount: Math.round(amountVnd * 100).toString(),
    vnp_CurrCode: "VND",
    vnp_TxnRef: txnRef,
    vnp_OrderInfo: orderInfo,
    vnp_OrderType: "other",
    vnp_Locale: "vn",
    vnp_ReturnUrl: VNPAY_CONFIG.vnp_ReturnUrl,
    vnp_IpnUrl: VNPAY_CONFIG.vnp_IpnUrl,
    vnp_CreateDate: createDate,
    vnp_ExpireDate: expDate,
  };

  const sortedParams = sortObject(params);
  const signData = new URLSearchParams(sortedParams).toString();
  const hmac = crypto.createHmac("sha512", VNPAY_CONFIG.vnp_HashSecret);
  const signed = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");
  sortedParams.vnp_SecureHash = signed;

  return VNPAY_CONFIG.vnp_Url + "?" + new URLSearchParams(sortedParams).toString();
}

// ─── VNPAY Payment Endpoints ───────────────────────────────────────────────────

app.post("/api/payment/vnpay/create", (req, res) => {
  const { amount, orderInfo, txnRef, tripId } = req.body;

  if (typeof amount !== "number" || amount <= 0) {
    res.status(400).json({ message: "amount is required and must be > 0" });
    return;
  }
  if (typeof orderInfo !== "string" || orderInfo.trim().length === 0) {
    res.status(400).json({ message: "orderInfo is required" });
    return;
  }

  const ref = typeof txnRef === "string" && txnRef.trim().length > 0
    ? txnRef.trim()
    : `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

  if (typeof tripId === "string" && tripId.trim().length > 0) {
    store.addTransaction(ref, tripId.trim());
  }

  const paymentUrl = createVNPayPaymentUrl(amount, orderInfo, ref);

  res.json({
    code: "00",
    message: "success",
    data: {
      paymentUrl,
      txnRef: ref,
      amount,
      orderInfo,
    },
  });
});

app.post("/api/payment/vnpay/ipn", async (req, res) => {
  const vnpParams: Record<string, string> = {};
  for (const [key, value] of Object.entries(req.body)) {
    vnpParams[key] = String(value);
  }

  const secureHash = vnpParams.vnp_SecureHash;
  delete vnpParams.vnp_SecureHash;

  const sortedParams = sortObject(vnpParams);
  const signData = new URLSearchParams(sortedParams).toString();
  const hmac = crypto.createHmac("sha512", VNPAY_CONFIG.vnp_HashSecret);
  const signed = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

  if (signed !== secureHash) {
    res.json({ RspCode: "97", Message: "Invalid signature" });
    return;
  }

  const txnRef = vnpParams.vnp_TxnRef;
  const responseCode = vnpParams.vnp_ResponseCode;

  if (responseCode === "00") {
    try {
      await store.updateTripStatus(txnRef, "Đã thanh toán");
      console.log(`Payment success for transaction ${txnRef}`);
      res.json({ RspCode: "00", Message: "Success" });
    } catch (err) {
      res.json({ RspCode: "99", Message: "Database error" });
    }
  } else {
    console.log(`Payment failed for transaction ${txnRef}: ${responseCode}`);
    res.json({ RspCode: "00", Message: "Success" });
  }
});

app.get("/api/payment/vnpay/return", (req, res) => {
  const vnpParams: Record<string, string> = {};
  for (const [key, value] of Object.entries(req.query)) {
    vnpParams[key] = String(value);
  }

  const secureHash = vnpParams.vnp_SecureHash ?? "";
  delete vnpParams.vnp_SecureHash;

  const sortedParams = sortObject(vnpParams);
  const signData = new URLSearchParams(sortedParams).toString();
  const hmac = crypto.createHmac("sha512", VNPAY_CONFIG.vnp_HashSecret);
  const signed = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

  if (signed !== secureHash) {
    res.status(400).json({ message: "Invalid signature" });
    return;
  }

  res.json({
    code: vnpParams.vnp_ResponseCode === "00" ? "00" : "01",
    message: vnpParams.vnp_ResponseCode === "00" ? "Payment success" : "Payment failed",
    data: vnpParams,
  });
});

app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
