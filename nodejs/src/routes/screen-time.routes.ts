import { Router } from 'express';
import { screenTimeController } from '../controllers/screen-time.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createScreenTimeSchema,
  updateScreenTimeSchema,
  screenTimeIdSchema,
  updateScreenTimeGoalSchema,
  dateQuerySchema,
} from '../schemas/screen-time.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), screenTimeController.getByDate);
router.get('/stats', screenTimeController.getStats);
router.get('/history', screenTimeController.getHistory);
router.get('/goal', screenTimeController.getGoal);
router.put('/goal', validateBody(updateScreenTimeGoalSchema), screenTimeController.updateGoal);
router.get('/:id', validateParams(screenTimeIdSchema), screenTimeController.getById);
router.post('/', validateBody(createScreenTimeSchema), screenTimeController.create);
router.put('/:id', validateParams(screenTimeIdSchema), validateBody(updateScreenTimeSchema), screenTimeController.update);
router.delete('/:id', validateParams(screenTimeIdSchema), screenTimeController.delete);

export default router;
