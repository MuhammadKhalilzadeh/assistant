import { z } from 'zod';

export const createInboxMessageSchema = z.object({
  service: z.string().max(50).default('General'),
  sender: z
    .string({ required_error: 'Sender is required' })
    .min(1, 'Sender cannot be empty')
    .max(255),
  subject: z
    .string({ required_error: 'Subject is required' })
    .min(1, 'Subject cannot be empty')
    .max(500),
  preview: z.string().max(1000).default(''),
  isRead: z.boolean().default(false),
  isStarred: z.boolean().default(false),
  receivedAt: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid datetime format' })
    .optional(),
});

export const updateInboxMessageSchema = z.object({
  service: z.string().max(50).optional(),
  sender: z.string().min(1).max(255).optional(),
  subject: z.string().min(1).max(500).optional(),
  preview: z.string().max(1000).optional(),
  isRead: z.boolean().optional(),
  isStarred: z.boolean().optional(),
});

export const inboxMessageIdSchema = z.object({
  id: z.string().uuid('Invalid message ID format'),
});

export const inboxQuerySchema = z.object({
  service: z.string().max(50).optional(),
  isRead: z
    .string()
    .transform((val) => val === 'true')
    .optional(),
});
