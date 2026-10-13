"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.llmResponseSchema = exports.coachRequestSchema = void 0;
const zod_1 = require("zod");
exports.coachRequestSchema = zod_1.z.object({
    installId: zod_1.z.string().min(1, 'installId is required').max(100),
    context: zod_1.z.object({
        readinessBand: zod_1.z.enum(['low', 'moderate', 'good']),
        drivers: zod_1.z.array(zod_1.z.string()).max(5),
        mood: zod_1.z.number().min(1).max(5),
        energy: zod_1.z.number().min(1).max(5),
        stress: zod_1.z.number().min(1).max(5),
        tags: zod_1.z.array(zod_1.z.string()).max(10),
        recentSummaries: zod_1.z.array(zod_1.z.string()).max(3),
    }),
    userMessage: zod_1.z.string().min(1).max(1000),
});
exports.llmResponseSchema = zod_1.z.object({
    reply: zod_1.z.string(),
    technique_id: zod_1.z.string(),
    chips: zod_1.z.array(zod_1.z.string()).max(3),
});
