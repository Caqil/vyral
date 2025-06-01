import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/app/app.dart';
import 'package:vyral/core/widgets/custom_text_field.dart';

class SocialLinksEditor extends StatefulWidget {
  final Map<String, String> socialLinks;
  final Function(Map<String, String>) onLinksChanged;

  const SocialLinksEditor({
    super.key,
    required this.socialLinks,
    required this.onLinksChanged,
  });

  @override
  State<SocialLinksEditor> createState() => _SocialLinksEditorState();
}

class _SocialLinksEditorState extends State<SocialLinksEditor> {
  late Map<String, String> _links;
  final Map<String, TextEditingController> _controllers = {};

  final List<SocialPlatform> _platforms = [
    SocialPlatform(
        'twitter', 'Twitter', LucideIcons.twitter, 'https://twitter.com/'),
    SocialPlatform('instagram', 'Instagram', LucideIcons.instagram,
        'https://instagram.com/'),
    SocialPlatform('linkedin', 'LinkedIn', LucideIcons.linkedin,
        'https://linkedin.com/in/'),
    SocialPlatform(
        'facebook', 'Facebook', LucideIcons.facebook, 'https://facebook.com/'),
    SocialPlatform(
        'youtube', 'YouTube', LucideIcons.youtube, 'https://youtube.com/@'),
    SocialPlatform(
        'github', 'GitHub', LucideIcons.github, 'https://github.com/'),
    SocialPlatform(
        'tiktok', 'TikTok', LucideIcons.music, 'https://tiktok.com/@'),
    SocialPlatform(
        'website', 'Personal Website', LucideIcons.globe, 'https://'),
  ];

  @override
  void initState() {
    super.initState();
    _links = Map<String, String>.from(widget.socialLinks);
    _initializeControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (final platform in _platforms) {
      final controller =
          TextEditingController(text: _links[platform.key] ?? '');
      controller.addListener(() => _updateLink(platform.key, controller.text));
      _controllers[platform.key] = controller;
    }
  }

  void _updateLink(String platform, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _links.remove(platform);
      } else {
        _links[platform] = value.trim();
      }
    });
    widget.onLinksChanged(_links);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Column(
      children: _platforms.map((platform) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CustomTextField(
            label: platform.name,
            controller: _controllers[platform.key],
            keyboardType: TextInputType.url,
            prefix: Icon(platform.icon, size: 16),
            placeholder: Text(platform.placeholder),
          ),
        );
      }).toList(),
    );
  }
}

class SocialPlatform {
  final String key;
  final String name;
  final IconData icon;
  final String placeholder;

  SocialPlatform(this.key, this.name, this.icon, this.placeholder);
}
