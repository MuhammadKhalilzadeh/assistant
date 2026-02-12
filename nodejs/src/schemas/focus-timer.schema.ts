import { z } from 'zod';

const focusTimerTypeEnum = z.enum(['focus', 'short_break', 'long_break']);

export const createFocusTimerSessionSchema = z.object({
  type: focusTimerTypeEnum,
  startTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
  endTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional()
    .nullable(),
  durationMinutes: z
    .number({ required_error: 'Duration is required' })
    .int('Duration must be an integer')
    .min(1, 'Duration must be at least 1 minute')
    .max(480, 'Duration cannot exceed 480 minutes'),
  isCompleted: z.boolean().default(false),
  task: z
    .string()
    .max(500, 'Task must be 500 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
});

export const updateFocusTimerSessionSchema = z.object({
  type: focusTimerTypeEnum.optional(),
  startTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
  endTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional()
    .nullable(),
  durationMinutes: z
    .number()
    .int()
    .min(1)
    .max(480)
    .optional(),
  isCompleted: z.boolean().optional(),
  task: z
    .string()
    .max(500)
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
});

export const focusTimerSessionIdSchema = z.object({
  id: z.string().uuid('Invalid focus timer session ID format'),
});

export const updateFocusTimerGoalSchema = z.object({
  dailyGoalSessions: z
    .number()
    .int()
    .min(1, 'Must be at least 1 session')
    .max(50, 'Cannot exceed 50 sessions')
    .optional(),
  focusDuration: z
    .number()
    .int()
    .min(1)
    .max(480)
    .optional(),
  shortBreakDuration: z
    .number()
    .int()
    .min(1)
    .max(60)
    .optional(),
  longBreakDuration: z
    .number()
    .int()
    .min(1)
    .max(60)
    .optional(),
  sessionsBeforeLongBreak: z
    .number()
    .int()
    .min(1)
    .max(20)
    .optional(),
  autoStartBreaks: z.boolean().optional(),
  autoStartFocus: z.boolean().optional(),
  soundEnabled: z.boolean().optional(),
  vibrationEnabled: z.boolean().optional(),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
