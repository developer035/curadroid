"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateCoachResponseStream = void 0;
const sdk_1 = __importDefault(require("@anthropic-ai/sdk"));
const env_1 = require("../../config/env");
const promptBuilder_1 = require("../promptBuilder");
const techniques_1 = require("../../catalog/techniques");
const client = new sdk_1.default({
    apiKey: env_1.env.ANTHROPIC_API_KEY || process.env.ANTHROPIC_API_KEY,
});
const generateCoachResponseStream = async function* (request) {
    const systemInstruction = (0, promptBuilder_1.buildSystemPrompt)();
    const userPrompt = (0, promptBuilder_1.buildUserPrompt)(request);
    let stream;
    try {
        stream = client.messages.stream({
            model: env_1.env.ANTHROPIC_MODEL || 'claude-haiku-5-5',
            max_tokens: 20000,
            system: systemInstruction,
            messages: [
                {
                    role: 'user',
                    content: userPrompt,
                },
            ],
        });
    }
    catch (error) {
        console.error('Error initiating Anthropic stream:', error);
        throw new Error('Failed to communicate with LLM');
    }
    let fullResponse = '';
    try {
        for await (const event of stream) {
            if (event.type === 'content_block_delta' &&
                event.delta.type === 'text_delta') {
                const text = event.delta.text;
                fullResponse += text;
                yield { type: 'chunk', text };
            }
        }
    }
    catch (error) {
        console.error('Error during Anthropic stream:', error);
        throw new Error('Failed to communicate with LLM');
    }
    // Strip code fences if model wrapped response in markdown
    let cleanedResponse = fullResponse.trim();
    if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.replace(/^```json\s*/, '').replace(/\s*```$/, '');
    }
    else if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.replace(/^```\s*/, '').replace(/\s*```$/, '');
    }
    let parsed;
    try {
        parsed = JSON.parse(cleanedResponse);
    }
    catch (e) {
        console.error('Invalid JSON from LLM:', fullResponse);
        throw new Error('Invalid JSON format from LLM');
    }
    // Validate technique_id
    if (!(0, techniques_1.isValidTechnique)(parsed.technique_id)) {
        parsed.technique_id = 'grounding_54321'; // fallback
    }
    yield { type: 'complete', data: parsed };
};
exports.generateCoachResponseStream = generateCoachResponseStream;
