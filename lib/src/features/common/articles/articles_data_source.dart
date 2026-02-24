import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/article_model.dart';
import '../../domain/models/review_model.dart';

class ArticlesDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ArticlesDataSource({
    required this.firestore,
    required this.storage,
  });

  CollectionReference get _articlesCollection =>
      firestore.collection('articles');

  CollectionReference get _reviewsCollection =>
      firestore.collection('reviews');

  /// Dohvati artikle (vidljivi, nisu obrisani)
  Future<List<Article>> getArticles({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? category,
  }) async {
    Query query = _articlesCollection
        .where('isVisible', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Article.fromFirestore(
              doc.data()! as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  /// Dohvati artikle za odredjenog korisnika
  Future<List<Article>> getUserArticles(String userId) async {
    final snapshot = await _articlesCollection
        .where('sellerId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Article.fromFirestore(
              doc.data()! as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  /// Dohvati jedan artikal po ID-u
  Future<Article?> getArticle(String articleId) async {
    final doc = await _articlesCollection.doc(articleId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Article.fromFirestore(
      doc.data()! as Map<String, dynamic>,
      doc.id,
    );
  }

  /// Kreiraj novi artikal
  Future<String> createArticle(Article article) async {
    final docRef = await _articlesCollection.add(article.toFirestore());
    return docRef.id;
  }

  /// Azuriraj artikal
  Future<void> updateArticle(Article article) async {
    final data = article.toFirestore();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _articlesCollection.doc(article.id).update(data);
  }

  /// Soft delete artikla
  Future<void> deleteArticle(String articleId) async {
    await _articlesCollection.doc(articleId).update({
      'isDeleted': true,
      'isVisible': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Oznaci artikal kao prodan
  Future<void> markAsSold(String articleId, {String? buyerId}) async {
    await _articlesCollection.doc(articleId).update({
      'status': 'sold',
      'isVisible': false,
      'buyerId': buyerId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Upload slika artikla
  Future<List<String>> uploadArticleImages({
    required String articleId,
    required List<File> images,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < images.length; i++) {
      final ref = storage
          .ref()
          .child('article_images/$articleId/${articleId}_$i.jpg');

      await ref.putFile(
        images[i],
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  /// Pretrazi artikle po naslovu
  Future<List<Article>> searchArticles(String query) async {
    final queryLower = query.toLowerCase();

    // Firestore nema full-text search, koristimo prefix matching
    final snapshot = await _articlesCollection
        .where('isVisible', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .orderBy('title')
        .startAt([queryLower])
        .endAt(['$queryLower\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => Article.fromFirestore(
              doc.data()! as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  /// Kreiraj review/dojam
  Future<void> createReview(Review review) async {
    await _reviewsCollection.add(review.toFirestore());

    // Azuriraj prosjecnu ocjenu prodavaca
    final reviewsSnapshot = await _reviewsCollection
        .where('sellerId', isEqualTo: review.sellerId)
        .get();

    final reviews = reviewsSnapshot.docs
        .map((doc) => Review.fromFirestore(
              doc.data()! as Map<String, dynamic>,
              doc.id,
            ))
        .toList();

    final avgRating =
        reviews.fold<double>(0, (sum, r) => sum + r.rating) / reviews.length;

    await firestore.collection('users').doc(review.sellerId).update({
      'averageRating': avgRating,
      'totalReviews': reviews.length,
    });
  }

  /// Dohvati reviewe za prodavaca
  Future<List<Review>> getSellerReviews(String sellerId) async {
    final snapshot = await _reviewsCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Review.fromFirestore(
              doc.data()! as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }
}
