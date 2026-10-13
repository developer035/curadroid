import { z } from 'zod';

export const coachRequestSchema = z.object({
  installId: z.string().min(1, 'installId is required').max(100),
  context: z.object({
    readinessBand: z.enum(['low', 'moderate', 'good']),
    drivers: z.array(z.string()).max(5),
    mood: z.number().min(1).max(5),
    energy: z.number().min(1).max(5),
    stress: z.number().min(1).max(5),
    tags: z.array(z.string()).max(10),
    recentSummaries: z.array(z.string()).max(3),
  }),
  userMessage: z.string().min(1).max(1000),
});

export type CoachRequest = z.infer<typeof coachRequestSchema>;

export const llmResponseSchema = z.object({
  reply: z.string(),
  technique_id: z.string(),
  chips: z.array(z.string()).max(3),
});

export type LlmResponse = z.infer<typeof llmResponseSchema>;
