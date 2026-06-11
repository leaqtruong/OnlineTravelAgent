import cors from "cors";
import express from "express";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import prisma from "./config/prisma.js";
import { routes } from "./routes/index.js";
import { adminAuth } from "./middlewares/auth.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

app.use(cors());
app.use(express.json());

// Redirect root to /admin
app.get("/", (req, res) => {
  res.redirect("/admin");
});

// Serve admin panel at /admin
app.use("/admin", adminAuth, express.static(join(__dirname, "../admin")));

// Serve uploads
app.use("/uploads", express.static(join(__dirname, "../public/uploads")));

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

// Mount all API routes
app.use("/api", routes);

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
