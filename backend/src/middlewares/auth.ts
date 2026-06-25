import express from "express";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET as string;
if (!JWT_SECRET) {
  console.error('FATAL: JWT_SECRET environment variable is not set. Authentication will fail.');
}

// Extract JWT Token
const extractToken = (req: express.Request): string | null => {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith("Bearer ")) {
    return authHeader.substring(7);
  }
  return null;
};

// Client Optional Auth (Sets req.userId if valid, but does not block if missing)
export const optionalAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const token = extractToken(req);
  if (token) {
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as { userId: string };
      (req as any).userId = decoded.userId;
    } catch (err) {
      // ignore invalid token, proceed as guest
    }
  }
  next();
};

// Client Strict Auth (Requires valid JWT)
export const clientAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const token = extractToken(req);
  if (!token) {
    res.status(401).json({ message: "Unauthorized - Token missing" });
    return;
  }
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as { userId: string };
    (req as any).userId = decoded.userId;
    next();
  } catch (err) {
    res.status(401).json({ message: "Unauthorized - Invalid token" });
  }
};

// Partner Auth
export const partnerAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const token = extractToken(req);
  if (!token) {
    res.status(401).json({ message: "Unauthorized - Token missing" });
    return;
  }
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as { userId: string, role: string };
    if (decoded.role !== 'PARTNER' && decoded.role !== 'ADMIN') {
      res.status(403).json({ message: "Forbidden - Partner role required" });
      return;
    }
    (req as any).userId = decoded.userId;
    next();
  } catch (err) {
    res.status(401).json({ message: "Unauthorized - Invalid token" });
  }
};

// Admin Basic Auth Middleware
export const adminAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    res.status(401).send('Unauthorized');
    return;
  }
  try {
    const auth = Buffer.from(authHeader.split(' ')[1], 'base64').toString().split(':');
    const user = auth[0];
    const pass = auth[1];
    
    if (user === 'admin' && pass === process.env.ADMIN_PASSWORD) {
      next();
    } else {
      res.status(401).send('Unauthorized');
    }
  } catch (err) {
    res.status(401).send('Unauthorized');
  }
};
