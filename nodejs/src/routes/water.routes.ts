import { Router } from 'express';
import { waterController } from '../controllers/water.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createWaterLogSchema,
  updateWaterLogSchema,
  waterLogIdSchema,
  updateGoalSchema,
  dateQuerySchema,
} from '../schemas/water.schema';

const router = Router();

// Water logs
router.get('/', validateQuery(dateQuerySchema), waterController.getLogsForDate);
router.get('/stats', waterController.getStats);
router.get('/history', waterController.getHistory);
router.get('/goal', waterController.getGoal);
router.put('/goal', validateBody(updateGoalSchema), waterController.updateGoal);
router.get('/:id', validateParams(waterLogIdSchema), waterController.getById);
router.post('/', validateBody(createWaterLogSchema), waterController.create);
router.put('/:id', validateParams(waterLogIdSchema), validateBody(updateWaterLogSchema), waterController.update);
router.delete('/:id', validateParams(waterLogIdSchema), waterController.delete);

export default router;
