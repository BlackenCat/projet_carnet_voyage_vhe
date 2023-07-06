import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weather/weather.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(TravelJournalApp());

class TravelJournalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>(
            create: (BuildContext context) => UserCubit(),
          ),
          BlocProvider<PlacesCubit>(
            create: (BuildContext context) => PlacesCubit(),
          ),
        ],
        child: TravelJournalScreen(),
      ),
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
  WeatherFactory weatherFactory =
  WeatherFactory("d1555451a6d58b703c400f0d4769379f", language: Language.FRENCH);

  @override
  void dispose() {
    BlocProvider.of<UserCubit>(context).close();
    BlocProvider.of<PlacesCubit>(context).close();
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
      body: Column(
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                selectImage(context);
              },
              child: Text('Ajouter une photo'),
            ),
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
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ListTile(
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState.initial());

  void signIn() {
    // Effectuer l'opération de connexion
    // Émettre un nouvel état indiquant que l'utilisateur est connecté
    emit(state.copyWith(isSignedIn: true));
  }

  void signOut() {
    // Effectuer l'opération de déconnexion
    // Émettre un nouvel état indiquant que l'utilisateur est déconnecté
    emit(state.copyWith(isSignedIn: false));
  }

  void saveUserData(String userName, String email) {
    // Enregistrer les données utilisateur dans Firebase ou tout autre service de votre choix
    // Émettre un nouvel état avec les données utilisateur mises à jour
    emit(state.copyWith(userName: userName, email: email));
  }
}

class UserState {
  final bool isSignedIn;
  final String userName;
  final String email;

  UserState({
    required this.isSignedIn,
    required this.userName,
    required this.email,
  });

  factory UserState.initial() {
    return UserState(isSignedIn: false, userName: '', email: '');
  }

  UserState copyWith({bool? isSignedIn, String? userName, String? email}) {
    return UserState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      userName: userName ?? this.userName,
      email: email ?? this.email,
    );
  }
}

class PlacesCubit extends Cubit<List<Place>> {
  PlacesCubit() : super([]);

  void fetchPlaces() {
    // Récupérer les données des lieux depuis Firebase ou tout autre service de votre choix
    // Émettre un nouvel état avec les données des lieux récupérées
    List<Place> places = [
      Place(name: 'Place 1', comment: 'Comment 1', rating: 4, country: 'Country 1', city: 'City 1', images: []),
      Place(name: 'Place 2', comment: 'Comment 2', rating: 3, country: 'Country 2', city: 'City 2', images: []),
      Place(name: 'Place 3', comment: 'Comment 3', rating: 5, country: 'Country 3', city: 'City 3', images: []),
    ];

    emit(places);
  }

  void addPlace(Place place) {
    // Ajouter un nouveau lieu dans Firebase
    // Émettre un nouvel état avec les données des lieux mises à jour
    List<Place> updatedPlaces = [...state, place];

    emit(updatedPlaces);
  }
}

class Place {
  final String name;
  final String comment;
  final int rating;
  final String country;
  final String city;
  final List<String> images;

  Place({
    required this.name,
    required this.comment,
    required this.rating,
    required this.country,
    required this.city,
    required this.images,
  });
}
