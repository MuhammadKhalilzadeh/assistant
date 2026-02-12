import { Router } from 'express';
import { sleepController } from '../controllers/sleep.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createSleepRecordSchema,
  updateSleepRecordSchema,
  sleepRecordIdSchema,
  updateSleepGoalSchema,
  dateQuerySchema,
} from '../schemas/sleep.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), sleepController.getRecordsForDate);
router.get('/stats', sleepController.getStats);
router.get('/history', sleepController.getHistory);
router.get('/goal', sleepController.getGoal);
router.put('/goal', validateBody(updateSleepGoalSchema), sleepController.updateGoal);
router.get('/:id', validateParams(sleepRecordIdSchema), sleepController.getById);
router.post('/', validateBody(createSleepRecordSchema), sleepController.create);
router.put('/:id', validateParams(sleepRecordIdSchema), validateBody(updateSleepRecordSchema), sleepController.update);
router.delete('/:id', validateParams(sleepRecordIdSchema), sleepController.delete);

export default router;
