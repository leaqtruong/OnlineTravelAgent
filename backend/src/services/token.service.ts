import crypto from "crypto";
import jwt from "jsonwebtoken";
import { Role } from "@prisma/client";
import prisma from "../config/prisma.js";
import { env } from "../config/env.js";

const ACCESS_TOKEN_TTL = "15m";
const REFRESH_TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const ACCESS_TOKEN_EXPIRES_IN_SECONDS = 15 * 60;

type AuthUser = {
  id: string;
  role: Role;
};

function hashToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function createRefreshTokenValue(): string {
  return crypto.randomBytes(48).toString("base64url");
}

function signAccessToken(user: AuthUser): string {
  return jwt.sign({ userId: user.id, role: user.role }, env.jwtSecret, {
    expiresIn: ACCESS_TOKEN_TTL,
  });
}

export const tokenService = {
  accessTokenExpiresInSeconds: ACCESS_TOKEN_EXPIRES_IN_SECONDS,

  async issueTokenPair(user: AuthUser) {
    const accessToken = signAccessToken(user);
    const refreshToken = createRefreshTokenValue();
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS);

    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: hashToken(refreshToken),
        expiresAt,
      },
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TOKEN_EXPIRES_IN_SECONDS,
    };
  },

  async rotateRefreshToken(refreshToken: string) {
    const stored = await prisma.refreshToken.findUnique({
      where: { tokenHash: hashToken(refreshToken) },
      include: { user: true },
    });

    if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
      return null;
    }

    await prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });

    return this.issueTokenPair({ id: stored.user.id, role: stored.user.role });
  },

  async revokeRefreshToken(refreshToken: string) {
    const stored = await prisma.refreshToken.findUnique({
      where: { tokenHash: hashToken(refreshToken) },
    });
    if (!stored || stored.revokedAt) return false;

    await prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });
    return true;
  },

  async revokeAllForUser(userId: string) {
    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  },
};
