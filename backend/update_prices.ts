import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const rate = 25000;
  
  const flights = await prisma.flight.findMany();
  for (const f of flights) {
    if (f.price < 50000) await prisma.flight.update({ where: { id: f.id }, data: { price: f.price * rate } });
  }
  
  const hotels = await prisma.hotel.findMany();
  for (const h of hotels) {
    if (h.priceFrom < 50000) await prisma.hotel.update({ where: { id: h.id }, data: { priceFrom: h.priceFrom * rate } });
  }
  
  const rooms = await prisma.room.findMany();
  for (const r of rooms) {
    if (r.price < 50000) await prisma.room.update({ where: { id: r.id }, data: { price: r.price * rate } });
  }
  
  const tours = await prisma.tourPackage.findMany();
  for (const t of tours) {
    if (t.price < 50000) await prisma.tourPackage.update({ where: { id: t.id }, data: { price: t.price * rate, originalPrice: t.originalPrice ? t.originalPrice * rate : null } });
  }

  // Update seed data as well so future seeds will be in VND
}

main().catch(console.error).finally(() => prisma.$disconnect());
