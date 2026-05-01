import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
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
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero copy block ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 56, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eyebrow
                        Text(
                          'WELCOME BACK, MEMBER.',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Big headline — two lines white + one gold italic
                        Text(
                          'The room\nis still',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.12,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'quiet.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: AppColors.gold,
                            height: 1.12,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sub-copy
                        Text(
                          'Sign in to find the people, places and bonds\nthat have been kept for you.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 52),

                  // ── Form block ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email / phone label styled uppercase
                          BondlyTextField(
                            controller: _emailController,
                            label: 'PHONE OR E-MAIL',
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
                          const SizedBox(height: 28),

                          // Password row with "use a magic link instead" inline link
                          Stack(
                            children: [
                              BondlyTextField(
                                controller: _passwordController,
                                label: 'PASSPHRASE',
                                hint: '••••••••••',
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                enabled: !isLoading,
                                onFieldSubmitted: (_) => _submit(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter your passphrase.';
                                  if (v.length < 8) return 'Minimum 8 characters.';
                                  return null;
                                },
                              ),
                              // Inline "use a magic link instead" top-right
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: isLoading ? null : () {},
                                  child: Text(
                                    'use a magic link instead',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),

                          // CTA — primary dark gold button
                          BondlyButton(
                            label: 'ENTER THE ROOM',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 36),

                          // Register link row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NOT A MEMBER?',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () => context.push(AppRoutes.register),
                                child: Text(
                                  'Join us →',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
