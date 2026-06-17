import crypto from "crypto";
import { Prisma } from "@prisma/client";
import prisma from "./config/prisma.js";
import { scheduleService } from "./services/schedule.service.js";

function generateId(prefix: string = ""): string {
  return prefix ? `${prefix}-${crypto.randomUUID()}` : crypto.randomUUID();
}

const categoryDisplayOrder = [
  "Tất cả",
  "Địa điểm",
  "Khách sạn",
  "Máy bay",
  "Ẩm thực",
];

const hiddenCategoryNames = new Set(["Bãi biển"]);

function normalizeCategoryName(category: string): string {
  return category === "Bãi biển" ? "Địa điểm" : category;
}

function orderCategoryNames(categories: Array<{ name: string }>): string[] {
  const names = categories
    .map((category) => normalizeCategoryName(category.name))
    .filter((name) => !hiddenCategoryNames.has(name));
  const remaining = new Set(names);

  return [
    ...categoryDisplayOrder.filter((name) => {
      if (!remaining.has(name)) {
        return false;
      }
      remaining.delete(name);
      return true;
    }),
    ...names.filter((name) => remaining.delete(name)),
  ];
}

export const store = {
  async getBootstrap(userId?: string) {
    const [categories, destinations, trips, documents, hotels, tourPackages] = await Promise.all([
      prisma.category.findMany({ orderBy: { name: "asc" } }),
      prisma.destination.findMany(),
      userId ? prisma.trip.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }) : Promise.resolve([]),
      prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } }),
      prisma.hotel.findMany(),
      prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } }),
    ]);

    const normalizedDestinations = destinations.map((destination) => ({
      ...destination,
      category: normalizeCategoryName(destination.category),
    }));
    const recommended = normalizedDestinations.filter((d) => d.isRecommended);

    return {
      categories: orderCategoryNames(categories),
      destinations: normalizedDestinations,
      recommended,
      trips,
      documents,
      hotels,
      tourPackages,
    };
  },

  async getHotels(location?: string) {
    const where: Prisma.HotelWhereInput = location ? { location: { contains: location, mode: "insensitive" } } : {};
    return prisma.hotel.findMany({ where });
  },

  async getHotelById(id: string) {
    return prisma.hotel.findUnique({
      where: { id },
      include: { rooms: true },
    });
  },

  async searchHotels(query: string) {
    return prisma.hotel.findMany({
      where: {
        OR: [
          { name: { contains: query, mode: "insensitive" } },
          { location: { contains: query, mode: "insensitive" } },
        ],
      },
    });
  },

  async bookHotel(userId: string | undefined, roomId: string, checkIn: string, checkOut: string, guests: string) {
    const room = await prisma.room.findUnique({
      where: { id: roomId },
      include: { hotel: true },
    });
    if (!room) {
      return null;
    }

    return prisma.trip.create({
      data: {
        id: generateId("trip-hotel"),
        userId,
        destination: room.hotel.name,
        location: room.hotel.location,
        date: `${checkIn} - ${checkOut}`,
        guests,
        status: "Sắp tới",
        imagePath: room.hotel.imagePath,
        isUpcoming: true,
      },
    });
  },

  async getTours() {
    return prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } });
  },

  async getTourById(id: string) {
    return prisma.tourPackage.findUnique({ where: { id } });
  },

  async bookTour(userId: string | undefined, tourId: string, date: string, guests: string, totalPrice?: number) {
    const tour = await prisma.tourPackage.findUnique({ where: { id: tourId } });
    if (!tour) return null;

    const tripId = generateId("trip-tour");
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: tour.name,
        location: tour.departure,
        date,
        guests,
        status: "Đã xác nhận",
        imagePath: tour.imagePath,
        isUpcoming: true,
        totalPrice: totalPrice,
      },
    });

    try {
      await scheduleService.copyTemplateToTrip({
        tripId: trip.id,
        sourceType: "tour",
        sourceId: tour.id,
        tripDate: date,
      });
    } catch (e) {
      console.error("Failed to copy schedule template to trip", e);
    }

    return trip;
  },

  async createCustomTour(userId: string | undefined, data: { destinations: string[]; date: string; guests: string; location: string; imagePath: string; totalPrice?: number }) {
    const tripId = generateId("trip-custom");
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: "Tour thiết kế riêng",
        location: data.location,
        date: data.date,
        guests: data.guests,
        status: "Chờ thanh toán",
        imagePath: data.imagePath,
        isUpcoming: true,
        totalPrice: data.totalPrice,
        isCustom: true,
      },
    });

    return trip;
  },

  async getFavorites() {
    return prisma.destination.findMany({ where: { isFavorite: true } });
  },

  async updateFavorite(destinationId: string, isFavorite?: boolean) {
    const destination = await prisma.destination.findUnique({ where: { id: destinationId } });
    if (!destination) {
      return null;
    }

    const newFavorite = typeof isFavorite === "boolean" ? isFavorite : !destination.isFavorite;

    return prisma.destination.update({
      where: { id: destinationId },
      data: { isFavorite: newFavorite },
    });
  },

  async createTrip(userId: string | undefined, destinationId: string, date: string, guests: string, totalPrice?: number) {
    const destination = await prisma.destination.findUnique({ where: { id: destinationId } });
    if (!destination) return null;

    const tripId = generateId("trip-dest");
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: destination.name,
        location: destination.location,
        date,
        guests,
        status: "Đã xác nhận",
        imagePath: destination.imagePath,
        isUpcoming: true,
        totalPrice: totalPrice,
      },
    });

    try {
      await scheduleService.copyTemplateToTrip({
        tripId: trip.id,
        sourceType: "destination",
        sourceId: destination.id,
        tripDate: date,
      });
    } catch (e) {
      console.error("Failed to copy schedule template to trip", e);
    }

    return trip;
  },

  async searchFlights(departure?: string, arrival?: string) {
    const where: Prisma.FlightWhereInput = {};

    if (departure) {
      where.departure = { equals: departure, mode: "insensitive" };
    }
    if (arrival) {
      where.arrival = { equals: arrival, mode: "insensitive" };
    }

    return prisma.flight.findMany({ where });
  },

  async bookFlightTrip(userId: string | undefined, flightId: string, date: string, guests: string) {
    const flight = await prisma.flight.findUnique({ where: { id: flightId } });
    if (!flight) {
      return null;
    }

    const tripId = generateId("trip-flight");
    return prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: `${flight.departure} ✈ ${flight.arrival}`,
        location: flight.airline,
        date,
        guests,
        status: "Sắp tới",
        imagePath: flight.airlineLogo,
        isUpcoming: true,
      },
    });
  },

  async getTrips(userId: string | undefined, type?: string) {
    const where: Prisma.TripWhereInput = userId ? { userId } : {};
    if (type === "upcoming") where.isUpcoming = true;
    if (type === "past") where.isUpcoming = false;
    return prisma.trip.findMany({ where, orderBy: { createdAt: "desc" } });
  },

  async getDocuments() {
    return prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } });
  },

  async createDocument(title: string, description: string, icon: string, color: string) {
    return prisma.documentItem.create({
      data: {
        id: generateId("doc"),
        title,
        description,
        icon,
        color,
      },
    });
  },

  async deleteDocument(id: string) {
    return prisma.documentItem.delete({ where: { id } });
  },

  // --- Reviews ---
  async getReviews(targetType: string, targetId: string) {
    const reviews = await prisma.review.findMany({
      where: { targetType, targetId },
      include: { user: { select: { id: true, name: true } } },
      orderBy: { createdAt: "desc" },
    });

    const total = reviews.length;
    const avgRating = total > 0 ? reviews.reduce((sum, r) => sum + r.rating, 0) / total : 0;

    return { reviews, total, avgRating: Math.round(avgRating * 10) / 10 };
  },

  async createReview(userId: string | undefined, targetType: string, targetId: string, rating: number, comment: string) {
    const review = await prisma.review.create({
      data: { userId: userId || "", targetType, targetId, rating, comment },
      include: { user: { select: { id: true, name: true } } },
    });
    return review;
  },

  async deleteReview(userId: string | undefined, reviewId: string) {
    const review = await prisma.review.findUnique({ where: { id: reviewId } });
    if (!review || review.userId !== userId) return null;
    await prisma.review.delete({ where: { id: reviewId } });
    return true;
  },
};
