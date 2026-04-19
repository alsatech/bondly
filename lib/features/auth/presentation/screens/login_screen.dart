import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/bondly_button.dart';
import '../../../../shared/widgets/bondly_text_field.dart';
import '../../../../shared/widgets/snack_helper.dart';
import '../providers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entryController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    // Show error snackbar reactively
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next is AuthError) {
        SnackHelper.showError(context, next.failure.message);
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 64),

                    // Logo mark
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 28),

                    // Headline
                    Text('Bienvenido\nde vuelta', style: AppTypography.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión para continuar.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 40),

                    // Email
                    BondlyTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hint: 'tu@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
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

                    // Password
                    BondlyTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: 'Mínimo 8 caracteres',
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu contraseña.';
                        if (v.length < 8) return 'Mínimo 8 caracteres.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot password (placeholder)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : () {}, // TODO: forgot password
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login CTA
                    BondlyButton(
                      label: 'Iniciar sesión',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'o',
                            style: AppTypography.bodySmall,
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Register CTA
                    BondlyButton(
                      label: 'Crear cuenta',
                      onPressed: isLoading ? null : () => context.push(AppRoutes.register),
                      variant: BondlyButtonVariant.outline,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
