import express from "express";

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
