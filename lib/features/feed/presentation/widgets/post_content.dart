import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';

class PostContent extends StatefulWidget {
  final String content;
  final List<String> hashtags;
  final List<UserEntity> mentions;
  final int maxLines;

  const PostContent({
    super.key,
    required this.content,
    this.hashtags = const [],
    this.mentions = const [],
    this.maxLines = 6,
  });

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContent(theme),
          if (widget.hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildHashtags(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final textStyle = theme.textTheme.bodyLarge;
    final content = widget.content;

    // Check if content needs to be truncated
    final textSpan = TextSpan(text: content, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);

    final needsTruncation = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          style: textStyle,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (needsTruncation) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'Show less' : 'Show more',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHashtags(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widget.hashtags.map((hashtag) {
        return GestureDetector(
          onTap: () => _handleHashtagTap(hashtag),
          child: Text(
            '#$hashtag',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleHashtagTap(String hashtag) {
    // Navigate to hashtag page
  }
}
