import { Request, Response } from "express";
import { store } from "../store.js";

export const clientController = {
  getBootstrap: async (req: Request, res: Response) => {
    const data = await store.getBootstrap();
    res.json(data);
    console.log("=============================================");
    console.log("✅ [BACKEND] Đã gửi dữ liệu từ Database cho ứng dụng Flutter thành công!");
    console.log("=============================================");
  },

  getFavorites: async (req: Request, res: Response) => {
    const data = await store.getFavorites();
    res.json(data);
  },

  updateFavorite: async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const isFavorite = req.body?.isFavorite;
    const updated = await store.updateFavorite(id, isFavorite);
    if (!updated) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.json(updated);
  },

  getTrips: async (req: Request, res: Response) => {
    const type = typeof req.query.type === "string" ? req.query.type : undefined;
    const data = await store.getTrips(type);
    res.json(data);
  },

  bookTrip: async (req: Request, res: Response) => {
    const body = req.body as any;
    const trip = await store.createTrip(body.destinationId, String(body.date || ""), String(body.guests || ""), body.totalPrice ? Number(body.totalPrice) : undefined);
    if (!trip) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.status(201).json(trip);
  },

  searchFlights: async (req: Request, res: Response) => {
    const departure = typeof req.query.departure === "string" ? req.query.departure : undefined;
    const arrival = typeof req.query.arrival === "string" ? req.query.arrival : undefined;
    const data = await store.searchFlights(departure, arrival);
    res.json(data);
  },

  bookFlightTrip: async (req: Request, res: Response) => {
    const body = req.body as any;
    const trip = await store.bookFlightTrip(body.flightId, String(body.date || ""), String(body.guests || ""));
    if (!trip) {
      res.status(404).json({ message: "Flight not found" });
      return;
    }
    res.status(201).json(trip);
  },

  getProfile: async (req: Request, res: Response) => {
    const data = await store.getProfile();
    res.json(data);
  },

  updateProfile: async (req: Request, res: Response) => {
    const body = req.body as any;
    const profile = await store.updateProfile(body.name, body.email);
    res.json(profile);
  },

  getDocuments: async (req: Request, res: Response) => {
    const data = await store.getDocuments();
    res.json(data);
  },

  createDocument: async (req: Request, res: Response) => {
    const body = req.body as any;
    const doc = await store.createDocument(body.title, body.description, body.icon, body.color);
    res.status(201).json(doc);
  },

  getHotels: async (req: Request, res: Response) => {
    const location = typeof req.query.location === "string" ? req.query.location : undefined;
    const data = await store.getHotels(location);
    res.json(data);
  },

  searchHotels: async (req: Request, res: Response) => {
    const q = typeof req.query.q === "string" ? req.query.q : "";
    const data = await store.searchHotels(q);
    res.json(data);
  },

  getHotelById: async (req: Request, res: Response) => {
    const data = await store.getHotelById(req.params.id as string);
    if (!data) {
      res.status(404).json({ message: "Hotel not found" });
      return;
    }
    res.json(data);
  },

  bookHotel: async (req: Request, res: Response) => {
    const body = req.body as any;
    const trip = await store.bookHotel(body.roomId, body.checkIn, body.checkOut, String(body.guests || ""));
    if (!trip) {
      res.status(404).json({ message: "Room not found" });
      return;
    }
    res.status(201).json(trip);
  },

  getTours: async (req: Request, res: Response) => {
    const data = await store.getTours();
    res.json(data);
  },

  getTourById: async (req: Request, res: Response) => {
    const data = await store.getTourById(req.params.id as string);
    if (!data) {
      res.status(404).json({ message: "Tour not found" });
      return;
    }
    res.json(data);
  },

  bookTour: async (req: Request, res: Response) => {
    const body = req.body as any;
    const trip = await store.bookTour(body.tourId, body.date, String(body.guests || ""), body.totalPrice ? Number(body.totalPrice) : undefined);
    if (!trip) {
      res.status(404).json({ message: "Tour not found" });
      return;
    }
    res.status(201).json(trip);
  },

  createCustomTour: async (req: Request, res: Response) => {
    const body = req.body as any;
    try {
      const trip = await store.createCustomTour({
        ...body,
        guests: String(body.guests || ""),
        totalPrice: body.totalPrice ? Number(body.totalPrice) : undefined
      });
      res.status(201).json(trip);
    } catch (error) {
      res.status(500).json({ message: "Failed to create custom tour" });
    }
  }
};
