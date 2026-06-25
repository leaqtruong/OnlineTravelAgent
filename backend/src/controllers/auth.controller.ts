import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import prisma from "../config/prisma.js";

const BCRYPT_ROUNDS = 10;

export const authController = {
  login: async (req: Request, res: Response) => {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ message: "Email and password are required" });
      return;
    }

    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      res.status(401).json({ message: "Invalid email or password" });
      return;
    }

    // Try bcrypt first (new format), then fall back to SHA-256 (legacy)
    let passwordValid = false;
    let needsMigration = false;

    if (user.password.startsWith("$2a$") || user.password.startsWith("$2b$")) {
      // bcrypt hash
      passwordValid = await bcrypt.compare(password, user.password);
    } else {
      // Legacy SHA-256 hash
      const sha256Hash = crypto.createHash("sha256").update(password).digest("hex");
      passwordValid = user.password === sha256Hash;
      needsMigration = passwordValid;
    }

    if (!passwordValid) {
      res.status(401).json({ message: "Invalid email or password" });
      return;
    }

    // Migrate legacy SHA-256 hash to bcrypt
    if (needsMigration) {
      const bcryptHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
      await prisma.user.update({
        where: { id: user.id },
        data: { password: bcryptHash },
      });
    }

    const { password: _, ...userWithoutPassword } = user;
    const JWT_SECRET = (process.env.JWT_SECRET as string);
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ user: userWithoutPassword, token });
  },

  register: async (req: Request, res: Response) => {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      res.status(400).json({ message: "Name, email and password are required" });
      return;
    }

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      res.status(409).json({ message: "Email already exists" });
      return;
    }

    const hashedPassword = await bcrypt.hash(password, BCRYPT_ROUNDS);

    const user = await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
      },
    });

    const { password: _, ...userWithoutPassword } = user;
    const JWT_SECRET = (process.env.JWT_SECRET as string);
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.status(201).json({ user: userWithoutPassword, token });
  },

  becomePartner: async (req: Request, res: Response) => {
    const userId = (req as any).userId;
    if (!userId) {
      res.status(401).json({ message: "Unauthorized" });
      return;
    }
    const user = await prisma.user.update({
      where: { id: userId },
      data: { role: 'PARTNER' }
    });
    const { password: _, ...userWithoutPassword } = user;
    const JWT_SECRET = (process.env.JWT_SECRET as string);
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ user: userWithoutPassword, token });
  }
};

