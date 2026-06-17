import cors from "cors";
import express from "express";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import prisma from "./config/prisma.js";
import { routes } from "./routes/index.js";
import { adminAuth } from "./middlewares/auth.js";
import { Request, Response, NextFunction } from "express";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'", "cdn.tailwindcss.com"],
      scriptSrcAttr: ["'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'", "fonts.googleapis.com", "cdnjs.cloudflare.com"],
      fontSrc: ["'self'", "fonts.gstatic.com", "cdnjs.cloudflare.com"],
      imgSrc: ["'self'", "data:", "blob:"],
    },
  },
}));

// CORS whitelist
const allowedOrigins = (process.env.CORS_ORIGINS ?? "http://localhost:3000,http://10.0.2.2:3000").split(",");
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
}));

// Request body size limit
app.use(express.json({ limit: "1mb" }));

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: "Too many requests, please try again later" },
});
app.use("/api", apiLimiter);

// Redirect root to /admin
app.get("/", (req, res) => {
  res.redirect("/admin");
});

// Serve admin panel at /admin (no auth for static files)
app.use("/admin", express.static(join(__dirname, "../admin")));

// Serve uploads
app.use("/uploads", express.static(join(__dirname, "../public/uploads")));

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

// Mount all API routes
app.use("/api", routes);

// Global error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ message: "Internal server error" });
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
