import { env } from '../../config/env';
import { generateCoachResponseStream as geminiStream } from './gemini';
import { generateCoachResponseStream as anthropicStream } from './anthropic';

// Extensible factory for LLM providers
export const getLlmStream = () => {
  if (env.LLM_PROVIDER === 'gemini') {
    return geminiStream;
  }
  
  if (env.LLM_PROVIDER === 'anthropic') {
    return anthropicStream;
  }
  
  return anthropicStream;
};
