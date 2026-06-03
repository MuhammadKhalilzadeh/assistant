import { Router } from 'express';
import { insightsController } from '../controllers/insights.controller';

const router = Router();

// Get user's active insights
router.get('/', insightsController.getInsights);

// Generate fresh insights from current data (full intelligence pipeline)
router.post('/generate', insightsController.generateInsights);

// Get correlation analysis
router.get('/correlations', insightsController.getCorrelations);

// Get trend analysis
router.get('/trends', insightsController.getTrends);

// Get anomaly detection results
router.get('/anomalies', insightsController.getAnomalies);

// Get raw data context (debugging/display)
router.get('/context', insightsController.getDataContext);

// Dismiss an insight
router.post('/:id/dismiss', insightsController.dismissInsight);

export default router;
