import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final favCount = ref.watch(favoritesProvider).length;
    final offlineCount = ref.watch(offlineIdsProvider).length;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: SingleChildScrollView(child: Column(children: [
        // ─── Profile Header ───────────────────────────────────────────────────
        Container(
          width: double.infinity,
          color: isDark ? AppColors.darkSurface : AppColors.inkDark,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
          child: Column(children: [
            // Avatar — initials only (Week 1 UI spec: "ไม่มีภาพโปรไฟล์มีเพียงชื่อที่ขึ้น")
            Stack(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.sienna, shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.5), width: 2),
                ),
                child: Center(child: Text(
                  user.nickname.isNotEmpty
                      ? user.nickname[0].toUpperCase() : 'G',
                  style: const TextStyle(
                    fontFamily: 'Cormorant', fontSize: 30,
                    fontWeight: FontWeight.w600, color: Colors.white,
                  ),
                )),
              ),
              Positioned(bottom: 0, right: 0,
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.gold, shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface : AppColors.inkDark,
                      width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 11, color: Colors.white),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(user.nickname, style: const TextStyle(
              fontFamily: 'Cormorant', fontSize: 24,
              fontWeight: FontWeight.w600, color: Colors.white,
            )),
            const SizedBox(height: 4),
            Text(
              user.isGuest
                  ? 'GUEST VISITOR'
                  : '@${user.username}  ·  GALLERY MEMBER',
              style: TextStyle(
                fontFamily: 'Jost', fontSize: 10, letterSpacing: 1.5,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            // Stats (Week 3: calculated from UserArtworkState)
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _StatBadge(count: favCount, label: 'Liked'),
              _Divider(),
              _StatBadge(count: offlineCount, label: 'Offline'),
              _Divider(),
              _StatBadge(count: user.stats.artworksViewed, label: 'Viewed'),
            ]),
          ]),
        ),
        const SizedBox(height: 24),

        // ─── Account Section ──────────────────────────────────────────────────
        _SectionLabel('Account', isDark),
        _SettingsCard(isDark: isDark, children: [
          if (!user.isGuest) ...[
            // Nickname — freely editable (Week 1 spec)
            _SettingsTile(
              icon: Icons.person_outline, label: 'Display Name',
              value: user.nickname, isDark: isDark,
              onTap: () => _editDialog(
                context, ref, 'Display Name', user.nickname, isDark,
                (val) => ref.read(authProvider.notifier).updateNickname(val),
              ),
            ),
            _Div(isDark),
            // Username — requires email confirmation (Week 1 spec)
            _SettingsTile(
              icon: Icons.alternate_email, label: 'Username',
              value: '@${user.username}', isDark: isDark,
              onTap: () => _editDialog(
                context, ref, 'Username', user.username, isDark,
                (val) => ref.read(authProvider.notifier).updateUsername(val),
                subtitle: 'Requires email confirmation to change',
                showEmailNote: true,
              ),
            ),
            _Div(isDark),
            _SettingsTile(
              icon: Icons.mail_outline, label: 'Email Address',
              value: user.email, isDark: isDark, onTap: () {},
            ),
          ] else
            _SettingsTile(
              icon: Icons.person_outline, label: 'Browsing as Guest',
              value: 'Sign in to save your collection', isDark: isDark,
              onTap: () {
                ref.read(authProvider.notifier).signOut();
                context.go(AppRoutes.login);
              },
            ),
        ]),
        const SizedBox(height: 16),

        // ─── Preferences ──────────────────────────────────────────────────────
        _SectionLabel('Preferences', isDark),
        _SettingsCard(isDark: isDark, children: [
          _ToggleTile(
            icon: Icons.dark_mode_outlined, label: 'Dark Mode',
            subtitle: 'Switch to dark museum theme',
            value: isDark, isDark: isDark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          _Div(isDark),
          _ToggleTile(
            icon: Icons.high_quality_outlined, label: 'High Fidelity Mode',
            subtitle: 'Display images at max resolution (1080p)',
            value: user.preferences.highFidelityMode, isDark: isDark,
            onChanged: (_) => ref.read(authProvider.notifier).toggleHighFidelity(),
          ),
          _Div(isDark),
          _SettingsTile(
            icon: Icons.tune_outlined, label: 'Preferred Periods',
            value: user.preferences.preferredPeriods.join(', '),
            isDark: isDark, onTap: () {},
          ),
        ]),
        const SizedBox(height: 16),

        // ─── Support ──────────────────────────────────────────────────────────
        _SectionLabel('Support', isDark),
        _SettingsCard(isDark: isDark, children: [
          _SettingsTile(icon: Icons.help_outline, label: 'Help & FAQ',
            isDark: isDark, onTap: () {}),
          _Div(isDark),
          _SettingsTile(icon: Icons.flag_outlined, label: 'Report a Problem',
            isDark: isDark, onTap: () {}),
          _Div(isDark),
          _SettingsTile(icon: Icons.info_outline, label: 'About RenaArt',
            value: 'v1.0.0 · Met Museum API', isDark: isDark, onTap: () {}),
        ]),
        const SizedBox(height: 16),

        // ─── Sign Out ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go(AppRoutes.login);
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.heartRed,
                side: const BorderSide(color: AppColors.heartRed, width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                  fontFamily: 'Jost', fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ])),
    );
  }

  void _editDialog(
    BuildContext context,
    WidgetRef ref,
    String label,
    String current,
    bool isDark,
    Function(String) onSave, {
    String? subtitle,
    bool showEmailNote = false,
  }) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('Edit $label', style: TextStyle(
          fontFamily: 'Cormorant', fontSize: 20, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
        )),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (subtitle != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.offlineBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.mail_outline, size: 14,
                    color: AppColors.offlineBlue),
                const SizedBox(width: 8),
                Expanded(child: Text(subtitle, style: const TextStyle(
                  fontFamily: 'Jost', fontSize: 12, color: AppColors.offlineBlue,
                ))),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          TextField(controller: ctrl),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontFamily: 'Jost',
              color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight)),
          ),
          TextButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(
              fontFamily: 'Jost', color: AppColors.sienna,
              fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final int count;
  final String label;
  const _StatBadge({required this.count, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(count.toString(), style: const TextStyle(
      fontFamily: 'Cormorant', fontSize: 24,
      fontWeight: FontWeight.w600, color: Colors.white,
    )),
    Text(label, style: TextStyle(
      fontFamily: 'Jost', fontSize: 11,
      color: Colors.white.withOpacity(0.6), letterSpacing: 0.5,
    )),
  ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 0.5, height: 36,
    color: Colors.white.withOpacity(0.2),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Text(text.toUpperCase(), style: TextStyle(
      fontFamily: 'Jost', fontSize: 10, letterSpacing: 1.2,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
    )),
  );
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.divider, width: 0.5,
      ),
    ),
    child: Column(children: children),
  );
}

Widget _Div(bool isDark) => Divider(
  color: isDark ? AppColors.darkBorder : AppColors.divider,
  height: 1, thickness: 0.5,
  indent: 48,
);

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isDark;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label,
      this.value, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Icon(icon, size: 18,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
            fontFamily: 'Jost', fontSize: 14,
            color: isDark ? AppColors.darkText : AppColors.inkDark,
          )),
          if (value != null)
            Text(value!, style: TextStyle(
              fontFamily: 'Jost', fontSize: 12,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
            )),
        ])),
        Icon(Icons.chevron_right, size: 18,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
      ]),
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.label,
      required this.subtitle, required this.value,
      required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 18,
        color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'Jost', fontSize: 14,
          color: isDark ? AppColors.darkText : AppColors.inkDark)),
        Text(subtitle, style: TextStyle(fontFamily: 'Jost', fontSize: 12,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint)),
      ])),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.sienna,
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sienna.withOpacity(0.3);
          }
          return isDark ? AppColors.darkBorder : AppColors.divider;
        }),
      ),
    ]),
  );
}
