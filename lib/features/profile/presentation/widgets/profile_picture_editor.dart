// lib/features/profile/presentation/widgets/profile_picture_editor.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/avatar_widget.dart';

class ProfilePictureEditor extends StatefulWidget {
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
  State<ProfilePictureEditor> createState() => _ProfilePictureEditorState();
}

class _ProfilePictureEditorState extends State<ProfilePictureEditor> {
  String? _tempImagePath;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture',
          style: theme.textTheme.large.copyWith(
            color: colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Profile Picture Preview
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.border,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildProfileImage(),
                  ),
                ),

                // Upload Indicator
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),

                // Edit Button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ShadButton.ghost(
                    onPressed: _showImageOptions,
                    size: ShadButtonSize.sm,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.background,
                          width: 2,
                        ),
                      ),
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

            const SizedBox(width: 20),

            // Options
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadButton.outline(
                    onPressed: _showImageOptions,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.image, size: 16),
                        SizedBox(width: 8),
                        Text('Change Picture'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.currentImageUrl != null || _tempImagePath != null)
                    ShadButton.ghost(
                      onPressed: _removeImage,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.trash2, size: 16),
                          SizedBox(width: 8),
                          Text('Remove Picture'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Recommended: Square image, at least 400×400 pixels',
                    style: theme.textTheme.small.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_tempImagePath != null) {
      // Show temp image (you'd typically use Image.file here)
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.person, size: 40),
      );
    } else if (widget.currentImageUrl != null &&
        widget.currentImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.currentImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(),
      );
    } else {
      return _buildFallbackAvatar();
    }
  }

  Widget _buildFallbackAvatar() {
    return AvatarWidget(
      name: widget.userName,
      size: 96,
    );
  }

  void _showImageOptions() {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Change Profile Picture'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (widget.currentImageUrl != null || _tempImagePath != null)
              ListTile(
                leading: const Icon(LucideIcons.trash2),
                title: const Text('Remove Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() => _isUploading = true);

    try {
      // Simulate camera capture and upload
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you'd use image_picker and upload the file
      final imagePath = 'temp_camera_image_path.jpg';
      setState(() => _tempImagePath = imagePath);
      widget.onImageChanged(imagePath);

      if (mounted) {
        context.showSuccessSnackBar(context,'Profile picture updated');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context,'Failed to take photo');
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isUploading = true);

    try {
      // Simulate gallery pick and upload
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you'd use image_picker and upload the file
      final imagePath = 'temp_gallery_image_path.jpg';
      setState(() => _tempImagePath = imagePath);
      widget.onImageChanged(imagePath);

      if (mounted) {
        context.showSuccessSnackBar(context,'Profile picture updated');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context,'Failed to pick image');
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _removeImage() {
    setState(() => _tempImagePath = null);
    widget.onImageChanged(null);
    context.showSuccessSnackBar(context,'Profile picture removed');
  }
}

// lib/features/profile/presentation/widgets/cover_picture_editor.dart
class CoverPictureEditor extends StatefulWidget {
  final String? currentImageUrl;
  final Function(String?) onImageChanged;

  const CoverPictureEditor({
    super.key,
    this.currentImageUrl,
    required this.onImageChanged,
  });

  @override
  State<CoverPictureEditor> createState() => _CoverPictureEditorState();
}

class _CoverPictureEditorState extends State<CoverPictureEditor> {
  String? _tempImagePath;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Picture',
          style: theme.textTheme.large.copyWith(
            color: colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Cover Picture Preview
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Cover Image
                Positioned.fill(
                  child: _buildCoverImage(colorScheme),
                ),

                // Upload Indicator
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Action Buttons
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      ShadButton.ghost(
                        onPressed: _showImageOptions,
                        size: ShadButtonSize.sm,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      if (widget.currentImageUrl != null ||
                          _tempImagePath != null) ...[
                        const SizedBox(width: 8),
                        ShadButton.ghost(
                          onPressed: _removeImage,
                          size: ShadButtonSize.sm,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.trash2,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Instructions
                if (widget.currentImageUrl == null && _tempImagePath == null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.muted.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.image,
                              size: 32,
                              color: colorScheme.mutedForeground,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add cover photo',
                              style: theme.textTheme.small.copyWith(
                                color: colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Recommended: 1200×400 pixels. This will be displayed at the top of your profile.',
          style: theme.textTheme.small.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage(ShadColorScheme colorScheme) {
    if (_tempImagePath != null) {
      // Show temp image (you'd typically use Image.file here)
      return Container(
        color: Colors.blue[100],
        child: const Center(
          child: Icon(Icons.landscape, size: 40),
        ),
      );
    } else if (widget.currentImageUrl != null &&
        widget.currentImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.currentImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: colorScheme.muted,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.8),
                colorScheme.secondary.withOpacity(0.6),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.8),
              colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
      );
    }
  }

  void _showImageOptions() {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Change Cover Picture'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (widget.currentImageUrl != null || _tempImagePath != null)
              ListTile(
                leading: const Icon(LucideIcons.trash2),
                title: const Text('Remove Cover'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() => _isUploading = true);

    try {
      // Simulate camera capture and upload
      await Future.delayed(const Duration(seconds: 2));

      final imagePath = 'temp_cover_camera_path.jpg';
      setState(() => _tempImagePath = imagePath);
      widget.onImageChanged(imagePath);

      if (mounted) {
        context.showSuccessSnackBar(context,'Cover picture updated');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context,'Failed to take photo');
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isUploading = true);

    try {
      // Simulate gallery pick and upload
      await Future.delayed(const Duration(seconds: 2));

      final imagePath = 'temp_cover_gallery_path.jpg';
      setState(() => _tempImagePath = imagePath);
      widget.onImageChanged(imagePath);

      if (mounted) {
        context.showSuccessSnackBar(context,'Cover picture updated');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context,'Failed to pick image');
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _removeImage() {
    setState(() => _tempImagePath = null);
    widget.onImageChanged(null);
    context.showSuccessSnackBar(context,'Cover picture removed');
  }
}
