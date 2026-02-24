import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../articles/presentation/bloc/articles_cubit.dart';
import '../../../articles/presentation/bloc/articles_state.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../app_router/app_routes.dart';
import '../../presentation/widgets/article_card_widget.dart';
import '../../presentation/widgets/category_filter_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Sve';
  final TextEditingController _searchController = TextEditingController();

  static const Color _bordoColor = Color(0xFF800000);

  final List<String> _categories = [
    'Sve',
    'Dresovi',
    'Salovi',
    'Kape',
    'Ulaznice',
    'Ostalo',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ArticlesCubit>().loadArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'FK Sarajevo Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _bordoColor,
        elevation: 0,
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Colors.white),
                      onPressed: () => Get.toNamed(AppRoutes.chatList),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline,
                          color: Colors.white),
                      onPressed: () => Get.toNamed(AppRoutes.profile),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.logout, color: Colors.white),
                      onPressed: () =>
                          context.read<AuthCubit>().signOut(),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.login, color: Colors.white),
                onPressed: () => Get.toNamed(AppRoutes.login),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: _bordoColor.withOpacity(0.05),
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context
                    .read<ArticlesCubit>()
                    .searchArticles(value);
              },
              decoration: InputDecoration(
                hintText: 'Pretrazi artikle...',
                prefixIcon:
                    Icon(Icons.search, color: _bordoColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Category filter
          CategoryFilterWidget(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
              if (category == 'Sve') {
                context.read<ArticlesCubit>().loadArticles();
              } else {
                context
                    .read<ArticlesCubit>()
                    .filterByCategory(category);
              }
            },
          ),

          // Articles grid
          Expanded(
            child: BlocBuilder<ArticlesCubit, ArticlesState>(
              builder: (context, state) {
                if (state is ArticlesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _bordoColor,
                    ),
                  );
                }

                if (state is ArticlesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ArticlesCubit>()
                              .loadArticles(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _bordoColor,
                          ),
                          child: const Text('Pokusaj ponovo',
                              style:
                                  TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ArticlesLoaded) {
                  if (state.articles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Nema dostupnih artikala',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: _bordoColor,
                    onRefresh: () async {
                      context.read<ArticlesCubit>().loadArticles();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.articles.length,
                      itemBuilder: (context, index) {
                        final article = state.articles[index];
                        return ArticleCardWidget(
                          article: article,
                          onTap: () => Get.toNamed(
                            AppRoutes.articleDetail,
                            arguments: article.id,
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return FloatingActionButton(
              onPressed: () => Get.toNamed(AppRoutes.createArticle),
              backgroundColor: _bordoColor,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
