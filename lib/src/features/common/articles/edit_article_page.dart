import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/articles_repository.dart';
import '../../domain/models/article_model.dart';
import '../bloc/articles_cubit.dart';
import '../bloc/articles_state.dart';

class EditArticlePage extends StatelessWidget {
  final String articleId;

  const EditArticlePage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticlesCubit(
        articlesRepository: GetIt.instance<ArticlesRepository>(),
      )..loadArticle(articleId),
      child: const _EditArticleContent(),
    );
  }
}

class _EditArticleContent extends StatefulWidget {
  const _EditArticleContent();

  @override
  State<_EditArticleContent> createState() => _EditArticleContentState();
}

class _EditArticleContentState extends State<_EditArticleContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isVisible = true;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticlesCubit, ArticlesState>(
      listener: (context, state) {
        if (state.status == ArticlesStatus.created) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikal azuriran!')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final article = state.selectedArticle;

        if (state.isLoading && !_initialized) {
          return Scaffold(
            appBar: AppBar(title: const Text('Uredi Artikal')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!_initialized && article != null) {
          _titleController.text = article.title;
          _descriptionController.text = article.description;
          _priceController.text = article.price.toString();
          _isVisible = article.isVisible;
          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Uredi Artikal')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Unesite naslov' : null,
                    decoration: const InputDecoration(
                      labelText: 'Naslov',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Unesite opis' : null,
                    decoration: const InputDecoration(
                      labelText: 'Opis',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Unesite cijenu';
                      if (double.tryParse(v) == null) return 'Unesite validnu cijenu';
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cijena (BAM)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Vidljiv'),
                    subtitle: const Text('Da li je artikal vidljiv u pretrazi'),
                    value: _isVisible,
                    onChanged: (v) => setState(() => _isVisible = v),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _handleSave(article),
                      child: const Text(
                        'SACUVAJ PROMJENE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSave(Article? article) {
    if (article == null || !_formKey.currentState!.validate()) return;

    final updated = Article(
      id: article.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      currency: article.currency,
      imageUrls: article.imageUrls,
      sellerId: article.sellerId,
      sellerName: article.sellerName,
      status: article.status,
      isVisible: _isVisible,
      isDeleted: article.isDeleted,
      buyerId: article.buyerId,
      category: article.category,
      createdAt: article.createdAt,
      updatedAt: DateTime.now(),
    );

    context.read<ArticlesCubit>().articlesRepository.updateArticle(updated);
  }
}
