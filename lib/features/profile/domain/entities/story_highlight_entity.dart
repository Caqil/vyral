import 'package:equatable/equatable.dart';

class StoryHighlightEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? coverImageUrl;
  final List<String> storyIds;
  final int viewsCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoryHighlightEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.coverImageUrl,
    required this.storyIds,
    this.viewsCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        coverImageUrl,
        storyIds,
        viewsCount,
        isActive,
        createdAt,
        updatedAt,
      ];

  int get storiesCount => storyIds.length;
}
