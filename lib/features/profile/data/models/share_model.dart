import 'package:json_annotation/json_annotation.dart';

part 'share_model.g.dart';

@JsonSerializable()
class ShareModel {
  final String id;
  final String userId;
  final String postId;
  final String shareType;
  final String? message;
  final DateTime createdAt;

  const ShareModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.shareType,
    this.message,
    required this.createdAt,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      shareType: json['share_type'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$ShareModelToJson(this);
}
