import pool from '../config/database';

// ---- Interfaces ----

export interface WeatherSettings {
  id: string;
  latitude: number;
  longitude: number;
  cityName: string;
  temperatureUnit: string;
  createdAt: Date;
  updatedAt: Date;
}

interface WeatherSettingsRow {
  id: string;
  latitude: string;
  longitude: string;
  city_name: string;
  temperature_unit: string;
  created_at: Date;
  updated_at: Date;
}

export interface CurrentWeather {
  temperature: number;
  feelsLike: number;
  humidity: number;
  windSpeed: number;
  windDirection: string;
  condition: string;
  pressure: number;
  visibility: number;
  uvIndex: number;
  precipChance: number;
  dewPoint: number;
}

export interface HourlyForecast {
  time: string;
  temperature: number;
  condition: string;
  precipChance: number;
  feelsLike: number;
}

export interface DailyForecast {
  date: string;
  high: number;
  low: number;
  condition: string;
  precipChance: number;
  uvIndex: number;
  sunrise: string;
  sunset: string;
}

export interface WeatherResponse {
  location: string;
  currentTemperature: number;
  currentCondition: string;
  high: number;
  low: number;
  humidity: number;
  windSpeed: number;
  windDirection: string;
  feelsLike: number;
  uvIndex: number;
  pressure: number;
  visibility: number;
  precipChance: number;
  dewPoint: number;
  sunrise: string;
  sunset: string;
  alerts: never[];
  hourlyForecast: HourlyForecast[];
  dailyForecast: DailyForecast[];
}

export interface SearchResult {
  name: string;
  latitude: number;
  longitude: number;
  country: string;
  admin1: string;
}

// ---- Helpers ----

function rowToSettings(row: WeatherSettingsRow): WeatherSettings {
  return {
    id: row.id,
    latitude: parseFloat(row.latitude),
    longitude: parseFloat(row.longitude),
    cityName: row.city_name,
    temperatureUnit: row.temperature_unit,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapWmoCode(code: number): string {
  if (code <= 1) return 'sunny';
  if (code === 2) return 'partlyCloudy';
  if (code === 3 || code === 45 || code === 48) return 'cloudy';
  if ((code >= 51 && code <= 57) || (code >= 61 && code <= 67) || (code >= 80 && code <= 82)) return 'rainy';
  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) return 'snowy';
  if (code >= 95 && code <= 99) return 'stormy';
  return 'cloudy';
}

function mapWindDirection(degrees: number): string {
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  const index = Math.round(degrees / 45) % 8;
  return directions[index];
}

// ---- Model ----

export const weatherModel = {
  async getSettings(userId: string): Promise<WeatherSettings> {
    const result = await pool.query<WeatherSettingsRow>(
      `SELECT id, latitude, longitude, city_name, temperature_unit, created_at, updated_at
       FROM weather_settings WHERE user_id = $1 ORDER BY created_at LIMIT 1`,
      [userId]
    );
    if (!result.rows[0]) {
      const insertResult = await pool.query<WeatherSettingsRow>(
        `INSERT INTO weather_settings (user_id, latitude, longitude, city_name, temperature_unit)
         VALUES ($1, 40.71280, -74.00600, 'New York', 'celsius')
         RETURNING id, latitude, longitude, city_name, temperature_unit, created_at, updated_at`,
        [userId]
      );
      return rowToSettings(insertResult.rows[0]);
    }
    return rowToSettings(result.rows[0]);
  },

  async updateSettings(userId: string, input: {
    latitude: number;
    longitude: number;
    cityName: string;
    temperatureUnit?: string;
  }): Promise<WeatherSettings> {
    const settings = await this.getSettings(userId);
    const unit = input.temperatureUnit ?? settings.temperatureUnit;

    await pool.query(
      `UPDATE weather_settings
       SET latitude = $1, longitude = $2, city_name = $3, temperature_unit = $4, updated_at = CURRENT_TIMESTAMP
       WHERE id = $5 AND user_id = $6`,
      [input.latitude, input.longitude, input.cityName, unit, settings.id, userId]
    );
    return this.getSettings(userId);
  },

  async fetchWeather(userId: string, lat: number, lon: number, unit: string = 'celsius'): Promise<WeatherResponse> {
    const tempUnit = unit === 'fahrenheit' ? 'fahrenheit' : 'celsius';
    const windUnit = 'kmh';

    const url = new URL('https://api.open-meteo.com/v1/forecast');
    url.searchParams.set('latitude', lat.toFixed(4));
    url.searchParams.set('longitude', lon.toFixed(4));
    url.searchParams.set('current', [
      'temperature_2m', 'relative_humidity_2m', 'apparent_temperature',
      'weather_code', 'wind_speed_10m', 'wind_direction_10m',
      'surface_pressure', 'precipitation', 'uv_index',
      'dew_point_2m'
    ].join(','));
    url.searchParams.set('hourly', [
      'temperature_2m', 'weather_code', 'precipitation_probability',
      'apparent_temperature'
    ].join(','));
    url.searchParams.set('daily', [
      'temperature_2m_max', 'temperature_2m_min', 'weather_code',
      'precipitation_probability_max', 'uv_index_max',
      'sunrise', 'sunset'
    ].join(','));
    url.searchParams.set('temperature_unit', tempUnit);
    url.searchParams.set('wind_speed_unit', windUnit);
    url.searchParams.set('timezone', 'auto');
    url.searchParams.set('forecast_days', '7');

    const response = await fetch(url.toString());
    if (!response.ok) {
      throw new Error(`Open-Meteo API error: ${response.status}`);
    }
    const data = await response.json() as Record<string, any>;

    const current = data.current;
    const hourly = data.hourly;
    const daily = data.daily;

    // Build today's hourly forecast (remaining hours)
    const now = new Date();
    const currentHour = now.getHours();
    const todayHourly: HourlyForecast[] = [];
    if (hourly && hourly.time) {
      for (let i = 0; i < hourly.time.length; i++) {
        const hourTime = new Date(hourly.time[i]);
        // Only include today's remaining hours
        if (hourTime.getDate() === now.getDate() &&
            hourTime.getMonth() === now.getMonth() &&
            hourTime.getFullYear() === now.getFullYear() &&
            hourTime.getHours() >= currentHour) {
          todayHourly.push({
            time: hourly.time[i],
            temperature: Math.round(hourly.temperature_2m[i]),
            condition: mapWmoCode(hourly.weather_code[i]),
            precipChance: hourly.precipitation_probability[i] ?? 0,
            feelsLike: Math.round(hourly.apparent_temperature[i]),
          });
        }
      }
    }

    // Build daily forecast
    const dailyForecasts: DailyForecast[] = [];
    if (daily && daily.time) {
      for (let i = 0; i < daily.time.length; i++) {
        dailyForecasts.push({
          date: daily.time[i],
          high: Math.round(daily.temperature_2m_max[i]),
          low: Math.round(daily.temperature_2m_min[i]),
          condition: mapWmoCode(daily.weather_code[i]),
          precipChance: daily.precipitation_probability_max[i] ?? 0,
          uvIndex: Math.round(daily.uv_index_max[i] ?? 0),
          sunrise: daily.sunrise[i],
          sunset: daily.sunset[i],
        });
      }
    }

    // Today's high/low from daily
    const todayHigh = dailyForecasts[0]?.high ?? Math.round(current.temperature_2m);
    const todayLow = dailyForecasts[0]?.low ?? Math.round(current.temperature_2m);
    const todaySunrise = dailyForecasts[0]?.sunrise ?? '';
    const todaySunset = dailyForecasts[0]?.sunset ?? '';

    // Get settings for location name
    let locationName: string;
    try {
      const settings = await this.getSettings(userId);
      // Check if the coordinates match saved settings (within 0.01 degrees)
      if (Math.abs(settings.latitude - lat) < 0.01 && Math.abs(settings.longitude - lon) < 0.01) {
        locationName = settings.cityName;
      } else {
        locationName = `${lat.toFixed(2)}, ${lon.toFixed(2)}`;
      }
    } catch {
      locationName = `${lat.toFixed(2)}, ${lon.toFixed(2)}`;
    }

    return {
      location: locationName,
      currentTemperature: Math.round(current.temperature_2m),
      currentCondition: mapWmoCode(current.weather_code),
      high: todayHigh,
      low: todayLow,
      humidity: Math.round(current.relative_humidity_2m),
      windSpeed: Math.round(current.wind_speed_10m),
      windDirection: mapWindDirection(current.wind_direction_10m),
      feelsLike: Math.round(current.apparent_temperature),
      uvIndex: Math.round(current.uv_index ?? 0),
      pressure: Math.round(current.surface_pressure),
      visibility: 10, // Open-Meteo free tier doesn't include visibility; default to 10km
      precipChance: dailyForecasts[0]?.precipChance ?? 0,
      dewPoint: Math.round(current.dew_point_2m ?? (current.temperature_2m - 5)),
      sunrise: todaySunrise,
      sunset: todaySunset,
      alerts: [], // Open-Meteo free tier does not include alerts
      hourlyForecast: todayHourly,
      dailyForecast: dailyForecasts,
    };
  },

  async fetchHourlyForDate(lat: number, lon: number, date: string, unit: string = 'celsius'): Promise<HourlyForecast[]> {
    const tempUnit = unit === 'fahrenheit' ? 'fahrenheit' : 'celsius';

    const url = new URL('https://api.open-meteo.com/v1/forecast');
    url.searchParams.set('latitude', lat.toFixed(4));
    url.searchParams.set('longitude', lon.toFixed(4));
    url.searchParams.set('hourly', [
      'temperature_2m', 'weather_code', 'precipitation_probability',
      'apparent_temperature'
    ].join(','));
    url.searchParams.set('temperature_unit', tempUnit);
    url.searchParams.set('timezone', 'auto');
    url.searchParams.set('start_date', date);
    url.searchParams.set('end_date', date);

    const response = await fetch(url.toString());
    if (!response.ok) {
      throw new Error(`Open-Meteo API error: ${response.status}`);
    }
    const data = await response.json() as Record<string, any>;

    const hourly = data.hourly;
    if (!hourly || !hourly.time) return [];

    const result: HourlyForecast[] = [];
    for (let i = 0; i < hourly.time.length; i++) {
      result.push({
        time: hourly.time[i],
        temperature: Math.round(hourly.temperature_2m[i]),
        condition: mapWmoCode(hourly.weather_code[i]),
        precipChance: hourly.precipitation_probability[i] ?? 0,
        feelsLike: Math.round(hourly.apparent_temperature[i]),
      });
    }
    return result;
  },

  async searchLocation(query: string): Promise<SearchResult[]> {
    const url = new URL('https://geocoding-api.open-meteo.com/v1/search');
    url.searchParams.set('name', query);
    url.searchParams.set('count', '10');
    url.searchParams.set('language', 'en');
    url.searchParams.set('format', 'json');

    const response = await fetch(url.toString());
    if (!response.ok) {
      throw new Error(`Open-Meteo Geocoding API error: ${response.status}`);
    }
    const data = await response.json() as Record<string, any>;

    if (!data.results || !Array.isArray(data.results)) return [];

    return data.results.map((r: Record<string, any>) => ({
      name: r.name ?? '',
      latitude: r.latitude ?? 0,
      longitude: r.longitude ?? 0,
      country: r.country ?? '',
      admin1: r.admin1 ?? '',
    }));
  },
};
