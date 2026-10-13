"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const health_controller_1 = require("./controllers/health.controller");
const coach_controller_1 = require("./controllers/coach.controller");
const payloadGuard_1 = require("./middleware/payloadGuard");
const rateLimiter_1 = require("./middleware/rateLimiter");
const errorHandler_1 = require("./middleware/errorHandler");
const app = (0, express_1.default)();
app.set('trust proxy', 1); // important for rate limiting behind reverse proxies
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)());
// Apply payload guard BEFORE body parser
app.use((0, payloadGuard_1.payloadGuard)(4096)); // 4KB limit
app.use(express_1.default.json({ limit: '4kb' }));
// Routes
app.get('/health', health_controller_1.healthCheck);
// Protect the coach endpoint with rate limiters
app.post('/coach', rateLimiter_1.ipRateLimiter, rateLimiter_1.installIdRateLimiter, rateLimiter_1.globalDailyCap, coach_controller_1.handleCoachRequest);
// Centralized error handling
app.use(errorHandler_1.errorHandler);
exports.default = app;
