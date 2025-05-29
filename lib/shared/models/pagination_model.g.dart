// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationModel _$PaginationModelFromJson(Map<String, dynamic> json) =>
    PaginationModel(
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      skip: (json['skip'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
      hasNext: json['has_next'] as bool?,
      hasPrev: json['has_prev'] as bool?,
    );

Map<String, dynamic> _$PaginationModelToJson(PaginationModel instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'skip': instance.skip,
      'total': instance.total,
      'total_pages': instance.totalPages,
      'has_next': instance.hasNext,
      'has_prev': instance.hasPrev,
    };
