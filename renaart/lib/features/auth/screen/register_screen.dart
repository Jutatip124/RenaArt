import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegState();
}

class _RegState extends ConsumerState<RegisterScreen> {
  final _nick    = TextEditingController();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  final _confirm = TextEditingController();
  bool _obs1 = true, _obs2 = true, _loading = false;
  String? _err;

  @override
  void dispose() {
    _nick.dispose(); _email.dispose(); _pass.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nick.text.trim().isEmpty || _email.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _err = 'Please fill in all fields.'); return;
    }
    if (_pass.text != _confirm.text) {
      setState(() => _err = 'Passwords do not match.'); return;
    }
    if (_pass.text.length < 6) {
      setState(() => _err = 'Password must be at least 6 characters.'); return;
    }
    setState(() { _loading = true; _err = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    await ref.read(authProvider.notifier).register(
        _nick.text.trim(), _email.text.trim(), _pass.text);
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
            const SizedBox(height: 16),
            IconButton(onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back, color: text), padding: EdgeInsets.zero),
            const SizedBox(height: 20),
            Text('Create\nAccount',
              style: TextStyle(fontFamily: 'Cormorant', fontSize: 38,
                  fontWeight: FontWeight.w700, color: text,
                  letterSpacing: -1.0, height: 1.08)),
            const SizedBox(height: 8),
            Container(width: 32, height: 1.5,
                color: isDark ? AppColors.gold : AppColors.ink),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: card, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border, width: isDark ? 0.5 : 0.8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('DISPLAY NAME', faint),
                const SizedBox(height: 6),
                TextField(controller: _nick,
                    decoration: const InputDecoration(hintText: 'Your preferred name')),
                const SizedBox(height: 14),
                _Label('EMAIL', faint),
                const SizedBox(height: 6),
                TextField(controller: _email, keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'you@example.com')),
                const SizedBox(height: 14),
                _Label('PASSWORD', faint),
                const SizedBox(height: 6),
                TextField(controller: _pass, obscureText: _obs1,
                  decoration: InputDecoration(hintText: 'Min. 6 characters',
                    suffixIcon: IconButton(
                      icon: Icon(_obs1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 17, color: faint),
                      onPressed: () => setState(() => _obs1 = !_obs1),
                    ))),
                const SizedBox(height: 14),
                _Label('CONFIRM PASSWORD', faint),
                const SizedBox(height: 6),
                TextField(controller: _confirm, obscureText: _obs2,
                  decoration: InputDecoration(hintText: 'Re-enter password',
                    suffixIcon: IconButton(
                      icon: Icon(_obs2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 17, color: faint),
                      onPressed: () => setState(() => _obs2 = !_obs2),
                    ))),
                if (_err != null) ...[
                  const SizedBox(height: 10),
                  Text(_err!, style: const TextStyle(fontFamily: 'Jost',
                      fontSize: 12, color: AppColors.errorRed)),
                ],
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 1.5,
                                color: isDark ? AppColors.darkCanvas : Colors.white))
                        : const Text('CREATE ACCOUNT'),
                  ),
                ),
                const SizedBox(height: 14),
                Center(child: GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(text: TextSpan(
                    text: 'Already have an account?  ',
                    style: TextStyle(fontFamily: 'Jost', fontSize: 13, color: sub),
                    children: [TextSpan(text: 'Sign in',
                      style: TextStyle(fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.gold : AppColors.ink,
                          decoration: TextDecoration.underline,
                          decorationColor: isDark ? AppColors.gold : AppColors.ink))],
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
}

class _Label extends StatelessWidget {
  final String text; final Color color;
  const _Label(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(fontFamily: 'Jost', fontSize: 10,
        fontWeight: FontWeight.w600, letterSpacing: 1.3, color: color));
}
