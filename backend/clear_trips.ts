import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const res = await prisma.trip.deleteMany();
  console.log('Deleted ' + res.count + ' trips');
}
main().finally(() => prisma.$disconnect());
