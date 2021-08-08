import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/components/alert_map.dart';
import 'package:weather_app/components/card_alert.dart';
import 'package:weather_app/components/card_weather.dart';
import 'package:weather_app/components/column_detail_today.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/request/api.dart';
import 'package:weather_app/utils/calculus.dart';

class PageHome extends StatefulWidget {
  PageHome({Key? key}) : super(key: key);

  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final controllerSearch = TextEditingController(text: 'Zapopan');

  LatLng? currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controllerSearch,
          decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              hintText: 'Buscar'),
          onSubmitted: (_) {
            Fluttertoast.showToast(msg: 'Buscando: ${controllerSearch.text}');
            setState(() {
              currentPosition = null;
            });
          },
        ),
        actions: [
          IconButton(
              onPressed: () async {
                LatLng newPosition =
                    await Calculus.getCurrentPositionInLatLng();
                controllerSearch.text = await Calculus.getNameCity(newPosition);
                setState(() {
                  currentPosition = newPosition;
                });
              },
              icon: Icon(Icons.place))
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Forecast>(
          future: currentPosition != null
              ? WeatherApi.getWeather(currentPosition!)
              : WeatherApi.getWeatherFromCity(controllerSearch.text),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Stack(
                children: [
                  Center(child: Image.asset('assets/error.gif')),
                  Positioned(
                    top: 35,
                    left: 20,
                    right: 20,
                    child: Text(
                      'Ha ocurrido un error',
                      style: TextStyle(color: Colors.red, fontSize: 30, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Image.asset('assets/loading.gif'),
              );
            }
            return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Calculus.weatherConditionToImage(
                          snapshot.data!.current.condition,
                          snapshot.data!.isDayTime))),
              child: ListView(
                children: [
                  ColumnDetailToday(
                    city: controllerSearch.text,
                    weather: snapshot.data!.current,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (builder) {
                              return AlertMap(
                                  title: '${controllerSearch.text}',
                                  changePosition: (LatLng position) async {
                                    controllerSearch.text =
                                        await Calculus.getNameCity(position);
                                    setState(() {
                                      currentPosition = position;
                                    });
                                  },
                                  location: LatLng(
                                      snapshot.data!.latitude.toDouble(),
                                      snapshot.data!.longitude.toDouble()));
                            });
                      },
                      icon: Icon(
                        Icons.place,
                        color: Colors.red,
                      ),
                      label: Text(
                        '${snapshot.data!.latitude}, ${snapshot.data!.longitude}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  if (0 < snapshot.data!.alerts.length) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(100, 255, 0, 0)),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (builder) {
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Column(
                                      children: snapshot.data!.alerts
                                          .map((e) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: CardAlert(alert: e),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                );
                              });
                        },
                        icon: Icon(
                          Icons.warning,
                          color: Colors.yellow,
                        ),
                        label: Text(
                          'Alertas',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    )
                  ],
                  SizedBox(
                    height: 35,
                  ),
                  ...snapshot.data!.daily.map((e) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CardWeather(weather: e),
                      ))
                ],
              ),
            );
          }),
    );
  }
}
