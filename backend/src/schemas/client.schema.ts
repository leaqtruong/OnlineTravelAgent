import { z } from "zod";

export const bookTripSchema = z.object({
  destinationId: z.string().min(1, "destinationId is required"),
  date: z.any().optional(),
  guests: z.any().optional(),
  totalPrice: z.any().optional()
});

export const bookFlightSchema = z.object({
  flightId: z.string().min(1, "flightId is required"),
  date: z.any().optional(),
  guests: z.any().optional()
});

export const documentSchema = z.object({
  title: z.string().min(1, "title is required"),
  description: z.string().min(1, "description is required"),
  icon: z.string().min(1, "icon is required"),
  color: z.string().min(1, "color is required")
});

export const bookHotelSchema = z.object({
  roomId: z.string().min(1, "roomId is required"),
  checkIn: z.string().min(1, "checkIn is required"),
  checkOut: z.string().min(1, "checkOut is required"),
  guests: z.any()
});

export const bookTourSchema = z.object({
  tourId: z.string().min(1, "tourId is required"),
  date: z.string().min(1, "date is required"),
  guests: z.any(),
  totalPrice: z.any().optional()
});

export const customTourSchema = z.object({
  destination: z.string().min(1, "destination is required"),
  location: z.string().min(1, "location is required"),
  date: z.string().min(1, "date is required"),
  guests: z.any(),
  imagePath: z.string().min(1, "imagePath is required"),
  flightId: z.string().optional(),
  hotelId: z.string().optional(),
  roomId: z.string().optional(),
  totalPrice: z.any().optional()
});

export const reviewSchema = z.object({
  targetType: z.string().min(1, "targetType is required"),
  targetId: z.string().min(1, "targetId is required"),
  rating: z.number().int().min(1).max(5, "rating must be 1-5"),
  comment: z.string().min(1, "comment is required").max(1000)
});
