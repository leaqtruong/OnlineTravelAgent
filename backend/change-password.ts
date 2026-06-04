import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("Altering user password to '123456'...");
  await prisma.$executeRawUnsafe("ALTER USER postgres WITH PASSWORD '123456';");
  console.log("Password altered successfully!");
  await prisma.$disconnect();
}

main().catch(err => {
  console.error("Failed to alter password:", err);
  process.exit(1);
});
