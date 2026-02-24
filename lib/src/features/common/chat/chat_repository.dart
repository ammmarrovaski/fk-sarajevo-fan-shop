import '../data_sources/chat_data_source.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/models/message_model.dart';

class ChatRepository {
  final ChatDataSource chatDataSource;

  ChatRepository({required this.chatDataSource});

  /// Stream chatova za korisnika
  Stream<List<Chat>> getUserChats(String userId) {
    return chatDataSource.getUserChats(userId);
  }

  /// Stream poruka u chatu
  Stream<List<Message>> getChatMessages(String chatId) {
    return chatDataSource.getChatMessages(chatId);
  }

  /// Posalji poruku
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final message = Message(
      id: '',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: DateTime.now(),
    );

    await chatDataSource.sendMessage(chatId: chatId, message: message);
  }

  /// Dohvati ili kreiraj chat
  Future<String> getOrCreateChat({
    required String userId1,
    required String userName1,
    required String userId2,
    required String userName2,
  }) async {
    return await chatDataSource.getOrCreateChat(
      userId1: userId1,
      userName1: userName1,
      userId2: userId2,
      userName2: userName2,
    );
  }
}
