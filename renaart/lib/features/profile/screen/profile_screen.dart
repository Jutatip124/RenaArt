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
    final offlineCount = ref.watch(offlineProvider).length;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final textColor = isDark ? AppColors.darkText : AppColors.inkDark;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.inkLight;
    final faint = isDark ? AppColors.darkTextFaint : AppColors.inkFaint;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.dividerLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
              color: isDark ? AppColors.darkSurface : AppColors.inkDark,
              child: Column(
                children: [
                  // Avatar (initials only)
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.sienna,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user.nickname.isNotEmpty
                                ? user.nickname[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.darkSurface : AppColors.inkDark,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.nickname,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.isGuest
                        ? 'GUEST VISITOR'
                        : '@${user.username}  ·  GALLERY MEMBER',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(count: favCount, label: 'Liked'),
                      _StatDivider(),
                      _Stat(count: offlineCount, label: 'Offline'),
                      _StatDivider(),
                      _Stat(count: user.artworksViewed, label: 'Viewed'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Account section
            _SectionHeader('Account', faint),
            _SettingsCard(isDark: isDark, children: [
              if (!user.isGuest) ...[
                _SettingsRow(
                  icon: Icons.person_outline,
                  label: 'Display Name',
                  value: user.nickname,
                  isDark: isDark,
                  onTap: () => _showEditDialog(
                    context,
                    ref,
                    'Display Name',
                    user.nickname,
                    isDark,
                    (val) => ref.read(authProvider.notifier).updateNickname(val),
                  ),
                ),
                Divider(color: borderColor, height: 1, thickness: 0.5),
                _SettingsRow(
                  icon: Icons.alternate_email,
                  label: 'Username',
                  value: '@${user.username}',
                  isDark: isDark,
                  onTap: () => _showEditDialog(
                    context,
                    ref,
                    'Username',
                    user.username,
                    isDark,
                    (val) => ref.read(authProvider.notifier).updateUsername(val),
                    subtitle: 'Requires email confirmation',
                  ),
                ),
                Divider(color: borderColor, height: 1, thickness: 0.5),
                _SettingsRow(
                  icon: Icons.mail_outline,
                  label: 'Email Address',
                  value: user.email,
                  isDark: isDark,
                  onTap: () {},
                ),
              ] else
                _SettingsRow(
                  icon: Icons.person_outline,
                  label: 'Browsing as Guest',
                  value: 'Sign in to save your collection',
                  isDark: isDark,
                  onTap: () {
                    ref.read(authProvider.notifier).signOut();
                    context.go(RouteNames.login);
                  },
                ),
            ]),
            const SizedBox(height: 16),
            // Preferences
            _SectionHeader('Preferences', faint),
            _SettingsCard(isDark: isDark, children: [
              _ToggleRow(
                icon: Icons.high_quality_outlined,
                label: 'High Fidelity Mode',
                subtitle: 'Display images at max resolution',
                value: user.highFidelityMode,
                isDark: isDark,
                onChanged: (v) =>
                    ref.read(authProvider.notifier).toggleHighFidelity(),
              ),
              Divider(
                color: borderColor,
                height: 1,
                thickness: 0.5,
              ),
              _ToggleRow(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: isDark,
                isDark: isDark,
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).toggle(),
              ),
              Divider(color: borderColor, height: 1, thickness: 0.5),
              _SettingsRow(
                icon: Icons.tune_outlined,
                label: 'Preferred Periods',
                value: user.preferredPeriods.join(', '),
                isDark: isDark,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 16),
            // Support
            _SectionHeader('Support', faint),
            _SettingsCard(isDark: isDark, children: [
              _SettingsRow(
                icon: Icons.help_outline,
                label: 'Help & FAQ',
                isDark: isDark,
                onTap: () {},
              ),
              Divider(color: borderColor, height: 1, thickness: 0.5),
              _SettingsRow(
                icon: Icons.flag_outlined,
                label: 'Report a Problem',
                isDark: isDark,
                onTap: () {},
              ),
              Divider(color: borderColor, height: 1, thickness: 0.5),
              _SettingsRow(
                icon: Icons.info_outline,
                label: 'About RenaArt',
                isDark: isDark,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 16),
            // Sign out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut();
                    context.go(RouteNames.login);
                  },
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.heartRed,
                    side: const BorderSide(color: AppColors.heartRed, width: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String label,
    String current,
    bool isDark,
    Function(String) onSave, {
    String? subtitle,
  }) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          'Edit $label',
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.inkDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(controller: ctrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Jost',
                color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Jost',
                color: AppColors.sienna,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int count;
  final String label;
  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 36,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Jost',
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.darkText : AppColors.inkDark,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      value!,
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextFaint
                            : AppColors.inkFaint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 14,
                    color: isDark ? AppColors.darkText : AppColors.inkDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.sienna,
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.sienna.withOpacity(0.3);
              }
              return isDark ? AppColors.darkBorder : AppColors.dividerLight;
            }),
          ),
        ],
      ),
    );
  }
}
