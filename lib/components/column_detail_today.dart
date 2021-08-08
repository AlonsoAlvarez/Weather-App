import 'package:flutter/material.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/utils/calculus.dart';

class ColumnDetailToday extends StatelessWidget {
  final Weather weather;
  final String city;
  const ColumnDetailToday({Key? key, required this.weather, required this.city})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Text(
          '$city',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 50),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          '${Calculus.translateDescription(weather.description)}',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          '${Calculus.kelvinToCelsius(weather.temp).toStringAsFixed(1)} °C',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 45),
        ),
        if (25 < Calculus.kelvinToCelsius(weather.temp)) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No olvides tu bloqueador solar, parece que el clima en $city es caluroso',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
        Text(
          'Sensación: ${Calculus.kelvinToCelsius(weather.feelLikeTemp).toStringAsFixed(1)} °C',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          '${Calculus.dateTimeWithoutCompare(weather.date)} hrs.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
