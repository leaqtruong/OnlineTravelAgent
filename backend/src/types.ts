export type Destination = {
  id: string;
  name: string;
  location: string;
  latitude?: number;
  longitude?: number;
  rating: string;
  duration: string;
  imagePath: string;
  description: string;
  price: string;
  reviewsCount: string;
  category: string;
  isFavorite: boolean;
};

export type Trip = {
  id: string;
  destination: string;
  location: string;
  date: string;
  guests?: string;
  status: string;
  imagePath: string;
  isUpcoming: boolean;
};

export type Flight = {
  id: string;
  airline: string;
  airlineLogo: string;
  departure: string;
  arrival: string;
  departureTime: string;
  arrivalTime: string;
  price: number;
  duration: string;
};

export type Profile = {
  name: string;
  email: string;
};

export type DocumentItem = {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
};
