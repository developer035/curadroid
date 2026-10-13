import rateLimit, { ipKeyGenerator } from 'express-rate-limit';
import { env } from '../config/env';
import { Request, Response } from 'express';

export const ipRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: env.RATE_LIMIT_PER_MINUTE,
  message: {
    error: 'Too many requests from this IP, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// A simple in-memory daily global cap.
// For multiple server instances, use Redis instead.
let dailyRequestsCount = 0;
let currentDay = new Date().getUTCDate();

export const globalDailyCap = (
  req: Request,
  res: Response,
  next: Function
) => {
  const today = new Date().getUTCDate();

  if (today !== currentDay) {
    dailyRequestsCount = 0;
    currentDay = today;
  }

  if (dailyRequestsCount >= env.DAILY_GLOBAL_CAP) {
    return res.status(429).json({
      error: 'Global daily API request cap reached.',
    });
  }

  // Count all requests that pass this middleware.
  dailyRequestsCount++;
  next();
};

export const installIdRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: env.RATE_LIMIT_PER_MINUTE,

  keyGenerator: (req: Request) => {
    const installId = req.body?.installId;

    if (typeof installId === 'string' && installId.trim().length > 0) {
      return installId.trim();
    }

    // Normalize IP addresses, including IPv6.
    return ipKeyGenerator(req.ip ?? '127.0.0.1');
  },

  message: {
    error: 'Too many requests from this device, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});