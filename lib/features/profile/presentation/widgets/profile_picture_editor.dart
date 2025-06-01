// lib/features/profile/presentation/widgets/profile_picture_editor.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/avatar_widget.dart';

class ProfilePictureEditor extends StatelessWidget {
  final String? currentImageUrl;
  final String userName;
  final Function(String?) onImageChanged;

  const ProfilePictureEditor({
    super.key,
    this.currentImageUrl,
    required this.userName,
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
          'Profile Picture',
          style: theme.textTheme.large?.copyWith(
            color: colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Current Avatar
            Stack(
              children: [
                AvatarWidget(
                  imageUrl: currentImageUrl,
                  name: userName,
                  size: 80,
                ),

                // Edit Button Overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.background,
                        width: 2,
                      ),
                    ),
                    child: ShadButton.ghost(
                      onPressed: _showImageOptions,
                      size: ShadButtonSize.sm,
                      child: Icon(
                        LucideIcons.camera,
                        color: colorScheme.primaryForeground,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Action Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadButton(
                    onPressed: _pickImage,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.upload, size: 16),
                        SizedBox(width: 8),
                        Text('Upload Photo'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Recommended: Square image, at least 400x400 pixels',
          style: theme.textTheme.small?.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _showImageOptions() {
    // Show options: Camera, Gallery, Remove
  }

  void _pickImage() {
    // Open image picker
    // For demo, simulate image selection
    onImageChanged('https://example.com/new-profile-pic.jpg');
  }
}
