import '../../domain/models/chat_model.dart';
import '../../domain/models/message_model.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  error,
}

class ChatListState {
  final ChatStatus status;
  final List<Chat> chats;
  final String? errorMessage;

  const ChatListState({
    this.status = ChatStatus.initial,
    this.chats = const [],
    this.errorMessage,
  });

  ChatListState copyWith({
    ChatStatus? status,
    List<Chat>? chats,
    String? errorMessage,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: errorMessage,
    );
  }
}

class ChatMessageState {
  final ChatStatus status;
  final List<Message> messages;
  final String? errorMessage;

  const ChatMessageState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  ChatMessageState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    String? errorMessage,
  }) {
    return ChatMessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}
