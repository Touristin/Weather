import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'weather.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Прогноз погоды',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        hintColor: Colors.pinkAccent,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Roboto',
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
      ),
      home: const WeatherHomePage(
        title: 'Прогноз погоды',
        key: null,
      ),
    );
  }
}

class WeatherService {
  final String apiKey = 'b00090cf4e3f6262d0b7572ab5682f32';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<WeatherForecast> getWeather(String city) async {
    final url = '$baseUrl?q=$city&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherForecast.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key, required this.title});
  final String title;

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService weatherService = WeatherService();
  String selectedCity = 'Ханты-Мансийск'; // Город по умолчанию
  List<String> cities = [
    'Ханты-Мансийск',
    'Москва',
    'Санкт-Петербург',
    'Норильск',
    'Тюмень',
    'Сочи',
    'Волгоград',
  ];
  WeatherForecast? weatherForecast;
  Weather? currentWeather;
  bool showForecast = false; // Прогноз скрыт по умолчанию

  @override
  void initState() {
    super.initState();
    _getWeather(selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: selectedCity,
              onChanged: (newValue) {
                setState(() {
                  selectedCity = newValue!;
                });
                _getWeather(selectedCity);
              },
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Выберите город',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (currentWeather != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Текущая температура:',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      '${currentWeather!.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ощущается как: ${currentWeather!.feelsLike.toStringAsFixed(1)}°C',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Влажность: ${currentWeather!.humidity}%',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            if (showForecast &&
                weatherForecast != null &&
                weatherForecast!.forecasts.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: WeatherForecastTable(forecasts: weatherForecast!.forecasts),
              ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showForecast = !showForecast;
                });
              },
              child: Text(showForecast ? 'Скрыть прогноз' : 'Показать прогноз'),
            ),
          ],
        ),
      ),
    );
  }

  void _getWeather(String city) async {
    try {
      final data = await weatherService.getWeather(city);
      setState(() {
        weatherForecast = data;
        currentWeather = data.forecasts.first;
      });
    } catch (e) {
      print(e);
    }
  }
}
