import { Router } from "express";
import { paymentController } from "../controllers/payment.controller.js";
import { clientAuth, optionalAuth } from "../middlewares/auth.js";

export const paymentRouter = Router();

paymentRouter.post("/vnpay/create", clientAuth, paymentController.createVnpayPayment);
paymentRouter.get("/vnpay/return", paymentController.vnpayReturn);
paymentRouter.post("/vnpay/ipn", paymentController.vnpayIpn);
paymentRouter.get("/vnpay/status/:tripId", optionalAuth, paymentController.checkPaymentStatus);

paymentRouter.post("/momo/create", clientAuth, paymentController.createMomoPayment);
paymentRouter.get("/momo/return", paymentController.momoReturn);
