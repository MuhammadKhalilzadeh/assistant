import { Router } from 'express';
import { jarvisController } from '../controllers/jarvis.controller';
import { validateBody } from '../middleware/validate.middleware';
import { jarvisChatSchema } from '../schemas/jarvis.schema';

const router = Router();

// All routes are protected (JWT required — handled by auth middleware)
router.post('/chat', validateBody(jarvisChatSchema), jarvisController.chat);
router.post('/conversations', jarvisController.createConversation);
router.get('/conversations', jarvisController.getConversations);
router.get('/conversations/:id', jarvisController.getConversation);
router.delete('/conversations/:id', jarvisController.deleteConversation);

export default router;
