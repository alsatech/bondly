import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bondly_button.dart';
import '../../../../shared/widgets/bondly_text_field.dart';
import '../../../../shared/widgets/snack_helper.dart';
import '../../data/models/register_request.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_step_indicator.dart';
import '../widgets/interest_chip.dart';

// ---------------------------------------------------------------------------
// Available interests
// ---------------------------------------------------------------------------

// Must mirror the backend `interests` table so we match existing rows instead
// of creating duplicates. Backend normalizes to lowercase on receive.
// See TECH_DEBT.md — replace with a dynamic fetch in MVP v2.
const _availableInterests = [
  'Music', 'Fitness', 'Coffee', 'Travel', 'Photography',
  'Hiking', 'Cooking', 'Reading', 'Gaming', 'Yoga',
  'Dancing', 'Movies', 'Art', 'Sports', 'Restaurants',
  'Running', 'Hyrox', 'Tennis', 'Padel', 'Meditacion',
  'Racing Cars',
];

const _genders = ['Hombre', 'Mujer', 'No binario', 'Prefiero no decir'];

// ---------------------------------------------------------------------------
// RegisterScreen
// ---------------------------------------------------------------------------

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  static const int _totalSteps = 3;

  // Step 1 — Basic data
  final _step1FormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = '';
  bool _termsAccepted = false;

  // Step 2 — Profile photo
  File? _profilePhoto;
  bool _photoLoading = false;

  // Step 3 — Interests
  final Set<String> _selectedInterests = {};

  // Animation
  late final AnimationController _stepController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepController, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(parent: _stepController, curve: Curves.easeOut);
    _stepController.forward();
  }

  @override
  void dispose() {
    _stepController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _nextStep() {
    if (_currentStep == 0) {
      if (!(_step1FormKey.currentState?.validate() ?? false)) return;
      if (_selectedGender.isEmpty) {
        SnackHelper.showError(context, 'Selecciona tu género.');
        return;
      }
      if (!_termsAccepted) {
        SnackHelper.showError(context, 'Accept the Terms & Privacy to continue.');
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _animateStep();
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animateStep();
    }
  }

  void _animateStep() {
    _stepController.reset();
    _stepController.forward();
  }

  // ---------------------------------------------------------------------------
  // Photo picker
  // ---------------------------------------------------------------------------

  Future<void> _pickPhoto() async {
    setState(() => _photoLoading = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _profilePhoto = File(picked.path));
      }
    } catch (e) {
      if (mounted) SnackHelper.showError(context, 'No se pudo seleccionar la foto.');
    } finally {
      if (mounted) setState(() => _photoLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  void _submit() {
    final request = RegisterRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _selectedGender,
      interests: _selectedInterests.toList(),
      profilePhotoPath: _profilePhoto?.path,
    );

    ref.read(authNotifierProvider.notifier).register(request);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next is AuthError) {
        SnackHelper.showError(context, next.failure.message);
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(isLoading),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildCurrentStep(isLoading),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isLoading) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: _currentStep > 0
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: isLoading ? null : _prevStep,
            )
          : null,
      title: AuthStepIndicator(
        totalSteps: _totalSteps,
        currentStep: _currentStep,
      ),
      titleSpacing: _currentStep > 0 ? 0 : 24,
      actions: const [SizedBox(width: 48)],
    );
  }

  Widget _buildCurrentStep(bool isLoading) {
    return switch (_currentStep) {
      0 => _Step1BasicData(
          formKey: _step1FormKey,
          nameController: _nameController,
          usernameController: _usernameController,
          emailController: _emailController,
          ageController: _ageController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          selectedGender: _selectedGender,
          onGenderChanged: (g) => setState(() => _selectedGender = g),
          termsAccepted: _termsAccepted,
          onTermsChanged: (v) => setState(() => _termsAccepted = v ?? false),
          isLoading: isLoading,
          onNext: _nextStep,
        ),
      1 => _Step2Photo(
          profilePhoto: _profilePhoto,
          isLoading: isLoading,
          isPhotoLoading: _photoLoading,
          onPickPhoto: _pickPhoto,
          onNext: _nextStep,
        ),
      2 => _Step3Interests(
          selectedInterests: _selectedInterests,
          onToggle: (interest) {
            setState(() {
              if (_selectedInterests.contains(interest)) {
                _selectedInterests.remove(interest);
              } else {
                _selectedInterests.add(interest);
              }
            });
          },
          isLoading: isLoading,
          onSubmit: _nextStep,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Basic Data
// ---------------------------------------------------------------------------

class _Step1BasicData extends StatelessWidget {
  const _Step1BasicData({
    required this.formKey,
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.ageController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.isLoading,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController ageController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String selectedGender;
  final void Function(String) onGenderChanged;
  final bool termsAccepted;
  final void Function(bool?) onTermsChanged;
  final bool isLoading;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero copy ──────────────────────────────────────────────────
            Text(
              '§ CREATE YOUR ACCOUNT',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Join the',
              style: GoogleFonts.playfairDisplay(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'circle.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppColors.gold,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Free to join. Bond with people, places and\nmoments worth keeping.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 36),

            // ── Fields ────────────────────────────────────────────────────
            BondlyTextField(
              controller: nameController,
              label: 'FULL NAME',
              hint: 'Soren Vail',
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your name.';
                if (v.trim().length < 2) return 'Minimum 2 characters.';
                return null;
              },
            ),
            const SizedBox(height: 24),

            BondlyTextField(
              controller: usernameController,
              label: 'USERNAME',
              hint: 'soren.vail',
              prefixText: '@  ',
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a username.';
                if (v.trim().length < 3) return 'Minimum 3 characters.';
                return null;
              },
            ),
            const SizedBox(height: 24),

            BondlyTextField(
              controller: emailController,
              label: 'E-MAIL',
              hint: 'you@quiet.studio',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your email.';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                  return 'Invalid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Age field (hidden but required for backend)
            BondlyTextField(
              controller: ageController,
              label: 'AGE',
              hint: '24',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                final age = int.tryParse(v ?? '');
                if (age == null) return 'Enter your age.';
                if (age < 18 || age > 100) return 'Must be between 18 and 100.';
                return null;
              },
            ),
            const SizedBox(height: 24),

            BondlyTextField(
              controller: passwordController,
              label: 'PASSWORD',
              hint: 'At least 8 characters',
              isPassword: true,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a password.';
                if (v.length < 8) return 'Minimum 8 characters.';
                if (!v.contains(RegExp(r'[A-Z]'))) return 'Include one uppercase letter.';
                if (!v.contains(RegExp(r'[a-z]'))) return 'Include one lowercase letter.';
                if (!v.contains(RegExp(r'\d'))) return 'Include one number.';
                return null;
              },
            ),
            const SizedBox(height: 24),

            BondlyTextField(
              controller: confirmPasswordController,
              label: 'CONFIRM PASSWORD',
              hint: 'Repeat password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              validator: (v) {
                if (v != passwordController.text) return 'Passwords do not match.';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Gender selector — minimal pill chips
            Text(
              'GENDER',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _genders.map((gender) {
                final isSelected = selectedGender == gender;
                return GestureDetector(
                  onTap: isLoading ? null : () => onGenderChanged(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold.withValues(alpha: 0.55)
                            : AppColors.border,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      gender,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: isSelected ? AppColors.gold : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // ── Terms checkbox ─────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: termsAccepted,
                    onChanged: isLoading ? null : onTermsChanged,
                    activeColor: AppColors.gold,
                    checkColor: AppColors.background,
                    side: BorderSide(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: "I agree to Bondly's "),
                        TextSpan(
                          text: 'Terms',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.gold,
                          ),
                        ),
                        const TextSpan(text: ' & '),
                        TextSpan(
                          text: 'Privacy',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.gold,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── CTA ───────────────────────────────────────────────────────
            BondlyButton(
              label: 'CREATE ACCOUNT',
              onPressed: isLoading ? null : onNext,
              isLoading: isLoading,
            ),
            const SizedBox(height: 28),

            // ── Already a member row ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALREADY A MEMBER?',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.6,
                  ),
                ),
                Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Text(
                      'Sign in →',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.gold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Profile Photo
// ---------------------------------------------------------------------------

class _Step2Photo extends StatelessWidget {
  const _Step2Photo({
    required this.profilePhoto,
    required this.isLoading,
    required this.isPhotoLoading,
    required this.onPickPhoto,
    required this.onNext,
  });

  final File? profilePhoto;
  final bool isLoading;
  final bool isPhotoLoading;
  final VoidCallback onPickPhoto;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '§ YOUR PHOTO',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Show your\nface.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'A good photo increases your chances\nof connecting with others.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 48),

          // Photo picker
          Center(
            child: GestureDetector(
              onTap: isLoading || isPhotoLoading ? null : onPickPhoto,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: profilePhoto != null
                        ? AppColors.gold.withValues(alpha: 0.6)
                        : AppColors.border,
                    width: 1.5,
                  ),
                  image: profilePhoto != null
                      ? DecorationImage(
                          image: FileImage(profilePhoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: profilePhoto != null
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : null,
                ),
                child: profilePhoto == null
                    ? isPhotoLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppColors.gold,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: AppColors.textSecondary,
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add photo',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (profilePhoto != null)
            Center(
              child: TextButton.icon(
                onPressed: isLoading ? null : onPickPhoto,
                icon: Icon(Icons.edit_outlined, size: 14, color: AppColors.gold),
                label: Text(
                  'Change photo',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 52),

          BondlyButton(
            label: profilePhoto != null ? 'CONTINUE' : 'SKIP FOR NOW',
            onPressed: isLoading ? null : onNext,
            isLoading: isLoading,
            variant: profilePhoto != null
                ? BondlyButtonVariant.primary
                : BondlyButtonVariant.outline,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Interests
// ---------------------------------------------------------------------------

class _Step3Interests extends StatelessWidget {
  const _Step3Interests({
    required this.selectedInterests,
    required this.onToggle,
    required this.isLoading,
    required this.onSubmit,
  });

  final Set<String> selectedInterests;
  final void Function(String) onToggle;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '§ YOUR PASSIONS',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'What moves\nyou?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Pick at least 3 interests. We use these\nto find your people.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),

          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _availableInterests.map((interest) {
              return InterestChip(
                label: interest,
                isSelected: selectedInterests.contains(interest),
                onTap: isLoading ? () {} : () => onToggle(interest),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Selection counter
          if (selectedInterests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${selectedInterests.length} selected',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          BondlyButton(
            label: 'CREATE MY PROFILE',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
