import { Request, Response, NextFunction } from 'express';
import { inboxModel } from '../models/inbox.model';
import { gmailService } from '../services/gmail.service';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const inboxController = {
  async getMessages(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { service, isRead } = req.query;
      const filters: { service?: string; isRead?: boolean } = {};

      if (service) filters.service = service as string;
      if (isRead !== undefined) filters.isRead = isRead === 'true';

      const messages = await inboxModel.getMessages(userId, filters);
      logger.debug({ count: messages.length }, 'Fetched inbox messages');
      res.json(messages);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch inbox messages');
      next(new DatabaseError('Failed to fetch inbox messages'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const message = await inboxModel.findById(userId, id);

      if (!message) {
        return next(new NotFoundError('Inbox message'));
      }

      logger.debug({ messageId: id }, 'Fetched inbox message by ID');
      res.json(message);
    } catch (error) {
      logger.error({ err: error, messageId: req.params.id }, 'Failed to fetch inbox message');
      next(new DatabaseError('Failed to fetch inbox message'));
    }
  },

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { service, sender, subject, preview, isRead, isStarred, receivedAt } = req.body;

      const message = await inboxModel.create(userId, {
        service,
        sender,
        subject,
        preview,
        isRead,
        isStarred,
        receivedAt,
      });

      logger.info({ messageId: message.id }, 'Created inbox message');
      res.status(201).json(message);
    } catch (error) {
      logger.error({ err: error }, 'Failed to create inbox message');
      next(new DatabaseError('Failed to create inbox message'));
    }
  },

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { service, sender, subject, preview, isRead, isStarred } = req.body;

      const updateData: Record<string, unknown> = {};
      if (service !== undefined) updateData.service = service;
      if (sender !== undefined) updateData.sender = sender;
      if (subject !== undefined) updateData.subject = subject;
      if (preview !== undefined) updateData.preview = preview;
      if (isRead !== undefined) updateData.isRead = isRead;
      if (isStarred !== undefined) updateData.isStarred = isStarred;

      const message = await inboxModel.update(userId, id, updateData);

      if (!message) {
        return next(new NotFoundError('Inbox message'));
      }

      logger.info({ messageId: id }, 'Updated inbox message');
      res.json(message);
    } catch (error) {
      logger.error({ err: error, messageId: req.params.id }, 'Failed to update inbox message');
      next(new DatabaseError('Failed to update inbox message'));
    }
  },

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const deleted = await inboxModel.delete(userId, id);

      if (!deleted) {
        return next(new NotFoundError('Inbox message'));
      }

      logger.info({ messageId: id }, 'Deleted inbox message');
      res.status(204).send();
    } catch (error) {
      logger.error({ err: error, messageId: req.params.id }, 'Failed to delete inbox message');
      next(new DatabaseError('Failed to delete inbox message'));
    }
  },

  async markAsRead(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const message = await inboxModel.markAsRead(userId, id);

      if (!message) {
        return next(new NotFoundError('Inbox message'));
      }

      logger.info({ messageId: id }, 'Marked inbox message as read');
      res.json(message);
    } catch (error) {
      logger.error({ err: error, messageId: req.params.id }, 'Failed to mark message as read');
      next(new DatabaseError('Failed to mark message as read'));
    }
  },

  async toggleStar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const message = await inboxModel.toggleStar(userId, id);

      if (!message) {
        return next(new NotFoundError('Inbox message'));
      }

      logger.info({ messageId: id }, 'Toggled inbox message star');
      res.json(message);
    } catch (error) {
      logger.error({ err: error, messageId: req.params.id }, 'Failed to toggle message star');
      next(new DatabaseError('Failed to toggle message star'));
    }
  },

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const stats = await inboxModel.getStats(userId);
      logger.debug('Fetched inbox stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch inbox stats');
      next(new DatabaseError('Failed to fetch inbox stats'));
    }
  },

  async sync(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;

      // Fetch messages from Gmail
      const gmailMessages = await gmailService.fetchMessages(userId);

      // Upsert into inbox_messages
      let synced = 0;
      for (const msg of gmailMessages) {
        await inboxModel.upsertGmailMessage(userId, {
          gmailMessageId: msg.gmailMessageId,
          sender: msg.sender,
          subject: msg.subject,
          preview: msg.preview,
          receivedAt: msg.receivedAt.toISOString(),
          isRead: msg.isRead,
        });
        synced++;
      }

      logger.info({ userId, synced }, 'Gmail inbox synced');
      res.json({ synced, total: gmailMessages.length });
    } catch (error) {
      logger.error({ err: error }, 'Failed to sync Gmail inbox');
      next(new DatabaseError('Failed to sync Gmail inbox'));
    }
  },

  async getBody(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;

      // First check if we have cached body
      const message = await inboxModel.findById(userId, id);
      if (!message) {
        return next(new NotFoundError('Inbox message'));
      }

      if (message.body) {
        res.json({ body: message.body });
        return;
      }

      // Lazy-load from Gmail if we have a gmailMessageId
      if (!message.gmailMessageId) {
        res.json({ body: '' });
        return;
      }

      const body = await gmailService.fetchMessageBody(userId, message.gmailMessageId);

      // Cache the body
      await inboxModel.updateBody(userId, id, body);

      res.json({ body });
    } catch (error) {
      logger.error({ err: error, messageId: req.params.id }, 'Failed to fetch message body');
      next(new DatabaseError('Failed to fetch message body'));
    }
  },
};
