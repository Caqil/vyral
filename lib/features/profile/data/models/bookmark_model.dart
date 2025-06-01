import 'package:json_annotation/json_annotation.dart';

part 'bookmark_model.g.dart';

@JsonSerializable()
class BookmarkModel {
  final String id;
  final String userId;
  final String postId;
  final DateTime createdAt;

  const BookmarkModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$BookmarkModelToJson(this);
}
