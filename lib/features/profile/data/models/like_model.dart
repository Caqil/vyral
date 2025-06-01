import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/like_entity.dart';

part 'like_model.g.dart';

@JsonSerializable()
class LikeModel extends LikeEntity {
  const LikeModel({
    required super.id,
    required super.userId,
    required super.targetId,
    required super.targetType,
    required super.reactionType,
    required super.createdAt,
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
