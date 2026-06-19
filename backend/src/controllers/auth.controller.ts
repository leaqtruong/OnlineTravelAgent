import { Request, Response } from "express";
import crypto from "crypto";
import jwt from "jsonwebtoken";
import prisma from "../config/prisma.js";

export const authController = {
  login: async (req: Request, res: Response) => {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ message: "Email and password are required" });
      return;
    }

    const hashedPassword = crypto.createHash("sha256").update(password).digest("hex");

    const user = await prisma.user.findUnique({ where: { email } });

    if (!user || user.password !== hashedPassword) {
      res.status(401).json({ message: "Invalid email or password" });
      return;
    }

    const { password: _, ...userWithoutPassword } = user;
    const JWT_SECRET = process.env.JWT_SECRET || "fallback_super_secret";
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

    const hashedPassword = crypto.createHash("sha256").update(password).digest("hex");

    const user = await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
      },
    });

    const { password: _, ...userWithoutPassword } = user;
    const JWT_SECRET = process.env.JWT_SECRET || "fallback_super_secret";
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
    const JWT_SECRET = process.env.JWT_SECRET || "fallback_super_secret";
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ user: userWithoutPassword, token });
  }
};
