import { z } from 'zod';

const sleepQualityEnum = z.enum(['poor', 'fair', 'good', 'excellent']);

export const createSleepRecordSchema = z.object({
  bedTime: z
    .string({ required_error: 'Bed time is required' })
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid bed time format' }),
  wakeTime: z
    .string({ required_error: 'Wake time is required' })
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid wake time format' }),
  quality: sleepQualityEnum.default('good'),
  notes: z
    .string()
    .max(1000, 'Notes must be 1000 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
});

export const updateSleepRecordSchema = z.object({
  bedTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid bed time format' })
    .optional(),
  wakeTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid wake time format' })
    .optional(),
  quality: sleepQualityEnum.optional(),
  notes: z
    .string()
    .max(1000)
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
});

export const sleepRecordIdSchema = z.object({
  id: z.string().uuid('Invalid sleep record ID format'),
});

export const updateSleepGoalSchema = z.object({
  goalMinutes: z
    .number({ required_error: 'Goal minutes is required' })
    .int()
    .min(60, 'Goal must be at least 1 hour')
    .max(1440, 'Goal cannot exceed 24 hours'),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
