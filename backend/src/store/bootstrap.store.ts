import prisma from "../config/prisma.js";
import { appCache, BOOTSTRAP_BASE_KEY } from "../config/cache.js";
import {
  applyFavoriteState,
  attachRealReviews,
  getFavoriteDestinationIds,
  normalizeCategoryName,
  orderCategoryNames,
  processTripStatus,
} from "./helpers.js";
import {
  mockCategories,
  mockDestinations,
  mockHotels,
  mockFlights,
  mockTourPackages,
  mockDocuments,
} from "../data/mock-data.js";

type ReviewedDestination = Awaited<
  ReturnType<typeof attachRealReviews<{
    id: string;
    isRecommended: boolean;
    category: string;
    [key: string]: unknown;
  }>>
>[number];

type BootstrapBase = {
  categories: string[];
  destinations: ReviewedDestination[];
  hotels: Awaited<ReturnType<typeof attachRealReviews>>;
  tourPackages: Awaited<ReturnType<typeof attachRealReviews>>;
  flights: Awaited<ReturnType<typeof prisma.flight.findMany>>;
};

async function loadFromDb(): Promise<BootstrapBase | null> {
  try {
    const [categories, destinations, hotels, tourPackages, flights] = await Promise.all([
      prisma.category.findMany({ orderBy: { name: "asc" } }),
      prisma.destination.findMany(),
      prisma.hotel.findMany(),
      prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } }),
      prisma.flight.findMany(),
    ]);

    if (!destinations.length && !hotels.length && !tourPackages.length) {
      return null;
    }

    const normalizedDestinations = destinations.map((destination) => ({
      ...destination,
      category: normalizeCategoryName(destination.category),
    }));

    const [reviewedDestinations, realHotels, realTours] = await Promise.all([
      attachRealReviews(normalizedDestinations, "destination"),
      attachRealReviews(hotels, "hotel"),
      attachRealReviews(tourPackages, "tour"),
    ]);

    return {
      categories: orderCategoryNames(categories),
      destinations: reviewedDestinations,
      hotels: realHotels,
      tourPackages: realTours,
      flights,
    };
  } catch {
    return null;
  }
}

function loadMockData(): BootstrapBase {
  return {
    categories: mockCategories,
    destinations: mockDestinations as ReviewedDestination[],
    hotels: mockHotels as unknown as BootstrapBase["hotels"],
    tourPackages: mockTourPackages as unknown as BootstrapBase["tourPackages"],
    flights: mockFlights as unknown as BootstrapBase["flights"],
  };
}

export const bootstrapStore = {
  async getBootstrap(userId?: string) {
    let cachedBase = appCache.get<BootstrapBase>(BOOTSTRAP_BASE_KEY);

    if (!cachedBase) {
      const dbData = await loadFromDb();
      cachedBase = dbData ?? loadMockData();
      appCache.set(BOOTSTRAP_BASE_KEY, cachedBase);
    }

    let favoriteDestinationIds = new Set<string>();
    let trips: Awaited<ReturnType<typeof prisma.trip.findMany>> = [];
    let documents: Awaited<ReturnType<typeof prisma.documentItem.findMany>> = [];

    if (userId) {
      try {
        [favoriteDestinationIds, trips, documents] = await Promise.all([
          getFavoriteDestinationIds(userId),
          prisma.trip.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }),
          prisma.documentItem.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }),
        ]);
      } catch {
        favoriteDestinationIds = new Set<string>();
        trips = [];
        documents = mockDocuments as unknown as typeof documents;
      }
    }

    const realDestinations = applyFavoriteState(cachedBase.destinations, favoriteDestinationIds);
    const realRecommended = realDestinations.filter((d) => d.isRecommended);

    return {
      categories: cachedBase.categories,
      destinations: realDestinations,
      recommended: realRecommended,
      trips: trips.map(processTripStatus),
      documents,
      hotels: cachedBase.hotels,
      tourPackages: cachedBase.tourPackages,
      flights: cachedBase.flights,
    };
  },

  async getFavorites(userId?: string) {
    if (!userId) return [];

    try {
      const favorites = await prisma.userFavoriteDestination.findMany({
        where: { userId },
        include: { destination: true },
        orderBy: { createdAt: "desc" },
      });
      const destinations = favorites.map((favorite) => ({
        ...favorite.destination,
        isFavorite: true,
      }));
      return attachRealReviews(destinations, "destination");
    } catch {
      return [];
    }
  },

  async updateFavorite(userId: string | undefined, destinationId: string, isFavorite?: boolean) {
    if (!userId) return null;

    try {
      const destination = await prisma.destination.findUnique({ where: { id: destinationId } });
      if (!destination) {
        return null;
      }

      const existing = await prisma.userFavoriteDestination.findUnique({
        where: { userId_destinationId: { userId, destinationId } },
      });
      const newFavorite = typeof isFavorite === "boolean" ? isFavorite : !existing;

      if (newFavorite) {
        await prisma.userFavoriteDestination.upsert({
          where: { userId_destinationId: { userId, destinationId } },
          update: {},
          create: { userId, destinationId },
        });
      } else {
        await prisma.userFavoriteDestination.deleteMany({
          where: { userId, destinationId },
        });
      }

      const [withReviews] = await attachRealReviews(
        [{ ...destination, isFavorite: newFavorite }],
        "destination",
      );
      return withReviews;
    } catch {
      return null;
    }
  },
};
