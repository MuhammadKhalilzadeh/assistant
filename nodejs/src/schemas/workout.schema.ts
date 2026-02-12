import { z } from 'zod';

const workoutTypeEnum = z.enum(['running', 'cycling', 'strength', 'yoga', 'swimming', 'walking', 'hiit', 'other']);

const exerciseSchema = z.object({
  name: z.string().min(1).max(100),
  sets: z.number().int().min(0).default(0),
  reps: z.number().int().min(0).default(0),
  weight: z.number().min(0).optional().nullable(),
});

export const createWorkoutSessionSchema = z.object({
  type: workoutTypeEnum,
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
    .min(0, 'Duration cannot be negative')
    .max(1440, 'Duration cannot exceed 24 hours')
    .default(0),
  caloriesBurned: z
    .number()
    .int()
    .min(0)
    .max(20000)
    .default(0),
  exercises: z.array(exerciseSchema).default([]),
  notes: z
    .string()
    .max(1000, 'Notes must be 1000 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
});

export const updateWorkoutSessionSchema = z.object({
  type: workoutTypeEnum.optional(),
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
    .min(0)
    .max(1440)
    .optional(),
  caloriesBurned: z
    .number()
    .int()
    .min(0)
    .max(20000)
    .optional(),
  exercises: z.array(exerciseSchema).optional(),
  notes: z
    .string()
    .max(1000)
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
});

export const workoutSessionIdSchema = z.object({
  id: z.string().uuid('Invalid workout session ID format'),
});

export const updateWorkoutGoalSchema = z.object({
  weeklyMinutesGoal: z
    .number({ required_error: 'Weekly minutes goal is required' })
    .int()
    .min(10, 'Must be at least 10 minutes')
    .max(5000, 'Cannot exceed 5000 minutes'),
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
