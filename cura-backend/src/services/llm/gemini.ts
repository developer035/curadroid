import { GoogleGenAI, Type } from '@google/genai';
import { env } from '../../config/env';
import { buildSystemPrompt, buildUserPrompt } from '../promptBuilder';
import { CoachRequest, LlmResponse } from '../../schemas/coach.schema';
import { isValidTechnique } from '../../catalog/techniques';

const ai = new GoogleGenAI({ apiKey: env.GEMINI_API_KEY });

const responseSchema = {
  type: Type.OBJECT,
  properties: {
    reply: {
      type: Type.STRING,
      description: "The empathetic response to the user."
    },
    technique_id: {
      type: Type.STRING,
      description: "The ID of the recommended CBT technique."
    },
    chips: {
      type: Type.ARRAY,
      items: {
        type: Type.STRING
      },
      description: "Up to 3 quick reply chips for the user."
    }
  },
  required: ["reply", "technique_id", "chips"]
};

export const generateCoachResponseStream = async function* (request: CoachRequest) {
  const systemInstruction = buildSystemPrompt();
  const userPrompt = buildUserPrompt(request);

  let responseStream;
  try {
    responseStream = await ai.models.generateContentStream({
      model: env.GEMINI_MODEL || 'gemini-3.8-flash',
      contents: userPrompt,
      config: {
        systemInstruction: systemInstruction,
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
      }
    });
  } catch (error) {
    console.error("Error calling Gemini API:", error);
    throw new Error("Failed to communicate with LLM");
  }

  let fullResponse = "";

  for await (const chunk of responseStream) {
    const text = chunk.text;
    if (text) {
      fullResponse += text;
      // Yield partial JSON chunks so the client can show progress if it wants
      yield { type: 'chunk', text };
    }
  }

  // At the end, try to parse and validate the JSON
  let parsed: any;
  try {
    parsed = JSON.parse(fullResponse);
  } catch (e) {
    console.error("Invalid JSON from LLM:", fullResponse);
    throw new Error("Invalid JSON format from LLM");
  }

  // Validate technique_id
  if (!isValidTechnique(parsed.technique_id)) {
    parsed.technique_id = 'grounding_54321'; // fallback
  }

  yield { type: 'complete', data: parsed as LlmResponse };
};
