import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
class ReportPostUseCase {
  final PostsRepository repository;

  ReportPostUseCase(this.repository);

  Future<Either<Failure, void>> call(ReportPostParams params) async {
    return await repository.reportPost(
      params.postId,
      params.reason,
      params.description,
    );
  }
}

class ReportPostParams {
  final String postId;
  final String reason;
  final String? description;

  ReportPostParams({
    required this.postId,
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'target_id': postId,
      'target_type': 'post',
      'reason': reason,
    };

    if (description != null) {
      data['description'] = description;
    }

    return data;
  }
}
