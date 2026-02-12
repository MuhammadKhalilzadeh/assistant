import { z } from 'zod';

const moodLevelEnum = z.enum(['great', 'good', 'okay', 'bad', 'awful']);

export const createMoodEntrySchema = z.object({
  mood: moodLevelEnum,
  notes: z
    .string()
    .max(1000, 'Notes must be 1000 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
  activities: z
    .array(z.string().max(100))
    .max(20, 'Maximum 20 activities')
    .default([]),
  recordedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const updateMoodEntrySchema = z.object({
  mood: moodLevelEnum.optional(),
  notes: z
    .string()
    .max(1000, 'Notes must be 1000 characters or less')
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
  activities: z
    .array(z.string().max(100))
    .max(20)
    .optional(),
  recordedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const moodEntryIdSchema = z.object({
  id: z.string().uuid('Invalid mood entry ID format'),
});

export const updateMoodGoalSchema = z.object({
  dailyEntriesGoal: z
    .number({ required_error: 'Daily entries goal is required' })
    .int()
    .min(1, 'Must be at least 1')
    .max(10, 'Cannot exceed 10'),
  targetMood: moodLevelEnum.optional(),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
