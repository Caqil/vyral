import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

@JsonSerializable()
class PaginationModel {
  final int? page;
  final int? limit;
  final int? skip;
  final int? total;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'has_next')
  final bool? hasNext;
  @JsonKey(name: 'has_prev')
  final bool? hasPrev;

  const PaginationModel({
    this.page,
    this.limit,
    this.skip,
    this.total,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);

  PaginationModel copyWith({
    int? page,
    int? limit,
    int? skip,
    int? total,
    int? totalPages,
    bool? hasNext,
    bool? hasPrev,
  }) {
    return PaginationModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      skip: skip ?? this.skip,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrev: hasPrev ?? this.hasPrev,
    );
  }
}
