import { z } from 'zod';

const heartRateZoneEnum = z.enum(['resting', 'warmUp', 'fatBurn', 'cardio', 'peak']);

export const createHeartRateSchema = z.object({
  bpm: z
    .number({ required_error: 'BPM is required' })
    .int('BPM must be an integer')
    .min(30, 'BPM must be at least 30')
    .max(250, 'BPM cannot exceed 250'),
  zone: heartRateZoneEnum.optional(),
  recordedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const updateHeartRateSchema = z.object({
  bpm: z
    .number()
    .int('BPM must be an integer')
    .min(30, 'BPM must be at least 30')
    .max(250, 'BPM cannot exceed 250')
    .optional(),
  zone: heartRateZoneEnum.optional(),
  recordedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const heartRateIdSchema = z.object({
  id: z.string().uuid('Invalid heart rate record ID format'),
});

export const updateHeartRateGoalSchema = z.object({
  targetRestingBpm: z
    .number({ required_error: 'Target resting BPM is required' })
    .int()
    .min(40, 'Target must be at least 40')
    .max(100, 'Target cannot exceed 100'),
  maxBpm: z
    .number()
    .int()
    .min(100, 'Max BPM must be at least 100')
    .max(250, 'Max BPM cannot exceed 250')
    .optional(),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
