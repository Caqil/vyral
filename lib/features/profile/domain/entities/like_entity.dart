import 'package:equatable/equatable.dart';

class LikeEntity extends Equatable {
  final String id;
  final String userId;
  final String targetId;
  final String targetType;
  final String reactionType;
  final DateTime createdAt;

  const LikeEntity({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.reactionType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        targetId,
        targetType,
        reactionType,
        createdAt,
      ];

  bool get isPostLike => targetType == 'post';
  bool get isCommentLike => targetType == 'comment';
}
