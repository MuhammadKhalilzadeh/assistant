import { Router } from 'express';
import { workoutController } from '../controllers/workout.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createWorkoutSessionSchema,
  updateWorkoutSessionSchema,
  workoutSessionIdSchema,
  updateWorkoutGoalSchema,
  dateQuerySchema,
} from '../schemas/workout.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), workoutController.getSessionsForDate);
router.get('/stats', workoutController.getStats);
router.get('/history', workoutController.getHistory);
router.get('/goal', workoutController.getGoal);
router.put('/goal', validateBody(updateWorkoutGoalSchema), workoutController.updateGoal);
router.get('/:id', validateParams(workoutSessionIdSchema), workoutController.getById);
router.post('/', validateBody(createWorkoutSessionSchema), workoutController.create);
router.put('/:id', validateParams(workoutSessionIdSchema), validateBody(updateWorkoutSessionSchema), workoutController.update);
router.delete('/:id', validateParams(workoutSessionIdSchema), workoutController.delete);

export default router;
