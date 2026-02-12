import { z } from 'zod';

const mealTypeEnum = z.enum(['breakfast', 'lunch', 'dinner', 'snack']);
const foodCategoryEnum = z.enum(['grains', 'protein', 'dairy', 'fruits', 'vegetables', 'fats', 'sweets', 'beverages', 'other']);

export const createCalorieEntrySchema = z.object({
  foodName: z
    .string({ required_error: 'Food name is required' })
    .min(1, 'Food name cannot be empty')
    .max(255, 'Food name must be 255 characters or less'),
  calories: z
    .number({ required_error: 'Calories is required' })
    .int('Calories must be an integer')
    .min(0, 'Calories cannot be negative')
    .max(10000, 'Calories cannot exceed 10000'),
  mealType: mealTypeEnum,
  protein: z.number().int().min(0).max(1000).optional().nullable(),
  carbs: z.number().int().min(0).max(1000).optional().nullable(),
  fat: z.number().int().min(0).max(1000).optional().nullable(),
  foodCategory: foodCategoryEnum.optional().nullable(),
  servingSize: z.number().int().min(1).max(10000).optional().nullable(),
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

export const updateCalorieEntrySchema = z.object({
  foodName: z.string().min(1).max(255).optional(),
  calories: z.number().int().min(0).max(10000).optional(),
  mealType: mealTypeEnum.optional(),
  protein: z.number().int().min(0).max(1000).optional().nullable(),
  carbs: z.number().int().min(0).max(1000).optional().nullable(),
  fat: z.number().int().min(0).max(1000).optional().nullable(),
  foodCategory: foodCategoryEnum.optional().nullable(),
  servingSize: z.number().int().min(1).max(10000).optional().nullable(),
  note: z
    .string()
    .max(500)
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
  loggedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const calorieEntryIdSchema = z.object({
  id: z.string().uuid('Invalid calorie entry ID format'),
});

export const updateNutritionGoalSchema = z.object({
  dailyCalorieGoal: z
    .number({ required_error: 'Daily calorie goal is required' })
    .int()
    .min(500, 'Must be at least 500 calories')
    .max(10000, 'Cannot exceed 10000 calories'),
  proteinGoalGrams: z.number().int().min(0).max(500).optional(),
  carbsGoalGrams: z.number().int().min(0).max(1000).optional(),
  fatGoalGrams: z.number().int().min(0).max(500).optional(),
  remindersEnabled: z.boolean().optional(),
});

export const dateQuerySchema = z.object({
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .optional(),
});
