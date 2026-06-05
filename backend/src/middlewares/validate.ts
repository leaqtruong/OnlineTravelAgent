import express from "express";
import { z } from "zod";

export const validate = (schema: z.ZodSchema) => (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    const err = parsed.error as any;
    res.status(400).json({ message: err.errors[0].message, errors: err.errors });
    return;
  }
  req.body = parsed.data;
  next();
};
