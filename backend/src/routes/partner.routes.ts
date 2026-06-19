import { Router } from "express";
import { partnerController } from "../controllers/partner.controller.js";
import { upload } from "../middlewares/upload.js";

export const partnerRouter = Router();

partnerRouter.post("/upload", upload.single("file"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }
  res.json({ url: `/uploads/${req.file.filename}` });
});

partnerRouter.get("/stats", partnerController.getStats);
partnerRouter.get("/hotels", partnerController.getHotels);
partnerRouter.post("/hotels", partnerController.createHotel);
partnerRouter.put("/hotels/:id", partnerController.updateHotel);
partnerRouter.delete("/hotels/:id", partnerController.deleteHotel);

partnerRouter.get("/tours", partnerController.getTours);
partnerRouter.post("/tours", partnerController.createTour);
partnerRouter.put("/tours/:id", partnerController.updateTour);
partnerRouter.delete("/tours/:id", partnerController.deleteTour);

partnerRouter.get("/hotels/:hotelId/rooms", partnerController.getRooms);
partnerRouter.post("/hotels/:hotelId/rooms", partnerController.createRoom);
partnerRouter.put("/hotels/:hotelId/rooms/:roomId", partnerController.updateRoom);
partnerRouter.delete("/hotels/:hotelId/rooms/:roomId", partnerController.deleteRoom);
