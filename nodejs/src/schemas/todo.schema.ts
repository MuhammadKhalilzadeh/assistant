import { z } from 'zod';

export const createTodoSchema = z.object({
  title: z
    .string({ required_error: 'Title is required' })
    .min(1, 'Title cannot be empty')
    .max(255, 'Title must be 255 characters or less')
    .transform((val) => val.trim()),
  description: z
    .string()
    .max(1000, 'Description must be 1000 characters or less')
    .transform((val) => val?.trim() || undefined)
    .optional()
    .nullable(),
  priority: z
    .number()
    .int('Priority must be an integer')
    .min(1, 'Priority must be between 1 and 3')
    .max(3, 'Priority must be between 1 and 3')
    .default(2),
  dueDate: z
    .string()
    .datetime({ message: 'Invalid date format' })
    .optional()
    .nullable()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)').optional().nullable()),
  categoryId: z
    .string()
    .uuid('Invalid category ID format')
    .optional()
    .nullable(),
});

export const updateTodoSchema = z.object({
  title: z
    .string()
    .min(1, 'Title cannot be empty')
    .max(255, 'Title must be 255 characters or less')
    .transform((val) => val.trim())
    .optional(),
  description: z
    .string()
    .max(1000, 'Description must be 1000 characters or less')
    .transform((val) => val?.trim() || null)
    .optional()
    .nullable(),
  isCompleted: z.boolean().optional(),
  priority: z
    .number()
    .int('Priority must be an integer')
    .min(1, 'Priority must be between 1 and 3')
    .max(3, 'Priority must be between 1 and 3')
    .optional(),
  dueDate: z
    .string()
    .datetime({ message: 'Invalid date format' })
    .optional()
    .nullable()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)').optional().nullable()),
  categoryId: z
    .string()
    .uuid('Invalid category ID format')
    .optional()
    .nullable(),
});

export const todoIdSchema = z.object({
  id: z.string().uuid('Invalid todo ID format'),
});

export type CreateTodoInput = z.infer<typeof createTodoSchema>;
export type UpdateTodoInput = z.infer<typeof updateTodoSchema>;
