import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Funkcija za Login
  Future<String?> login(String email, String password) async {
    print("DEBUG: Pozvan register za $email");
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sve OK
    } on FirebaseAuthException catch (e) {
      return e.message; // Vraća tekst greške (npr. "Pogrešna lozinka")
    }
  }

  // Funkcija za Registraciju
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}