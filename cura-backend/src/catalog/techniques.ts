export const VALID_TECHNIQUES = [
  'box_breathing',
  'grounding_54321',
  'thought_record',
  'behavioral_activation',
  'wind_down_breathing',
];

export const isValidTechnique = (id: string): boolean => {
  return VALID_TECHNIQUES.includes(id);
};
