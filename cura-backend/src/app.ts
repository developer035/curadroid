import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { healthCheck } from './controllers/health.controller';
import { handleCoachRequest } from './controllers/coach.controller';
import { payloadGuard } from './middleware/payloadGuard';
import { ipRateLimiter, installIdRateLimiter, globalDailyCap } from './middleware/rateLimiter';
import { errorHandler } from './middleware/errorHandler';

const app = express();

app.set('trust proxy', 1); // important for rate limiting behind reverse proxies

app.use(helmet());
app.use(cors());

// Apply payload guard BEFORE body parser
app.use(payloadGuard(4096)); // 4KB limit
app.use(express.json({ limit: '4kb' }));

// Routes
app.get('/health', healthCheck);

// Protect the coach endpoint with rate limiters
app.post(
  '/coach',
  ipRateLimiter,
  installIdRateLimiter,
  globalDailyCap,
  handleCoachRequest
);

// Centralized error handling
app.use(errorHandler);

export default app;
