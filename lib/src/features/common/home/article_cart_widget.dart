import 'package:flutter/material.dart';
import '../articles/article_model.dart';

class ArticleCardWidget extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;

  const ArticleCardWidget({
    super.key,
    required this.article,
    required this.onTap,
  });

  static const Color _bordoColor = Color(0xFF800000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: article.imageUrls.isNotEmpty
                  ? Image.network(
                      article.imageUrls.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${article.price.toStringAsFixed(2)} KM',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _bordoColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _bordoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: _bordoColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
