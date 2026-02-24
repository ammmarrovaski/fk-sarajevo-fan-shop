import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({required this.authRepository}) : super(const AuthState());

  /// Provjeri trenutno auth stanje pri pokretanju
  void checkAuthStatus() {
    _authSubscription = authRepository.authStateChanges.listen(
      (user) async {
        if (user != null) {
          // Korisnik je ulogovan, dohvati AppUser iz Firestore
          final appUser = await authRepository.getCurrentAppUser();
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: appUser,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
          ));
        }
      },
    );
  }

  /// Prijava sa email i lozinkom
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Prijava nije uspjela. Provjerite podatke.',
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Doslo je do greske. Pokusajte ponovo.',
      ));
    }
  }

  /// Registracija sa email i lozinkom
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await authRepository.registerWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Registracija nije uspjela.',
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Doslo je do greske. Pokusajte ponovo.',
      ));
    }
  }

  /// Prijava sa Google racunom
  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await authRepository.signInWithGoogle();

      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        // Korisnik je otkazao Google prijavu
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google prijava nije uspjela.',
      ));
    }
  }

  /// Odjava
  Future<void> signOut() async {
    await authRepository.signOut();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    ));
  }

  /// Reset lozinke
  Future<void> resetPassword(String email) async {
    try {
      await authRepository.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.code),
      ));
    }
  }

  /// Preskoci login (nastavi kao gost)
  void skipLogin() {
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  /// Mapiranje Firebase error kodova na korisnicki prilagodene poruke
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Korisnik sa ovim emailom ne postoji.';
      case 'wrong-password':
        return 'Pogresna lozinka.';
      case 'email-already-in-use':
        return 'Email adresa je vec registrovana.';
      case 'invalid-email':
        return 'Email adresa nije validna.';
      case 'weak-password':
        return 'Lozinka je preslaba. Koristite najmanje 6 karaktera.';
      case 'too-many-requests':
        return 'Previse pokusaja. Pokusajte ponovo kasnije.';
      case 'network-request-failed':
        return 'Problem sa internetom. Provjerite konekciju.';
      default:
        return 'Doslo je do greske ($code). Pokusajte ponovo.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
