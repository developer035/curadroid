import { Request, Response } from 'express';
import { coachRequestSchema, CoachRequest } from '../schemas/coach.schema';
import { getLlmStream } from '../services/llm/factory';

export const handleCoachRequest = async (req: Request, res: Response) => {
  // Validate request body
  const parseResult = coachRequestSchema.safeParse(req.body);
  if (!parseResult.success) {
    return res.status(400).json({ error: 'Invalid request body', details: parseResult.error.format() });
  }

  const validRequest: CoachRequest = parseResult.data;
  
  // Set headers for SSE
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  const streamFn = getLlmStream();

  let success = false;
  let attempts = 0;
  const maxAttempts = 2; // 1 initial + 1 retry

  while (!success && attempts < maxAttempts) {
    attempts++;
    try {
      const stream = streamFn(validRequest);
      
      for await (const event of stream) {
        if (event.type === 'chunk') {
          res.write(`data: ${JSON.stringify(event)}\n\n`);
        } else if (event.type === 'complete') {
          res.write(`data: ${JSON.stringify(event)}\n\n`);
          success = true;
        }
      }
    } catch (error: any) {
      console.error(`Attempt ${attempts} failed:`, error.message);
      if (attempts >= maxAttempts) {
        res.write(`event: error\ndata: ${JSON.stringify({ error: 'Failed to generate response after retries' })}\n\n`);
        res.write(`event: done\ndata: [DONE]\n\n`);
        res.end();
        return;
      }
      // If we retry, we just run the loop again.
      // The client will see a mix of chunks, but it will get a new sequence.
      // In a real robust system, we might want to signal a "retry" event to the client to reset its buffer.
      res.write(`event: retry\ndata: {"message": "Retrying request"}\n\n`);
    }
  }

  res.write(`event: done\ndata: [DONE]\n\n`);
  res.end();
};
