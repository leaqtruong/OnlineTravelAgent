import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const admin = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      name: 'Admin',
      email: 'admin@example.com',
      password: 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',
      role: 'ADMIN'
    }
  });
  console.log('Admin user created:', admin.email);
}
main().finally(() => prisma.$disconnect());
