class Review {
  final String id;
  final String articleId;
  final String reviewerId;
  final String reviewerName;
  final String sellerId;
  final String message;
  final int rating;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.articleId,
    required this.reviewerId,
    this.reviewerName = '',
    required this.sellerId,
    this.message = '',
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromFirestore(Map<String, dynamic> map, String docId) {
    return Review(
      id: docId,
      articleId: map['articleId'] as String? ?? '',
      reviewerId: map['reviewerId'] as String? ?? '',
      reviewerName: map['reviewerName'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      rating: map['rating'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'articleId': articleId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'sellerId': sellerId,
      'message': message,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
