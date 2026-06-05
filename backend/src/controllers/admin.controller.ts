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
};
