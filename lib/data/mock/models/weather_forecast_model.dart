enum WeatherConditionType { sunny, cloudy, rainy, stormy, snowy, partlyCloudy }

enum AlertSeverity { low, moderate, high, extreme }

class WeatherAlert {
  final String id;
  final String type; // "storm", "heat", "cold", "flood", "wind"
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final AlertSeverity severity;

  WeatherAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.severity,
  });

  WeatherAlert copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    AlertSeverity? severity,
  }) {
    return WeatherAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      severity: severity ?? this.severity,
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final int temperature;
  final WeatherConditionType condition;
  final int precipChance; // 0-100%
  final int feelsLike;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    this.precipChance = 0,
    int? feelsLike,
  }) : feelsLike = feelsLike ?? temperature;

  HourlyForecast copyWith({
    DateTime? time,
    int? temperature,
    WeatherConditionType? condition,
    int? precipChance,
    int? feelsLike,
  }) {
    return HourlyForecast(
      time: time ?? this.time,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      precipChance: precipChance ?? this.precipChance,
      feelsLike: feelsLike ?? this.feelsLike,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int high;
  final int low;
  final WeatherConditionType condition;
  final int precipChance; // 0-100%
  final int uvIndex; // 0-11+
  final DateTime sunrise;
  final DateTime sunset;

  DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.condition,
    this.precipChance = 0,
    this.uvIndex = 5,
    DateTime? sunrise,
    DateTime? sunset,
  })  : sunrise = sunrise ?? DateTime(date.year, date.month, date.day, 6, 30),
        sunset = sunset ?? DateTime(date.year, date.month, date.day, 19, 45);

  DailyForecast copyWith({
    DateTime? date,
    int? high,
    int? low,
    WeatherConditionType? condition,
    int? precipChance,
    int? uvIndex,
    DateTime? sunrise,
    DateTime? sunset,
  }) {
    return DailyForecast(
      date: date ?? this.date,
      high: high ?? this.high,
      low: low ?? this.low,
      condition: condition ?? this.condition,
      precipChance: precipChance ?? this.precipChance,
      uvIndex: uvIndex ?? this.uvIndex,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
    );
  }
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
  final int feelsLike;
  final int uvIndex;
  final int pressure; // hPa
  final int visibility; // km
  final int precipChance;
  final String windDirection; // "N", "NE", etc.
  final DateTime sunrise;
  final DateTime sunset;
  final int dewPoint;
  final List<WeatherAlert> alerts;

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
    int? feelsLike,
    this.uvIndex = 5,
    this.pressure = 1013,
    this.visibility = 10,
    this.precipChance = 0,
    this.windDirection = 'N',
    DateTime? sunrise,
    DateTime? sunset,
    int? dewPoint,
    this.alerts = const [],
  })  : feelsLike = feelsLike ?? currentTemperature,
        sunrise = sunrise ?? DateTime.now().copyWith(hour: 6, minute: 30),
        sunset = sunset ?? DateTime.now().copyWith(hour: 19, minute: 45),
        dewPoint = dewPoint ?? (currentTemperature - 5);

  WeatherForecastModel copyWith({
    String? location,
    int? currentTemperature,
    WeatherConditionType? currentCondition,
    int? high,
    int? low,
    int? humidity,
    int? windSpeed,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
    int? feelsLike,
    int? uvIndex,
    int? pressure,
    int? visibility,
    int? precipChance,
    String? windDirection,
    DateTime? sunrise,
    DateTime? sunset,
    int? dewPoint,
    List<WeatherAlert>? alerts,
  }) {
    return WeatherForecastModel(
      location: location ?? this.location,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      currentCondition: currentCondition ?? this.currentCondition,
      high: high ?? this.high,
      low: low ?? this.low,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      feelsLike: feelsLike ?? this.feelsLike,
      uvIndex: uvIndex ?? this.uvIndex,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      precipChance: precipChance ?? this.precipChance,
      windDirection: windDirection ?? this.windDirection,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      dewPoint: dewPoint ?? this.dewPoint,
      alerts: alerts ?? this.alerts,
    );
  }
}
