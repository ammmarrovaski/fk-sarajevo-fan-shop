import 'package:firebase_auth/firebase_auth.dart';

import '../data_sources/auth_data_source.dart';
import '../../../app_user/data/data_sources/user_data_source.dart';
import '../../../app_user/domain/models/app_user_model.dart';

class AuthRepository {
  final AuthDataSource authDataSource;
  final UserDataSource userDataSource;

  AuthRepository({
    required this.authDataSource,
    required this.userDataSource,
  });

  /// Trenutni Firebase User
  User? get currentUser => authDataSource.currentUser;

  /// Stream auth promjena
  Stream<User?> get authStateChanges => authDataSource.authStateChanges;

  /// Prijava sa emailom
  /// Vraca AppUser ako postoji u bazi, inace null
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await authDataSource.signInWithEmail(
      email: email,
      password: password,
    );

    if (credential.user == null) return null;

    // Pokusaj dohvatiti korisnika iz Firestore baze
    return await userDataSource.getUser(credential.user!.uid);
  }

  /// Registracija sa emailom
  /// Kreira Firebase Auth korisnika i AppUser dokument u Firestore
  Future<AppUser?> registerWithEmail({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) async {
    final credential = await authDataSource.registerWithEmail(
      email: email,
      password: password,
    );

    if (credential.user == null) return null;

    // Kreiraj AppUser u Firestore
    final appUser = AppUser(
      id: credential.user!.uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await userDataSource.createUser(appUser);
    return appUser;
  }

  /// Prijava sa Google racunom
  Future<AppUser?> signInWithGoogle() async {
    final credential = await authDataSource.signInWithGoogle();

    if (credential?.user == null) return null;

    final user = credential!.user!;

    // Provjeri da li korisnik vec postoji u Firestore
    AppUser? appUser = await userDataSource.getUser(user.uid);

    // Ako ne postoji, kreiraj novog
    if (appUser == null) {
      appUser = AppUser(
        id: user.uid,
        email: user.email ?? '',
        firstName: user.displayName?.split(' ').first ?? '',
        lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
        profileImageUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await userDataSource.createUser(appUser);
    }

    return appUser;
  }

  /// Odjava
  Future<void> signOut() async {
    await authDataSource.signOut();
  }

  /// Reset lozinke
  Future<void> resetPassword(String email) async {
    await authDataSource.resetPassword(email);
  }

  /// Dohvati trenutnog AppUser-a iz Firestore
  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;
    return await userDataSource.getUser(user.uid);
  }
}
