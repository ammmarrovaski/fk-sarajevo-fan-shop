import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/app_user_model.dart';

class UserDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  UserDataSource({
    required this.firestore,
    required this.storage,
  });

  /// Referenca na kolekciju korisnika
  CollectionReference get _usersCollection => firestore.collection('users');

  /// Dohvati korisnika po ID-u
  Future<AppUser?> getUser(String userId) async {
    final doc = await _usersCollection.doc(userId).get();

    if (!doc.exists || doc.data() == null) return null;

    return AppUser.fromFirestore(
      doc.data()! as Map<String, dynamic>,
      doc.id,
    );
  }

  /// Kreiraj novog korisnika
  Future<void> createUser(AppUser user) async {
    await _usersCollection.doc(user.id).set(user.toFirestore());
  }

  /// Azuriraj korisnika
  Future<void> updateUser(AppUser user) async {
    final data = user.toFirestore();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _usersCollection.doc(user.id).update(data);
  }

  /// Upload profilne slike
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final ref = storage.ref().child('profile_images/$userId.jpg');

    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Obrisi profilnu sliku
  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = storage.ref().child('profile_images/$userId.jpg');
      await ref.delete();
    } catch (_) {
      // Slika mozda ne postoji, ignorisemo gresku
    }
  }

  /// Pretrazi korisnike po imenu
  Future<List<AppUser>> searchUsers(String query) async {
    final queryLower = query.toLowerCase();

    final snapshot = await _usersCollection
        .orderBy('firstName')
        .startAt([queryLower])
        .endAt(['$queryLower\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => AppUser.fromFirestore(
              doc.data()! as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  /// Dohvati sve korisnike (paginacija)
  Future<List<AppUser>> getUsers({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _usersCollection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => AppUser.fromFirestore(
              doc.data()! as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }
}
