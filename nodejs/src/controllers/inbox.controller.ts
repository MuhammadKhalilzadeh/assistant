import { Request, Response, NextFunction } from 'express';
import { inboxModel } from '../models/inbox.model';
import { NotFoundError, DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const inboxController = {
  async getMessages(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { service, isRead } = req.query;
      const filters: { service?: string; isRead?: boolean } = {};

      if (service) filters.service = service as string;
      if (isRead !== undefined) filters.isRead = isRead === 'true';

      const messages = await inboxModel.getMessages(filters);
      logger.debug({ count: messages.length }, 'Fetched inbox messages');
      res.json(messages);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch inbox messages');
      next(new DatabaseError('Failed to fetch inbox messages'));
    }
  },

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const message = await inboxModel.findById(id);

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
      const { service, sender, subject, preview, isRead, isStarred, receivedAt } = req.body;

      const message = await inboxModel.create({
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
      const { id } = req.params;
      const { service, sender, subject, preview, isRead, isStarred } = req.body;

      const updateData: Record<string, unknown> = {};
      if (service !== undefined) updateData.service = service;
      if (sender !== undefined) updateData.sender = sender;
      if (subject !== undefined) updateData.subject = subject;
      if (preview !== undefined) updateData.preview = preview;
      if (isRead !== undefined) updateData.isRead = isRead;
      if (isStarred !== undefined) updateData.isStarred = isStarred;

      const message = await inboxModel.update(id, updateData);

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
      const { id } = req.params;
      const deleted = await inboxModel.delete(id);

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
      const { id } = req.params;
      const message = await inboxModel.markAsRead(id);

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
      const { id } = req.params;
      const message = await inboxModel.toggleStar(id);

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
      const stats = await inboxModel.getStats();
      logger.debug('Fetched inbox stats');
      res.json(stats);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch inbox stats');
      next(new DatabaseError('Failed to fetch inbox stats'));
    }
  },
};
