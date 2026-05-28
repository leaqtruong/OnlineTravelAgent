import { Destination, DocumentItem, Flight, Profile, Trip } from "./types.js";

const categories = ["Tất cả", "Địa điểm", "Khách sạn", "Bãi biển", "Máy bay", "Ẩm thực"];

const destinations: Destination[] = [
  {
    id: "dalat",
    name: "Đà Lạt",
    location: "Lâm Đồng, VN",
    rating: "4.1",
    duration: "4N/5D",
    imagePath: "assets/images/dalat_image.jpg",
    description:
      "Đà Lạt là thành phố ngàn hoa với khí hậu mát mẻ quanh năm. Đây là địa điểm lý tưởng cho các cặp đôi và gia đình muốn tìm kiếm sự yên bình.",
    price: "199",
    reviewsCount: "355",
    category: "Địa điểm",
    isFavorite: false,
    latitude: 11.9404,
    longitude: 108.4583
  },
  {
    id: "phuquoc",
    name: "Đảo Phú Quốc",
    location: "Kiên Giang, VN",
    rating: "4.5",
    duration: "2N/3D",
    imagePath: "assets/images/phuquoc_image.jpg",
    description:
      "Phú Quốc nổi tiếng với những bãi biển xanh ngắt và cát trắng mịn. Du khách có thể thưởng thức hải sản tươi ngon và tham gia các hoạt động lặn ngắm san hô.",
    price: "250",
    reviewsCount: "1.2k",
    category: "Bãi biển",
    isFavorite: false,
    latitude: 10.2270,
    longitude: 103.9670
  },
  {
    id: "hoian",
    name: "Hội An",
    location: "Quảng Nam, VN",
    rating: "4.8",
    duration: "2N/1Đ",
    imagePath: "assets/images/hoian_image.webp",
    description:
      "Phố cổ Hội An là di sản văn hóa thế giới với những con phố đèn lồng lung linh và nền ẩm thực phong phú, mang đậm dấu ấn lịch sử.",
    price: "150",
    reviewsCount: "800",
    category: "Địa điểm",
    isFavorite: false,
    latitude: 15.8801,
    longitude: 108.3380
  },
  {
    id: "vinpearl",
    name: "Vinpearl Resort",
    location: "Nha Trang, VN",
    rating: "4.7",
    duration: "3N/2Đ",
    imagePath: "assets/images/hoian_image.webp",
    description: "Khu nghỉ dưỡng sang trọng bậc nhất.",
    price: "500",
    reviewsCount: "2.5k",
    category: "Khách sạn",
    isFavorite: false,
    latitude: 12.2118,
    longitude: 109.1592
  }
];

const recommendedIds = ["hoian", "dalat"];

const trips: Trip[] = [
  {
    id: "trip-1",
    destination: "Đảo Phú Quốc",
    location: "Kiên Giang, VN",
    date: "20/05/2026 - 23/05/2026",
    guests: "2 Người lớn",
    status: "Sắp tới",
    imagePath: "assets/images/phuquoc_image.jpg",
    isUpcoming: true
  },
  {
    id: "trip-2",
    destination: "Hội An",
    location: "Quảng Nam, VN",
    date: "15/04/2026 - 17/04/2026",
    guests: "1 Người lớn",
    status: "Đã đi",
    imagePath: "assets/images/hoian_image.webp",
    isUpcoming: false
  },
  {
    id: "trip-3",
    destination: "Đà Lạt",
    location: "Lâm Đồng, VN",
    date: "10/03/2026 - 14/03/2026",
    guests: "2 Người lớn, 1 Trẻ em",
    status: "Đã đi",
    imagePath: "assets/images/dalat_image.jpg",
    isUpcoming: false
  }
];

const profile: Profile = {
  name: "Nguyễn Văn A",
  email: "vanya.traveler@email.com"
};

const documents: DocumentItem[] = [
  { id: "doc-1", title: "Hộ chiếu", description: "Hết hạn: 12/2030", icon: "description", color: "#176FF2" },
  { id: "doc-2", title: "Visa", description: "Vietnam - Multiple Entry", icon: "assignment", color: "#4CAF50" },
  { id: "doc-3", title: "Bảo hiểm du lịch", description: "Bảo việt - Toàn cầu", icon: "verified_user", color: "#FF9800" },
  { id: "doc-4", title: "Vé máy bay", description: "Phú Quốc - Sài Gòn", icon: "flight_takeoff", color: "#E91E63" }
];

const mockFlights: Flight[] = [
  {
    id: "fl-1",
    airline: "Vietnam Airlines",
    airlineLogo: "assets/images/vna_logo.png",
    departure: "SGN",
    arrival: "HAN",
    departureTime: "08:30",
    arrivalTime: "10:45",
    price: 120,
    duration: "2h 15m"
  },
  {
    id: "fl-2",
    airline: "Vietjet Air",
    airlineLogo: "assets/images/vj_logo.png",
    departure: "SGN",
    arrival: "HAN",
    departureTime: "09:00",
    arrivalTime: "11:10",
    price: 85,
    duration: "2h 10m"
  },
  {
    id: "fl-3",
    airline: "Bamboo Airways",
    airlineLogo: "assets/images/bb_logo.png",
    departure: "SGN",
    arrival: "HAN",
    departureTime: "14:00",
    arrivalTime: "16:15",
    price: 95,
    duration: "2h 15m"
  },
  {
    id: "fl-4",
    airline: "Vietnam Airlines",
    airlineLogo: "assets/images/vna_logo.png",
    departure: "HAN",
    arrival: "SGN",
    departureTime: "12:15",
    arrivalTime: "14:30",
    price: 130,
    duration: "2h 15m"
  },
  {
    id: "fl-5",
    airline: "Vietjet Air",
    airlineLogo: "assets/images/vj_logo.png",
    departure: "HAN",
    arrival: "SGN",
    departureTime: "18:00",
    arrivalTime: "20:10",
    price: 80,
    duration: "2h 10m"
  },
  {
    id: "fl-6",
    airline: "Vietnam Airlines",
    airlineLogo: "assets/images/vna_logo.png",
    departure: "SGN",
    arrival: "DLI",
    departureTime: "07:00",
    arrivalTime: "07:55",
    price: 65,
    duration: "0h 55m"
  },
  {
    id: "fl-7",
    airline: "Vietjet Air",
    airlineLogo: "assets/images/vj_logo.png",
    departure: "SGN",
    arrival: "DLI",
    departureTime: "11:30",
    arrivalTime: "12:20",
    price: 45,
    duration: "0h 50m"
  },
  {
    id: "fl-8",
    airline: "Bamboo Airways",
    airlineLogo: "assets/images/bb_logo.png",
    departure: "SGN",
    arrival: "PQC",
    departureTime: "14:00",
    arrivalTime: "15:00",
    price: 95,
    duration: "1h 00m"
  },
  {
    id: "fl-9",
    airline: "Vietnam Airlines",
    airlineLogo: "assets/images/vna_logo.png",
    departure: "HAN",
    arrival: "DLI",
    departureTime: "06:15",
    arrivalTime: "08:10",
    price: 150,
    duration: "1h 55m"
  },
  {
    id: "fl-10",
    airline: "Vietnam Airlines",
    airlineLogo: "assets/images/vna_logo.png",
    departure: "SGN",
    arrival: "DAD",
    departureTime: "10:30",
    arrivalTime: "11:55",
    price: 110,
    duration: "1h 25m"
  },
  {
    id: "fl-11",
    airline: "Vietjet Air",
    airlineLogo: "assets/images/vj_logo.png",
    departure: "HAN",
    arrival: "DAD",
    departureTime: "16:00",
    arrivalTime: "17:20",
    price: 75,
    duration: "1h 20m"
  }
];

function getDestinationById(id: string): Destination | undefined {
  return destinations.find((d) => d.id === id);
}

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

function generateTripFromDestination(destination: Destination, customDate?: string, customGuests?: string): Trip {
  const now = new Date();
  const start = new Date(now);
  start.setDate(start.getDate() + 7);
  const days = durationToDays(destination.duration);
  const end = new Date(start);
  end.setDate(end.getDate() + days);
  const id = `trip-${Date.now()}`;

  return {
    id,
    destination: destination.name,
    location: destination.location,
    date: customDate ?? `${formatDate(start)} - ${formatDate(end)}`,
    guests: customGuests ?? "1 Người lớn",
    status: "Sắp tới",
    imagePath: destination.imagePath,
    isUpcoming: true
  };
}

function setFavorite(destinationId: string, isFavorite: boolean): Destination | null {
  const destination = getDestinationById(destinationId);
  if (!destination) {
    return null;
  }
  destination.isFavorite = isFavorite;
  return destination;
}

function toggleFavorite(destinationId: string): Destination | null {
  const destination = getDestinationById(destinationId);
  if (!destination) {
    return null;
  }
  destination.isFavorite = !destination.isFavorite;
  return destination;
}

function bookTrip(destinationId: string, customDate?: string, customGuests?: string): Trip | null {
  const destination = getDestinationById(destinationId);
  if (!destination) {
    return null;
  }
  const trip = generateTripFromDestination(destination, customDate, customGuests);
  trips.unshift(trip);
  return trip;
}

function searchFlights(departure?: string, arrival?: string): Flight[] {
  return mockFlights.filter(f => {
    const matchDep = !departure || f.departure.toLowerCase() === departure.toLowerCase();
    const matchArr = !arrival || f.arrival.toLowerCase() === arrival.toLowerCase();
    return matchDep && matchArr;
  });
}

function bookFlightTrip(flightId: string, date: string, guests: string): Trip | null {
  const flight = mockFlights.find(f => f.id === flightId);
  if (!flight) return null;
  const trip: Trip = {
    id: `trip-fl-${Date.now()}`,
    destination: `${flight.departure} ✈ ${flight.arrival}`,
    location: flight.airline,
    date: date,
    guests: guests,
    status: "Sắp tới",
    imagePath: flight.airlineLogo,
    isUpcoming: true
  };
  trips.unshift(trip);
  return trip;
}

function addDocument(title: string, description: string, icon: string, color: string): DocumentItem {
  const doc: DocumentItem = {
    id: `doc-${Date.now()}`,
    title,
    description,
    icon,
    color
  };
  documents.unshift(doc);
  return doc;
}

export const store = {
  getBootstrap() {
    return {
      categories,
      destinations,
      recommended: destinations.filter((d) => recommendedIds.includes(d.id)),
      trips,
      profile,
      documents
    };
  },
  getFavorites() {
    return destinations.filter((d) => d.isFavorite);
  },
  updateFavorite(destinationId: string, isFavorite?: boolean) {
    if (typeof isFavorite === "boolean") {
      return setFavorite(destinationId, isFavorite);
    }
    return toggleFavorite(destinationId);
  },
  createTrip(destinationId: string, date?: string, guests?: string) {
    return bookTrip(destinationId, date, guests);
  },
  searchFlights,
  bookFlightTrip,
  getTrips(type?: string) {
    if (type === "upcoming") {
      return trips.filter((t) => t.isUpcoming);
    }
    if (type === "history") {
      return trips.filter((t) => !t.isUpcoming);
    }
    return trips;
  },
  getProfile() {
    return profile;
  },
  updateProfile(name?: string, email?: string) {
    if (typeof name === "string" && name.trim().length > 0) {
      profile.name = name.trim();
    }
    if (typeof email === "string" && email.trim().length > 0) {
      profile.email = email.trim();
    }
    return profile;
  },
  getDocuments() {
    return documents;
  },
  createDocument(title: string, description: string, icon: string, color: string) {
    return addDocument(title, description, icon, color);
  }
};
