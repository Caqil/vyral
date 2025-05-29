import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call(RegisterParams params) async {
    return await repository.register(
      username: params.username,
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      displayName: params.displayName,
      bio: params.bio,
      dateOfBirth: params.dateOfBirth,
      gender: params.gender,
      phone: params.phone,
    );
  }
}

class RegisterParams {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? displayName;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;

  RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.displayName,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.phone,
  });
}
