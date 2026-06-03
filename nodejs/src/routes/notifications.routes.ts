import { Router } from 'express';
import { notificationsController } from '../controllers/notifications.controller';

const router = Router();

// On-demand morning briefing
router.post('/morning-briefing', notificationsController.generateMorningBriefing);

// On-demand weekly report
router.post('/weekly-report', notificationsController.generateWeeklyReport);

export default router;
