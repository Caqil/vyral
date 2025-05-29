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

  static DioClient get dioClient {
    if (_sharedDioClient == null) {
      _sharedDioClient = DioClient();
      _sharedDioClient!.init(); // Initialize only once
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

  AuthBloc _createAuthBloc() {
    // Use shared DioClient instance
    final dio = dioClient; // This will create and init only once

    // Create data sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl(dio);
    final authLocalDataSource = AuthLocalDataSourceImpl(secureStorage);

    // Create repository
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

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
