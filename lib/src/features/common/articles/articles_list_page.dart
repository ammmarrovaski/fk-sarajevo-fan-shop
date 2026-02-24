import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../app_router/app.routes.dart';
import '../auth/auth_cubit.dart';
import 'articles_repository.dart';
import 'article_model.dart';
import 'articles_cubit.dart';
import 'articles_state.dart';

class ArticlesListPage extends StatelessWidget {
  const ArticlesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticlesCubit(
        articlesRepository: GetIt.instance<ArticlesRepository>(),
      )..loadArticles(),
      child: const _ArticlesListContent(),
    );
  }
}

class _ArticlesListContent extends StatefulWidget {
  const _ArticlesListContent();

  @override
  State<_ArticlesListContent> createState() => _ArticlesListContentState();
}

class _ArticlesListContentState extends State<_ArticlesListContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikli'),
      ),
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (!authState.isAuthenticated) return const SizedBox.shrink();
          return FloatingActionButton(
            backgroundColor: fksBordo,
            foregroundColor: Colors.white,
            onPressed: () => context.push(AppRoutes.createArticle),
            child: const Icon(Icons.add),
          );
        },
      ),
      body: Column(
        children: [
          // Pretraga
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<ArticlesCubit>().searchArticles(value);
              },
              decoration: InputDecoration(
                hintText: 'Pretrazi artikle...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ArticlesCubit>().loadArticles();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Lista artikala
          Expanded(
            child: BlocBuilder<ArticlesCubit, ArticlesState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nema artikala',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<ArticlesCubit>().loadArticles(),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: state.articles.length,
                    itemBuilder: (context, index) {
                      return _ArticleCard(article: state.articles[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return GestureDetector(
      onTap: () => context.push('/articles/${article.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slika
            Expanded(
              flex: 3,
              child: article.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrls.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
            ),
            // Detalji
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${article.price.toStringAsFixed(2)} ${article.currency}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: fksBordo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      article.sellerName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
