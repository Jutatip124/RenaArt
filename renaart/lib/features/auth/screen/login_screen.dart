import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';

// Login — Arts Gallery editorial style
// Clean off-white, serif large headline, black CTA button
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obs = true, _loading = false;
  String? _err;

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _signIn() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _err = 'Please fill in all fields.'); return;
    }
    setState(() { _loading = true; _err = null; });
    await Future.delayed(const Duration(milliseconds: 500));
    await ref.read(authProvider.notifier).signIn(_email.text.trim(), _pass.text);
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
    final bg     = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final text   = isDark ? AppColors.darkText   : AppColors.ink;
    final sub    = isDark ? AppColors.darkSub    : AppColors.inkMid;
    final faint  = isDark ? AppColors.darkFaint  : AppColors.inkLight;
    final card   = isDark ? AppColors.darkCard   : AppColors.canvasCard;
    final border = isDark ? AppColors.darkBorder : AppColors.inkHair;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 52),
            // Large serif headline
            Text('Welcome to\nRenaArt',
              style: TextStyle(fontFamily: 'Cormorant', fontSize: 38,
                  fontWeight: FontWeight.w700, color: text,
                  letterSpacing: -1.0, height: 1.08)),
            const SizedBox(height: 8),
            // Gold rule (dark) / ink hairline (light)
            Container(width: 32, height: 1.5,
                color: isDark ? AppColors.gold : AppColors.ink),
            const SizedBox(height: 36),
            // Form card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border, width: isDark ? 0.5 : 0.8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('EMAIL', faint),
                const SizedBox(height: 6),
                TextField(controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'you@example.com')),
                const SizedBox(height: 14),
                _Label('PASSWORD', faint),
                const SizedBox(height: 6),
                TextField(controller: _pass, obscureText: _obs,
                  decoration: InputDecoration(
                    hintText: 'Min. 6 characters',
                    suffixIcon: IconButton(
                      icon: Icon(_obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 17, color: faint),
                      onPressed: () => setState(() => _obs = !_obs),
                    ),
                  )),
                if (_err != null) ...[
                  const SizedBox(height: 10),
                  Text(_err!, style: const TextStyle(fontFamily: 'Jost',
                      fontSize: 12, color: AppColors.errorRed)),
                ],
                const SizedBox(height: 20),
                // Black CTA button — Arts Gallery style
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 1.5,
                                color: isDark ? AppColors.darkCanvas : Colors.white))
                        : const Text('SIGN IN'),
                  ),
                ),
                const SizedBox(height: 14),
                Center(child: GestureDetector(
                  onTap: () => context.push(AppRoutes.register),
                  child: RichText(text: TextSpan(
                    text: "Don't have an account?  ",
                    style: TextStyle(fontFamily: 'Jost', fontSize: 13, color: sub),
                    children: [TextSpan(text: 'Create one',
                      style: TextStyle(fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.gold : AppColors.ink,
                          decoration: TextDecoration.underline,
                          decorationColor: isDark ? AppColors.gold : AppColors.ink))],
                  )),
                )),
              ]),
            ),
            const SizedBox(height: 20),
            // Guest link — subtle
            Center(child: GestureDetector(
              onTap: _loading ? null : _guest,
              child: Text('Continue without account',
                style: TextStyle(fontFamily: 'Jost', fontSize: 12,
                    color: faint, letterSpacing: 0.2,
                    decoration: TextDecoration.underline,
                    decorationColor: faint)),
            )),
            const SizedBox(height: 12),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text; final Color color;
  const _Label(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(fontFamily: 'Jost', fontSize: 10,
        fontWeight: FontWeight.w600, letterSpacing: 1.3, color: color));
}
