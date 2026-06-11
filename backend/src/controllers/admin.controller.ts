import { Request, Response } from "express";
import prisma from "../config/prisma.js";

export const adminController = {
  getStats: async (_: Request, res: Response) => {
    const [destinations, hotels, flights, tours, tripsUpcoming, tripsHistory] = await Promise.all([
      prisma.destination.count(),
      prisma.hotel.count(),
      prisma.flight.count(),
      prisma.tourPackage.count(),
      prisma.trip.count({ where: { isUpcoming: true } }),
      prisma.trip.count({ where: { isUpcoming: false } }),
    ]);
    res.json({ destinations, hotels, flights, tours, tripsUpcoming, tripsHistory });
  },

  // --- Destinations ---
  getDestinations: async (_: Request, res: Response) => {
    const data = await prisma.destination.findMany({ orderBy: { name: "asc" } });
    res.json(data);
  },

  createDestination: async (req: Request, res: Response) => {
    const body = req.body as any;
    const dest = await prisma.destination.create({
      data: {
        id: body.id || `dest-${Date.now()}`,
        name: body.name, location: body.location,
        category: body.category || "Địa điểm",
        rating: body.rating || "4.0",
        duration: body.duration || "2N/1Đ",
        imagePath: body.imagePath || "",
        description: body.description || "",
        price: body.price || "0",
        reviewsCount: body.reviewsCount || "0",
        isFavorite: body.isFavorite ?? false,
        isRecommended: body.isRecommended ?? false,
        latitude: body.latitude ?? null,
        longitude: body.longitude ?? null,
      },
    });
    res.status(201).json(dest);
  },

  updateDestination: async (req: Request, res: Response) => {
    const body = req.body as any;
    const dest = await prisma.destination.update({
      where: { id: req.params.id as string },
      data: { 
        name: body.name, location: body.location, category: body.category, 
        rating: body.rating, duration: body.duration, imagePath: body.imagePath, 
        description: body.description, price: body.price, reviewsCount: body.reviewsCount, 
        isFavorite: body.isFavorite, isRecommended: body.isRecommended, 
        latitude: body.latitude, longitude: body.longitude 
      },
    });
    res.json(dest);
  },

  deleteDestination: async (req: Request, res: Response) => {
    await prisma.destination.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },

  // --- Hotels ---
  getHotels: async (_: Request, res: Response) => {
    const data = await prisma.hotel.findMany({ include: { rooms: true }, orderBy: { name: "asc" } });
    res.json(data);
  },

  createHotel: async (req: Request, res: Response) => {
    const body = req.body as any;
    const hotel = await prisma.hotel.create({
      data: {
        id: body.id || `hotel-${Date.now()}`,
        name: body.name, location: body.location,
        address: body.address || "",
        rating: body.rating || "4.0",
        imagePath: body.imagePath || "",
        description: body.description || "",
        priceFrom: body.priceFrom || 0,
        amenities: body.amenities || [],
        latitude: body.latitude ?? null,
        longitude: body.longitude ?? null,
      },
    });
    res.status(201).json(hotel);
  },

  updateHotel: async (req: Request, res: Response) => {
    const body = req.body as any;
    const hotel = await prisma.hotel.update({
      where: { id: req.params.id as string },
      data: { 
        name: body.name, location: body.location, address: body.address, 
        rating: body.rating, imagePath: body.imagePath, description: body.description, 
        priceFrom: body.priceFrom, amenities: body.amenities, 
        latitude: body.latitude, longitude: body.longitude 
      },
    });
    res.json(hotel);
  },

  deleteHotel: async (req: Request, res: Response) => {
    await prisma.room.deleteMany({ where: { hotelId: req.params.id as string } });
    await prisma.hotel.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },

  // --- Flights ---
  getFlights: async (_: Request, res: Response) => {
    const data = await prisma.flight.findMany({ orderBy: { airline: "asc" } });
    res.json(data);
  },

  createFlight: async (req: Request, res: Response) => {
    const body = req.body as any;
    const flight = await prisma.flight.create({
      data: {
        id: body.id || `fl-${Date.now()}`,
        airline: body.airline,
        airlineLogo: body.airlineLogo || "",
        departure: body.departure,
        arrival: body.arrival,
        departureTime: body.departureTime || "",
        arrivalTime: body.arrivalTime || "",
        price: body.price || 0,
        duration: body.duration || "",
      },
    });
    res.status(201).json(flight);
  },

  updateFlight: async (req: Request, res: Response) => {
    const body = req.body as any;
    const flight = await prisma.flight.update({
      where: { id: req.params.id as string },
      data: { 
        airline: body.airline, airlineLogo: body.airlineLogo, departure: body.departure, 
        arrival: body.arrival, departureTime: body.departureTime, arrivalTime: body.arrivalTime, 
        price: body.price, duration: body.duration 
      },
    });
    res.json(flight);
  },

  deleteFlight: async (req: Request, res: Response) => {
    await prisma.flight.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },

  // --- Tours ---
  getTours: async (_: Request, res: Response) => {
    const data = await prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } });
    res.json(data);
  },

  createTour: async (req: Request, res: Response) => {
    const body = req.body as any;
    const tour = await prisma.tourPackage.create({
      data: {
        id: body.id || `tour-${Date.now()}`,
        name: body.name,
        description: body.description || "",
        imagePath: body.imagePath || "",
        duration: body.duration || "",
        price: body.price || 0,
        originalPrice: body.originalPrice ?? null,
        destinations: body.destinations || [],
        includes: body.includes || [],
        departure: body.departure || "",
        departureDate: body.departureDate || null,
        isPopular: body.isPopular ?? false,
        includesGuide: body.includesGuide ?? true,
        guideFee: body.guideFee ?? 50,
      },
    });
    res.status(201).json(tour);
  },

  updateTour: async (req: Request, res: Response) => {
    const body = req.body as any;
    const tour = await prisma.tourPackage.update({
      where: { id: req.params.id as string },
      data: { 
        name: body.name, description: body.description, imagePath: body.imagePath, 
        duration: body.duration, price: body.price, originalPrice: body.originalPrice, 
        destinations: body.destinations, includes: body.includes, departure: body.departure, 
        departureDate: body.departureDate ?? undefined,
        isPopular: body.isPopular, includesGuide: body.includesGuide, guideFee: body.guideFee 
      },
    });
    res.json(tour);
  },

  deleteTour: async (req: Request, res: Response) => {
    await prisma.tourPackage.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },

  // --- Trips ---
  getTrips: async (_: Request, res: Response) => {
    const data = await prisma.trip.findMany({ orderBy: { createdAt: "desc" } });
    res.json(data);
  },

  updateTrip: async (req: Request, res: Response) => {
    const body = req.body as any;
    const trip = await prisma.trip.update({
      where: { id: req.params.id as string },
      data: { status: body.status, isUpcoming: body.isUpcoming },
    });
    res.json(trip);
  },

  deleteTrip: async (req: Request, res: Response) => {
    await prisma.trip.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },

  getTripSchedule: async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const days = await prisma.tripScheduleDay.findMany({
      where: { tripId },
      include: {
        items: {
          orderBy: { sortOrder: "asc" }
        }
      },
      orderBy: { dayNumber: "asc" }
    });
    const updates = await prisma.tripScheduleUpdate.findMany({
      where: { tripId },
      orderBy: { createdAt: "desc" }
    });
    res.json({ days, updates });
  },

  updateTripScheduleItem: async (req: Request, res: Response) => {
    const itemId = req.params.itemId as string;
    const body = req.body as { statusOverride?: string, note?: string };
    const item = await prisma.tripScheduleItem.update({
      where: { id: itemId },
      data: {
        statusOverride: body.statusOverride,
        note: body.note
      }
    });
    res.json(item);
  },

  createTripScheduleUpdate: async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const body = req.body as { message: string };
    const update = await prisma.tripScheduleUpdate.create({
      data: {
        tripId,
        message: body.message
      }
    });
    res.status(201).json(update);
  },

  // --- Categories ---
  getCategories: async (_: Request, res: Response) => {
    const data = await prisma.category.findMany({ orderBy: { name: "asc" } });
    res.json(data);
  },

  createCategory: async (req: Request, res: Response) => {
    const body = req.body as any;
    const cat = await prisma.category.create({ data: { name: body.name } });
    res.status(201).json(cat);
  },

  deleteCategory: async (req: Request, res: Response) => {
    await prisma.category.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },

  // --- Users ---
  getUsers: async (_: Request, res: Response) => {
    const data = await prisma.user.findMany({ orderBy: { createdAt: "desc" }, select: { id: true, name: true, email: true, createdAt: true } });
    res.json(data);
  },

  createUser: async (req: Request, res: Response) => {
    const body = req.body as any;
    const user = await prisma.user.create({ data: { name: body.name, email: body.email, password: body.password } });
    res.status(201).json({ id: user.id, name: user.name, email: user.email });
  },

  deleteUser: async (req: Request, res: Response) => {
    await prisma.user.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },

  // --- Rooms ---
  getRooms: async (req: Request, res: Response) => {
    const data = await prisma.room.findMany({ where: { hotelId: req.params.hotelId as string }, orderBy: { name: "asc" } });
    res.json(data);
  },

  createRoom: async (req: Request, res: Response) => {
    const body = req.body as any;
    const room = await prisma.room.create({
      data: {
        id: body.id || `room-${Date.now()}`,
        hotelId: req.params.hotelId as string,
        name: body.name,
        description: body.description || "",
        price: body.price,
        capacity: body.capacity,
        imagePath: body.imagePath || "",
        amenities: body.amenities || []
      }
    });
    res.status(201).json(room);
  },

  updateRoom: async (req: Request, res: Response) => {
    const body = req.body as any;
    const room = await prisma.room.update({
      where: { id: req.params.roomId as string },
      data: { name: body.name, description: body.description, price: body.price, capacity: body.capacity, imagePath: body.imagePath, amenities: body.amenities }
    });
    res.json(room);
  },

  deleteRoom: async (req: Request, res: Response) => {
    await prisma.room.delete({ where: { id: req.params.roomId as string } });
    res.json({ ok: true });
  },

  // --- Documents ---
  getDocuments: async (_: Request, res: Response) => {
    const data = await prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } });
    res.json(data);
  },

  createDocument: async (req: Request, res: Response) => {
    const body = req.body as any;
    const doc = await prisma.documentItem.create({
      data: { id: body.id || `doc-${Date.now()}`, title: body.title, description: body.description || "", icon: body.icon || "fa-file", color: body.color || "text-gray-500" }
    });
    res.status(201).json(doc);
  },

  updateDocument: async (req: Request, res: Response) => {
    const body = req.body as any;
    const doc = await prisma.documentItem.update({
      where: { id: req.params.id as string },
      data: { title: body.title, description: body.description, icon: body.icon, color: body.color }
    });
    res.json(doc);
  },

  deleteDocument: async (req: Request, res: Response) => {
    await prisma.documentItem.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  },
};
