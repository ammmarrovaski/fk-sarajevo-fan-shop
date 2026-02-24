import '../../domain/models/article_model.dart';

enum ArticlesStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  error,
}

class ArticlesState {
  final ArticlesStatus status;
  final List<Article> articles;
  final Article? selectedArticle;
  final String? errorMessage;
  final String? searchQuery;

  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.articles = const [],
    this.selectedArticle,
    this.errorMessage,
    this.searchQuery,
  });

  bool get isLoading =>
      status == ArticlesStatus.loading ||
      status == ArticlesStatus.creating;

  ArticlesState copyWith({
    ArticlesStatus? status,
    List<Article>? articles,
    Article? selectedArticle,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      selectedArticle: selectedArticle ?? this.selectedArticle,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
