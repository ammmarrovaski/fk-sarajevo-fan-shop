import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/chat_model.dart';
import '../../domain/models/message_model.dart';

class ChatDataSource {
  final FirebaseFirestore firestore;

  ChatDataSource({required this.firestore});

  CollectionReference get _chatsCollection => firestore.collection('chats');

  /// Dohvati chatove korisnika (stream za real-time)
  Stream<List<Chat>> getUserChats(String userId) {
    return _chatsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chat.fromFirestore(
                  doc.data()! as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  /// Dohvati poruke za chat (stream za real-time)
  Stream<List<Message>> getChatMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  /// Posalji poruku
  Future<void> sendMessage({
    required String chatId,
    required Message message,
  }) async {
    // Dodaj poruku u subcollection
    await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .add(message.toFirestore());

    // Azuriraj chat sa zadnjom porukom
    await _chatsCollection.doc(chatId).update({
      'lastMessage': message.text,
      'lastMessageAt': message.createdAt.toIso8601String(),
      'lastMessageSenderId': message.senderId,
    });
  }

  /// Kreiraj novi chat ili vrati postojeci
  Future<String> getOrCreateChat({
    required String userId1,
    required String userName1,
    required String userId2,
    required String userName2,
  }) async {
    // Provjeri da li vec postoji chat izmedju ova dva korisnika
    final existingChats = await _chatsCollection
        .where('participantIds', arrayContains: userId1)
        .get();

    for (final doc in existingChats.docs) {
      final data = doc.data()! as Map<String, dynamic>;
      final participants =
          (data['participantIds'] as List<dynamic>).cast<String>();
      if (participants.contains(userId2)) {
        return doc.id; // Chat vec postoji
      }
    }

    // Kreiraj novi chat
    final chat = Chat(
      id: '',
      participantIds: [userId1, userId2],
      participantNames: {userId1: userName1, userId2: userName2},
      createdAt: DateTime.now(),
    );

    final docRef = await _chatsCollection.add(chat.toFirestore());
    return docRef.id;
  }
}
