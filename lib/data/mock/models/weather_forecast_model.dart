enum WeatherConditionType { sunny, cloudy, rainy, stormy, snowy, partlyCloudy }

class HourlyForecast {
  final DateTime time;
  final int temperature;
  final WeatherConditionType condition;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });
}

class DailyForecast {
  final DateTime date;
  final int high;
  final int low;
  final WeatherConditionType condition;

  DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.condition,
  });
}

class WeatherForecastModel {
  final String location;
  final int currentTemperature;
  final WeatherConditionType currentCondition;
  final int high;
  final int low;
  final int humidity;
  final int windSpeed;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherForecastModel({
    required this.location,
    required this.currentTemperature,
    required this.currentCondition,
    required this.high,
    required this.low,
    this.humidity = 50,
    this.windSpeed = 10,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
  });
}
