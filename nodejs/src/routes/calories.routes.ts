import { Router } from 'express';
import { caloriesController } from '../controllers/calories.controller';
import { validateBody, validateParams, validateQuery } from '../middleware/validate.middleware';
import {
  createCalorieEntrySchema,
  updateCalorieEntrySchema,
  calorieEntryIdSchema,
  updateNutritionGoalSchema,
  dateQuerySchema,
} from '../schemas/calories.schema';

const router = Router();

router.get('/', validateQuery(dateQuerySchema), caloriesController.getEntriesForDate);
router.get('/stats', caloriesController.getStats);
router.get('/history', caloriesController.getHistory);
router.get('/goal', caloriesController.getGoal);
router.put('/goal', validateBody(updateNutritionGoalSchema), caloriesController.updateGoal);
router.get('/:id', validateParams(calorieEntryIdSchema), caloriesController.getById);
router.post('/', validateBody(createCalorieEntrySchema), caloriesController.create);
router.put('/:id', validateParams(calorieEntryIdSchema), validateBody(updateCalorieEntrySchema), caloriesController.update);
router.delete('/:id', validateParams(calorieEntryIdSchema), caloriesController.delete);

export default router;
