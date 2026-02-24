import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_model.dart';
import 'chat_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository chatRepository;
  StreamSubscription<List<Chat>>? _subscription;

  ChatListCubit({required this.chatRepository})
      : super(const ChatListState());

  /// Sluskaj chatove korisnika u real-time
  void listenToChats(String userId) {
    emit(state.copyWith(status: ChatStatus.loading));

    _subscription?.cancel();
    _subscription = chatRepository.getUserChats(userId).listen(
      (chats) {
        emit(state.copyWith(
          status: ChatStatus.loaded,
          chats: chats,
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
