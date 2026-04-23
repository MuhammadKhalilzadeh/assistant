import { z } from 'zod';

export const chatMessageSchema = z.object({
  role: z.enum(['user', 'assistant', 'system']),
  content: z.string().min(1, 'Content cannot be empty'),
});

export const jarvisChatSchema = z.object({
  message: z.string({ required_error: 'Message is required' }).min(1, 'Message cannot be empty'),
  history: z.array(chatMessageSchema).optional().default([]),
  provider: z.enum(['openai', 'anthropic', 'googleai'], {
    required_error: 'Provider is required',
    invalid_type_error: 'Provider must be one of: openai, anthropic, googleai',
  }),
  conversationId: z.string().uuid().optional(),
});

export type JarvisChatInput = z.infer<typeof jarvisChatSchema>;
