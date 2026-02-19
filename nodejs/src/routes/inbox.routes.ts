import { Router } from 'express';
import { inboxController } from '../controllers/inbox.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createInboxMessageSchema,
  updateInboxMessageSchema,
  inboxMessageIdSchema,
  inboxQuerySchema,
} from '../schemas/inbox.schema';

const router = Router();

router.get('/', validateQuery(inboxQuerySchema), inboxController.getMessages);
router.get('/stats', inboxController.getStats);
router.get('/:id', validateParams(inboxMessageIdSchema), inboxController.getById);
router.post('/', validateBody(createInboxMessageSchema), inboxController.create);
router.put('/:id', validateParams(inboxMessageIdSchema), validateBody(updateInboxMessageSchema), inboxController.update);
router.delete('/:id', validateParams(inboxMessageIdSchema), inboxController.delete);
router.patch('/:id/read', validateParams(inboxMessageIdSchema), inboxController.markAsRead);
router.patch('/:id/star', validateParams(inboxMessageIdSchema), inboxController.toggleStar);

export default router;
