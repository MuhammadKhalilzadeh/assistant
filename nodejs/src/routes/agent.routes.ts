import { Router } from 'express';
import { agentController } from '../controllers/agent.controller';

const router = Router();

// Goal suggestions
router.get('/goals', agentController.getGoalSuggestions);
router.post('/goals/review', agentController.reviewGoals);
router.post('/goals/:id/respond', agentController.respondToGoal);

// Weekly plan
router.get('/plan', agentController.getCurrentPlan);
router.post('/plan/generate', agentController.generatePlan);
router.get('/plan/history', agentController.getPlanHistory);

// Auto actions
router.get('/actions', agentController.getPendingActions);
router.post('/actions/:id/respond', agentController.respondToAction);
router.post('/actions/:id/undo', agentController.undoAction);

// Agent settings
router.get('/settings', agentController.getSettings);
router.put('/settings', agentController.updateSettings);

export default router;
