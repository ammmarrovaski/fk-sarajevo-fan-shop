import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import 'chat_repository.dart';
import 'chat_model.dart';
import 'chat_list_cubit.dart';
import 'chat_state.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated || authState.user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Poruke')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prijavite se da vidite poruke',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocProvider(
          create: (_) => ChatListCubit(
            chatRepository: GetIt.instance<ChatRepository>(),
          )..listenToChats(authState.user!.id),
          child: _ChatListContent(currentUserId: authState.user!.id),
        );
      },
    );
  }
}

class _ChatListContent extends StatelessWidget {
  final String currentUserId;

  const _ChatListContent({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poruke')),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nemate poruka',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Poruke ce se pojaviti kada kontaktirate prodavaca.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: state.chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _ChatTile(
                chat: state.chats[index],
                currentUserId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final String currentUserId;

  const _ChatTile({required this.chat, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);
    final otherName = chat.otherParticipantName(currentUserId);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: fksBordo,
        child: Text(
          otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        otherName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: chat.lastMessage != null
          ? Text(
              chat.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            )
          : null,
      trailing: chat.lastMessageAt != null
          ? Text(
              _formatTime(chat.lastMessageAt!),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            )
          : null,
      onTap: () => context.push('/chats/${chat.id}'),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (diff.inDays == 1) {
      return 'Jucer';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd.MM').format(dateTime);
    }
  }
}
