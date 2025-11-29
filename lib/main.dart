import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/weather_screen.dart';
import 'services/weather_service.dart';

/// Punto de entrada de la aplicación de clima.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno desde el archivo .env (no se sube a Git).
  // Si el archivo no existe, la app sigue arrancando (pero sin API key).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignoramos el error para evitar que la app se caiga al arrancar.
  }

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.isInitialized
        ? (dotenv.env['OPENWEATHER_API_KEY'] ?? '')
        : '';

    final weatherService = WeatherService(apiKey: apiKey);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App del Clima',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: WeatherScreen(weatherService: weatherService),
    );
  }
}
