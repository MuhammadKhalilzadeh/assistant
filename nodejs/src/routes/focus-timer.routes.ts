import { Router } from 'express';
import { focusTimerController } from '../controllers/focus-timer.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createFocusTimerSessionSchema,
  updateFocusTimerSessionSchema,
  focusTimerSessionIdSchema,
  updateFocusTimerGoalSchema,
  dateQuerySchema,
} from '../schemas/focus-timer.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), focusTimerController.getSessionsForDate);
router.get('/stats', focusTimerController.getStats);
router.get('/history', focusTimerController.getHistory);
router.get('/goal', focusTimerController.getGoal);
router.put('/goal', validateBody(updateFocusTimerGoalSchema), focusTimerController.updateGoal);
router.patch('/:id/complete', validateParams(focusTimerSessionIdSchema), focusTimerController.markComplete);
router.get('/:id', validateParams(focusTimerSessionIdSchema), focusTimerController.getById);
router.post('/', validateBody(createFocusTimerSessionSchema), focusTimerController.create);
router.put('/:id', validateParams(focusTimerSessionIdSchema), validateBody(updateFocusTimerSessionSchema), focusTimerController.update);
router.delete('/:id', validateParams(focusTimerSessionIdSchema), focusTimerController.delete);

export default router;
