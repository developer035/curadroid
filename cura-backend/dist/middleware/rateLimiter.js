"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.installIdRateLimiter = exports.globalDailyCap = exports.ipRateLimiter = void 0;
const express_rate_limit_1 = __importStar(require("express-rate-limit"));
const env_1 = require("../config/env");
exports.ipRateLimiter = (0, express_rate_limit_1.default)({
    windowMs: 60 * 1000, // 1 minute
    max: env_1.env.RATE_LIMIT_PER_MINUTE,
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
const globalDailyCap = (req, res, next) => {
    const today = new Date().getUTCDate();
    if (today !== currentDay) {
        dailyRequestsCount = 0;
        currentDay = today;
    }
    if (dailyRequestsCount >= env_1.env.DAILY_GLOBAL_CAP) {
        return res.status(429).json({
            error: 'Global daily API request cap reached.',
        });
    }
    // Count all requests that pass this middleware.
    dailyRequestsCount++;
    next();
};
exports.globalDailyCap = globalDailyCap;
exports.installIdRateLimiter = (0, express_rate_limit_1.default)({
    windowMs: 60 * 1000, // 1 minute
    max: env_1.env.RATE_LIMIT_PER_MINUTE,
    keyGenerator: (req) => {
        const installId = req.body?.installId;
        if (typeof installId === 'string' && installId.trim().length > 0) {
            return installId.trim();
        }
        // Normalize IP addresses, including IPv6.
        return (0, express_rate_limit_1.ipKeyGenerator)(req.ip ?? '127.0.0.1');
    },
    message: {
        error: 'Too many requests from this device, please try again later.',
    },
    standardHeaders: true,
    legacyHeaders: false,
});
