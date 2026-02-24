import 'package:go_router/go_router.dart';

import '../features/common/auth/login_page.dart';
import '../features/common/auth/register_page.dart';
import '../features/common/home/home_page.dart';
import '../features/common/articles/articles_list_page.dart';
import '../features/common/articles/article_detail_page.dart';
import '../features/common/articles/create_artical_page.dart';
import '../features/common/articles/edit_article_page.dart';
import '../features/common/articles/my_articles_page.dart';
import '../features/common/user_profile/user_profile_page.dart';
import '../features/common/user_profile/edit_profile_page.dart';
import '../features/common/user_profile/other_user_profile_page.dart';
import '../features/common/chat/chat_list_page.dart';
import '../features/common/chat/chat_page.dart';
import 'app.routes.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const UserProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.articles,
        builder: (context, state) => const ArticlesListPage(),
      ),
      GoRoute(
        path: AppRoutes.articleDetail,
        builder: (context, state) {
          final articleId = state.pathParameters['id']!;
          return ArticleDetailPage(articleId: articleId);
        },
      ),
      GoRoute(
        path: AppRoutes.createArticle,
        builder: (context, state) => const CreateArticlePage(),
      ),
      GoRoute(
        path: AppRoutes.editArticle,
        builder: (context, state) {
          final articleId = state.pathParameters['id']!;
          return EditArticlePage(articleId: articleId);
        },
      ),
      GoRoute(
        path: AppRoutes.myArticles,
        builder: (context, state) => const MyArticlesPage(),
      ),
      GoRoute(
        path: AppRoutes.chatList,
        builder: (context, state) => const ChatListPage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final otherUserName = state.uri.queryParameters['name'] ?? '';
          return ChatPage(chatId: chatId, otherUserName: otherUserName);
        },
      ),
      GoRoute(
        path: AppRoutes.userProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return OtherUserProfilePage(userId: userId);
        },
      ),
    ],
  );
}
