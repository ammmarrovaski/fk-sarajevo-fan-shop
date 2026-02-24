import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/chat_repository.dart';
import '../../domain/models/message_model.dart';
import 'chat_state.dart';

class ChatMessageCubit extends Cubit<ChatMessageState> {
  final ChatRepository chatRepository;
  StreamSubscription<List<Message>>? _subscription;

  ChatMessageCubit({required this.chatRepository})
      : super(const ChatMessageState());

  /// Sluskaj poruke u chatu u real-time
  void listenToMessages(String chatId) {
    emit(state.copyWith(status: ChatStatus.loading));

    _subscription?.cancel();
    _subscription = chatRepository.getChatMessages(chatId).listen(
      (messages) {
        emit(state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Greska pri ucitavanju poruka.',
        ));
      },
    );
  }

  /// Posalji poruku
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      await chatRepository.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        text: text,
      );
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Greska pri slanju poruke.',
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
