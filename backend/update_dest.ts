import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const rate = 25000;
  const dests = await prisma.destination.findMany();
  for (const d of dests) {
    let p = parseFloat(d.price);
    if (!isNaN(p) && p < 50000) {
      await prisma.destination.update({ where: { id: d.id }, data: { price: (p * rate).toString() } });
    }
  }
  console.log('Dests updated');
}

main().catch(console.error).finally(() => prisma.$disconnect());
