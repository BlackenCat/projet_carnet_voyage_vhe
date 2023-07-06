import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Événements pour le Cubit
abstract class PlacesEvent {}

class FetchPlacesEvent extends PlacesEvent {}

class AddPlaceEvent extends PlacesEvent {
  final String name;
  final String comment;
  final String note;
  final String country;
  final String city;
  final List<String> images;

  AddPlaceEvent({
    required this.name,
    required this.comment,
    required this.note,
    required this.country,
    required this.city,
    required this.images,
  });
}

// État pour le Cubit
class PlacesState {
  final List<Place> places;
  final bool isLoading;

  PlacesState({required this.places, required this.isLoading});

  factory PlacesState.initial() {
    return PlacesState(places: [], isLoading: false);
  }

  PlacesState copyWith({List<Place>? places, bool? isLoading}) {
    return PlacesState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Cubit des lieux
class PlacesCubit extends Cubit<PlacesState> {
  PlacesCubit() : super(PlacesState.initial());

  Future<void> fetchPlaces() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Utilisez FirebaseFirestore.instance pour récupérer les données des lieux depuis Firestore
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('places').get();

      // Convertir les documents Firestore en objets Place
      List<Place> places = querySnapshot.docs.map((doc) {
        return Place.fromFirestore(doc);
      }).toList();

      // Mettre à jour l'état avec les lieux récupérés
      emit(state.copyWith(places: places, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // Gérer les erreurs
    }
  }

  Future<void> addPlace(String name, String comment, String note,
      String country, String city, List<String> images) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Utilisez FirebaseFirestore.instance pour ajouter les données d'un nouveau lieu à Firestore
      CollectionReference placesCollection =
      FirebaseFirestore.instance.collection('places');
      await placesCollection.add({
        'name': name,
        'comment': comment,
        'note': note,
        'country': country,
        'city': city,
        'images': images,
      });

      // Récupérer à nouveau les lieux après l'ajout
      await fetchPlaces();
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // Gérer les erreurs
    }
  }
}

// Modèle de lieu
class Place {
  final String id;
  final String name;
  final String comment;
  final String note;
  final String country;
  final String city;
  final List<String> images;

  Place({
    required this.id,
    required this.name,
    required this.comment,
    required this.note,
    required this.country,
    required this.city,
    required this.images,
  });

  factory Place.fromFirestore(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      comment: data['comment'] ?? '',
      note: data['note'] ?? '',
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      images: List<String>.from(data['images'] ?? []),
    );
  }
}