import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

const envSchema = z.object({
  PORT: z.string().default('3000'),
  LLM_PROVIDER: z.enum(['gemini', 'openai', 'anthropic']).default('anthropic'),
  GEMINI_API_KEY: z.string().optional(),
  GEMINI_MODEL: z.string().default('gemini-3.8-flash'),
  ANTHROPIC_API_KEY: z.string().optional(),
  ANTHROPIC_MODEL: z.string().default('claude-haiku-5-5'),
  DAILY_GLOBAL_CAP: z.coerce.number().default(1000),
  RATE_LIMIT_PER_MINUTE: z.coerce.number().default(10),
});

const envParse = envSchema.safeParse(process.env);

if (!envParse.success) {
  console.error('Invalid environment variables:', envParse.error.format());
  process.exit(1);
}

export const env = envParse.data;
