import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Événements pour le Cubit
abstract class UserEvent {}

class FetchUserEvent extends UserEvent {}

// État pour le Cubit
class UserState {
  final String userName;
  final bool isLoading;

  UserState({required this.userName, required this.isLoading,});

  factory UserState.initial() {
    return UserState(userName: '', isLoading: false, );
  }

  UserState copyWith({String? userName, bool? isLoading}) {
    return UserState(
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Cubit utilisateur
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState.initial());

  Future<void> signIn() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Utilisez FirebaseAuth.instance pour gérer l'authentification de l'utilisateur
      // Par exemple, pour effectuer une connexion anonyme :
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();

      // Mettre à jour l'état de l'utilisateur avec les informations appropriées
      User user = userCredential.user!;
      String userName = user.uid;
      emit(state.copyWith(userName: userName, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // Gérer les erreurs
    }
  }


  Future<void> signOut() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Utilisez FirebaseAuth.instance pour gérer la déconnexion de l'utilisateur
      await FirebaseAuth.instance.signOut();

      // Mettre à jour l'état de l'utilisateur après la déconnexion
      emit(state.copyWith(userName: '', isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // Gérer les erreurs
    }
  }

  void fetchUser() async {
    // Indiquer que le chargement est en cours
    emit(state.copyWith(isLoading: true));

    try {
      // Simuler une requête réseau
      await Future.delayed(Duration(seconds: 2));

      // Vérifier l'état d'authentification
      User? user = FirebaseAuth.instance.currentUser;
      String userName = user != null ? user.displayName ?? 'John Doe' : 'John Doe';

      // Mettre à jour l'état avec le nom de l'utilisateur
      emit(state.copyWith(userName: userName, isLoading: false));
    } catch (e) {
      // Gérer les erreurs
      emit(state.copyWith(isLoading: false));
    }
  }
}