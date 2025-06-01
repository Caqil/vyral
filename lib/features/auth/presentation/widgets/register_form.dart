import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;
  DateTime? _dateOfBirth;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the terms and conditions'),
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName:
                  '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
              bio: _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
              dateOfBirth: _dateOfBirth,
              gender: _selectedGender,
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            ),
          );
    }
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(const Duration(days: 365 * 18)), // 18 years ago
      firstDate: DateTime.now()
          .subtract(const Duration(days: 365 * 120)), // 120 years ago
      lastDate: DateTime.now()
          .subtract(const Duration(days: 365 * 13)), // 13 years ago
      helpText: 'Select your date of birth',
    );

    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Name and Last Name
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  placeholder: Text('Enter first name'),
                  prefix: const Icon(Icons.person_outline),
                  validator: (value) =>
                      Validators.validateName(value, fieldName: 'First name'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  placeholder: Text('Enter last name'),
                  prefix: const Icon(Icons.person_outline),
                  validator: (value) =>
                      Validators.validateName(value, fieldName: 'Last name'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Username
          CustomTextField(
            controller: _usernameController,
            label: 'Username',
            placeholder: Text('Choose a unique username'),
            prefix: const Icon(Icons.alternate_email),
            validator: Validators.validateUsername,
          ),

          const SizedBox(height: 16),

          // Email
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            placeholder: Text('Enter your email'),
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(Icons.email_outlined),
            validator: Validators.validateEmail,
          ),

          const SizedBox(height: 16),

          // Password
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            placeholder: Text('Create a strong password'),
            obscureText: true,
            prefix: const Icon(Icons.lock_outline),
            validator: Validators.validatePassword,
          ),

          const SizedBox(height: 16),

          // Confirm Password
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            placeholder: Text('Confirm your password'),
            obscureText: true,
            prefix: const Icon(Icons.lock_outline),
            validator: (value) => Validators.validateConfirmPassword(
              _passwordController.text,
              value,
            ),
          ),

          const SizedBox(height: 16),

          // Phone (Optional)
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number (Optional)',
            placeholder: Text('Enter your phone number'),
            keyboardType: TextInputType.phone,
            prefix: const Icon(Icons.phone_outlined),
            validator: Validators.validatePhone,
          ),

          const SizedBox(height: 16),

          // Date of Birth (Optional)
          InkWell(
            onTap: _selectDateOfBirth,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date of Birth (Optional)',
                hintText: 'Select your date of birth',
                prefix: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _dateOfBirth?.toString().split(' ')[0] ?? 'Select date',
                style: _dateOfBirth != null
                    ? theme.textTheme.bodyLarge
                    : theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Gender (Optional)
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Gender (Optional)',
              prefix: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
              DropdownMenuItem(
                  value: 'prefer_not_to_say', child: Text('Prefer not to say')),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
          ),

          const SizedBox(height: 16),

          // Bio (Optional)
          CustomTextField(
            controller: _bioController,
            label: 'Bio (Optional)',
            placeholder: Text('Tell us about yourself'),
            maxLines: 3,
            prefix: const Icon(Icons.description_outlined),
            validator: Validators.validateBio,
            onChanged: (_) => _handleSubmit(),
          ),

          const SizedBox(height: 24),

          // Terms and Conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) =>
                    setState(() => _acceptTerms = value ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Register button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return CustomButton(
                text: 'Create Account',
                onPressed: _handleSubmit,
                isLoading: state.isLoading,
                isFullWidth: true,
                icon: Icons.person_add_rounded,
              );
            },
          ),

          const SizedBox(height: 24),

          // Validation errors display
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.hasValidationErrors) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.error),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.onErrorContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Please fix the following errors:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...state.validationErrors!.entries.expand(
                        (entry) => entry.value.map((error) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 28, bottom: 4),
                              child: Text(
                                '• $error',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
