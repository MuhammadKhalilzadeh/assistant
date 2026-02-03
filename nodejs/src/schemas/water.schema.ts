import { z } from 'zod';

const beverageTypeEnum = z.enum(['water', 'coffee', 'tea', 'juice', 'milk', 'other']);

export const createWaterLogSchema = z.object({
  amountMl: z
    .number({ required_error: 'Amount is required' })
    .int('Amount must be an integer')
    .min(1, 'Amount must be at least 1ml')
    .max(5000, 'Amount cannot exceed 5000ml'),
  beverageType: beverageTypeEnum.default('water'),
  note: z
    .string()
    .max(500, 'Note must be 500 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
  loggedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const updateWaterLogSchema = z.object({
  amountMl: z
    .number()
    .int('Amount must be an integer')
    .min(1, 'Amount must be at least 1ml')
    .max(5000, 'Amount cannot exceed 5000ml')
    .optional(),
  beverageType: beverageTypeEnum.optional(),
  note: z
    .string()
    .max(500, 'Note must be 500 characters or less')
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
  loggedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const waterLogIdSchema = z.object({
  id: z.string().uuid('Invalid water log ID format'),
});

export const updateGoalSchema = z.object({
  dailyGoalMl: z
    .number({ required_error: 'Daily goal is required' })
    .int('Daily goal must be an integer')
    .min(500, 'Daily goal must be at least 500ml')
    .max(10000, 'Daily goal cannot exceed 10000ml'),
  reminderIntervalMinutes: z
    .number()
    .int()
    .min(15, 'Reminder interval must be at least 15 minutes')
    .max(480, 'Reminder interval cannot exceed 8 hours')
    .optional(),
  remindersEnabled: z.boolean().optional(),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});

export type CreateWaterLogInput = z.infer<typeof createWaterLogSchema>;
export type UpdateWaterLogInput = z.infer<typeof updateWaterLogSchema>;
export type UpdateGoalInput = z.infer<typeof updateGoalSchema>;
