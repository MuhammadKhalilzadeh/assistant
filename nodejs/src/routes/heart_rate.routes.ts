import { Router } from 'express';
import { heartRateController } from '../controllers/heart_rate.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createHeartRateSchema,
  updateHeartRateSchema,
  heartRateIdSchema,
  updateHeartRateGoalSchema,
  dateQuerySchema,
} from '../schemas/heart_rate.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), heartRateController.getRecordsForDate);
router.get('/stats', heartRateController.getStats);
router.get('/history', heartRateController.getHistory);
router.get('/goal', heartRateController.getGoal);
router.put('/goal', validateBody(updateHeartRateGoalSchema), heartRateController.updateGoal);
router.get('/:id', validateParams(heartRateIdSchema), heartRateController.getById);
router.post('/', validateBody(createHeartRateSchema), heartRateController.create);
router.put('/:id', validateParams(heartRateIdSchema), validateBody(updateHeartRateSchema), heartRateController.update);
router.delete('/:id', validateParams(heartRateIdSchema), heartRateController.delete);

export default router;
