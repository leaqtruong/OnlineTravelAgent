import { bootstrapStore } from "./bootstrap.store.js";
import { documentStore } from "./document.store.js";
import { hotelStore } from "./hotel.store.js";
import { promoStore } from "./promo.store.js";
import { reviewStore } from "./review.store.js";
import { searchStore } from "./search.store.js";
import { tourStore } from "./tour.store.js";
import { tripStore } from "./trip.store.js";

export const store = {
  ...bootstrapStore,
  ...tripStore,
  ...hotelStore,
  ...tourStore,
  ...reviewStore,
  ...documentStore,
  ...searchStore,
  ...promoStore,
};
