import prisma from "./config/prisma.js";

function formatDate(date: Date): string {
  const day = date.getDate().toString().padStart(2, "0");
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const year = date.getFullYear();
  return `${day}/${month}/${year}`;
}

function durationToDays(duration: string): number {
  const match = duration.match(/^(\d+)N/);
  if (!match) {
    return 2;
  }
  const days = Number.parseInt(match[1], 10);
  return Number.isNaN(days) ? 2 : Math.max(days, 1);
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
  async getBootstrap() {
    const [categories, destinations, trips, profile, documents, hotels, tourPackages] = await Promise.all([
      prisma.category.findMany({ orderBy: { name: "asc" } }),
      prisma.destination.findMany(),
      prisma.trip.findMany({ orderBy: { createdAt: "desc" } }),
      prisma.profile.findFirst(),
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
      profile,
      documents,
      hotels,
      tourPackages,
    };
  },

  async getHotels(location?: string) {
    const where = location ? { location: { contains: location, mode: "insensitive" as any } } : {};
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
          { name: { contains: query, mode: "insensitive" as any } },
          { location: { contains: query, mode: "insensitive" as any } },
        ],
      },
    });
  },

  async bookHotel(roomId: string, checkIn: string, checkOut: string, guests: string) {
    const room = await prisma.room.findUnique({
      where: { id: roomId },
      include: { hotel: true },
    });
    if (!room) {
      return null;
    }

    return prisma.trip.create({
      data: {
        id: `trip-hotel-${Date.now()}`,
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

  async bookTour(tourId: string, date: string, guests: string, totalPrice?: number) {
    const tour = await prisma.tourPackage.findUnique({ where: { id: tourId } });
    if (!tour) return null;

    const tripId = `trip_tour_${Date.now()}`;
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
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

    return trip;
  },

  async createCustomTour(data: {
    destination: string;
    location: string;
    date: string;
    guests: string;
    imagePath: string;
    flightId?: string;
    hotelId?: string;
    roomId?: string;
    totalPrice?: number;
  }) {
    const tripId = `trip_custom_${Date.now()}`;
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
        destination: data.destination,
        location: data.location,
        date: data.date,
        guests: data.guests,
        status: "Chờ thanh toán",
        imagePath: data.imagePath,
        isUpcoming: true,
        flightId: data.flightId,
        hotelId: data.hotelId,
        roomId: data.roomId,
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

  async createTrip(destinationId: string, customDate?: string, customGuests?: string, totalPrice?: number) {
    const destination = await prisma.destination.findUnique({ where: { id: destinationId } });
    if (!destination) {
      return null;
    }

    const now = new Date();
    const start = new Date(now);
    start.setDate(start.getDate() + 7);
    const days = durationToDays(destination.duration);
    const end = new Date(start);
    end.setDate(end.getDate() + days);

    return prisma.trip.create({
      data: {
        id: `trip-${Date.now()}`,
        destination: destination.name,
        location: destination.location,
        date: customDate ?? `${formatDate(start)} - ${formatDate(end)}`,
        guests: customGuests ?? "1 Người lớn",
        status: "Sắp tới",
        imagePath: destination.imagePath,
        isUpcoming: true,
        totalPrice: totalPrice,
      },
    });
  },

  async searchFlights(departure?: string, arrival?: string) {
    const where: Record<string, unknown> = {};

    if (departure) {
      where.departure = { equals: departure, mode: "insensitive" };
    }
    if (arrival) {
      where.arrival = { equals: arrival, mode: "insensitive" };
    }

    return prisma.flight.findMany({ where });
  },

  async bookFlightTrip(flightId: string, date: string, guests: string) {
    const flight = await prisma.flight.findUnique({ where: { id: flightId } });
    if (!flight) {
      return null;
    }

    return prisma.trip.create({
      data: {
        id: `trip-fl-${Date.now()}`,
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

  async getTrips(type?: string) {
    if (type === "upcoming") {
      return prisma.trip.findMany({
        where: { isUpcoming: true },
        orderBy: { createdAt: "desc" },
      });
    }
    if (type === "history") {
      return prisma.trip.findMany({
        where: { isUpcoming: false },
        orderBy: { createdAt: "desc" },
      });
    }
    return prisma.trip.findMany({ orderBy: { createdAt: "desc" } });
  },

  async getProfile() {
    return prisma.profile.findFirst();
  },

  async updateProfile(name?: string, email?: string) {
    const profile = await prisma.profile.findFirst();
    if (!profile) {
      return null;
    }

    const data: Record<string, string> = {};
    if (typeof name === "string" && name.trim().length > 0) {
      data.name = name.trim();
    }
    if (typeof email === "string" && email.trim().length > 0) {
      data.email = email.trim();
    }

    if (Object.keys(data).length === 0) {
      return profile;
    }

    return prisma.profile.update({
      where: { id: profile.id },
      data,
    });
  },

  async getDocuments() {
    return prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } });
  },

  async createDocument(title: string, description: string, icon: string, color: string) {
    return prisma.documentItem.create({
      data: {
        id: `doc-${Date.now()}`,
        title,
        description,
        icon,
        color,
      },
    });
  },
};
