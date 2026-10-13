"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateCoachResponseStream = void 0;
const genai_1 = require("@google/genai");
const env_1 = require("../../config/env");
const promptBuilder_1 = require("../promptBuilder");
const techniques_1 = require("../../catalog/techniques");
const ai = new genai_1.GoogleGenAI({ apiKey: env_1.env.GEMINI_API_KEY });
const responseSchema = {
    type: genai_1.Type.OBJECT,
    properties: {
        reply: {
            type: genai_1.Type.STRING,
            description: "The empathetic response to the user."
        },
        technique_id: {
            type: genai_1.Type.STRING,
            description: "The ID of the recommended CBT technique."
        },
        chips: {
            type: genai_1.Type.ARRAY,
            items: {
                type: genai_1.Type.STRING
            },
            description: "Up to 3 quick reply chips for the user."
        }
    },
    required: ["reply", "technique_id", "chips"]
};
const generateCoachResponseStream = async function* (request) {
    const systemInstruction = (0, promptBuilder_1.buildSystemPrompt)();
    const userPrompt = (0, promptBuilder_1.buildUserPrompt)(request);
    let responseStream;
    try {
        responseStream = await ai.models.generateContentStream({
            model: env_1.env.GEMINI_MODEL || 'gemini-3.8-flash',
            contents: userPrompt,
            config: {
                systemInstruction: systemInstruction,
                responseMimeType: 'application/json',
                responseSchema: responseSchema,
            }
        });
    }
    catch (error) {
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
    let parsed;
    try {
        parsed = JSON.parse(fullResponse);
    }
    catch (e) {
        console.error("Invalid JSON from LLM:", fullResponse);
        throw new Error("Invalid JSON format from LLM");
    }
    // Validate technique_id
    if (!(0, techniques_1.isValidTechnique)(parsed.technique_id)) {
        parsed.technique_id = 'grounding_54321'; // fallback
    }
    yield { type: 'complete', data: parsed };
};
exports.generateCoachResponseStream = generateCoachResponseStream;
