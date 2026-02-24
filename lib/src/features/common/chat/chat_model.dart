class Chat {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final DateTime createdAt;

  const Chat({
    required this.id,
    required this.participantIds,
    this.participantNames = const {},
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.createdAt,
  });

  factory Chat.fromFirestore(Map<String, dynamic> map, String docId) {
    return Chat(
      id: docId,
      participantIds: (map['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      participantNames: (map['participantNames'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.parse(map['lastMessageAt'] as String)
          : null,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Vraca ime drugog ucesnika u chatu
  String otherParticipantName(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantNames[otherId] ?? 'Nepoznat korisnik';
  }
}
