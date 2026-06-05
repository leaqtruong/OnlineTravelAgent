import { Router } from "express";
import { adminController } from "../controllers/admin.controller.js";
import { validate } from "../middlewares/validate.js";
import {
  adminDestinationSchema,
  adminHotelSchema,
  adminFlightSchema,
  adminTourSchema,
  adminTripSchema,
  adminCategorySchema,
} from "../schemas/admin.schema.js";

export const adminRouter = Router();

// Stats
adminRouter.get("/stats", adminController.getStats);

// Destinations
adminRouter.get("/destinations", adminController.getDestinations);
adminRouter.post("/destinations", validate(adminDestinationSchema), adminController.createDestination);
adminRouter.put("/destinations/:id", validate(adminDestinationSchema), adminController.updateDestination);
adminRouter.delete("/destinations/:id", adminController.deleteDestination);

// Hotels
adminRouter.get("/hotels", adminController.getHotels);
adminRouter.post("/hotels", validate(adminHotelSchema), adminController.createHotel);
adminRouter.put("/hotels/:id", validate(adminHotelSchema), adminController.updateHotel);
adminRouter.delete("/hotels/:id", adminController.deleteHotel);

// Flights
adminRouter.get("/flights", adminController.getFlights);
adminRouter.post("/flights", validate(adminFlightSchema), adminController.createFlight);
adminRouter.put("/flights/:id", validate(adminFlightSchema), adminController.updateFlight);
adminRouter.delete("/flights/:id", adminController.deleteFlight);

// Tours
adminRouter.get("/tours", adminController.getTours);
adminRouter.post("/tours", validate(adminTourSchema), adminController.createTour);
adminRouter.put("/tours/:id", validate(adminTourSchema), adminController.updateTour);
adminRouter.delete("/tours/:id", adminController.deleteTour);

// Trips
adminRouter.get("/trips", adminController.getTrips);
adminRouter.put("/trips/:id", validate(adminTripSchema), adminController.updateTrip);
adminRouter.delete("/trips/:id", adminController.deleteTrip);

// Categories
adminRouter.get("/categories", adminController.getCategories);
adminRouter.post("/categories", validate(adminCategorySchema), adminController.createCategory);
adminRouter.delete("/categories/:id", adminController.deleteCategory);
