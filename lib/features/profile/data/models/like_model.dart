import 'package:json_annotation/json_annotation.dart';
part 'like_model.g.dart';

@JsonSerializable()
class LikeModel {
  final String id;
  final String userId;
  final String targetId;
  final String targetType;
  final String reactionType;
  final DateTime createdAt;

  const LikeModel({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.reactionType,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetId: json['target_id'] as String,
      targetType: json['target_type'] as String,
      reactionType: json['reaction_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$LikeModelToJson(this);
}
