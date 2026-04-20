import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
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
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = '';

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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: isLoading ? null : _prevStep,
              )
            : null,
        title: AuthStepIndicator(
          totalSteps: _totalSteps,
          currentStep: _currentStep,
        ),
        titleSpacing: _currentStep > 0 ? 0 : 24,
        actions: const [SizedBox(width: 48)],
      ),
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

  Widget _buildCurrentStep(bool isLoading) {
    return switch (_currentStep) {
      0 => _Step1BasicData(
          formKey: _step1FormKey,
          nameController: _nameController,
          emailController: _emailController,
          ageController: _ageController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          selectedGender: _selectedGender,
          onGenderChanged: (g) => setState(() => _selectedGender = g),
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
    required this.emailController,
    required this.ageController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.isLoading,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController ageController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String selectedGender;
  final void Function(String) onGenderChanged;
  final bool isLoading;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Cuéntanos sobre ti', style: AppTypography.displayMedium),
            const SizedBox(height: 6),
            Text(
              'Paso 1 de 3 — Datos básicos',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 32),

            BondlyTextField(
              controller: nameController,
              label: 'Nombre completo',
              hint: 'Tu nombre',
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre.';
                if (v.trim().length < 2) return 'Mínimo 2 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            BondlyTextField(
              controller: emailController,
              label: 'Correo electrónico',
              hint: 'tu@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu correo.';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                  return 'Correo no válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            BondlyTextField(
              controller: ageController,
              label: 'Edad',
              hint: 'Tu edad',
              prefixIcon: const Icon(Icons.cake_outlined),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                final age = int.tryParse(v ?? '');
                if (age == null) return 'Ingresa tu edad.';
                if (age < 18 || age > 100) return 'Debes tener entre 18 y 100.';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Gender selector
            Text('Género', style: AppTypography.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _genders.map((gender) {
                final isSelected = selectedGender == gender;
                return GestureDetector(
                  onTap: isLoading ? null : () => onGenderChanged(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      gender,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            BondlyTextField(
              controller: passwordController,
              label: 'Contraseña',
              hint: '8+ chars, con mayúscula, minúscula y número',
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline),
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa una contraseña.';
                if (v.length < 8) return 'Mínimo 8 caracteres.';
                if (!v.contains(RegExp(r'[A-Z]'))) {
                  return 'Incluye al menos una mayúscula.';
                }
                if (!v.contains(RegExp(r'[a-z]'))) {
                  return 'Incluye al menos una minúscula.';
                }
                if (!v.contains(RegExp(r'\d'))) {
                  return 'Incluye al menos un número.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            BondlyTextField(
              controller: confirmPasswordController,
              label: 'Confirmar contraseña',
              hint: 'Repite tu contraseña',
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline),
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              validator: (v) {
                if (v != passwordController.text) return 'Las contraseñas no coinciden.';
                return null;
              },
            ),
            const SizedBox(height: 32),

            BondlyButton(
              label: 'Continuar',
              onPressed: isLoading ? null : onNext,
              isLoading: isLoading,
            ),
            const SizedBox(height: 32),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Tu foto de perfil', style: AppTypography.displayMedium),
          const SizedBox(height: 6),
          Text(
            'Paso 2 de 3 — Una buena foto aumenta tus matches.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 48),

          // Photo picker
          Center(
            child: GestureDetector(
              onTap: isLoading || isPhotoLoading ? null : onPickPhoto,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: profilePhoto != null ? AppColors.primary : AppColors.border,
                    width: profilePhoto != null ? 2.5 : 1.5,
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
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : null,
                ),
                child: profilePhoto == null
                    ? isPhotoLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                color: AppColors.textSecondary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Agregar foto',
                                style: AppTypography.labelMedium,
                              ),
                            ],
                          )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (profilePhoto != null)
            Center(
              child: TextButton.icon(
                onPressed: isLoading ? null : onPickPhoto,
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.accent),
                label: Text(
                  'Cambiar foto',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.accent),
                ),
              ),
            ),

          const SizedBox(height: 48),

          BondlyButton(
            label: profilePhoto != null ? 'Continuar' : 'Saltar por ahora',
            onPressed: isLoading ? null : onNext,
            isLoading: isLoading,
            variant: profilePhoto != null
                ? BondlyButtonVariant.primary
                : BondlyButtonVariant.outline,
          ),
          const SizedBox(height: 32),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('¿Qué te apasiona?', style: AppTypography.displayMedium),
          const SizedBox(height: 6),
          Text(
            'Paso 3 de 3 — Selecciona al menos 3 intereses.',
            style: AppTypography.bodySmall,
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
          const SizedBox(height: 32),

          // Selection counter
          if (selectedInterests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${selectedInterests.length} seleccionado${selectedInterests.length == 1 ? '' : 's'}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),

          BondlyButton(
            label: 'Crear mi perfil',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
