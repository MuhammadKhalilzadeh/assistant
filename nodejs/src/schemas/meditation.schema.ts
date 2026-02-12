import { z } from 'zod';

const meditationTypeEnum = z.enum(['breathing', 'guided', 'unguided', 'sleep', 'focus']);

export const createMeditationSessionSchema = z.object({
  type: meditationTypeEnum,
  startTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
  durationMinutes: z
    .number({ required_error: 'Duration is required' })
    .int('Duration must be an integer')
    .min(1, 'Duration must be at least 1 minute')
    .max(480, 'Duration cannot exceed 480 minutes'),
  isCompleted: z.boolean().default(false),
  notes: z
    .string()
    .max(1000, 'Notes must be 1000 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
});

export const updateMeditationSessionSchema = z.object({
  type: meditationTypeEnum.optional(),
  startTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
  durationMinutes: z
    .number()
    .int()
    .min(1)
    .max(480)
    .optional(),
  isCompleted: z.boolean().optional(),
  notes: z
    .string()
    .max(1000)
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
});

export const meditationSessionIdSchema = z.object({
  id: z.string().uuid('Invalid meditation session ID format'),
});

export const updateMeditationGoalSchema = z.object({
  dailyMinutesGoal: z
    .number({ required_error: 'Daily minutes goal is required' })
    .int()
    .min(1, 'Must be at least 1 minute')
    .max(480, 'Cannot exceed 480 minutes'),
  weeklySessionsGoal: z
    .number()
    .int()
    .min(1, 'Must be at least 1 session')
    .max(50, 'Cannot exceed 50 sessions')
    .optional(),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
