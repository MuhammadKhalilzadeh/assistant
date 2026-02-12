import { Router } from 'express';
import { meditationController } from '../controllers/meditation.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createMeditationSessionSchema,
  updateMeditationSessionSchema,
  meditationSessionIdSchema,
  updateMeditationGoalSchema,
  dateQuerySchema,
} from '../schemas/meditation.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), meditationController.getSessionsForDate);
router.get('/stats', meditationController.getStats);
router.get('/history', meditationController.getHistory);
router.get('/goal', meditationController.getGoal);
router.put('/goal', validateBody(updateMeditationGoalSchema), meditationController.updateGoal);
router.patch('/:id/complete', validateParams(meditationSessionIdSchema), meditationController.markComplete);
router.get('/:id', validateParams(meditationSessionIdSchema), meditationController.getById);
router.post('/', validateBody(createMeditationSessionSchema), meditationController.create);
router.put('/:id', validateParams(meditationSessionIdSchema), validateBody(updateMeditationSessionSchema), meditationController.update);
router.delete('/:id', validateParams(meditationSessionIdSchema), meditationController.delete);

export default router;
