import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';

import '../../domain/entities/story_highlight_entity.dart';

class ProfileHighlights extends StatelessWidget {
  final List<StoryHighlightEntity> highlights;
  final Function(String) onHighlightPressed;

  const ProfileHighlights({
    super.key,
    required this.highlights,
    required this.onHighlightPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: highlights.length,
        itemBuilder: (context, index) {
          final highlight = highlights[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => onHighlightPressed(highlight.id),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: highlight.coverImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: highlight.coverImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: colorScheme.muted,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: colorScheme.muted,
                                child: Icon(
                                  LucideIcons.image,
                                  color: colorScheme.mutedForeground,
                                ),
                              ),
                            )
                          : Container(
                              color: colorScheme.muted,
                              child: Icon(
                                LucideIcons.bookmark,
                                color: colorScheme.mutedForeground,
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 64,
                    child: Text(
                      highlight.title,
                      style: theme.textTheme.small.copyWith(
                        color: colorScheme.foreground,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
