import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../app_router/app.routes.dart';
import '../auth/auth_cubit.dart';
import 'articles_repository.dart';
import 'article_status.dart';
import 'articles_cubit.dart';
import 'articles_state.dart';

class ArticleDetailPage extends StatelessWidget {
  final String articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticlesCubit(
        articlesRepository: GetIt.instance<ArticlesRepository>(),
      )..loadArticle(articleId),
      child: const _ArticleDetailContent(),
    );
  }
}

class _ArticleDetailContent extends StatelessWidget {
  const _ArticleDetailContent();

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return BlocBuilder<ArticlesCubit, ArticlesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final article = state.selectedArticle;
        if (article == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Artikal nije pronadjen.')),
          );
        }

        final authState = context.read<AuthCubit>().state;
        final isOwner =
            authState.user != null && authState.user!.id == article.sellerId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalji artikla'),
            actions: [
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.push('/articles/${article.id}/edit');
                        break;
                      case 'sold':
                        _showMarkAsSoldDialog(context, article.id);
                        break;
                      case 'delete':
                        _showDeleteDialog(context, article.id);
                        break;
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Uredi'),
                        ],
                      ),
                    ),
                    if (article.status == ArticleStatus.active)
                      const PopupMenuItem(
                        value: 'sold',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 20),
                            SizedBox(width: 8),
                            Text('Oznaci kao prodan'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Obrisi', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slike (horizontalni PageView)
                if (article.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: article.imageUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: article.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      if (article.status != ArticleStatus.active)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: article.status == ArticleStatus.sold
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article.status.displayName,
                            style: TextStyle(
                              color: article.status == ArticleStatus.sold
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      // Naslov
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Cijena
                      Text(
                        '${article.price.toStringAsFixed(2)} ${article.currency}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: fksBordo,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prodavac
                      InkWell(
                        onTap: () {
                          context.push('/users/${article.sellerId}');
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: fksBordo,
                              child: Text(
                                article.sellerName.isNotEmpty
                                    ? article.sellerName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.sellerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Objavljeno ${DateFormat('dd.MM.yyyy').format(article.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Opis
                      const Text(
                        'Opis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      if (article.category != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.category, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Kategorija: ${article.category}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Dugme za poruku (samo za ulogovane, ne za vlasnika)
                      if (authState.isAuthenticated && !isOwner)
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fksBordo,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: Otvori chat sa prodavacem
                            },
                            icon: const Icon(Icons.message),
                            label: const Text(
                              'POSALJI PORUKU',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMarkAsSoldDialog(BuildContext context, String articleId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Oznaci kao prodan'),
        content: const Text('Da li ste sigurni da zelite oznaciti ovaj artikal kao prodan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ne'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ArticlesCubit>().markAsSold(articleId);
              context.pop();
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String articleId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obrisi artikal'),
        content: const Text('Da li ste sigurni? Ova akcija se ne moze ponistiti.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ne'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ArticlesCubit>().deleteArticle(articleId);
              context.pop();
            },
            child: const Text('Obrisi'),
          ),
        ],
      ),
    );
  }
}
