import 'package:flutter_bloc/flutter_bloc.dart';

// Événements pour le Cubit
abstract class UserEvent {}

class FetchUserEvent extends UserEvent {}

// État pour le Cubit
class UserState {
  final String userName;
  final bool isLoading;

  UserState({required this.userName, required this.isLoading});

  factory UserState.initial() {
    return UserState(userName: '', isLoading: false);
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

  void fetchUser() async {
    // Indiquer que le chargement est en cours
    emit(state.copyWith(isLoading: true));

    try {
      // Simuler une requête réseau
      await Future.delayed(Duration(seconds: 2));

      // Mettre à jour le nom de l'utilisateur
      String userName = 'John Doe';

      // Mettre à jour l'état avec le nom de l'utilisateur
      emit(state.copyWith(userName: userName, isLoading: false));
    } catch (e) {
      // Gérer les erreurs
      emit(state.copyWith(isLoading: false));
    }
  }
}