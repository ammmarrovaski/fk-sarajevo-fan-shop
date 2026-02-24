import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../auth/auth_cubit.dart';
import 'chat_repository.dart';
import 'message_model.dart';
import 'chat_message_cubit.dart';
import 'chat_state.dart';

class ChatPage extends StatelessWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatMessageCubit(
        chatRepository: GetIt.instance<ChatRepository>(),
      )..listenToMessages(chatId),
      child: _ChatContent(chatId: chatId),
    );
  }
}

class _ChatContent extends StatefulWidget {
  final String chatId;

  const _ChatContent({required this.chatId});

  @override
  State<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<_ChatContent> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          // Poruke
          Expanded(
            child: BlocConsumer<ChatMessageCubit, ChatMessageState>(
              listener: (context, state) {
                // Auto-scroll na dno kada dodju nove poruke
                if (state.messages.isNotEmpty && _scrollController.hasClients) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  });
                }
              },
              builder: (context, state) {
                if (state.status == ChatStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Pocnite razgovor!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.senderId == currentUserId;

                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // Input polje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Napisi poruku...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: fksBordo,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(currentUserId, authState.user?.fullName ?? ''),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String senderId, String senderName) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatMessageCubit>().sendMessage(
          chatId: widget.chatId,
          senderId: senderId,
          senderName: senderName,
          text: text,
        );

    _messageController.clear();
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? fksBordo : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(
                  color: isMe ? Colors.white60 : Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
