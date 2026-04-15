import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

/// PDPA-compliant privacy consent dialog shown on first Login/Register use.
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
            Text('Privacy Policy',
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: text)),
            const SizedBox(height: 4),
            Text('App: RenaArt  |  Last updated: 15 April 2026',
                style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 11,
                    color: faint)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This Privacy Policy explains how RenaArt collects, uses, stores, and protects personal data when you use the application. This policy is prepared in accordance with Thailand's Personal Data Protection Act B.E. 2562 (PDPA).",
                  style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 12,
                      height: 1.45,
                      color: faint),
                ),
                const SizedBox(height: 14),
                _buildSection(
                    '1. Personal Data We Collect',
                    [
                      '• Email address (for account authentication and security actions).',
                      '• Name / nickname / username that you provide.',
                      '• Account-related settings and preferences (for example theme mode and quality settings).',
                      '• App usage data needed for core functionality (for example favorites, viewing history, and issue reports submitted by you).',
                      'We do not collect phone number, postal address, contacts list, camera photos, or precise GPS location.',
                    ],
                    text,
                    faint),
                _buildSection(
                    '2. How We Use Your Data',
                    [
                      '• To create and manage your account.',
                      '• To provide core app features such as favorites sync and profile settings.',
                      '• To provide account security flows such as password reset and email verification.',
                      '• To respond to support/issue reports sent from within the app.',
                    ],
                    text,
                    faint),
                _buildSection(
                    '3. Legal Basis (PDPA)',
                    [
                      '• Performance of contract: to provide the service you requested.',
                      '• Consent: where consent is required by applicable law.',
                      '• Legitimate interest: to maintain app security and service reliability.',
                    ],
                    text,
                    faint),
                _buildSection(
                    '4. Data Sharing',
                    [
                      'We do not sell your personal data. We use service providers only as necessary to operate the app (for example Firebase services for authentication, database, and hosting).',
                    ],
                    text,
                    faint),
                _buildSection(
                    '5. Data Retention',
                    [
                      'We keep personal data only for as long as necessary to provide the service and comply with legal obligations. If you delete your account, associated account data is deleted from active systems subject to technical and legal limits.',
                    ],
                    text,
                    faint),
                _buildSection(
                    '6. Security',
                    [
                      'We apply reasonable technical and organizational safeguards to protect personal data, including encrypted transport (HTTPS) and platform-provided secure storage mechanisms where applicable.',
                    ],
                    text,
                    faint),
                _buildSection(
                    "7. Children's Privacy",
                    [
                      'This app is not intentionally directed to children under 13 years of age, and we do not knowingly collect personal data from children under 13.',
                    ],
                    text,
                    faint),
                _buildSection(
                    '8. Your Rights Under PDPA',
                    [
                      'Subject to PDPA conditions, you may request access, correction, deletion, restriction, objection, or data portability. You may also withdraw consent where processing is based on consent.',
                    ],
                    text,
                    faint),
                _buildSection(
                    '9. Contact',
                    [
                      'For privacy questions or data rights requests, contact:',
                      '6631503124@lamduan.mfu.ac.th',
                    ],
                    text,
                    faint),
                _buildSection(
                    '10. Policy Updates',
                    [
                      'We may update this policy from time to time. Material changes will be reflected on this page with an updated effective date.',
                    ],
                    text,
                    faint),
                Text(
                  'This policy is intended for transparency and compliance with Thailand PDPA requirements for the RenaArt application.',
                  style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 12,
                      height: 1.45,
                      color: faint),
                ),
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
