import prisma from "../config/prisma.js";
import { attachRealReviews } from "./helpers.js";

export const searchStore = {
  async globalSearch(query: string) {
    if (!query.trim()) return { hotels: [], tours: [], destinations: [] };
    const formattedQuery = query.trim().split(/\s+/).join(" | ");
    const [hotels, tours, destinations] = await Promise.all([
      prisma.hotel.findMany({
        where: {
          OR: [
            { name: { search: formattedQuery } },
            { location: { search: formattedQuery } },
            { name: { contains: query, mode: "insensitive" } },
          ],
        },
        take: 5,
      }),
      prisma.tourPackage.findMany({
        where: {
          OR: [
            { name: { search: formattedQuery } },
            { description: { search: formattedQuery } },
            { departure: { search: formattedQuery } },
            { name: { contains: query, mode: "insensitive" } },
          ],
        },
        take: 5,
      }),
      prisma.destination.findMany({
        where: {
          OR: [
            { name: { search: formattedQuery } },
            { location: { search: formattedQuery } },
            { name: { contains: query, mode: "insensitive" } },
          ],
        },
        take: 5,
      }),
    ]);

    return {
      hotels: await attachRealReviews(hotels, "hotel"),
      tours: await attachRealReviews(tours, "tour"),
      destinations: await attachRealReviews(destinations, "destination"),
    };
  },
};
