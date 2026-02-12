enum WeatherConditionType { sunny, cloudy, rainy, stormy, snowy, partlyCloudy }

extension WeatherConditionTypeExt on WeatherConditionType {
  static WeatherConditionType fromApiValue(String value) {
    switch (value) {
      case 'sunny':
        return WeatherConditionType.sunny;
      case 'cloudy':
        return WeatherConditionType.cloudy;
      case 'rainy':
        return WeatherConditionType.rainy;
      case 'stormy':
        return WeatherConditionType.stormy;
      case 'snowy':
        return WeatherConditionType.snowy;
      case 'partlyCloudy':
        return WeatherConditionType.partlyCloudy;
      default:
        return WeatherConditionType.sunny;
    }
  }

  String toApiValue() => name;
}

enum AlertSeverity { low, moderate, high, extreme }

extension AlertSeverityExt on AlertSeverity {
  static AlertSeverity fromApiValue(String value) {
    switch (value) {
      case 'low':
        return AlertSeverity.low;
      case 'moderate':
        return AlertSeverity.moderate;
      case 'high':
        return AlertSeverity.high;
      case 'extreme':
        return AlertSeverity.extreme;
      default:
        return AlertSeverity.low;
    }
  }

  String toApiValue() => name;
}

class WeatherAlert {
  final String id;
  final String type;
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

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      severity: AlertSeverityExt.fromApiValue(json['severity'] as String? ?? 'low'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'severity': severity.toApiValue(),
      };

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
  final int precipChance;
  final int feelsLike;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    this.precipChance = 0,
    int? feelsLike,
  }) : feelsLike = feelsLike ?? temperature;

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final temp = (json['temperature'] as num).round();
    return HourlyForecast(
      time: DateTime.parse(json['time'] as String),
      temperature: temp,
      condition: WeatherConditionTypeExt.fromApiValue(json['condition'] as String? ?? 'sunny'),
      precipChance: (json['precipChance'] as num?)?.round() ?? 0,
      feelsLike: (json['feelsLike'] as num?)?.round() ?? temp,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temperature': temperature,
        'condition': condition.toApiValue(),
        'precipChance': precipChance,
        'feelsLike': feelsLike,
      };

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
  final int precipChance;
  final int uvIndex;
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

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String;
    final date = DateTime.parse(dateStr);
    return DailyForecast(
      date: date,
      high: (json['high'] as num).round(),
      low: (json['low'] as num).round(),
      condition: WeatherConditionTypeExt.fromApiValue(json['condition'] as String? ?? 'sunny'),
      precipChance: (json['precipChance'] as num?)?.round() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.round() ?? 5,
      sunrise: json['sunrise'] != null ? DateTime.parse(json['sunrise'] as String) : null,
      sunset: json['sunset'] != null ? DateTime.parse(json['sunset'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'high': high,
        'low': low,
        'condition': condition.toApiValue(),
        'precipChance': precipChance,
        'uvIndex': uvIndex,
        'sunrise': sunrise.toIso8601String(),
        'sunset': sunset.toIso8601String(),
      };

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
  final int pressure;
  final int visibility;
  final int precipChance;
  final String windDirection;
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

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      location: json['location'] as String? ?? '',
      currentTemperature: (json['currentTemperature'] as num).round(),
      currentCondition: WeatherConditionTypeExt.fromApiValue(
          json['currentCondition'] as String? ?? 'sunny'),
      high: (json['high'] as num).round(),
      low: (json['low'] as num).round(),
      humidity: (json['humidity'] as num?)?.round() ?? 50,
      windSpeed: (json['windSpeed'] as num?)?.round() ?? 10,
      hourlyForecast: (json['hourlyForecast'] as List<dynamic>?)
              ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyForecast: (json['dailyForecast'] as List<dynamic>?)
              ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      feelsLike: (json['feelsLike'] as num?)?.round(),
      uvIndex: (json['uvIndex'] as num?)?.round() ?? 5,
      pressure: (json['pressure'] as num?)?.round() ?? 1013,
      visibility: (json['visibility'] as num?)?.round() ?? 10,
      precipChance: (json['precipChance'] as num?)?.round() ?? 0,
      windDirection: json['windDirection'] as String? ?? 'N',
      sunrise: json['sunrise'] != null && (json['sunrise'] as String).isNotEmpty
          ? DateTime.parse(json['sunrise'] as String)
          : null,
      sunset: json['sunset'] != null && (json['sunset'] as String).isNotEmpty
          ? DateTime.parse(json['sunset'] as String)
          : null,
      dewPoint: (json['dewPoint'] as num?)?.round(),
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'currentTemperature': currentTemperature,
        'currentCondition': currentCondition.toApiValue(),
        'high': high,
        'low': low,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'hourlyForecast': hourlyForecast.map((e) => e.toJson()).toList(),
        'dailyForecast': dailyForecast.map((e) => e.toJson()).toList(),
        'feelsLike': feelsLike,
        'uvIndex': uvIndex,
        'pressure': pressure,
        'visibility': visibility,
        'precipChance': precipChance,
        'windDirection': windDirection,
        'sunrise': sunrise.toIso8601String(),
        'sunset': sunset.toIso8601String(),
        'dewPoint': dewPoint,
        'alerts': alerts.map((e) => e.toJson()).toList(),
      };

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

class WeatherSettings {
  final String? id;
  final double latitude;
  final double longitude;
  final String cityName;
  final String temperatureUnit;

  WeatherSettings({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.temperatureUnit = 'celsius',
  });

  factory WeatherSettings.fromJson(Map<String, dynamic> json) {
    return WeatherSettings(
      id: json['id'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String? ?? '',
      temperatureUnit: json['temperatureUnit'] as String? ?? 'celsius',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'cityName': cityName,
        'temperatureUnit': temperatureUnit,
      };
}

class WeatherSearchResult {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String admin1;

  WeatherSearchResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.admin1,
  });

  factory WeatherSearchResult.fromJson(Map<String, dynamic> json) {
    return WeatherSearchResult(
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String? ?? '',
    );
  }

  String get displayName {
    final parts = [name];
    if (admin1.isNotEmpty) parts.add(admin1);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}
