import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../app_user/user_repository.dart';
import 'user_profile_cubit.dart';
import 'user_profile_state.dart';

/// Prikaz profila drugog korisnika (read-only)
class OtherUserProfilePage extends StatelessWidget {
  final String userId;

  const OtherUserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return BlocProvider(
      create: (_) => UserProfileCubit(
        userRepository: GetIt.instance<UserRepository>(),
      )..loadProfile(userId),
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profil')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final user = state.user;
          if (user == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profil')),
              body: const Center(child: Text('Korisnik nije pronadjen.')),
            );
          }

          return Scaffold(
            appBar: AppBar(title: Text(user.fullName)),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: fksBordo,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: user.profileImageUrl != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.profileImageUrl!,
                                    width: 106,
                                    height: 106,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: fksBordo,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${user.averageRating.toStringAsFixed(1)} (${user.totalReviews} dojmova)',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Clan od ${DateFormat('dd.MM.yyyy').format(user.createdAt)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Ovdje se moze dodati lista artikala ovog korisnika
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Artikli ovog korisnika ce biti prikazani ovdje.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
