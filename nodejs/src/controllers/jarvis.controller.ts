import { Request, Response, NextFunction } from 'express';
import { userModel } from '../models/user.model';
import { conversationModel } from '../models/conversation.model';
import { cryptoService } from '../services/crypto.service';
import { systemPromptService } from '../services/brain/system-prompt.service';
import { queryRouterService } from '../services/brain/query-router.service';
import { ValidationError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

interface ChatMessage {
  role: string;
  content: string;
}

async function callOpenAI(apiKey: string, messages: ChatMessage[]): Promise<string> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: 'gpt-4o',
      messages,
      max_tokens: 4096,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    logger.error({ status: response.status, error }, 'OpenAI API error');
    throw new Error(`OpenAI API error: ${response.status} - ${error}`);
  }

  const data = (await response.json()) as { choices: Array<{ message: { content: string } }> };
  return data.choices[0]?.message?.content || '';
}

async function callAnthropic(apiKey: string, messages: ChatMessage[]): Promise<string> {
  // Anthropic expects system message separate from messages
  const systemMessage = messages.find((m) => m.role === 'system');
  const nonSystemMessages = messages.filter((m) => m.role !== 'system');

  const body: Record<string, unknown> = {
    model: 'claude-sonnet-4-20250514',
    max_tokens: 4096,
    messages: nonSystemMessages.map((m) => ({
      role: m.role,
      content: m.content,
    })),
  };

  if (systemMessage) {
    body.system = systemMessage.content;
  }

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const error = await response.text();
    logger.error({ status: response.status, error }, 'Anthropic API error');
    throw new Error(`Anthropic API error: ${response.status} - ${error}`);
  }

  const data = (await response.json()) as { content: Array<{ text: string }> };
  return data.content?.[0]?.text || '';
}

async function callGoogleAI(apiKey: string, messages: ChatMessage[]): Promise<string> {
  // Google Gemini API
  const contents = messages
    .filter((m) => m.role !== 'system')
    .map((m) => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

  const systemInstruction = messages.find((m) => m.role === 'system');

  const body: Record<string, unknown> = { contents };
  if (systemInstruction) {
    body.systemInstruction = { parts: [{ text: systemInstruction.content }] };
  }

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    }
  );

  if (!response.ok) {
    const error = await response.text();
    logger.error({ status: response.status, error }, 'Google AI API error');
    throw new Error(`Google AI API error: ${response.status} - ${error}`);
  }

  const data = (await response.json()) as { candidates: Array<{ content: { parts: Array<{ text: string }> } }> };
  return data.candidates?.[0]?.content?.parts?.[0]?.text || '';
}

export const jarvisController = {
  async chat(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { message, history, provider, conversationId } = req.body;

      // Look up the user's API key for the specified provider
      const encryptedKey = await userModel.getApiKey(userId, provider);
      if (!encryptedKey) {
        return next(new ValidationError(`No API key configured for provider: ${provider}. Please add your ${provider} API key in Settings.`));
      }

      // Decrypt the API key
      let apiKey: string;
      try {
        apiKey = cryptoService.decrypt(encryptedKey);
      } catch {
        return next(new ValidationError(`Failed to decrypt API key for provider: ${provider}. Please re-enter your API key in Settings.`));
      }

      // Route the query and build data-aware system prompt
      const route = queryRouterService.route(message);
      const systemPrompt = await systemPromptService.buildFromRoute(userId, route);
      logger.debug({ complexity: route.complexity, domains: route.domains, contextLevel: route.contextLevel }, 'Query routed');

      // Build messages array with data-enriched system prompt
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        ...history,
        { role: 'user', content: message },
      ];

      // Call the appropriate provider
      let responseText: string;
      switch (provider) {
        case 'openai':
          responseText = await callOpenAI(apiKey, messages);
          break;
        case 'anthropic':
          responseText = await callAnthropic(apiKey, messages);
          break;
        case 'googleai':
          responseText = await callGoogleAI(apiKey, messages);
          break;
        default:
          return next(new ValidationError(`Unsupported provider: ${provider}`));
      }

      // Optionally persist to conversation history
      let convId = conversationId;
      if (convId) {
        await conversationModel.addMessage(convId, 'user', message);
        await conversationModel.addMessage(convId, 'assistant', responseText);
      }

      res.json({
        response: responseText,
        provider,
        conversationId: convId || null,
      });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Chat request failed';
      logger.error({ err: error }, 'Jarvis chat failed');
      next(new DatabaseError(errorMessage));
    }
  },

  async createConversation(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { title } = req.body;

      const conversation = await conversationModel.create(userId, title);

      res.status(201).json({
        id: conversation.id,
        title: conversation.title,
        createdAt: conversation.createdAt,
      });
    } catch (error) {
      logger.error({ err: error }, 'Failed to create conversation');
      next(new DatabaseError('Failed to create conversation'));
    }
  },

  async getConversations(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const limit = parseInt(req.query.limit as string) || 20;
      const offset = parseInt(req.query.offset as string) || 0;

      const conversations = await conversationModel.findByUserId(userId, limit, offset);

      res.json(conversations);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get conversations');
      next(new DatabaseError('Failed to get conversations'));
    }
  },

  async getConversation(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;

      const conversation = await conversationModel.findById(id, userId);
      if (!conversation) {
        return next(new ValidationError('Conversation not found'));
      }

      res.json(conversation);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get conversation');
      next(new DatabaseError('Failed to get conversation'));
    }
  },

  async deleteConversation(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;

      const deleted = await conversationModel.delete(id, userId);
      if (!deleted) {
        return next(new ValidationError('Conversation not found'));
      }

      res.json({ message: 'Conversation deleted successfully' });
    } catch (error) {
      logger.error({ err: error }, 'Failed to delete conversation');
      next(new DatabaseError('Failed to delete conversation'));
    }
  },
};
