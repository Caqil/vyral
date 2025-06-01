// Updated main.dart - Simple solution

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vyral/core/storage/secure_storage.dart';
import 'app/app.dart';
import 'core/storage/cache_manager.dart';
import 'core/storage/shared_preferences_helper.dart';
import 'core/network/dio_client.dart';

// Auth imports
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/refresh_token_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/verify_email_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Profile imports
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/datasources/posts_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/data/repositories/posts_repository_impl.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/domain/usecases/get_user_by_username_usecase.dart';
import 'features/profile/domain/usecases/get_user_stats_usecase.dart';
import 'features/profile/domain/usecases/get_follow_status_usecase.dart';
import 'features/profile/domain/usecases/follow_user_usecase.dart';
import 'features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'features/profile/domain/usecases/get_user_posts_usecase.dart';
import 'features/profile/domain/usecases/get_user_media_usecase.dart';
import 'features/profile/domain/usecases/get_user_highlights_usecase.dart';
import 'features/profile/domain/usecases/get_followers_usecase.dart';
import 'features/profile/domain/usecases/get_following_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/upload_profile_picture_usecase.dart';
import 'features/profile/domain/usecases/upload_cover_picture_usecase.dart';

// Post use cases
import 'features/profile/domain/usecases/get_post_usecase.dart';
import 'features/profile/domain/usecases/get_post_comments_usecase.dart';
import 'features/profile/domain/usecases/like_post_usecase.dart';
import 'features/profile/domain/usecases/create_comment_usecase.dart';
import 'features/profile/domain/usecases/like_comment_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize storage
  await SecureStorage.init();
  await SharedPreferencesHelper.init();
  await CacheManager.init();

  runApp(const SocialNetworkApp());
}

class SocialNetworkApp extends StatelessWidget {
  const SocialNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => _createAuthBloc(),
        ),
      ],
      child: const App(),
    );
  }

  // Create shared dependencies
  static DioClient? _sharedDioClient;
  static SecureStorage? _sharedSecureStorage;
  static CacheManager? _sharedCacheManager;

  // Auth related
  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthLocalDataSource? _authLocalDataSource;
  static AuthRepositoryImpl? _authRepository;

  // Profile related
  static ProfileRemoteDataSource? _profileRemoteDataSource;
  static ProfileRepositoryImpl? _profileRepository;

  // Posts related
  static PostsRemoteDataSource? _postsRemoteDataSource;
  static PostsRepositoryImpl? _postsRepository;

  // SIMPLE: Store current user ID in memory
  static String? _currentUserId;

  static DioClient get dioClient {
    if (_sharedDioClient == null) {
      _sharedDioClient = DioClient();
      _sharedDioClient!.init();
    }
    return _sharedDioClient!;
  }

  static SecureStorage get secureStorage {
    _sharedSecureStorage ??= SecureStorage();
    return _sharedSecureStorage!;
  }

  static CacheManager get cacheManager {
    _sharedCacheManager ??= CacheManager();
    return _sharedCacheManager!;
  }

  // Auth Repository
  static AuthRepositoryImpl get authRepository {
    if (_authRepository == null) {
      _authRemoteDataSource ??= AuthRemoteDataSourceImpl(dioClient);
      _authLocalDataSource ??= AuthLocalDataSourceImpl(secureStorage);
      _authRepository = AuthRepositoryImpl(
        remoteDataSource: _authRemoteDataSource!,
        localDataSource: _authLocalDataSource!,
      );
    }
    return _authRepository!;
  }

  // Profile Repository
  static ProfileRepositoryImpl get profileRepository {
    if (_profileRepository == null) {
      _profileRemoteDataSource ??= ProfileRemoteDataSourceImpl(dioClient);
      _profileRepository = ProfileRepositoryImpl(
        remoteDataSource: _profileRemoteDataSource!,
        getCurrentUserId: getCurrentUserId, // Simple sync function
      );
    }
    return _profileRepository!;
  }

  // Posts Repository
  static PostsRepositoryImpl get postsRepository {
    if (_postsRepository == null) {
      _postsRemoteDataSource ??= PostsRemoteDataSourceImpl(dioClient);
      _postsRepository = PostsRepositoryImpl(
        remoteDataSource: _postsRemoteDataSource!,
      );
    }
    return _postsRepository!;
  }

  // SIMPLE: Get current user ID (synchronous)
  static String? getCurrentUserId() {
    return _currentUserId;
  }

  // SIMPLE: Set user ID after login
  static void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  static void clearCurrentUserId() {
    _currentUserId = null;
  }

  // Helper method to get current user ID with context (for widgets)
  static String? getCurrentUserIdWithContext(BuildContext context) {
    try {
      final authBloc = context.read<AuthBloc>();
      return authBloc.state.user?.id;
    } catch (e) {
      // Fallback to stored value
      return getCurrentUserId();
    }
  }

  // Profile Use Cases
  static GetUserProfileUseCase getUserProfileUseCase() =>
      GetUserProfileUseCase(profileRepository);
  static GetUserByUsernameUseCase getUserByUsernameUseCase() =>
      GetUserByUsernameUseCase(profileRepository);
  static GetUserStatsUseCase getUserStatsUseCase() =>
      GetUserStatsUseCase(profileRepository);
  static GetFollowStatusUseCase getFollowStatusUseCase() =>
      GetFollowStatusUseCase(profileRepository);
  static FollowUserUseCase getFollowUserUseCase() =>
      FollowUserUseCase(profileRepository);
  static UnfollowUserUseCase getUnfollowUserUseCase() =>
      UnfollowUserUseCase(profileRepository);
  static GetUserPostsUseCase getUserPostsUseCase() =>
      GetUserPostsUseCase(profileRepository);
  static GetUserMediaUseCase getUserMediaUseCase() =>
      GetUserMediaUseCase(profileRepository);
  static GetUserHighlightsUseCase getUserHighlightsUseCase() =>
      GetUserHighlightsUseCase(profileRepository);
  static GetFollowersUseCase getFollowersUseCase() =>
      GetFollowersUseCase(profileRepository);
  static GetFollowingUseCase getFollowingUseCase() =>
      GetFollowingUseCase(profileRepository);
  static UpdateProfileUseCase getUpdateProfileUseCase() =>
      UpdateProfileUseCase(profileRepository);
  static UploadProfilePictureUseCase getUploadProfilePictureUseCase() =>
      UploadProfilePictureUseCase(profileRepository);
  static UploadCoverPictureUseCase getUploadCoverPictureUseCase() =>
      UploadCoverPictureUseCase(profileRepository);

  // Post Use Cases
  static GetPostUseCase getPostUseCase() => GetPostUseCase(postsRepository);
  static GetPostCommentsUseCase getPostCommentsUseCase() =>
      GetPostCommentsUseCase(postsRepository);
  static LikePostUseCase getLikePostUseCase() =>
      LikePostUseCase(postsRepository);
  static CreateCommentUseCase getCreateCommentUseCase() =>
      CreateCommentUseCase(postsRepository);
  static LikeCommentUseCase getLikeCommentUseCase() =>
      LikeCommentUseCase(postsRepository);

  AuthBloc _createAuthBloc() {
    // Create use cases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final refreshTokenUseCase = RefreshTokenUseCase(authRepository);
    final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    final verifyEmailUseCase = VerifyEmailUseCase(authRepository);

    // Create and return AuthBloc
    return AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      refreshTokenUseCase: refreshTokenUseCase,
      forgotPasswordUseCase: forgotPasswordUseCase,
      verifyEmailUseCase: verifyEmailUseCase,
      authRepository: authRepository,
    );
  }
}
