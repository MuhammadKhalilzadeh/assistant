import { z } from 'zod';

export const weatherQuerySchema = z.object({
  lat: z
    .string()
    .transform((val) => parseFloat(val))
    .pipe(z.number().min(-90, 'Latitude must be >= -90').max(90, 'Latitude must be <= 90')),
  lon: z
    .string()
    .transform((val) => parseFloat(val))
    .pipe(z.number().min(-180, 'Longitude must be >= -180').max(180, 'Longitude must be <= 180')),
});

export const weatherHourlyQuerySchema = z.object({
  lat: z
    .string()
    .transform((val) => parseFloat(val))
    .pipe(z.number().min(-90).max(90)),
  lon: z
    .string()
    .transform((val) => parseFloat(val))
    .pipe(z.number().min(-180).max(180)),
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format'),
});

export const weatherSearchSchema = z.object({
  q: z
    .string()
    .min(1, 'Search query is required')
    .max(200, 'Search query must be 200 characters or less'),
});

export const updateWeatherSettingsSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  cityName: z.string().min(1).max(200),
  temperatureUnit: z.enum(['celsius', 'fahrenheit']).optional(),
});
