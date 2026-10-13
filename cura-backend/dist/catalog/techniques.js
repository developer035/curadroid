"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isValidTechnique = exports.VALID_TECHNIQUES = void 0;
exports.VALID_TECHNIQUES = [
    'box_breathing',
    'grounding_54321',
    'thought_record',
    'behavioral_activation',
    'wind_down_breathing',
];
const isValidTechnique = (id) => {
    return exports.VALID_TECHNIQUES.includes(id);
};
exports.isValidTechnique = isValidTechnique;
