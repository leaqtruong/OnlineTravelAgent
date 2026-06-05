import { z } from "zod";

export const adminDestinationSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, "name is required"),
  location: z.string().min(1, "location is required"),
  category: z.string().optional(),
  rating: z.string().optional(),
  duration: z.string().optional(),
  imagePath: z.string().optional(),
  description: z.string().optional(),
  price: z.string().optional(),
  reviewsCount: z.string().optional(),
  isFavorite: z.boolean().optional(),
  isRecommended: z.boolean().optional(),
  latitude: z.number().nullable().optional(),
  longitude: z.number().nullable().optional()
});

export const adminHotelSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, "name is required"),
  location: z.string().min(1, "location is required"),
  address: z.string().optional(),
  rating: z.string().optional(),
  imagePath: z.string().optional(),
  description: z.string().optional(),
  priceFrom: z.number().optional(),
  amenities: z.array(z.string()).optional(),
  latitude: z.number().nullable().optional(),
  longitude: z.number().nullable().optional()
});

export const adminFlightSchema = z.object({
  id: z.string().optional(),
  airline: z.string().min(1, "airline is required"),
  airlineLogo: z.string().optional(),
  departure: z.string().min(1, "departure is required"),
  arrival: z.string().min(1, "arrival is required"),
  departureTime: z.string().optional(),
  arrivalTime: z.string().optional(),
  price: z.number().optional(),
  duration: z.string().optional()
});

export const adminTourSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, "name is required"),
  description: z.string().optional(),
  imagePath: z.string().optional(),
  duration: z.string().optional(),
  price: z.number().optional(),
  originalPrice: z.number().nullable().optional(),
  destinations: z.array(z.string()).optional(),
  includes: z.array(z.string()).optional(),
  departure: z.string().optional(),
  isPopular: z.boolean().optional(),
  includesGuide: z.boolean().optional(),
  guideFee: z.number().optional()
});

export const adminTripSchema = z.object({
  status: z.string().optional(),
  isUpcoming: z.boolean().optional()
});

export const adminCategorySchema = z.object({
  name: z.string().min(1, "name is required")
});
