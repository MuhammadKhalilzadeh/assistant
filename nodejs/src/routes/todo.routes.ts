import { Router } from 'express';
import { todoController } from '../controllers/todo.controller';
import { validateBody, validateParams } from '../middleware/validate.middleware';
import { createTodoSchema, updateTodoSchema, todoIdSchema } from '../schemas/todo.schema';

const router = Router();

router.get('/', todoController.getAll);
router.get('/stats', todoController.getStats);
router.get('/:id', validateParams(todoIdSchema), todoController.getById);
router.post('/', validateBody(createTodoSchema), todoController.create);
router.put('/:id', validateParams(todoIdSchema), validateBody(updateTodoSchema), todoController.update);
router.patch('/:id/toggle', validateParams(todoIdSchema), todoController.toggleComplete);
router.delete('/:id', validateParams(todoIdSchema), todoController.delete);

export default router;
