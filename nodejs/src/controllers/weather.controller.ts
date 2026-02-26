import { Request, Response, NextFunction } from 'express';
import { weatherModel } from '../models/weather.model';
import { DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const weatherController = {
  async getWeather(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { lat, lon } = req.query as unknown as { lat: number; lon: number };
      const settings = await weatherModel.getSettings(userId);
      const weather = await weatherModel.fetchWeather(userId, lat, lon, settings.temperatureUnit);
      logger.debug({ lat, lon }, 'Fetched weather data');
      res.json(weather);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch weather data');
      next(new DatabaseError('Failed to fetch weather data'));
    }
  },

  async getHourlyForDate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { lat, lon, date } = req.query as unknown as { lat: number; lon: number; date: string };
      const settings = await weatherModel.getSettings(userId);
      const hourly = await weatherModel.fetchHourlyForDate(lat, lon, date, settings.temperatureUnit);
      logger.debug({ lat, lon, date }, 'Fetched hourly forecast for date');
      res.json(hourly);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch hourly forecast');
      next(new DatabaseError('Failed to fetch hourly forecast'));
    }
  },

  async searchLocation(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { q } = req.query as unknown as { q: string };
      const results = await weatherModel.searchLocation(q);
      logger.debug({ query: q, count: results.length }, 'Searched weather locations');
      res.json(results);
    } catch (error) {
      logger.error({ err: error }, 'Failed to search locations');
      next(new DatabaseError('Failed to search locations'));
    }
  },

  async getSettings(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const settings = await weatherModel.getSettings(userId);
      logger.debug('Fetched weather settings');
      res.json(settings);
    } catch (error) {
      logger.error({ err: error }, 'Failed to fetch weather settings');
      next(new DatabaseError('Failed to fetch weather settings'));
    }
  },

  async updateSettings(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { latitude, longitude, cityName, temperatureUnit } = req.body;
      const settings = await weatherModel.updateSettings(userId, { latitude, longitude, cityName, temperatureUnit });
      logger.info({ cityName: settings.cityName }, 'Updated weather settings');
      res.json(settings);
    } catch (error) {
      logger.error({ err: error }, 'Failed to update weather settings');
      next(new DatabaseError('Failed to update weather settings'));
    }
  },
};
