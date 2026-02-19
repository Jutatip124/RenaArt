import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/services/providers.dart';
import 'package:renaart/services/storage_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final offline = ref.watch(offlineProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Profile Hero ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A1508),
                      Color(0xFF4A2510),
                      AppColors.sienna,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.parchment,
                            child: Text(
                              'J',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 36,
                                color: AppColors.sienna,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.sienna, width: 2),
                                ),
                                child: const Icon(Icons.edit,
                                    size: 13, color: AppColors.ink),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Jutatip Sriputhon',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          color: AppColors.cream,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'RENAISSANCE CURATOR · GALLERY MEMBER',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.goldLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatItem(
                              label: 'Liked', value: '${favorites.length}'),
                          _divider(),
                          _StatItem(label: 'Offline', value: '${offline.length}'),
                          _divider(),
                          const _StatItem(label: 'Viewed', value: '156'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Section
                _SectionHeader('Account'),
                _ProfileItem(
                  icon: Icons.person_outline,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE67E22),
                  label: 'Display Name',
                  subtitle: 'Jutatip Sriputhon',
                  onTap: () => _editNameDialog(context),
                ),
                _ProfileItem(
                  icon: Icons.email_outlined,
                  iconBg: const Color(0xFFE8F4FD),
                  iconColor: const Color(0xFF2980B9),
                  label: 'Email Address',
                  subtitle: 'student@example.com',
                  onTap: () {},
                ),

                // Preferences
                _SectionHeader('Preferences'),
                _ProfileToggleItem(
                  icon: Icons.hd_outlined,
                  iconBg: const Color(0xFFF0E6FF),
                  iconColor: const Color(0xFF8E44AD),
                  label: 'High Fidelity Mode',
                  subtitle: 'Display images at max resolution',
                  value: true,
                  onChanged: (_) {},
                ),
                _ProfileItem(
                  icon: Icons.bookmark_border,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF27AE60),
                  label: 'Offline Storage Limit',
                  subtitle:
                      '${offline.length}/${StorageService.maxOfflineArtworks} artworks saved',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.palette_outlined,
                  iconBg: const Color(0xFFFFF8E1),
                  iconColor: const Color(0xFFF39C12),
                  label: 'Preferred Periods',
                  subtitle: 'High Renaissance, Early Renaissance',
                  onTap: () {},
                ),
                _ProfileToggleItem(
                  icon: Icons.dark_mode_outlined,
                  iconBg: const Color(0xFFEEEEEE),
                  iconColor: AppColors.ink,
                  label: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: false,
                  onChanged: (_) {},
                ),

                // Support
                _SectionHeader('Support'),
                _ProfileItem(
                  icon: Icons.help_outline,
                  iconBg: const Color(0xFFEDF2FF),
                  iconColor: const Color(0xFF3498DB),
                  label: 'Help & FAQ',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.flag_outlined,
                  iconBg: const Color(0xFFFDECEA),
                  iconColor: const Color(0xFFE74C3C),
                  label: 'Report a Problem',
                  onTap: () {},
                ),

                // Account Actions
                _SectionHeader('Account Actions'),
                _ProfileItem(
                  icon: Icons.logout,
                  iconBg: const Color(0xFFFDECEA),
                  iconColor: const Color(0xFFC0392B),
                  label: 'Log Out',
                  labelColor: const Color(0xFFC0392B),
                  onTap: () => _logoutDialog(context),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'RenaArt · v1.0.0\nThe Digital Museum of the Renaissance',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.stone,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editNameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: 'Jutatip Sriputhon');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Name',
            style: GoogleFonts.cormorantGaramond(fontSize: 20)),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Save',
                  style: TextStyle(color: AppColors.sienna))),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Log Out',
            style: GoogleFonts.cormorantGaramond(fontSize: 20)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Log Out',
                  style: TextStyle(color: Color(0xFFC0392B)))),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                color: AppColors.cream,
                fontWeight: FontWeight.w600)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0x99F7F3ED))),
      ],
    );
  }
}

Widget _divider() => Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.stone.withOpacity(0.4),
    );

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.stone.withOpacity(0.12), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? AppColors.ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.stone, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ProfileToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProfileToggleItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.stone.withOpacity(0.12), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.sienna,
          ),
        ],
      ),
    );
  }
}
