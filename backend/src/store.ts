import prisma from "./prisma.js";
import { Destination, DocumentItem, Flight, Profile, Trip } from "./types.js";

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

const transactions = new Map<string, { tripId: string; status: string }>();

function mapDbTrip(t: any): Trip {
  return {
    id: t.id,
    destination: t.destination,
    location: t.location,
    date: t.date,
    guests: t.guests,
    status: t.status,
    imagePath: t.imagePath,
    isUpcoming: t.isUpcoming,
    totalAmount: t.totalPrice ?? undefined,
    currency: t.currency ?? undefined
  };
}

export const store = {
  async getBootstrap() {
    const categoriesDb = await prisma.category.findMany();
    const destinationsDb = await prisma.destination.findMany();
    const tripsDb = await prisma.trip.findMany({ orderBy: { createdAt: "desc" } });
    const documentsDb = await prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } });
    
    let profileDb = await prisma.profile.findFirst();
    if (!profileDb) {
      profileDb = await prisma.profile.create({
        data: { name: "Nguyễn Văn A", email: "vanya.traveler@email.com" }
      });
    }

    return {
      categories: categoriesDb.map((c) => c.name),
      destinations: destinationsDb,
      recommended: destinationsDb.filter((d) => d.isRecommended),
      trips: tripsDb.map(mapDbTrip),
      profile: { name: profileDb.name, email: profileDb.email },
      documents: documentsDb
    };
  },

  async getFavorites() {
    return await prisma.destination.findMany({ where: { isFavorite: true } });
  },

  async updateFavorite(destinationId: string, isFavorite?: boolean) {
    let targetFav = isFavorite;
    if (typeof isFavorite !== "boolean") {
      const current = await prisma.destination.findUnique({ where: { id: destinationId } });
      if (!current) return null;
      targetFav = !current.isFavorite;
    }
    return await prisma.destination.update({
      where: { id: destinationId },
      data: { isFavorite: targetFav }
    });
  },

  async createTrip(destinationId: string, date?: string, guests?: string, totalAmount?: number, currency?: string) {
    const dest = await prisma.destination.findUnique({ where: { id: destinationId } });
    if (!dest) return null;

    const now = new Date();
    const start = new Date(now);
    start.setDate(start.getDate() + 7);
    const days = durationToDays(dest.duration);
    const end = new Date(start);
    end.setDate(end.getDate() + days);

    const trip = await prisma.trip.create({
      data: {
        id: `trip-${Date.now()}`,
        destination: dest.name,
        location: dest.location,
        date: date ?? `${formatDate(start)} - ${formatDate(end)}`,
        guests: guests ?? "1 Người lớn",
        status: "Sắp tới",
        imagePath: dest.imagePath,
        isUpcoming: true,
        totalPrice: totalAmount ?? (Number.parseFloat(dest.price) || 0),
        currency: currency ?? "USD",
        isCustom: false
      }
    });
    return mapDbTrip(trip);
  },

  async searchFlights(departure?: string, arrival?: string) {
    return await prisma.flight.findMany({
      where: {
        departure: departure ? { equals: departure, mode: "insensitive" } : undefined,
        arrival: arrival ? { equals: arrival, mode: "insensitive" } : undefined,
      }
    });
  },

  async bookFlightTrip(flightId: string, date: string, guests: string, totalAmount?: number, currency?: string) {
    const flight = await prisma.flight.findUnique({ where: { id: flightId } });
    if (!flight) return null;

    const trip = await prisma.trip.create({
      data: {
        id: `trip-fl-${Date.now()}`,
        destination: `${flight.departure} ✈ ${flight.arrival}`,
        location: flight.airline,
        date: date,
        guests: guests,
        status: "Sắp tới",
        imagePath: flight.airlineLogo,
        isUpcoming: true,
        totalPrice: totalAmount ?? flight.price,
        currency: currency ?? "USD",
        flightId: flight.id,
        isCustom: false
      }
    });
    return mapDbTrip(trip);
  },

  async getTrips(type?: string) {
    let tripsDb;
    if (type === "upcoming") {
      tripsDb = await prisma.trip.findMany({ where: { isUpcoming: true }, orderBy: { createdAt: "desc" } });
    } else if (type === "history") {
      tripsDb = await prisma.trip.findMany({ where: { isUpcoming: false }, orderBy: { createdAt: "desc" } });
    } else {
      tripsDb = await prisma.trip.findMany({ orderBy: { createdAt: "desc" } });
    }
    return tripsDb.map(mapDbTrip);
  },

  async getProfile() {
    let p = await prisma.profile.findFirst();
    if (!p) {
      p = await prisma.profile.create({
        data: { name: "Nguyễn Văn A", email: "vanya.traveler@email.com" }
      });
    }
    return { name: p.name, email: p.email };
  },

  async updateProfile(name?: string, email?: string) {
    let p = await prisma.profile.findFirst();
    if (!p) {
      p = await prisma.profile.create({
        data: { name: name || "Nguyễn Văn A", email: email || "vanya.traveler@email.com" }
      });
      return { name: p.name, email: p.email };
    }
    const updated = await prisma.profile.update({
      where: { id: p.id },
      data: {
        name: name?.trim() || undefined,
        email: email?.trim() || undefined
      }
    });
    return { name: updated.name, email: updated.email };
  },

  async getDocuments() {
    return await prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } });
  },

  async createDocument(title: string, description: string, icon: string, color: string) {
    return await prisma.documentItem.create({
      data: {
        id: `doc-${Date.now()}`,
        title,
        description,
        icon,
        color
      }
    });
  },

  async updateTripStatus(txnRef: string, status: string) {
    const tx = transactions.get(txnRef);
    if (tx) {
      tx.status = status;
      await prisma.trip.updateMany({
        where: { id: tx.tripId },
        data: { status }
      });
    }
  },

  addTransaction(txnRef: string, tripId: string) {
    transactions.set(txnRef, { tripId, status: "Chờ thanh toán" });
  },

  async deleteTrip(tripId: string) {
    try {
      await prisma.trip.delete({ where: { id: tripId } });
      return true;
    } catch {
      return false;
    }
  },

  // ─── ADMIN ENDPOINTS ──────────────────────────────────────────────────────────
  async getDestinations() {
    return await prisma.destination.findMany();
  },

  async addDestination(destination: Destination) {
    return await prisma.destination.create({ data: destination });
  },

  async updateDestination(id: string, updates: Partial<Destination>) {
    try {
      return await prisma.destination.update({
        where: { id },
        data: updates
      });
    } catch {
      return null;
    }
  },

  async deleteDestination(id: string) {
    try {
      await prisma.destination.delete({ where: { id } });
      return true;
    } catch {
      return false;
    }
  },

  async getFlights() {
    return await prisma.flight.findMany();
  },

  async addFlight(flight: Flight) {
    return await prisma.flight.create({ data: flight });
  },

  async updateFlight(id: string, updates: Partial<Flight>) {
    try {
      return await prisma.flight.update({
        where: { id },
        data: updates
      });
    } catch {
      return null;
    }
  },

  async deleteFlight(id: string) {
    try {
      await prisma.flight.delete({ where: { id } });
      return true;
    } catch {
      return false;
    }
  },

  async updateTrip(id: string, updates: Partial<Trip>) {
    try {
      const data: any = { ...updates };
      if (updates.totalAmount !== undefined) {
        data.totalPrice = updates.totalAmount;
        delete data.totalAmount;
      }
      const updated = await prisma.trip.update({
        where: { id },
        data
      });
      return mapDbTrip(updated);
    } catch {
      return null;
    }
  }
};
