import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class ReportUserUseCase {
  final ProfileRepository repository;

  ReportUserUseCase(this.repository);

  Future<Either<Failure, void>> call(ReportUserParams params) async {
    // This would be implemented in a separate reporting service/repository
    throw UnimplementedError('Report user functionality not implemented');
  }
}

class ReportUserParams {
  final String userId;
  final String reason;
  final String? description;

  ReportUserParams({
    required this.userId,
    required this.reason,
    this.description,
  });
}
