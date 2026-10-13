"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.env = void 0;
const zod_1 = require("zod");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const envSchema = zod_1.z.object({
    PORT: zod_1.z.string().default('3000'),
    LLM_PROVIDER: zod_1.z.enum(['gemini', 'openai', 'anthropic']).default('anthropic'),
    GEMINI_API_KEY: zod_1.z.string().optional(),
    GEMINI_MODEL: zod_1.z.string().default('gemini-3.8-flash'),
    ANTHROPIC_API_KEY: zod_1.z.string().optional(),
    ANTHROPIC_MODEL: zod_1.z.string().default('claude-haiku-5-5'),
    DAILY_GLOBAL_CAP: zod_1.z.coerce.number().default(1000),
    RATE_LIMIT_PER_MINUTE: zod_1.z.coerce.number().default(10),
});
const envParse = envSchema.safeParse(process.env);
if (!envParse.success) {
    console.error('Invalid environment variables:', envParse.error.format());
    process.exit(1);
}
exports.env = envParse.data;
