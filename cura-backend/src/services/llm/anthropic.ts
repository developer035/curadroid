import Anthropic from '@anthropic-ai/sdk';
import { env } from '../../config/env';
import { buildSystemPrompt, buildUserPrompt } from '../promptBuilder';
import { CoachRequest, LlmResponse } from '../../schemas/coach.schema';
import { isValidTechnique } from '../../catalog/techniques';

const client = new Anthropic({
  apiKey: env.ANTHROPIC_API_KEY || process.env.ANTHROPIC_API_KEY,
});

export const generateCoachResponseStream = async function* (request: CoachRequest) {
  const systemInstruction = buildSystemPrompt();
  const userPrompt = buildUserPrompt(request);

  let stream;
  try {
    stream = client.messages.stream({
      model: env.ANTHROPIC_MODEL || 'claude-haiku-5-5',
      max_tokens: 20000,
      system: systemInstruction,
      messages: [
        {
          role: 'user',
          content: userPrompt,
        },
      ],
    });
  } catch (error) {
    console.error('Error initiating Anthropic stream:', error);
    throw new Error('Failed to communicate with LLM');
  }

  let fullResponse = '';

  try {
    for await (const event of stream) {
      if (
        event.type === 'content_block_delta' &&
        event.delta.type === 'text_delta'
      ) {
        const text = event.delta.text;
        fullResponse += text;
        yield { type: 'chunk', text };
      }
    }
  } catch (error) {
    console.error('Error during Anthropic stream:', error);
    throw new Error('Failed to communicate with LLM');
  }

  // Strip code fences if model wrapped response in markdown
  let cleanedResponse = fullResponse.trim();
  if (cleanedResponse.startsWith('```json')) {
    cleanedResponse = cleanedResponse.replace(/^```json\s*/, '').replace(/\s*```$/, '');
  } else if (cleanedResponse.startsWith('```')) {
    cleanedResponse = cleanedResponse.replace(/^```\s*/, '').replace(/\s*```$/, '');
  }

  let parsed: any;
  try {
    parsed = JSON.parse(cleanedResponse);
  } catch (e) {
    console.error('Invalid JSON from LLM:', fullResponse);
    throw new Error('Invalid JSON format from LLM');
  }

  // Validate technique_id
  if (!isValidTechnique(parsed.technique_id)) {
    parsed.technique_id = 'grounding_54321'; // fallback
  }

  yield { type: 'complete', data: parsed as LlmResponse };
};
