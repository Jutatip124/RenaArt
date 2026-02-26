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
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    await ref.read(authProvider.notifier).signIn(email, pass);
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _guest() async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).continueAsGuest();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.parchment;
    final text = isDark ? AppColors.darkText : AppColors.inkDark;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.inkLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const SizedBox(height: 60),
            // Logo
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.sienna,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text('RA', style: TextStyle(
                  fontFamily: 'Cormorant', fontSize: 24,
                  fontWeight: FontWeight.w600, color: Colors.white,
                )),
              ),
            ),
            const SizedBox(height: 16),
            Text('RenaArt', style: TextStyle(
              fontFamily: 'Cormorant', fontSize: 34,
              fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
              color: text,
            )),
            Text('The Digital Museum of the Renaissance', style: TextStyle(
              fontFamily: 'Jost', fontSize: 11,
              letterSpacing: 1.2, fontWeight: FontWeight.w300,
              color: sub,
            )),
            const SizedBox(height: 44),
            // Card
            _Card(isDark: isDark, children: [
              Text('Welcome back', style: TextStyle(
                fontFamily: 'Cormorant', fontSize: 24,
                fontWeight: FontWeight.w600, color: text,
              )),
              const SizedBox(height: 2),
              Text('Sign in to your gallery', style: TextStyle(
                fontFamily: 'Jost', fontSize: 13, color: sub,
              )),
              const SizedBox(height: 24),
              _FieldLabel('EMAIL ADDRESS', sub),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline, size: 18,
                    color: AppColors.inkFaint),
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel('PASSWORD', sub),
              const SizedBox(height: 6),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Min. 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18,
                    color: AppColors.inkFaint),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18, color: AppColors.inkFaint,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
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
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white))
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => context.push(AppRoutes.register),
                child: Center(child: RichText(text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(fontFamily: 'Jost', fontSize: 13, color: sub),
                  children: [TextSpan(
                    text: 'Create one',
                    style: const TextStyle(
                      color: AppColors.sienna, fontWeight: FontWeight.w500,
                    ),
                  )],
                ))),
              ),
            ]),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _loading ? null : _guest,
              child: Text('Continue as Guest', style: TextStyle(
                fontFamily: 'Jost', fontSize: 13, color: sub,
                decoration: TextDecoration.underline, decorationColor: sub,
              )),
            ),
            const SizedBox(height: 10),
            Text('Demo mode — any email & password accepted', style: TextStyle(
              fontFamily: 'Jost', fontSize: 11, color: sub.withOpacity(0.5),
            )),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _FieldLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    fontFamily: 'Jost', fontSize: 10, letterSpacing: 1.2,
    fontWeight: FontWeight.w500, color: color,
  ));
}

class _Card extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _Card({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.divider,
        width: 0.5,
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}
