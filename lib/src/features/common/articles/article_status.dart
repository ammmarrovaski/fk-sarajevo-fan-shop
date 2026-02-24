enum ArticleStatus {
  active,    // Artikal je aktivan i vidljiv
  sold,      // Artikal je prodan
  reserved,  // Artikal je rezervisan
  deleted;   // Artikal je obrisan (soft delete)

  static ArticleStatus fromString(String value) {
    return ArticleStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ArticleStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case ArticleStatus.active:
        return 'Aktivan';
      case ArticleStatus.sold:
        return 'Prodan';
      case ArticleStatus.reserved:
        return 'Rezervisan';
      case ArticleStatus.deleted:
        return 'Obrisan';
    }
  }
}
