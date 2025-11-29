import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService({
    required this.apiKey,
    this.baseUrl = 'https://api.openweathermap.org/data/2.5',
  });

  /// Tu API key de OpenWeatherMap.
  final String apiKey;

  /// URL base de la API.
  final String baseUrl;

  /// Obtiene el clima actual por nombre de ciudad.
  ///
  /// Los datos devueltos incluyen temperatura en °C, descripción
  /// y nombre de ciudad.
  Future<WeatherData> getCurrentWeatherByCity(String city) async {
    final uri = Uri.parse(
      '$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=es',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        throw Exception(
          'Error 401: API key inválida o no autorizada. '
          'Revisa tu clave de OpenWeatherMap en el archivo .env.',
        );
      }

      throw Exception(
        'Error al obtener el clima (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> jsonBody = json.decode(response.body);
    return WeatherData.fromJson(jsonBody);
  }
}

class WeatherData {
  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List<dynamic>?;
    final main = json['main'] as Map<String, dynamic>?;

    if (weatherList == null || weatherList.isEmpty || main == null) {
      throw Exception('Respuesta de clima inválida');
    }

    final weather = weatherList.first as Map<String, dynamic>;

    return WeatherData(
      cityName: json['name']?.toString() ?? 'Desconocido',
      temperature: (main['temp'] as num).toDouble(),
      description: weather['description']?.toString() ?? '',
      iconCode: weather['icon']?.toString() ?? '01d',
    );
  }
}
