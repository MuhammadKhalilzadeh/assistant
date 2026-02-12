import { z } from 'zod';

export const createStepRecordSchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format'),
  steps: z
    .number({ required_error: 'Steps count is required' })
    .int('Steps must be an integer')
    .min(0, 'Steps cannot be negative')
    .max(200000, 'Steps cannot exceed 200000'),
  goal: z
    .number()
    .int()
    .min(1000, 'Goal must be at least 1000')
    .max(100000, 'Goal cannot exceed 100000')
    .optional(),
  distanceKm: z
    .number()
    .min(0)
    .max(200)
    .optional(),
  caloriesBurned: z
    .number()
    .int()
    .min(0)
    .max(20000)
    .optional(),
});

export const updateStepRecordSchema = z.object({
  steps: z
    .number()
    .int('Steps must be an integer')
    .min(0, 'Steps cannot be negative')
    .max(200000, 'Steps cannot exceed 200000')
    .optional(),
  goal: z
    .number()
    .int()
    .min(1000)
    .max(100000)
    .optional(),
  distanceKm: z
    .number()
    .min(0)
    .max(200)
    .optional(),
  caloriesBurned: z
    .number()
    .int()
    .min(0)
    .max(20000)
    .optional(),
});

export const addStepsSchema = z.object({
  steps: z
    .number({ required_error: 'Steps count is required' })
    .int('Steps must be an integer')
    .min(1, 'Steps must be at least 1')
    .max(200000, 'Steps cannot exceed 200000'),
});

export const stepRecordIdSchema = z.object({
  id: z.string().uuid('Invalid step record ID format'),
});

export const updateStepsGoalSchema = z.object({
  dailyGoal: z
    .number({ required_error: 'Daily goal is required' })
    .int('Daily goal must be an integer')
    .min(1000, 'Daily goal must be at least 1000')
    .max(100000, 'Daily goal cannot exceed 100000'),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
