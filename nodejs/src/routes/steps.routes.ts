import { Router } from 'express';
import { stepsController } from '../controllers/steps.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createStepRecordSchema,
  updateStepRecordSchema,
  addStepsSchema,
  stepRecordIdSchema,
  updateStepsGoalSchema,
  dateQuerySchema,
} from '../schemas/steps.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), stepsController.getRecordForDate);
router.get('/stats', stepsController.getStats);
router.get('/history', stepsController.getHistory);
router.get('/goal', stepsController.getGoal);
router.put('/goal', validateBody(updateStepsGoalSchema), stepsController.updateGoal);
router.post('/add', validateBody(addStepsSchema), stepsController.addSteps);
router.get('/:id', validateParams(stepRecordIdSchema), stepsController.getById);
router.post('/', validateBody(createStepRecordSchema), stepsController.create);
router.put('/:id', validateParams(stepRecordIdSchema), validateBody(updateStepRecordSchema), stepsController.update);
router.delete('/:id', validateParams(stepRecordIdSchema), stepsController.delete);

export default router;
