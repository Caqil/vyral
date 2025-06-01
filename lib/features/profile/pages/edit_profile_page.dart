import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../presentation/bloc/edit_profile_bloc.dart';
import '../presentation/bloc/edit_profile_event.dart';
import '../presentation/bloc/edit_profile_state.dart';
import '../presentation/widgets/profile_picture_editor.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  Map<String, String> _socialLinks = {};
  bool _isPrivate = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    context.read<EditProfileBloc>().add(const EditProfileLoadRequested());
    _setupControllerListeners();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _setupControllerListeners() {
    void markAsChanged() => setState(() => _hasUnsavedChanges = true);

    _firstNameController.addListener(markAsChanged);
    _lastNameController.addListener(markAsChanged);
    _displayNameController.addListener(markAsChanged);
    _bioController.addListener(markAsChanged);
    _websiteController.addListener(markAsChanged);
    _locationController.addListener(markAsChanged);
    _phoneController.addListener(markAsChanged);
  }

  void _populateFields(UserEntity user) {
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _displayNameController.text = user.displayName ?? '';
    _bioController.text = user.bio ?? '';
    _websiteController.text = user.website ?? '';
    _locationController.text = user.location ?? '';
    _phoneController.text = user.phone ?? '';
    _selectedDateOfBirth = user.dateOfBirth;
    _selectedGender = user.gender;
    _socialLinks = Map<String, String>.from(user.socialLinks ?? {});
    _isPrivate = user.isPrivate;
    _hasUnsavedChanges = false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) {
        if (!didPop && _hasUnsavedChanges) {
          _showDiscardChangesDialog();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar.simple(
          title: 'Edit Profile',
          automaticallyImplyLeading: true,
          actions: [
            BlocBuilder<EditProfileBloc, EditProfileState>(
              builder: (context, state) {
                return ShadButton.ghost(
                  onPressed: state.isLoading ? null : _saveProfile,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<EditProfileBloc, EditProfileState>(
          listener: (context, state) {
            if (state.user != null && !state.isInitialized) {
              _populateFields(state.user!);
              context
                  .read<EditProfileBloc>()
                  .add(const EditProfileInitialized());
            }

            if (state.isSuccess) {
              context.showSuccessSnackBar('Profile updated successfully');
              setState(() => _hasUnsavedChanges = false);
            }

            if (state.hasError) {
              context.showErrorSnackBar(
                  state.errorMessage ?? 'Failed to update profile');
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.user == null) {
              return const LoadingWidget(message: 'Loading profile...');
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Pictures Section
                    _buildProfilePicturesSection(state, colorScheme, theme),

                    const SizedBox(height: 32),

                    // Basic Information
                    _buildBasicInformationSection(colorScheme, theme),

                    const SizedBox(height: 32),

                    // Contact Information
                    _buildContactInformationSection(colorScheme, theme),

                    const SizedBox(height: 32),

                    // Social Links
                    _buildSocialLinksSection(colorScheme, theme),

                    const SizedBox(height: 32),

                    // Privacy Settings
                    _buildPrivacySection(colorScheme, theme),

                    const SizedBox(height: 32),

                    // Danger Zone
                    _buildDangerZone(colorScheme, theme),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfilePicturesSection(
    EditProfileState state,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Pictures',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Cover Picture Editor
          CoverPictureEditor(
            currentImageUrl: state.user?.coverPicture,
            onImageChanged: (imagePath) {
              setState(() => _hasUnsavedChanges = true);
              context.read<EditProfileBloc>().add(
                    EditProfileCoverPictureChanged(imagePath: imagePath),
                  );
            },
          ),

          const SizedBox(height: 16),

          // Profile Picture Editor
          ProfilePictureEditor(
            currentImageUrl: state.user?.profilePicture,
            userName: state.user?.displayName ?? state.user?.username ?? '',
            onImageChanged: (imagePath) {
              setState(() => _hasUnsavedChanges = true);
              context.read<EditProfileBloc>().add(
                    EditProfileProfilePictureChanged(imagePath: imagePath),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationSection(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  validator: (value) =>
                      Validators.validateName(value, fieldName: 'First name'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  validator: (value) =>
                      Validators.validateName(value, fieldName: 'Last name'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          CustomTextField(
            label: 'Display Name',
            controller: _displayNameController,
            validator: (value) =>
                Validators.validateRequired(value, fieldName: 'Display name'),
          ),

          const SizedBox(height: 16),

          CustomTextField.multiline(
            label: 'Bio',
            controller: _bioController,
            maxLength: 500,
            maxLines: 3,
            validator: (value) => Validators.validateBio(value),
          ),

          const SizedBox(height: 16),

          // Date of Birth Picker
          _buildDateOfBirthField(colorScheme, theme),

          const SizedBox(height: 16),

          // Gender Selector
          _buildGenderField(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildContactInformationSection(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) => Validators.validatePhone(value),
            prefix: const Icon(LucideIcons.phone, size: 16),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Website',
            controller: _websiteController,
            keyboardType: TextInputType.url,
            validator: (value) => Validators.validateUrl(value),
            prefix: const Icon(LucideIcons.globe, size: 16),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Location',
            controller: _locationController,
            validator: (value) => null, // Optional field
            prefix: const Icon(LucideIcons.mapPin, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksSection(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Links',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SocialLinksEditor(
            socialLinks: _socialLinks,
            onLinksChanged: (links) {
              setState(() {
                _socialLinks = links;
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Settings',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ShadCheckbox(
            value: _isPrivate,
            onChanged: (value) {
              setState(() {
                _isPrivate = value;
                _hasUnsavedChanges = true;
              });
            },
            label: const Text('Private Account'),
          ),
          const SizedBox(height: 8),
          Text(
            'When your account is private, only people you approve can see your posts and profile.',
            style: theme.textTheme.small?.copyWith(
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.destructive.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.destructive.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.destructive,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ShadButton.destructive(
            onPressed: _showDeactivateAccountDialog,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.userX, size: 16),
                SizedBox(width: 8),
                Text('Deactivate Account'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deactivating your account will hide your profile and content from other users.',
            style: theme.textTheme.small.copyWith(
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return GestureDetector(
      onTap: _selectDateOfBirth,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.calendar,
              size: 16,
              color: colorScheme.mutedForeground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: theme.textTheme.small?.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                  Text(
                    _selectedDateOfBirth?.displayDate ?? 'Select date',
                    style: theme.textTheme.small.copyWith(
                      color: _selectedDateOfBirth != null
                          ? colorScheme.foreground
                          : colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    const genderOptions = ['male', 'female', 'other', 'prefer_not_to_say'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: theme.textTheme.large.copyWith(
            color: colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: genderOptions.map((gender) {
            final isSelected = _selectedGender == gender;
            return ChoiceChip(
              label: Text(gender.replaceAll('_', ' ').capitalizeWords),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedGender = selected ? gender : null;
                  _hasUnsavedChanges = true;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate:
          DateTime.now().subtract(const Duration(days: 4745)), // 13 years ago
    );

    if (date != null) {
      setState(() {
        _selectedDateOfBirth = date;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<EditProfileBloc>().add(
            EditProfileSaveRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              displayName: _displayNameController.text.trim(),
              bio: _bioController.text.trim(),
              website: _websiteController.text.trim(),
              location: _locationController.text.trim(),
              phone: _phoneController.text.trim(),
              dateOfBirth: _selectedDateOfBirth,
              gender: _selectedGender,
              socialLinks: _socialLinks,
              isPrivate: _isPrivate,
            ),
          );
    }
  }

  void _showDiscardChangesDialog() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Discard Changes?'),
        description: const Text(
            'You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateAccountDialog() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Deactivate Account'),
        description: const Text(
          'Are you sure you want to deactivate your account? This action will hide your profile and content from other users.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              // Handle account deactivation
              context.read<EditProfileBloc>().add(
                    const EditProfileDeactivateRequested(),
                  );
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}
