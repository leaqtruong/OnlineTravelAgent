import { Router } from "express";
import { authController } from "../controllers/auth.controller.js";
import { validate } from "../middlewares/validate.js";
import { clientAuth } from "../middlewares/auth.js";
import { loginSchema, registerSchema } from "../schemas/auth.schema.js";

export const authRouter = Router();

authRouter.post("/login", validate(loginSchema), authController.login);
authRouter.post("/register", validate(registerSchema), authController.register);
authRouter.post("/become-partner", clientAuth, authController.becomePartner);
