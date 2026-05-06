import { z } from 'zod';

export const scenarioCategorySchema = z.enum([
  'work',
  'family',
  'friendship',
  'romantic',
  'other',
]);

export const createScenarioSchema = z.object({
  title: z.string().min(3).max(100),
  context: z.string().min(10),
  category: scenarioCategorySchema,
});

export const createSessionSchema = z.object({
  scenario_id: z.uuid(),
});

export const sessionMessageSchema = z.object({
  content: z.string().min(1).max(2000),
});

export const googleAuthSchema = z.object({
  id_token: z.string().min(1),
});

export const analysisSchema = z.object({
  empathy_score: z.number().int().min(1).max(10),
  clarity_score: z.number().int().min(1).max(10),
  assertiveness_score: z.number().int().min(1).max(10),
  summary: z.string().min(1),
  strengths: z.array(z.string()).default([]),
  improvements: z.array(z.string()).default([]),
  alternative_lines: z.array(z.string()).default([]),
});

export type ScenarioCategory = z.infer<typeof scenarioCategorySchema>;
export type CreateScenarioInput = z.infer<typeof createScenarioSchema>;
export type CreateSessionInput = z.infer<typeof createSessionSchema>;
export type SessionMessageInput = z.infer<typeof sessionMessageSchema>;
export type GoogleAuthInput = z.infer<typeof googleAuthSchema>;
export type Analysis = z.infer<typeof analysisSchema>;
