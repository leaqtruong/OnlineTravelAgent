import { Router } from "express";
import { clientRouter } from "./client.routes.js";
import { adminRouter } from "./admin.routes.js";
import { adminAuth } from "../middlewares/auth.js";

export const routes = Router();

routes.use("/", clientRouter);
routes.use("/admin", adminAuth, adminRouter);
