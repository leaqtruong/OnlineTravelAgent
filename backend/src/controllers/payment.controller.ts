import { Request, Response } from "express";
import crypto from "crypto";
import prisma from "../config/prisma.js";
import { vnpayService } from "../services/vnpay.service.js";
import { asyncHandler } from "../utils/asyncHandler.js";

const MOMO_PARTNER_CODE = process.env.MOMO_PARTNER_CODE ?? "MOMO";
const MOMO_ACCESS_KEY = process.env.MOMO_ACCESS_KEY ?? "";
const MOMO_SECRET_KEY = process.env.MOMO_SECRET_KEY ?? "";
const MOMO_URL = process.env.MOMO_URL ?? "https://test-payment.momo.vn/v2/gateway/api/create";

export const paymentController = {
  createVnpayPayment: asyncHandler(async (req: Request, res: Response) => {
    const { tripId, amount, orderInfo } = req.body;
    if (!tripId || !amount) {
      res.status(400).json({ message: "tripId and amount are required" });
      return;
    }

    const ipAddr = req.ip ?? req.socket.remoteAddress ?? "127.0.0.1";
    const locale = (req.body.locale as string) ?? "vn";

    const { paymentUrl, txnRef } = vnpayService.createPaymentUrl({
      tripId,
      amount,
      orderInfo: orderInfo ?? `Thanh toan cho don hang ${tripId}`,
      ipAddr,
      locale,
    });

    await vnpayService.updateTripPaymentStatus(tripId, "pending", txnRef);

    res.json({
      paymentUrl,
      txnRef,
      tripId,
      amount,
    });
  }),

  vnpayReturn: asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const result = vnpayService.verifyReturnUrl(query);

    let txnRef = result.txnRef;
    let tripId = txnRef.split("-").slice(0, -1).join("-");

    if (tripId.includes("-")) {
      const parts = txnRef.split("-");
      parts.pop();
      tripId = parts.join("-");
    }

    if (result.isValid && result.responseCode === "00") {
      try {
        await vnpayService.updateTripPaymentStatus(
          tripId,
          "paid",
          txnRef,
          result.transactionNo
        );
        await prisma.trip.update({
          where: { id: tripId },
          data: { status: "Đã xác nhận", isUpcoming: true },
        });
      } catch {}
    } else {
      try {
        await vnpayService.updateTripPaymentStatus(tripId, "failed", txnRef);
      } catch {}
    }

    res.send(`
      <!DOCTYPE html>
      <html lang="vi">
      <head><meta charset="UTF-8"><title>Kết quả thanh toán</title>
      <style>
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: #f5f5f5; }
        .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); text-align: center; max-width: 400px; }
        .icon { font-size: 64px; margin-bottom: 16px; }
        .success { color: #07D95A; }
        .fail { color: #E53E3E; }
        h2 { margin: 8px 0; }
        p { color: #666; margin: 8px 0 24px; }
        .btn { background: #176FF2; color: white; border: none; padding: 12px 32px; border-radius: 12px; font-size: 16px; cursor: pointer; text-decoration: none; display: inline-block; }
      </style>
      </head>
      <body>
        <div class="card">
          <div class="icon ${result.responseCode === "00" ? "success" : "fail"}">
            ${result.responseCode === "00" ? "✅" : "❌"}
          </div>
          <h2>${result.responseCode === "00" ? "Thanh toán thành công!" : "Thanh toán thất bại"}</h2>
          <p>${result.responseCode === "00" ? "Cảm ơn bạn đã thanh toán. Bạn có thể quay lại ứng dụng để kiểm tra chuyến đi." : `Mã lỗi: ${result.responseCode}. Vui lòng thử lại.`}</p>
          <p style="font-size:12px;color:#999;">Mã giao dịch: ${result.transactionNo}<br>Mã tham chiếu: ${txnRef}</p>
          <a href="/" class="btn">Quay về trang chủ</a>
        </div>
      </body>
      </html>
    `);
  }),

  vnpayIpn: asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const result = vnpayService.verifyReturnUrl(query);

    let tripId = result.txnRef.split("-").slice(0, -1).join("-");
    if (tripId.includes("-")) {
      const parts = result.txnRef.split("-");
      parts.pop();
      tripId = parts.join("-");
    }

    if (result.isValid) {
      if (result.responseCode === "00") {
        await vnpayService.updateTripPaymentStatus(
          tripId,
          "paid",
          result.txnRef,
          result.transactionNo
        );
        await prisma.trip.update({
          where: { id: tripId },
          data: { status: "Đã xác nhận", isUpcoming: true },
        });
      } else {
        await vnpayService.updateTripPaymentStatus(tripId, "failed", result.txnRef);
      }
      res.status(200).json({ RspCode: "00", Message: "Confirm Success" });
    } else {
      res.status(200).json({ RspCode: "97", Message: "Invalid Signature" });
    }
  }),

  checkPaymentStatus: asyncHandler(async (req: Request, res: Response) => {
    const { tripId } = req.params;
    if (!tripId) {
      res.status(400).json({ message: "tripId is required" });
      return;
    }

    const status = await vnpayService.getTripPaymentStatus(tripId as string);
    if (!status) {
      res.status(404).json({ message: "Trip not found" });
      return;
    }

    res.json(status);
  }),

  createMomoPayment: asyncHandler(async (req: Request, res: Response) => {
    const { tripId, amount, orderInfo } = req.body;
    if (!tripId || !amount) {
      res.status(400).json({ message: "tripId and amount are required" });
      return;
    }

    if (!MOMO_ACCESS_KEY || !MOMO_SECRET_KEY) {
      res.status(501).json({
        message: "MoMo payment is not configured. Please contact support.",
        note: "Vui lòng liên hệ quản trị viên để cấu hình thanh toán MoMo.",
      });
      return;
    }

    const orderId = `${tripId}-${Date.now()}`;
    const requestId = orderId;
    const orderInfoStr = orderInfo ?? `Thanh toan Momo cho don hang ${tripId}`;
    const redirectUrl = `${req.protocol}://${req.get("host")}/api/payment/momo/return`;
    const ipnUrl = `${req.protocol}://${req.get("host")}/api/payment/momo/ipn`;
    const extraData = Buffer.from(tripId).toString("base64");

    const rawSignature = `accessKey=${MOMO_ACCESS_KEY}&amount=${amount}&extraData=${extraData}&ipnUrl=${ipnUrl}&orderId=${orderId}&orderInfo=${orderInfoStr}&partnerCode=${MOMO_PARTNER_CODE}&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=captureWallet`;
    const signature = crypto.createHmac("sha256", MOMO_SECRET_KEY).update(rawSignature).digest("hex");

    const requestBody = {
      partnerCode: MOMO_PARTNER_CODE,
      partnerName: "Online Travel Agent",
      storeId: "OnlineTravelAgent",
      requestId,
      amount,
      orderId,
      orderInfo: orderInfoStr,
      redirectUrl,
      ipnUrl,
      lang: "vi",
      extraData,
      requestType: "captureWallet",
      signature,
    };

    try {
      const response = await fetch(MOMO_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(requestBody),
      });
      const result = await response.json() as Record<string, string>;

      if (result.resultCode === "0" || result.payUrl) {
        await prisma.trip.update({
          where: { id: tripId },
          data: { paymentStatus: "pending", paymentMethod: "momo", paymentTxnRef: orderId },
        });
        res.json({
          payUrl: result.payUrl,
          orderId,
          tripId,
          amount,
          deeplink: result.deeplink,
          qrCodeUrl: result.qrCodeUrl,
        });
      } else {
        res.status(400).json({ message: result.message ?? "MoMo payment creation failed" });
      }
    } catch (e) {
      res.status(500).json({ message: "Failed to create MoMo payment" });
    }
  }),

  momoReturn: asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const resultCode = query["resultCode"];
    const orderId = query["orderId"] ?? "";

    if (resultCode === "0") {
      const tripId = Buffer.from(query["extraData"] ?? "", "base64").toString("utf-8");
      try {
        await prisma.trip.update({
          where: { id: tripId },
          data: {
            paymentStatus: "paid",
            paymentMethod: "momo",
            status: "Đã xác nhận",
            isUpcoming: true,
          },
        });
      } catch {}
    }

    res.send(`
      <!DOCTYPE html>
      <html lang="vi">
      <head><meta charset="UTF-8"><title>Kết quả thanh toán Momo</title>
      <style>
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: #f5f5f5; }
        .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); text-align: center; max-width: 400px; }
        .icon { font-size: 64px; margin-bottom: 16px; }
        .success { color: #A50064; }
        .fail { color: #E53E3E; }
        h2 { margin: 8px 0; }
        p { color: #666; margin: 8px 0 24px; }
        .btn { background: #A50064; color: white; border: none; padding: 12px 32px; border-radius: 12px; font-size: 16px; cursor: pointer; text-decoration: none; display: inline-block; }
      </style>
      </head>
      <body>
        <div class="card">
          <div class="icon ${resultCode === "0" ? "success" : "fail"}">
            ${resultCode === "0" ? "✅" : "❌"}
          </div>
          <h2>${resultCode === "0" ? "Thanh toán Momo thành công!" : "Thanh toán thất bại"}</h2>
          <p>${resultCode === "0" ? "Cảm ơn bạn đã thanh toán qua MoMo." : `Mã lỗi: ${resultCode}. Vui lòng thử lại.`}</p>
          <a href="/" class="btn">Quay về trang chủ</a>
        </div>
      </body>
      </html>
    `);
  }),
};
