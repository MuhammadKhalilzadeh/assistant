import { z } from 'zod';

const appUsageItemSchema = z.object({
  appName: z.string().min(1, 'App name is required').max(255),
  category: z.string().max(50).default('other'),
  minutesUsed: z.number().int().min(0).max(1440),
  iconName: z.string().max(50).default('apps'),
});

export const createScreenTimeSchema = z.object({
  date: z
    .string({ required_error: 'Date is required' })
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format'),
  totalMinutes: z
    .number({ required_error: 'Total minutes is required' })
    .int('Total minutes must be an integer')
    .min(0, 'Total minutes must be at least 0')
    .max(1440, 'Total minutes cannot exceed 1440'),
  pickups: z
    .number()
    .int()
    .min(0)
    .default(0),
  note: z
    .string()
    .max(500, 'Note must be 500 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
  appUsage: z.array(appUsageItemSchema).optional(),
});

export const updateScreenTimeSchema = z.object({
  totalMinutes: z
    .number()
    .int()
    .min(0)
    .max(1440)
    .optional(),
  pickups: z
    .number()
    .int()
    .min(0)
    .optional(),
  note: z
    .string()
    .max(500)
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
  appUsage: z.array(appUsageItemSchema).optional(),
});

export const screenTimeIdSchema = z.object({
  id: z.string().uuid('Invalid screen time record ID format'),
});

export const updateScreenTimeGoalSchema = z.object({
  dailyLimitMinutes: z
    .number({ required_error: 'Daily limit is required' })
    .int('Daily limit must be an integer')
    .min(30, 'Daily limit must be at least 30 minutes')
    .max(1440, 'Daily limit cannot exceed 24 hours'),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
