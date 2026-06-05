import { Router } from "express";
import { clientController } from "../controllers/client.controller.js";
import { validate } from "../middlewares/validate.js";
import {
  bookTripSchema,
  bookFlightSchema,
  profileSchema,
  documentSchema,
  bookHotelSchema,
  bookTourSchema,
  customTourSchema,
} from "../schemas/client.schema.js";

export const clientRouter = Router();

clientRouter.get("/bootstrap", clientController.getBootstrap);

// Favorites
clientRouter.get("/favorites", clientController.getFavorites);
clientRouter.patch("/destinations/:id/favorite", clientController.updateFavorite);

// Trips
clientRouter.get("/trips", clientController.getTrips);
clientRouter.post("/trips/book", validate(bookTripSchema), clientController.bookTrip);
clientRouter.post("/trips/book-flight", validate(bookFlightSchema), clientController.bookFlightTrip);
clientRouter.post("/trips/custom-tour", validate(customTourSchema), clientController.createCustomTour);

// Flights
clientRouter.get("/flights/search", clientController.searchFlights);

// Profile
clientRouter.get("/profile", clientController.getProfile);
clientRouter.put("/profile", validate(profileSchema), clientController.updateProfile);

// Documents
clientRouter.get("/documents", clientController.getDocuments);
clientRouter.post("/documents", validate(documentSchema), clientController.createDocument);

// Hotels
clientRouter.get("/hotels", clientController.getHotels);
clientRouter.get("/hotels/search", clientController.searchHotels);
clientRouter.get("/hotels/:id", clientController.getHotelById);
clientRouter.post("/hotels/book", validate(bookHotelSchema), clientController.bookHotel);

// Tours
clientRouter.get("/tours", clientController.getTours);
clientRouter.get("/tours/:id", clientController.getTourById);
clientRouter.post("/tours/book", validate(bookTourSchema), clientController.bookTour);
