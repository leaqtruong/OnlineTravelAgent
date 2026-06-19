import { PrismaClient } from '@prisma/client';
import crypto from 'crypto';

const prisma = new PrismaClient();

async function main() {
  const email = "partner@example.com";
  const password = "password123";
  const hashedPassword = crypto.createHash("sha256").update(password).digest("hex");

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    if (existing.role !== 'PARTNER') {
      await prisma.user.update({ where: { email }, data: { role: 'PARTNER', password: hashedPassword } });
      console.log('Updated existing partner@example.com to PARTNER role.');
    } else {
      console.log('Partner account already exists.');
    }
  } else {
    await prisma.user.create({
      data: {
        name: "Test Partner",
        email: email,
        password: hashedPassword,
        role: "PARTNER"
      }
    });
    console.log('Created partner account: partner@example.com / password123');
  }
}

main().catch(e => {
  console.error(e);
  process.exit(1);
}).finally(async () => {
  await prisma.$disconnect();
});
