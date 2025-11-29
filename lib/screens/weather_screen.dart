import 'package:flutter/material.dart';

import '../services/weather_service.dart';

/// Pantalla principal que permite buscar una ciudad
/// y muestra el clima actual usando OpenWeatherMap.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key, required this.weatherService});

  final WeatherService weatherService;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final List<String> _cities = <String>[
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Santa Marta',
  ];
  String _selectedCity = 'Bogotá';

  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather(); // carga inicial para la ciudad por defecto
  }

  Future<void> _fetchWeather() async {
    if (widget.weatherService.apiKey.isEmpty) {
      setState(() {
        _error = 'API key vacía. Revisa el archivo .env (OPENWEATHER_API_KEY).';
      });
      return;
    }

    final String city = _selectedCity.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.weatherService.getCurrentWeatherByCity(city);
      setState(() {
        _weather = result;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color topColor = _getBackgroundTopColor();
    final Color bottomColor = _getBackgroundBottomColor();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Clima en Colombia'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[topColor, bottomColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCityDropdown(),
                const SizedBox(height: 24),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                dropdownColor: Colors.blueGrey.shade800,
                style: const TextStyle(color: Colors.white),
                items: _cities
                    .map(
                      (String city) => DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCity = value;
                  });
                  _fetchWeather();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.lightBlueAccent),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_weather == null) {
      return const Center(
        child: Text(
          'Selecciona una ciudad de Colombia para ver el clima.',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    final weather = _weather!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          weather.cityName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          weather.description,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
        ),
        const SizedBox(height: 24),
        _buildWeatherIcon(weather),
        const SizedBox(height: 24),
        Text(
          '${weather.temperature.toStringAsFixed(1)} °C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherIcon(WeatherData weather) {
    final String description = weather.description.toLowerCase();

    IconData iconData;

    if (description.contains('lluvia') || description.contains('rain')) {
      iconData = Icons.beach_access; // paraguas / lluvia
    } else if (description.contains('nube') || description.contains('cloud')) {
      iconData = Icons.cloud;
    } else if (description.contains('tormenta') ||
        description.contains('storm')) {
      iconData = Icons.thunderstorm;
    } else if (description.contains('nieve') || description.contains('snow')) {
      iconData = Icons.ac_unit;
    } else {
      // cielo claro / despejado
      iconData = Icons.wb_sunny;
    }

    return Icon(iconData, color: Colors.white, size: 80);
  }

  Color _getBackgroundTopColor() {
    if (_weather == null) {
      return Colors.blueGrey.shade900;
    }

    final String description = _weather!.description.toLowerCase();

    if (description.contains('lluvia') || description.contains('rain')) {
      return Colors.indigo.shade900;
    }

    if (description.contains('nube') || description.contains('cloud')) {
      return Colors.blueGrey.shade800;
    }

    if (description.contains('tormenta') || description.contains('storm')) {
      return Colors.deepPurple.shade900;
    }

    if (description.contains('nieve') || description.contains('snow')) {
      return Colors.lightBlue.shade200;
    }

    // Despejado / otras condiciones
    return Colors.orange.shade400;
  }

  Color _getBackgroundBottomColor() {
    if (_weather == null) {
      return Colors.blueGrey.shade700;
    }

    final String description = _weather!.description.toLowerCase();

    if (description.contains('lluvia') || description.contains('rain')) {
      return Colors.blueGrey.shade900;
    }

    if (description.contains('nube') || description.contains('cloud')) {
      return Colors.blueGrey.shade900;
    }

    if (description.contains('tormenta') || description.contains('storm')) {
      return Colors.black87;
    }

    if (description.contains('nieve') || description.contains('snow')) {
      return Colors.blueGrey.shade100;
    }

    // Despejado / otras condiciones
    return Colors.deepOrange.shade700;
  }
}
