import 'article_status.dart';

class Article {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final ArticleStatus status;
  final bool isVisible;
  final bool isDeleted;
  final String? buyerId;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'BAM',
    this.imageUrls = const [],
    required this.sellerId,
    this.sellerName = '',
    this.status = ArticleStatus.active,
    this.isVisible = true,
    this.isDeleted = false,
    this.buyerId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Konverzija iz Firestore dokumenta
  factory Article.fromFirestore(Map<String, dynamic> map, String docId) {
    return Article(
      id: docId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'BAM',
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? '',
      status: ArticleStatus.fromString(map['status'] as String? ?? 'active'),
      isVisible: map['isVisible'] as bool? ?? true,
      isDeleted: map['isDeleted'] as bool? ?? false,
      buyerId: map['buyerId'] as String?,
      category: map['category'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Konverzija u Firestore mapu
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'status': status.name,
      'isVisible': isVisible,
      'isDeleted': isDeleted,
      'buyerId': buyerId,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
