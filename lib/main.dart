import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet_carnet_voyage_vhe/UserCubit.dart';
import 'package:weather/weather.dart';

void main() => runApp(TravelJournalApp());

class TravelJournalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TravelJournalScreen(),
    );
  }
}

class TravelJournalScreen extends StatefulWidget {

  @override
  _TravelJournalScreenState createState() => _TravelJournalScreenState();
}

class _TravelJournalScreenState extends State<TravelJournalScreen> {
  List<TravelEntry> travelEntries = [];
  TextEditingController locationController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  late DateTime selectedDate;
  late String selectedImagePath;
  late UserCubit _userCubit;
  WeatherFactory weatherFactory =
  WeatherFactory("d1555451a6d58b703c400f0d4769379f", language: Language.FRENCH);

  @override
  void initState() {
    super.initState();
    _userCubit = UserCubit(); // Initialisation du Cubit utilisateur
  }

  @override
  void dispose() {
    _userCubit.close(); // Fermeture du Cubit utilisateur
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await DatePicker.showDatePicker(
      context,
      locale: LocaleType.fr,
      currentTime: selectedDate ?? DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImagePath = pickedImage.path;
      });
    }
  }

  Future<Weather> fetchWeather(String location) async {
    Weather weather = await weatherFactory.currentWeatherByCityName(location);
    return weather;
  }

  void addTravelEntry() async {
    if (selectedDate == null || locationController.text.isEmpty) {
      return;
    }

    Weather weather = await fetchWeather(locationController.text);

    setState(() {
      travelEntries.add(
        TravelEntry(
          date: selectedDate,
          location: locationController.text,
          comment: commentController.text,
          imagePath: selectedImagePath,
          weather: weather,
        ),
      );
      selectedDate = DateTime(1900);
      locationController.clear();
      commentController.clear();
      selectedImagePath = 'null';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Journal'),
      ),
      body: BlocProvider(
        // Ajout de BlocProvider pour envelopper la colonne des widgets
        create: (context) => _userCubit,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Lieu visité',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () {
                      selectDate(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Commentaire',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                selectImage(context);
              },
              child: Text('Ajouter une photo'),
            ),
            ElevatedButton(
              onPressed: () {
                addTravelEntry();
              },
              child: Text('Ajouter'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: travelEntries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Lieu : ${travelEntries[index].location}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date : ${travelEntries[index].formattedDate}'),
                        Text('Commentaire : ${travelEntries[index].comment}'),
                        if (travelEntries[index].imagePath != null)
                          Image.file(
                            File(travelEntries[index].imagePath),
                            width: 100,
                            height: 100,
                          ),
                        FutureBuilder<Weather>(
                          future: fetchWeather(travelEntries[index].location),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final weather = snapshot.data;
                              return Text(
                                  'Météo : ${weather?.temperature?.celsius ?? 'N/A'}°C, ${weather?.weatherDescription ?? 'N/A'} ');
                            } else if (snapshot.hasError) {
                              return Text('Erreur de chargement de la météo');
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TravelEntry {
  final DateTime date;
  final String location;
  final String comment;
  final String imagePath;
  final Weather weather;

  TravelEntry({
    required this.date,
    required this.location,
    required this.comment,
    required this.imagePath,
    required this.weather,
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
}