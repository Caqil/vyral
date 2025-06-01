// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      actorId: json['actorId'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      actionText: json['actionText'] as String?,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
      targetUrl: json['targetUrl'] as String?,
      priority: json['priority'] as String,
      isRead: json['isRead'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'actorId': instance.actorId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'actionText': instance.actionText,
      'targetId': instance.targetId,
      'targetType': instance.targetType,
      'targetUrl': instance.targetUrl,
      'priority': instance.priority,
      'isRead': instance.isRead,
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };
