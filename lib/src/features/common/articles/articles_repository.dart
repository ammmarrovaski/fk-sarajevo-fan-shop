import 'dart:io';

import 'articles_data_source.dart';
import 'article_model.dart';
import 'review_model.dart';

class ArticlesRepository {
  final ArticlesDataSource articlesDataSource;

  ArticlesRepository({required this.articlesDataSource});

  /// Dohvati listu artikala
  Future<List<Article>> getArticles({
    int limit = 20,
    String? category,
  }) async {
    return await articlesDataSource.getArticles(
      limit: limit,
      category: category,
    );
  }

  /// Dohvati artikle korisnika
  Future<List<Article>> getUserArticles(String userId) async {
    return await articlesDataSource.getUserArticles(userId);
  }

  /// Dohvati jedan artikal
  Future<Article?> getArticle(String articleId) async {
    return await articlesDataSource.getArticle(articleId);
  }

  /// Objavi novi artikal sa slikama
  Future<Article> createArticle({
    required String title,
    required String description,
    required double price,
    required String sellerId,
    required String sellerName,
    String? category,
    List<File> images = const [],
  }) async {
    final now = DateTime.now();

    // Prvo kreiraj artikal bez slika da dobijemo ID
    final article = Article(
      id: '', // Dodijelit ce Firestore
      title: title,
      description: description,
      price: price,
      sellerId: sellerId,
      sellerName: sellerName,
      category: category,
      createdAt: now,
      updatedAt: now,
    );

    final articleId = await articlesDataSource.createArticle(article);

    // Upload slika ako postoje
    List<String> imageUrls = [];
    if (images.isNotEmpty) {
      imageUrls = await articlesDataSource.uploadArticleImages(
        articleId: articleId,
        images: images,
      );

      // Azuriraj artikal sa URL-ovima slika
      final updatedArticle = Article(
        id: articleId,
        title: title,
        description: description,
        price: price,
        imageUrls: imageUrls,
        sellerId: sellerId,
        sellerName: sellerName,
        category: category,
        createdAt: now,
        updatedAt: now,
      );
      await articlesDataSource.updateArticle(updatedArticle);

      return updatedArticle;
    }

    return Article(
      id: articleId,
      title: title,
      description: description,
      price: price,
      sellerId: sellerId,
      sellerName: sellerName,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Azuriraj artikal
  Future<void> updateArticle(Article article) async {
    await articlesDataSource.updateArticle(article);
  }

  /// Obrisi artikal (soft delete)
  Future<void> deleteArticle(String articleId) async {
    await articlesDataSource.deleteArticle(articleId);
  }

  /// Oznaci kao prodan
  Future<void> markAsSold(String articleId, {String? buyerId}) async {
    await articlesDataSource.markAsSold(articleId, buyerId: buyerId);
  }

  /// Pretrazi artikle
  Future<List<Article>> searchArticles(String query) async {
    return await articlesDataSource.searchArticles(query);
  }

  /// Ostavi dojam
  Future<void> leaveReview(Review review) async {
    await articlesDataSource.createReview(review);
  }

  /// Dohvati reviewe za prodavaca
  Future<List<Review>> getSellerReviews(String sellerId) async {
    return await articlesDataSource.getSellerReviews(sellerId);
  }
}
