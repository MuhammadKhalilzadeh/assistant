import { Router } from 'express';
import { habitController } from '../controllers/habit.controller';
import { validateBody, validateParams } from '../middleware/validate.middleware';
import { createHabitSchema, updateHabitSchema, habitIdSchema } from '../schemas/habit.schema';

const router = Router();

router.get('/', habitController.getAll);
router.get('/stats', habitController.getStats);
router.get('/:id', validateParams(habitIdSchema), habitController.getById);
router.post('/', validateBody(createHabitSchema), habitController.create);
router.put('/:id', validateParams(habitIdSchema), validateBody(updateHabitSchema), habitController.update);
router.patch('/:id/toggle', validateParams(habitIdSchema), habitController.toggleComplete);
router.delete('/:id', validateParams(habitIdSchema), habitController.delete);

export default router;
