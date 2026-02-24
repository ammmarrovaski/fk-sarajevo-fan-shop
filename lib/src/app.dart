import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'flavor_config/flavors.dart';
import 'app_router/app_pages.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authRepository: GetIt.instance<AuthRepository>(),
          )..checkAuthStatus(),
        ),
      ],
      child: MaterialApp.router(
        title: F.title,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        routerConfig: router,
      ),
    );
  }

  ThemeData _buildTheme() {
    const Color fksBordo = Color(0xFF800000);
    const Color fksBijela = Colors.white;

    return ThemeData(
      primaryColor: fksBordo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: fksBordo,
        primary: fksBordo,
        onPrimary: fksBijela,
        surface: fksBijela,
        onSurface: const Color(0xFF1A1A1A),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: fksBordo,
        foregroundColor: fksBijela,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: fksBordo,
          foregroundColor: fksBijela,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fksBordo, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: fksBordo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
