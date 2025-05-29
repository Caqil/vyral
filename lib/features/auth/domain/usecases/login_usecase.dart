import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    return await repository.login(
      emailOrUsername: params.emailOrUsername,
      password: params.password,
      deviceInfo: params.deviceInfo,
    );
  }
}

class LoginParams {
  final String emailOrUsername;
  final String password;
  final String? deviceInfo;

  LoginParams({
    required this.emailOrUsername,
    required this.password,
    this.deviceInfo,
  });
}
