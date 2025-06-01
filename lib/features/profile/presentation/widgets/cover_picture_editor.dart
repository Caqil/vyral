import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/app/app.dart';

class CoverPictureEditor extends StatelessWidget {
  final String? currentImageUrl;
  final Function(String?) onImageChanged;

  const CoverPictureEditor({
    super.key,
    this.currentImageUrl,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Photo',
          style: theme.textTheme.large?.copyWith(
            color: colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Cover Image Preview
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.border),
          ),
          child: Stack(
            children: [
              // Current Cover Image
              if (currentImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    currentImageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(colorScheme),
                  ),
                )
              else
                _buildPlaceholder(colorScheme),

              // Edit Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: ShadButton.outline(
                      onPressed: _showCoverOptions,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.camera,
                            color: colorScheme.background,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentImageUrl != null ? 'Change' : 'Add Cover',
                            style: TextStyle(color: colorScheme.background),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Action Buttons
        Row(
          children: [
            ShadButton.outline(
              onPressed: _pickImage,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.upload, size: 16),
                  SizedBox(width: 8),
                  Text('Upload'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (currentImageUrl != null)
              ShadButton.destructive(
                onPressed: () => onImageChanged(null),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.trash, size: 16),
                    SizedBox(width: 8),
                    Text('Remove'),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          'Recommended: 1500x500 pixels',
          style: theme.textTheme.small?.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ShadColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 32,
          color: colorScheme.mutedForeground,
        ),
      ),
    );
  }

  void _showCoverOptions() {
    // Show options: Gallery, Remove
  }

  void _pickImage() {
    // Open image picker
    // For demo, simulate image selection
    onImageChanged('https://example.com/new-cover-pic.jpg');
  }
}
