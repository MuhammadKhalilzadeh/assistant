import { Router } from 'express';
import { weatherController } from '../controllers/weather.controller';
import { validateBody, validateQuery } from '../middleware/validate.middleware';
import {
  weatherQuerySchema,
  weatherHourlyQuerySchema,
  weatherSearchSchema,
  updateWeatherSettingsSchema,
} from '../schemas/weather.schema';

const router = Router();

router.get('/', validateQuery(weatherQuerySchema), weatherController.getWeather);
router.get('/hourly', validateQuery(weatherHourlyQuerySchema), weatherController.getHourlyForDate);
router.get('/search', validateQuery(weatherSearchSchema), weatherController.searchLocation);
router.get('/settings', weatherController.getSettings);
router.put('/settings', validateBody(updateWeatherSettingsSchema), weatherController.updateSettings);

export default router;
