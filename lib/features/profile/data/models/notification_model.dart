import 'package:json_annotation/json_annotation.dart';
part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String recipientId;
  final String? actorId;
  final String type;
  final String title;
  final String message;
  final String? actionText;
  final String? targetId;
  final String? targetType;
  final String? targetUrl;
  final String priority;
  final bool isRead;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    this.actorId,
    required this.type,
    required this.title,
    required this.message,
    this.actionText,
    this.targetId,
    this.targetType,
    this.targetUrl,
    required this.priority,
    this.isRead = false,
    this.isArchived = false,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      actorId: json['actor_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      actionText: json['action_text'] as String?,
      targetId: json['target_id'] as String?,
      targetType: json['target_type'] as String?,
      targetUrl: json['target_url'] as String?,
      priority: json['priority'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
