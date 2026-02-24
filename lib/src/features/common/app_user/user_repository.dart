import 'dart:io';

import '../data_sources/user_data_source.dart';
import '../../domain/models/app_user_model.dart';

class UserRepository {
  final UserDataSource userDataSource;

  UserRepository({required this.userDataSource});

  /// Dohvati korisnika po ID-u
  Future<AppUser?> getUser(String userId) async {
    return await userDataSource.getUser(userId);
  }

  /// Azuriraj profil korisnika
  Future<AppUser> updateProfile({
    required AppUser currentUser,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    File? newProfileImage,
  }) async {
    String? imageUrl = currentUser.profileImageUrl;

    // Upload nove profilne slike ako je dostavljena
    if (newProfileImage != null) {
      imageUrl = await userDataSource.uploadProfileImage(
        userId: currentUser.id,
        imageFile: newProfileImage,
      );
    }

    final updatedUser = AppUser(
      id: currentUser.id,
      email: currentUser.email,
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      profileImageUrl: imageUrl,
      dateOfBirth: dateOfBirth ?? currentUser.dateOfBirth,
      gender: gender ?? currentUser.gender,
      createdAt: currentUser.createdAt,
      updatedAt: DateTime.now(),
      averageRating: currentUser.averageRating,
      totalReviews: currentUser.totalReviews,
    );

    await userDataSource.updateUser(updatedUser);
    return updatedUser;
  }

  /// Pretrazi korisnike
  Future<List<AppUser>> searchUsers(String query) async {
    return await userDataSource.searchUsers(query);
  }

  /// Dohvati listu korisnika
  Future<List<AppUser>> getUsers({int limit = 20}) async {
    return await userDataSource.getUsers(limit: limit);
  }
}
