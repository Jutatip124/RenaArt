import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nicknameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nickname = _nicknameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (nickname.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 700));
    await ref.read(authProvider.notifier).register(nickname, email, pass);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.inkDark;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.inkLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 14),
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back, color: text),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            Text('Create Account', style: TextStyle(
              fontFamily: 'Cormorant', fontSize: 32,
              fontWeight: FontWeight.w600, color: text,
            )),
            Text('Join the Renaissance', style: TextStyle(
              fontFamily: 'Jost', fontSize: 13, color: sub,
            )),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.divider,
                  width: 0.5,
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('DISPLAY NAME', sub),
                const SizedBox(height: 6),
                TextField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Your preferred name',
                    prefixIcon: Icon(Icons.person_outline, size: 18, color: AppColors.inkFaint),
                  ),
                ),
                const SizedBox(height: 16),
                _label('EMAIL ADDRESS', sub),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.inkFaint),
                  ),
                ),
                const SizedBox(height: 16),
                _label('PASSWORD', sub),
                const SizedBox(height: 6),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Min. 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkFaint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18, color: AppColors.inkFaint,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _label('CONFIRM PASSWORD', sub),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkFaint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18, color: AppColors.inkFaint,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'By creating an account you agree to our Terms of Service.',
                  style: TextStyle(fontFamily: 'Jost', fontSize: 11, color: sub, height: 1.5),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(
                    fontFamily: 'Jost', fontSize: 12, color: AppColors.errorRed,
                  )),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 14),
                Center(child: GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(fontFamily: 'Jost', fontSize: 13, color: sub),
                    children: [TextSpan(
                      text: 'Sign in',
                      style: const TextStyle(color: AppColors.sienna, fontWeight: FontWeight.w500),
                    )],
                  )),
                )),
              ]),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Text(text, style: TextStyle(
    fontFamily: 'Jost', fontSize: 10,
    letterSpacing: 1.2, fontWeight: FontWeight.w500, color: color,
  ));
}
