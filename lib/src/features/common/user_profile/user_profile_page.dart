import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../app_router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../app_user/data/repositories/user_repository.dart';
import '../bloc/user_profile_cubit.dart';
import '../bloc/user_profile_state.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Ako korisnik nije ulogovan, prikazi opciju za prijavu
        if (!authState.isAuthenticated || authState.user == null) {
          return _buildNotLoggedIn(context);
        }

        return BlocProvider(
          create: (_) => UserProfileCubit(
            userRepository: GetIt.instance<UserRepository>(),
          )..loadProfile(authState.user!.id),
          child: const _ProfileContent(),
        );
      },
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'Niste prijavljeni',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prijavite se da vidite svoj profil i pristupite svim funkcionalnostima.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fksBordo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text(
                    'PRIJAVI SE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return BlocBuilder<UserProfileCubit, UserProfileState>(
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
            body: const Center(child: Text('Greska pri ucitavanju profila')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Moj Profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push(AppRoutes.editProfile),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Odjava'),
                      content: const Text('Da li ste sigurni da se zelite odjaviti?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Ne'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AuthCubit>().signOut();
                            context.go(AppRoutes.login);
                          },
                          child: const Text('Da'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profilna slika i ime
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
                                  placeholder: (_, __) =>
                                      const CircularProgressIndicator(),
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
                        user.fullName.isEmpty ? 'Korisnik' : user.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Ocjene i datum registracije
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatChip(
                            icon: Icons.star,
                            label: user.averageRating.toStringAsFixed(1),
                          ),
                          const SizedBox(width: 16),
                          _StatChip(
                            icon: Icons.rate_review,
                            label: '${user.totalReviews} dojmova',
                          ),
                          const SizedBox(width: 16),
                          _StatChip(
                            icon: Icons.calendar_today,
                            label: DateFormat('dd.MM.yyyy').format(user.createdAt),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Detalji profila
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informacije',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoTile(
                        icon: Icons.person_outline,
                        label: 'Ime i prezime',
                        value: user.fullName.isEmpty
                            ? 'Nije postavljeno'
                            : user.fullName,
                      ),
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Telefon',
                        value: user.phoneNumber ?? 'Nije postavljeno',
                      ),
                      _InfoTile(
                        icon: Icons.cake_outlined,
                        label: 'Datum rodjenja',
                        value: user.dateOfBirth != null
                            ? DateFormat('dd.MM.yyyy').format(user.dateOfBirth!)
                            : 'Nije postavljeno',
                      ),
                      _InfoTile(
                        icon: Icons.wc_outlined,
                        label: 'Spol',
                        value: user.gender ?? 'Nije postavljeno',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF800000), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
