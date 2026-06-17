import { Router } from "express";
import rateLimit from "express-rate-limit";
import { clientRouter } from "./client.routes.js";
import { adminRouter } from "./admin.routes.js";
import { authRouter } from "./auth.routes.js";
import { adminAuth } from "../middlewares/auth.js";

export const routes = Router();

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: "Too many login attempts, please try again later" },
});

routes.use("/", clientRouter);
routes.use("/admin", adminAuth, adminRouter);
routes.use("/auth", authLimiter, authRouter);
