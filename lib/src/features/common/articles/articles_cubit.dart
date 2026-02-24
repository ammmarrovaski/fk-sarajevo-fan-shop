import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/articles_repository.dart';
import '../../domain/models/review_model.dart';
import 'articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final ArticlesRepository articlesRepository;

  ArticlesCubit({required this.articlesRepository})
      : super(const ArticlesState());

  /// Ucitaj artikle
  Future<void> loadArticles({String? category}) async {
    emit(state.copyWith(status: ArticlesStatus.loading));

    try {
      final articles = await articlesRepository.getArticles(
        category: category,
      );
      emit(state.copyWith(
        status: ArticlesStatus.loaded,
        articles: articles,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.error,
        errorMessage: 'Greska pri ucitavanju artikala.',
      ));
    }
  }

  /// Ucitaj jedan artikal
  Future<void> loadArticle(String articleId) async {
    emit(state.copyWith(status: ArticlesStatus.loading));

    try {
      final article = await articlesRepository.getArticle(articleId);
      emit(state.copyWith(
        status: ArticlesStatus.loaded,
        selectedArticle: article,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.error,
        errorMessage: 'Greska pri ucitavanju artikla.',
      ));
    }
  }

  /// Kreiraj novi artikal
  Future<void> createArticle({
    required String title,
    required String description,
    required double price,
    required String sellerId,
    required String sellerName,
    String? category,
    List<File> images = const [],
  }) async {
    emit(state.copyWith(status: ArticlesStatus.creating));

    try {
      await articlesRepository.createArticle(
        title: title,
        description: description,
        price: price,
        sellerId: sellerId,
        sellerName: sellerName,
        category: category,
        images: images,
      );

      emit(state.copyWith(status: ArticlesStatus.created));

      // Ponovno ucitaj artikle
      await loadArticles();
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.error,
        errorMessage: 'Greska pri kreiranju artikla.',
      ));
    }
  }

  /// Obrisi artikal
  Future<void> deleteArticle(String articleId) async {
    try {
      await articlesRepository.deleteArticle(articleId);
      // Ukloni iz lokalne liste
      final updated = state.articles.where((a) => a.id != articleId).toList();
      emit(state.copyWith(articles: updated));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.error,
        errorMessage: 'Greska pri brisanju artikla.',
      ));
    }
  }

  /// Oznaci kao prodan
  Future<void> markAsSold(String articleId, {String? buyerId}) async {
    try {
      await articlesRepository.markAsSold(articleId, buyerId: buyerId);
      await loadArticles();
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.error,
        errorMessage: 'Greska pri oznacavanju artikla.',
      ));
    }
  }

  /// Pretrazi artikle
  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      await loadArticles();
      return;
    }

    emit(state.copyWith(
      status: ArticlesStatus.loading,
      searchQuery: query,
    ));

    try {
      final articles = await articlesRepository.searchArticles(query);
      emit(state.copyWith(
        status: ArticlesStatus.loaded,
        articles: articles,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.error,
        errorMessage: 'Greska pri pretrazi.',
      ));
    }
  }

  /// Ostavi dojam
  Future<void> leaveReview({
    required String articleId,
    required String reviewerId,
    required String reviewerName,
    required String sellerId,
    required String message,
    required int rating,
  }) async {
    try {
      final review = Review(
        id: '',
        articleId: articleId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        sellerId: sellerId,
        message: message,
        rating: rating,
        createdAt: DateTime.now(),
      );

      await articlesRepository.leaveReview(review);
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.error,
        errorMessage: 'Greska pri ostavljanju dojma.',
      ));
    }
  }
}
