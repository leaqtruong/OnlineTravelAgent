import crypto from "crypto";
import cors from "cors";
import express from "express";
import { store } from "./store.js";

const app = express();
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

app.use(cors());
app.use(express.json());

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

app.get("/api/bootstrap", (_, res) => {
  res.json(store.getBootstrap());
});

app.get("/api/favorites", (_, res) => {
  res.json(store.getFavorites());
});

app.patch("/api/destinations/:id/favorite", (req, res) => {
  const id = req.params.id;
  const isFavorite = req.body?.isFavorite;
  const updated = store.updateFavorite(id, isFavorite);
  if (!updated) {
    res.status(404).json({ message: "Destination not found" });
    return;
  }
  res.json(updated);
});

app.delete("/api/trips/:id", (req, res) => {
  const id = req.params.id;
  const deleted = store.deleteTrip(id);
  if (!deleted) {
    res.status(404).json({ message: "Trip not found" });
    return;
  }
  res.json({ message: "Cancelled" });
});

app.get("/api/trips", (req, res) => {
  const type = typeof req.query.type === "string" ? req.query.type : undefined;
  res.json(store.getTrips(type));
});

app.post("/api/trips/book", (req, res) => {
  const destinationId = req.body?.destinationId;
  const date = req.body?.date;
  const guests = req.body?.guests;
  const totalAmount = typeof req.body?.totalAmount === "number" ? req.body.totalAmount : undefined;
  const currency = typeof req.body?.currency === "string" ? req.body.currency : undefined;

  if (typeof destinationId !== "string" || destinationId.trim().length === 0) {
    res.status(400).json({ message: "destinationId is required" });
    return;
  }

  const trip = store.createTrip(destinationId, date, guests, totalAmount, currency);
  if (!trip) {
    res.status(404).json({ message: "Destination not found" });
    return;
  }
  res.status(201).json(trip);
});

app.get("/api/flights/search", (req, res) => {
  const departure = typeof req.query.departure === "string" ? req.query.departure : undefined;
  const arrival = typeof req.query.arrival === "string" ? req.query.arrival : undefined;
  res.json(store.searchFlights(departure, arrival));
});

app.post("/api/trips/book-flight", (req, res) => {
  const flightId = req.body?.flightId;
  const date = req.body?.date;
  const guests = req.body?.guests;
  const totalAmount = typeof req.body?.totalAmount === "number" ? req.body.totalAmount : undefined;
  const currency = typeof req.body?.currency === "string" ? req.body.currency : undefined;

  if (typeof flightId !== "string" || flightId.trim().length === 0) {
    res.status(400).json({ message: "flightId is required" });
    return;
  }

  const trip = store.bookFlightTrip(flightId, date || "", guests || "", totalAmount, currency);
  if (!trip) {
    res.status(404).json({ message: "Flight not found" });
    return;
  }
  res.status(201).json(trip);
});

app.get("/api/profile", (_, res) => {
  res.json(store.getProfile());
});

app.put("/api/profile", (req, res) => {
  const name = req.body?.name;
  const email = req.body?.email;
  const profile = store.updateProfile(name, email);
  res.json(profile);
});

app.get("/api/documents", (_, res) => {
  res.json(store.getDocuments());
});

app.post("/api/documents", (req, res) => {
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

  const doc = store.createDocument(title, description, icon, color);
  res.status(201).json(doc);
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

app.post("/api/payment/vnpay/ipn", (req, res) => {
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
    store.updateTripStatus(txnRef, "Đã thanh toán");
    console.log(`Payment success for transaction ${txnRef}`);
    res.json({ RspCode: "00", Message: "Success" });
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
