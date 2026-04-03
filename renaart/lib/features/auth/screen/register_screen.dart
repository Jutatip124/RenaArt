import 'dart:async';

/// Registration screen with nickname, username, email, and password fields.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';
import '../widgets/art_mosaic_bg.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegState();
}

class _RegState extends ConsumerState<RegisterScreen> {
  final _nick = TextEditingController();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obs1 = true, _obs2 = true, _loading = false;
  String? _err;

  // Username availability
  bool? _usernameAvailable;
  bool _usernameChecking = false;
  Timer? _usernameTimer;

  @override
  void initState() {
    super.initState();
    _pass.addListener(() => setState(() {}));
    _user.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameTimer?.cancel();
    _nick.dispose();
    _user.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    _usernameTimer?.cancel();
    final val = _user.text.trim();
    if (val.length < 3) {
      setState(() {
        _usernameAvailable = null;
        _usernameChecking = false;
      });
      return;
    }
    setState(() => _usernameChecking = true);
    _usernameTimer = Timer(const Duration(milliseconds: 600), () async {
      final available =
          await ref.read(authProvider.notifier).isUsernameAvailable(val);
      if (mounted && _user.text.trim() == val) {
        setState(() {
          _usernameAvailable = available;
          _usernameChecking = false;
        });
      }
    });
  }

  Future<void> _register() async {
    final nick = _nick.text.trim();
    final user = _user.text.trim();
    final email = _email.text.trim();
    if (nick.isEmpty || user.isEmpty || email.isEmpty || _pass.text.isEmpty) {
      if (mounted) setState(() => _err = 'Please fill in all fields.');
      return;
    }
    // Validate email format
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      if (mounted) setState(() => _err = 'Please enter a valid email address.');
      return;
    }
    if (user.length < 3) {
      if (mounted)
        setState(() => _err = 'Username must be at least 3 characters.');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(user)) {
      if (mounted)
        setState(() => _err =
            'Username can only contain letters, numbers, and underscores.');
      return;
    }
    if (_pass.text != _confirm.text) {
      if (mounted) setState(() => _err = 'Passwords do not match.');
      return;
    }
    final strength = _passwordStrength(_pass.text);
    if (!strength.every((r) => r.met)) {
      if (mounted)
        setState(() => _err = 'Password does not meet all requirements.');
      return;
    }
    if (mounted)
      setState(() {
        _loading = true;
        _err = null;
      });
    try {
      await ref
          .read(authProvider.notifier)
          .register(nick, user, email, _pass.text);
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _err = e.toString();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final text = isDark ? AppColors.darkText : AppColors.ink;
    final faint = isDark ? AppColors.darkFaint : AppColors.inkLight;
    final card = isDark ? AppColors.darkCard : AppColors.canvasCard;
    final border = isDark ? AppColors.darkBorder : AppColors.inkHair;
    final sub = isDark ? AppColors.darkSub : AppColors.inkMid;
    final gold = isDark ? AppColors.gold : AppColors.ink;

    final passReqs = _passwordStrength(_pass.text);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
        ArtMosaicBackground(isDark: isDark),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back, color: text),
                  padding: EdgeInsets.zero),
              const SizedBox(height: 20),
              Text('Create\nAccount',
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: text,
                      letterSpacing: -1.0,
                      height: 1.08)),
              const SizedBox(height: 8),
              Container(width: 32, height: 1.5, color: gold),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border, width: isDark ? 0.5 : 0.8),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('DISPLAY NAME', faint),
                      const SizedBox(height: 6),
                      TextField(
                          controller: _nick,
                          decoration: const InputDecoration(
                              hintText: 'Your preferred name')),
                      const SizedBox(height: 14),
                      _Label('USERNAME', faint),
                      const SizedBox(height: 6),
                      TextField(
                          controller: _user,
                          decoration: InputDecoration(
                            hintText: 'Unique username (letters, numbers, _)',
                            prefixText: '@ ',
                            prefixStyle:
                                TextStyle(fontFamily: 'Jost', color: faint),
                            suffixIcon: _usernameChecking
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.5)))
                                : _usernameAvailable == null
                                    ? null
                                    : Icon(
                                        _usernameAvailable!
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 17,
                                        color: _usernameAvailable!
                                            ? const Color(0xFF4CAF50)
                                            : AppColors.errorRed),
                          )),
                      if (_user.text.trim().length >= 3 &&
                          !_usernameChecking &&
                          _usernameAvailable != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _usernameAvailable!
                                ? 'Username is available'
                                : 'Username is already taken',
                            style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 11,
                                color: _usernameAvailable!
                                    ? const Color(0xFF4CAF50)
                                    : AppColors.errorRed),
                          ),
                        ),
                      const SizedBox(height: 14),
                      _Label('EMAIL', faint),
                      const SizedBox(height: 6),
                      TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'you@example.com')),
                      const SizedBox(height: 14),
                      _Label('PASSWORD', faint),
                      const SizedBox(height: 6),
                      TextField(
                          controller: _pass,
                          obscureText: _obs1,
                          decoration: InputDecoration(
                              hintText: 'Create a strong password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obs1
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 17,
                                    color: faint),
                                onPressed: () => setState(() => _obs1 = !_obs1),
                              ))),
                      if (_pass.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...passReqs.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(children: [
                                Icon(
                                    r.met
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 13,
                                    color: r.met
                                        ? const Color(0xFF4CAF50)
                                        : isDark
                                            ? AppColors.darkFaint
                                            : AppColors.inkLight),
                                const SizedBox(width: 6),
                                Text(r.label,
                                    style: TextStyle(
                                        fontFamily: 'Jost',
                                        fontSize: 11,
                                        color: r.met
                                            ? const Color(0xFF4CAF50)
                                            : isDark
                                                ? AppColors.darkFaint
                                                : AppColors.inkLight)),
                              ]),
                            )),
                      ],
                      const SizedBox(height: 14),
                      _Label('CONFIRM PASSWORD', faint),
                      const SizedBox(height: 6),
                      TextField(
                          controller: _confirm,
                          obscureText: _obs2,
                          decoration: InputDecoration(
                              hintText: 'Re-enter password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obs2
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 17,
                                    color: faint),
                                onPressed: () => setState(() => _obs2 = !_obs2),
                              ))),
                      if (_err != null) ...[
                        const SizedBox(height: 10),
                        Text(_err!,
                            style: const TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 12,
                                color: AppColors.errorRed)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: isDark
                                          ? AppColors.darkCanvas
                                          : Colors.white))
                              : const Text('CREATE ACCOUNT'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                          child: GestureDetector(
                        onTap: () => context.pop(),
                        child: RichText(
                            text: TextSpan(
                          text: 'Already have an account?  ',
                          style: TextStyle(
                              fontFamily: 'Jost', fontSize: 13, color: sub),
                          children: [
                            TextSpan(
                                text: 'Sign in',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: gold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: gold))
                          ],
                        )),
                      )),
                    ]),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }

  List<_PasswordReq> _passwordStrength(String pass) => [
        _PasswordReq('At least 8 characters', pass.length >= 8),
        _PasswordReq(
            'Contains uppercase letter (A-Z)', pass.contains(RegExp(r'[A-Z]'))),
        _PasswordReq(
            'Contains lowercase letter (a-z)', pass.contains(RegExp(r'[a-z]'))),
        _PasswordReq('Contains number (0-9)', pass.contains(RegExp(r'[0-9]'))),
        _PasswordReq('Contains special character (!@#\$%...)',
            pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\[\]\\\/~`]'))),
      ];
}

class _PasswordReq {
  final String label;
  final bool met;
  const _PasswordReq(this.label, this.met);
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontFamily: 'Jost',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.3,
          color: color));
}
