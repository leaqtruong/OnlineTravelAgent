import express from "express";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "fallback_super_secret";

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

// Admin Basic Auth Middleware
export const adminAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    res.setHeader('WWW-Authenticate', 'Basic realm="Admin Panel"');
    res.status(401).send('Unauthorized');
    return;
  }
  try {
    const auth = Buffer.from(authHeader.split(' ')[1], 'base64').toString().split(':');
    const user = auth[0];
    const pass = auth[1];
    
    if (user === 'admin' && pass === (process.env.ADMIN_PASSWORD || 'admin123')) {
      next();
    } else {
      res.setHeader('WWW-Authenticate', 'Basic realm="Admin Panel"');
      res.status(401).send('Unauthorized');
    }
  } catch (err) {
    res.setHeader('WWW-Authenticate', 'Basic realm="Admin Panel"');
    res.status(401).send('Unauthorized');
  }
};
