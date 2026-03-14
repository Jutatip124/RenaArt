import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final favCount = ref.watch(favoritesProvider).length;
    final offCount = ref.watch(offlineIdsProvider).length;

    if (user == null) return const SizedBox.shrink();

    final bg = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final text = isDark ? AppColors.darkText : AppColors.ink;
    final faint = isDark ? AppColors.darkFaint : AppColors.inkLight;
    final card = isDark ? AppColors.darkCard : AppColors.canvasCard;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: isDark ? AppColors.darkSurface : AppColors.canvasTone,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkRaised : AppColors.canvasCard,
                          border: Border.all(
                              color: isDark ? AppColors.gold : AppColors.inkHair,
                              width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            user.nickname.isNotEmpty ? user.nickname[0].toUpperCase() : 'G',
                            style: TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.gold : AppColors.ink),
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user.nickname,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: text,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 3),
                  Text(
                      user.isGuest
                          ? 'GUEST VISITOR'
                          : '@${user.username}  ·  GALLERY MEMBER',
                      style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 10,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w400,
                          color: faint)),
                  const SizedBox(height: 22),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(count: favCount, label: 'Liked', isDark: isDark),
                        VerticalDivider(
                            color: isDark ? AppColors.darkBorder : AppColors.inkHair,
                            thickness: 0.8,
                            width: 32),
                        _Stat(count: offCount, label: 'Offline', isDark: isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Label('ACCOUNT', faint),
            _Card(card, isDark, [
              if (!user.isGuest) ...[
                _Tile(Icons.person_outline, 'Display Name', user.nickname, isDark,
                    onTap: () => _editDialog(context, ref, 'Display Name', user.nickname, isDark,
                        (v) => ref.read(authProvider.notifier).updateNickname(v))),
                _Div(isDark),
                _Tile(Icons.alternate_email, 'Username', '@${user.username}', isDark,
                    onTap: () => _secureEditDialog(context, ref, 'Username', user.username, isDark,
                        (v) => ref.read(authProvider.notifier).updateUsername(v))),
                _Div(isDark),
                _Tile(Icons.mail_outline, 'Email', user.email, isDark,
                    onTap: () => _secureEditDialog(context, ref, 'Email', user.email, isDark,
                        (v) => ref.read(authProvider.notifier).updateEmail(v),
                        note: 'A verification email will be sent to your new address')),
                _Div(isDark),
                _Tile(Icons.lock_outline, 'Password', '••••••••', isDark,
                    onTap: () => _changePasswordDialog(context, ref, isDark)),
                _Div(isDark),
                _ReadOnlyTile(Icons.badge_outlined, 'User ID', user.userId, isDark),
              ] else
                _Tile(Icons.person_outline, 'Browsing as Guest',
                    'Sign in to save your collection', isDark, onTap: () {
                  ref.read(authProvider.notifier).signOut();
                  context.go(AppRoutes.login);
                }),
            ]),
            const SizedBox(height: 14),
            _Label('PREFERENCES', faint),
            _Card(card, isDark, [
              _ToggleTile(
                  Icons.dark_mode_outlined,
                  'Dark Mode',
                  'Museum cinematic theme',
                  isDark ? AppColors.gold : AppColors.ink,
                  isDark,
                  isDark,
                  onToggle: (_) => ref.read(themeModeProvider.notifier).toggle()),
              _Div(isDark),
              _ToggleTile(
                  Icons.high_quality_outlined,
                  'High Fidelity',
                  'Images at max 1080p resolution',
                  isDark ? AppColors.gold : AppColors.ink,
                  user.preferences.highFidelityMode,
                  isDark,
                  onToggle: (_) => ref.read(authProvider.notifier).toggleHighFidelity()),
            ]),
            const SizedBox(height: 14),
            _Label('SUPPORT', faint),
            _Card(card, isDark, [
              _Tile(Icons.help_outline, 'Help & FAQ', null, isDark, onTap: () {}),
              _Div(isDark),
              _Tile(Icons.flag_outlined, 'Report a Problem', null, isDark,
                  onTap: () => _reportDialog(context, ref, isDark)),
              _Div(isDark),
              _Tile(Icons.info_outline, 'About RenaArt',
                  'v${AppConstants.appVersion}  ·  Wikimedia Commons', isDark,
                  onTap: () => _aboutDialog(context, isDark)),
            ]),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut();
                    context.go(AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.heartRed,
                    side: const BorderSide(color: AppColors.heartRed, width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5),
                  ),
                  child: const Text('SIGN OUT'),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
      ),
    );
  }

  void _aboutDialog(BuildContext ctx, bool isDark) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.canvasCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(AppConstants.appName,
            style: TextStyle(fontFamily: 'Cormorant', fontSize: 26,
                fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkText : AppColors.ink)),
        content: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppConstants.appTagline,
              style: TextStyle(fontFamily: 'Jost', fontSize: 12,
                  color: isDark ? AppColors.darkSub : AppColors.inkMid)),
          const SizedBox(height: 14),
          Container(height: 0.8,
              color: isDark ? AppColors.darkBorder : AppColors.inkHair),
          const SizedBox(height: 14),
          _InfoRow('Version', 'v${AppConstants.appVersion}', isDark),
          const SizedBox(height: 6),
          _InfoRow('Data Source', 'Wikimedia Commons + Firestore', isDark),
          const SizedBox(height: 6),
          _InfoRow('Repository', 'github.com/Jutatip124/RenaArt', isDark),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close',
                style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.gold : AppColors.ink)),
          ),
        ],
      ),
    );
  }

  void _editDialog(BuildContext ctx, WidgetRef ref, String label, String current, bool isDark,
      Function(String) onSave,
      {String? note, bool isPassword = false}) {
    final ctrl = TextEditingController(text: current);
    String? dialogErr;
    showDialog(
        context: ctx,
        builder: (_) => StatefulBuilder(builder: (dialogCtx, setDialogState) => AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : AppColors.canvasCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text('Edit $label',
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.ink)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                if (note != null) ...[
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.saveBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(children: [
                        const Icon(Icons.mail_outline, size: 13, color: AppColors.saveBlue),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(note,
                                style: const TextStyle(
                                    fontFamily: 'Jost', fontSize: 12, color: AppColors.saveBlue))),
                      ])),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: ctrl,
                  obscureText: isPassword,
                  decoration: isPassword
                      ? const InputDecoration(hintText: 'New password')
                      : null,
                ),
                if (dialogErr != null) ...[
                  const SizedBox(height: 8),
                  Text(dialogErr!, style: const TextStyle(
                      fontFamily: 'Jost', fontSize: 12, color: AppColors.errorRed)),
                ],
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text('Cancel',
                        style: TextStyle(
                            fontFamily: 'Jost',
                            color: isDark ? AppColors.darkFaint : AppColors.inkLight))),
                TextButton(
                    onPressed: () async {
                      try {
                        await onSave(ctrl.text.trim());
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      } catch (e) {
                        setDialogState(() => dialogErr = e.toString());
                      }
                    },
                    child: Text('Save',
                        style: TextStyle(
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.gold : AppColors.ink))),
              ],
            )));
  }

  /// Secure edit dialog — requires current password re-authentication.
  void _secureEditDialog(BuildContext ctx, WidgetRef ref, String label, String current, bool isDark,
      Function(String) onSave, {String? note}) {
    final valueCtrl = TextEditingController(text: current);
    final passCtrl = TextEditingController();
    String? dialogErr;
    bool loading = false;
    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(builder: (dialogCtx, setDialogState) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.canvasCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Edit $label',
            style: TextStyle(fontFamily: 'Cormorant', fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.ink)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (note != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.saveBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                const Icon(Icons.info_outline, size: 13, color: AppColors.saveBlue),
                const SizedBox(width: 8),
                Expanded(child: Text(note,
                    style: const TextStyle(fontFamily: 'Jost', fontSize: 12,
                        color: AppColors.saveBlue))),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          TextField(controller: valueCtrl,
            decoration: InputDecoration(
              labelText: 'New $label',
              labelStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                  color: isDark ? AppColors.darkFaint : AppColors.inkLight),
            )),
          const SizedBox(height: 12),
          TextField(controller: passCtrl, obscureText: true,
            decoration: InputDecoration(
              labelText: 'Current Password',
              labelStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                  color: isDark ? AppColors.darkFaint : AppColors.inkLight),
              hintText: 'Enter password to verify',
            )),
          if (dialogErr != null) ...[
            const SizedBox(height: 8),
            Text(dialogErr!, style: const TextStyle(fontFamily: 'Jost',
                fontSize: 12, color: AppColors.errorRed)),
          ],
        ]),
        actions: [
          TextButton(
              onPressed: loading ? null : () => Navigator.pop(dialogCtx),
              child: Text('Cancel', style: TextStyle(fontFamily: 'Jost',
                  color: isDark ? AppColors.darkFaint : AppColors.inkLight))),
          TextButton(
              onPressed: loading ? null : () async {
                if (passCtrl.text.isEmpty) {
                  setDialogState(() => dialogErr = 'Please enter your current password.');
                  return;
                }
                setDialogState(() { loading = true; dialogErr = null; });
                try {
                  await ref.read(authProvider.notifier).reauthenticate(passCtrl.text);
                  await onSave(valueCtrl.text.trim());
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                } catch (e) {
                  setDialogState(() { loading = false; dialogErr = e.toString(); });
                }
              },
              child: loading
                  ? const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5))
                  : Text('Save', style: TextStyle(fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.gold : AppColors.ink))),
        ],
      )),
    );
  }

  /// Change password dialog with strength indicators.
  void _changePasswordDialog(BuildContext ctx, WidgetRef ref, bool isDark) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? dialogErr;
    bool loading = false;

    List<_PwdReq> reqs(String p) => [
      _PwdReq('At least 8 characters', p.length >= 8),
      _PwdReq('Uppercase letter (A-Z)', p.contains(RegExp(r'[A-Z]'))),
      _PwdReq('Lowercase letter (a-z)', p.contains(RegExp(r'[a-z]'))),
      _PwdReq('Number (0-9)', p.contains(RegExp(r'[0-9]'))),
      _PwdReq('Special character (!@#\$%...)', p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\[\]\\\/~`]'))),
    ];

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(builder: (dialogCtx, setDialogState) {
        void onNewPassChange() => setDialogState(() {});
        newCtrl.addListener(onNewPassChange);

        final passReqs = reqs(newCtrl.text);
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.canvasCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('Change Password',
              style: TextStyle(fontFamily: 'Cormorant', fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.ink)),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: currentCtrl, obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                      color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                )),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                      color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                )),
            if (newCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...passReqs.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(children: [
                  Icon(r.met ? Icons.check_circle : Icons.circle_outlined, size: 12,
                      color: r.met ? const Color(0xFF4CAF50)
                          : isDark ? AppColors.darkFaint : AppColors.inkLight),
                  const SizedBox(width: 6),
                  Text(r.label, style: TextStyle(fontFamily: 'Jost', fontSize: 11,
                      color: r.met ? const Color(0xFF4CAF50)
                          : isDark ? AppColors.darkFaint : AppColors.inkLight)),
                ]),
              )),
            ],
            const SizedBox(height: 12),
            TextField(controller: confirmCtrl, obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                      color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                )),
            if (dialogErr != null) ...[
              const SizedBox(height: 8),
              Text(dialogErr!, style: const TextStyle(fontFamily: 'Jost',
                  fontSize: 12, color: AppColors.errorRed)),
            ],
          ])),
          actions: [
            TextButton(
                onPressed: loading ? null : () => Navigator.pop(dialogCtx),
                child: Text('Cancel', style: TextStyle(fontFamily: 'Jost',
                    color: isDark ? AppColors.darkFaint : AppColors.inkLight))),
            TextButton(
                onPressed: loading ? null : () async {
                  if (currentCtrl.text.isEmpty) {
                    setDialogState(() => dialogErr = 'Enter your current password.');
                    return;
                  }
                  if (!reqs(newCtrl.text).every((r) => r.met)) {
                    setDialogState(() => dialogErr = 'New password does not meet all requirements.');
                    return;
                  }
                  if (newCtrl.text != confirmCtrl.text) {
                    setDialogState(() => dialogErr = 'New passwords do not match.');
                    return;
                  }
                  setDialogState(() { loading = true; dialogErr = null; });
                  try {
                    await ref.read(authProvider.notifier).reauthenticate(currentCtrl.text);
                    await ref.read(authProvider.notifier).updatePassword(newCtrl.text);
                    if (dialogCtx.mounted) {
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('Password updated successfully'),
                        backgroundColor: Color(0xFF4CAF50),
                      ));
                    }
                  } catch (e) {
                    setDialogState(() { loading = false; dialogErr = e.toString(); });
                  }
                },
                child: loading
                    ? const SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5))
                    : Text('Update', style: TextStyle(fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.gold : AppColors.ink))),
          ],
        );
      }),
    );
  }

  /// Report a Problem dialog with categories.
  void _reportDialog(BuildContext ctx, WidgetRef ref, bool isDark) {
    const categories = [
      'Bug / App Crash',
      'Image Not Loading',
      'Incorrect Artwork Info',
      'Slow Performance',
      'Login / Account Issue',
      'UI / Display Problem',
      'Other',
    ];
    String? selectedCategory;
    final otherCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? dialogErr;
    bool loading = false;

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(builder: (dialogCtx, setDialogState) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.canvasCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Report a Problem',
            style: TextStyle(fontFamily: 'Cormorant', fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.ink)),
        content: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SELECT CATEGORY', style: TextStyle(fontFamily: 'Jost', fontSize: 10,
                fontWeight: FontWeight.w600, letterSpacing: 1.3,
                color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6,
              children: categories.map((c) => ChoiceChip(
                label: Text(c, style: TextStyle(fontFamily: 'Jost', fontSize: 12,
                    color: selectedCategory == c
                        ? (isDark ? AppColors.darkCanvas : Colors.white)
                        : (isDark ? AppColors.darkText : AppColors.ink))),
                selected: selectedCategory == c,
                onSelected: (_) => setDialogState(() => selectedCategory = c),
                selectedColor: isDark ? AppColors.gold : AppColors.ink,
                backgroundColor: isDark ? AppColors.darkRaised : AppColors.canvasTone,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              )).toList(),
            ),
            if (selectedCategory == 'Other') ...[
              const SizedBox(height: 12),
              TextField(controller: otherCtrl,
                decoration: InputDecoration(
                  labelText: 'Specify category',
                  labelStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                      color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                )),
            ],
            const SizedBox(height: 14),
            Text('DESCRIPTION', style: TextStyle(fontFamily: 'Jost', fontSize: 10,
                fontWeight: FontWeight.w600, letterSpacing: 1.3,
                color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the problem in detail...',
                hintStyle: TextStyle(fontFamily: 'Jost', fontSize: 13,
                    color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (dialogErr != null) ...[
              const SizedBox(height: 8),
              Text(dialogErr!, style: const TextStyle(fontFamily: 'Jost',
                  fontSize: 12, color: AppColors.errorRed)),
            ],
          ],
        )),
        actions: [
          TextButton(
              onPressed: loading ? null : () => Navigator.pop(dialogCtx),
              child: Text('Cancel', style: TextStyle(fontFamily: 'Jost',
                  color: isDark ? AppColors.darkFaint : AppColors.inkLight))),
          TextButton(
              onPressed: loading ? null : () async {
                if (selectedCategory == null) {
                  setDialogState(() => dialogErr = 'Please select a category.');
                  return;
                }
                final cat = selectedCategory == 'Other'
                    ? (otherCtrl.text.trim().isEmpty ? 'Other' : otherCtrl.text.trim())
                    : selectedCategory!;
                setDialogState(() { loading = true; dialogErr = null; });
                try {
                  await ref.read(authProvider.notifier).submitReport(cat, descCtrl.text.trim());
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Report submitted successfully. Thank you!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ));
                  }
                } catch (e) {
                  setDialogState(() { loading = false; dialogErr = 'Failed to submit. Please try again.'; });
                }
              },
              child: loading
                  ? const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5))
                  : Text('Submit', style: TextStyle(fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.gold : AppColors.ink))),
        ],
      )),
    );
  }
}

class _PwdReq {
  final String label;
  final bool met;
  const _PwdReq(this.label, this.met);
}

class _Stat extends StatelessWidget {
  final int count;
  final String label;
  final bool isDark;
  const _Stat({required this.count, required this.label, required this.isDark});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(count.toString(),
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.ink)),
        Text(label,
            style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 10,
                letterSpacing: 0.4,
                color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
      ]);
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _InfoRow(this.label, this.value, this.isDark);
  @override
  Widget build(BuildContext context) => Row(children: [
    Text('$label  ', style: TextStyle(fontFamily: 'Jost', fontSize: 11,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
    Expanded(child: Text(value, style: TextStyle(fontFamily: 'Jost', fontSize: 11,
        color: isDark ? AppColors.darkText : AppColors.ink), overflow: TextOverflow.ellipsis)),
  ]);
}

// ignore: non_constant_identifier_names
Widget _Label(String t, Color c) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
    child: Text(t,
        style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: c)));

// ignore: non_constant_identifier_names
Widget _Card(Color bg, bool isDark, List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.inkHair, width: isDark ? 0.5 : 0.8)),
    child: Column(children: children));

// ignore: non_constant_identifier_names
Widget _Div(bool isDark) => Divider(
    color: isDark ? AppColors.darkBorder : AppColors.inkHair, height: 1, thickness: 0.8, indent: 44);

class _ReadOnlyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _ReadOnlyTile(this.icon, this.label, this.value, this.isDark);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Icon(icon, size: 17, color: isDark ? AppColors.darkFaint : AppColors.inkLight),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontFamily: 'Jost', fontSize: 14,
              color: isDark ? AppColors.darkText : AppColors.ink)),
          Text(value, style: TextStyle(fontFamily: 'Jost', fontSize: 11,
              letterSpacing: 0.5,
              color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
        ]),
      ),
      Icon(Icons.lock, size: 13, color: isDark ? AppColors.darkFaint : AppColors.inkLight),
    ]),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isDark;
  final VoidCallback onTap;
  const _Tile(this.icon, this.label, this.value, this.isDark, {required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icon(icon, size: 17, color: isDark ? AppColors.darkFaint : AppColors.inkLight),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 14,
                      color: isDark ? AppColors.darkText : AppColors.ink)),
              if (value != null)
                Text(value!,
                    style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 12,
                        color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
            ])),
            Icon(Icons.chevron_right,
                size: 16, color: isDark ? AppColors.darkFaint : AppColors.inkLight),
          ]),
        ),
      );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color activeColor;
  final bool value, isDark;
  final ValueChanged<bool> onToggle;
  const _ToggleTile(this.icon, this.label, this.sub, this.activeColor, this.value, this.isDark,
      {required this.onToggle});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 17, color: isDark ? AppColors.darkFaint : AppColors.inkLight),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 14,
                    color: isDark ? AppColors.darkText : AppColors.ink)),
            Text(sub,
                style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 12,
                    color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
          ])),
          Switch(
              value: value,
              onChanged: onToggle,
              activeThumbColor: activeColor,
              trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
                  ? activeColor.withValues(alpha: 0.25)
                  : isDark
                      ? AppColors.darkBorder
                      : AppColors.inkHair)),
        ]),
      );
}