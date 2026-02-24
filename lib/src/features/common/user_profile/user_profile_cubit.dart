import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_user/user_repository.dart';
import '../app_user/app_user_model.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository userRepository;

  UserProfileCubit({required this.userRepository})
      : super(const UserProfileState());

  /// Ucitaj profil korisnika
  Future<void> loadProfile(String userId) async {
    emit(state.copyWith(status: UserProfileStatus.loading));

    try {
      final user = await userRepository.getUser(userId);

      if (user != null) {
        emit(state.copyWith(
          status: UserProfileStatus.loaded,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: 'Korisnik nije pronadjen.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: 'Greska pri ucitavanju profila.',
      ));
    }
  }

  /// Azuriraj profil
  Future<void> updateProfile({
    required AppUser currentUser,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    File? newProfileImage,
  }) async {
    emit(state.copyWith(status: UserProfileStatus.updating));

    try {
      final updatedUser = await userRepository.updateProfile(
        currentUser: currentUser,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
        newProfileImage: newProfileImage,
      );

      emit(state.copyWith(
        status: UserProfileStatus.updated,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: 'Greska pri azuriranju profila.',
      ));
    }
  }
}
