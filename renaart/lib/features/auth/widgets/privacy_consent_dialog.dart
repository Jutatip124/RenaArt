import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

/// PDPA-compliant privacy consent dialog shown on first app launch.
/// User must accept before using the app.
class PrivacyConsentDialog extends StatefulWidget {
  final VoidCallback onAccept;

  const PrivacyConsentDialog({super.key, required this.onAccept});

  @override
  State<PrivacyConsentDialog> createState() => _PrivacyConsentDialogState();

  /// Check if user has already accepted privacy policy.
  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPrivacyAccepted) ?? false;
  }

  /// Mark privacy policy as accepted.
  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacyAccepted, true);
    await prefs.setString(
        _kPrivacyAcceptedDate, DateTime.now().toIso8601String());
  }

  static const String _kPrivacyAccepted = 'privacy_policy_accepted';
  static const String _kPrivacyAcceptedDate = 'privacy_policy_accepted_date';
}

class _PrivacyConsentDialogState extends State<PrivacyConsentDialog> {
  bool _hasReadPolicy = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Mark as read when user scrolls to bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasReadPolicy) {
        setState(() => _hasReadPolicy = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.canvasCard;
    final text = isDark ? AppColors.darkText : AppColors.ink;
    final faint = isDark ? AppColors.darkFaint : AppColors.inkLight;

    return PopScope(
      canPop: false, // Prevent dismissing without accepting
      child: AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy & Terms',
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: text)),
            const SizedBox(height: 4),
            Text('PDPA Compliance Notice',
                style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: faint)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                    'Data We Collect',
                    [
                      '• Email address (for authentication)',
                      '• Username and display name',
                      '• App preferences (theme, settings)',
                      '• Favorite artworks and viewing history',
                    ],
                    text,
                    faint),
                _buildSection(
                    'How We Use Your Data',
                    [
                      'Your data is used solely to provide app functionality:',
                      '• Authentication and account management',
                      '• Syncing favorites across devices',
                      '• Personalizing your experience',
                      '',
                      'We do NOT sell or share your personal information with third parties.',
                    ],
                    text,
                    faint),
                _buildSection(
                    'Data Storage & Security',
                    [
                      '• Account data is stored securely in Firebase (Google Cloud)',
                      '• Sensitive data (email, username) uses encrypted storage',
                      '• Viewing history is stored only on your device',
                      '• All data transmission uses HTTPS encryption',
                    ],
                    text,
                    faint),
                _buildSection(
                    'Your Rights (PDPA)',
                    [
                      '• Access: View your data in Profile settings',
                      '• Rectification: Edit your profile information anytime',
                      '• Deletion: Delete your account and ALL data permanently',
                      '• Withdrawal: You may withdraw consent by deleting your account',
                    ],
                    text,
                    faint),
                _buildSection(
                    'Data Retention',
                    [
                      '• Account data is retained while your account is active',
                      '• Upon account deletion, all data is permanently removed',
                      '• Local data can be cleared by uninstalling the app',
                    ],
                    text,
                    faint),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.gold : AppColors.ink)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'By tapping "I Accept", you consent to our collection and use of your data as described above.',
                    style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: text),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scroll to read the full policy before accepting.',
                  style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: faint),
                ),
              ],
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasReadPolicy
                  ? () async {
                      await PrivacyConsentDialog.markAccepted();
                      widget.onAccept();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.gold : AppColors.ink,
                foregroundColor: isDark ? AppColors.darkCanvas : Colors.white,
                disabledBackgroundColor: faint.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _hasReadPolicy ? 'I Accept' : 'Please read the policy first',
                style: const TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> items, Color text, Color faint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: text)),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(item,
                    style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 12,
                        height: 1.4,
                        color: faint)),
              )),
        ],
      ),
    );
  }
}
