import { Router } from 'express';
import { moodController } from '../controllers/mood.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createMoodEntrySchema,
  updateMoodEntrySchema,
  moodEntryIdSchema,
  updateMoodGoalSchema,
  dateQuerySchema,
} from '../schemas/mood.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), moodController.getEntriesForDate);
router.get('/stats', moodController.getStats);
router.get('/history', moodController.getHistory);
router.get('/goal', moodController.getGoal);
router.put('/goal', validateBody(updateMoodGoalSchema), moodController.updateGoal);
router.get('/:id', validateParams(moodEntryIdSchema), moodController.getById);
router.post('/', validateBody(createMoodEntrySchema), moodController.create);
router.put('/:id', validateParams(moodEntryIdSchema), validateBody(updateMoodEntrySchema), moodController.update);
router.delete('/:id', validateParams(moodEntryIdSchema), moodController.delete);

export default router;
