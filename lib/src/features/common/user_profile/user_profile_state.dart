import '../app_user/app_user_model.dart';

enum UserProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  error,
}

class UserProfileState {
  final UserProfileStatus status;
  final AppUser? user;
  final String? errorMessage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isLoading =>
      status == UserProfileStatus.loading ||
      status == UserProfileStatus.updating;

  UserProfileState copyWith({
    UserProfileStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
