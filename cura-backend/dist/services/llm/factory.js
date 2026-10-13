"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getLlmStream = void 0;
const env_1 = require("../../config/env");
const gemini_1 = require("./gemini");
const anthropic_1 = require("./anthropic");
// Extensible factory for LLM providers
const getLlmStream = () => {
    if (env_1.env.LLM_PROVIDER === 'gemini') {
        return gemini_1.generateCoachResponseStream;
    }
    if (env_1.env.LLM_PROVIDER === 'anthropic') {
        return anthropic_1.generateCoachResponseStream;
    }
    return anthropic_1.generateCoachResponseStream;
};
exports.getLlmStream = getLlmStream;
