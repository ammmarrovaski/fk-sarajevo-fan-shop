import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'features/common/auth/auth_data_source.dart';
import 'features/common/auth/auth_repository.dart';
import 'features/common/app_user/user_data_source.dart';
import 'features/common/app_user/user_repository.dart';
import 'features/common/articles/articles_data_source.dart';
import 'features/common/articles/articles_repository.dart';
import 'features/common/chat/chat_data_source.dart';
import 'features/common/chat/chat_repository.dart';

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
