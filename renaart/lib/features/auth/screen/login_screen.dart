import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: '');
  final _passwordCtrl = TextEditingController(text: '');
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await ref
        .read(authProvider.notifier)
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (mounted) context.go(RouteNames.home);
  }

  Future<void> _guest() async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).continueAsGuest();
    if (mounted) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.parchment;
    final textColor = isDark ? AppColors.darkText : AppColors.inkDark;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.inkLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 56),
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.sienna,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'RA',
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'RenaArt',
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: textColor,
                ),
              ),
              Text(
                'The Digital Museum of the Renaissance',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 11,
                  color: secondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 48),
              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Sign in to your gallery',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 13,
                        color: secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Email
                    Text(
                      'EMAIL ADDRESS',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                        color: secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          size: 18,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password
                    Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                        color: secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Min. 6 characters',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppColors.inkFaint,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.inkFaint,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 12,
                          color: AppColors.heartRed,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signIn,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push(RouteNames.register),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 13,
                              color: secondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create one',
                                style: TextStyle(
                                  color: AppColors.sienna,
                                  fontWeight: FontWeight.w500,
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
              const SizedBox(height: 20),
              // Continue as guest
              GestureDetector(
                onTap: _loading ? null : _guest,
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 13,
                    color: secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: secondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mock mode — any email & password works',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 11,
                  color: secondary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
