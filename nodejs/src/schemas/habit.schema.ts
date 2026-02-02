import { z } from 'zod';

const categoryEnum = z.enum(['health', 'fitness', 'mindfulness', 'learning', 'productivity', 'social', 'other']);
const frequencyEnum = z.enum(['daily', 'weekdays', 'weekends', 'specificDays']);

export const createHabitSchema = z.object({
  name: z
    .string({ required_error: 'Name is required' })
    .min(1, 'Name cannot be empty')
    .max(255, 'Name must be 255 characters or less')
    .transform((val) => val.trim()),
  description: z
    .string()
    .max(1000, 'Description must be 1000 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
  icon: z
    .string()
    .max(50, 'Icon must be 50 characters or less')
    .default('check_circle'),
  category: categoryEnum.default('other'),
  frequency: frequencyEnum.default('daily'),
  targetDays: z
    .array(z.number().int().min(0).max(6))
    .default([0, 1, 2, 3, 4, 5, 6]),
});

export const updateHabitSchema = z.object({
  name: z
    .string()
    .min(1, 'Name cannot be empty')
    .max(255, 'Name must be 255 characters or less')
    .transform((val) => val.trim())
    .optional(),
  description: z
    .string()
    .max(1000, 'Description must be 1000 characters or less')
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
  icon: z
    .string()
    .max(50, 'Icon must be 50 characters or less')
    .optional(),
  category: categoryEnum.optional(),
  frequency: frequencyEnum.optional(),
  targetDays: z
    .array(z.number().int().min(0).max(6))
    .optional(),
});

export const habitIdSchema = z.object({
  id: z.string().uuid('Invalid habit ID format'),
});

export type CreateHabitInput = z.infer<typeof createHabitSchema>;
export type UpdateHabitInput = z.infer<typeof updateHabitSchema>;
