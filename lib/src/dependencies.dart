import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'features/auth/data/data_sources/auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/app_user/data/data_sources/user_data_source.dart';
import 'features/app_user/data/repositories/user_repository.dart';
import 'features/articles/data/data_sources/articles_data_source.dart';
import 'features/articles/data/repositories/articles_repository.dart';
import 'features/chat/data/data_sources/chat_data_source.dart';
import 'features/chat/data/repositories/chat_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ---- Firebase instances ----
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final googleSignIn = GoogleSignIn();

  // ---- Data Sources ----
  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSource(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
    ),
  );

  getIt.registerLazySingleton<UserDataSource>(
    () => UserDataSource(
      firestore: firestore,
      storage: storage,
    ),
  );

  getIt.registerLazySingleton<ArticlesDataSource>(
    () => ArticlesDataSource(
      firestore: firestore,
      storage: storage,
    ),
  );

  getIt.registerLazySingleton<ChatDataSource>(
    () => ChatDataSource(
      firestore: firestore,
    ),
  );

  // ---- Repositories ----
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authDataSource: getIt<AuthDataSource>(),
      userDataSource: getIt<UserDataSource>(),
    ),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(
      userDataSource: getIt<UserDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ArticlesRepository>(
    () => ArticlesRepository(
      articlesDataSource: getIt<ArticlesDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepository(
      chatDataSource: getIt<ChatDataSource>(),
    ),
  );
}
