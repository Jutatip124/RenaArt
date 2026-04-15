import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy Policy'),
      content: const SizedBox(
        width: double.maxFinite,
        height: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('App: RenaArt  |  Last updated: 15 April 2026',
                  style: TextStyle(fontSize: 12)),
              SizedBox(height: 12),
              Text(
                "This Privacy Policy explains how RenaArt collects, uses, stores, and protects personal data when you use the application. This policy is prepared in accordance with Thailand's Personal Data Protection Act B.E. 2562 (PDPA).",
              ),
              SizedBox(height: 12),
              Text('1. Personal Data We Collect',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('• Email address (for account authentication and security actions).'),
              Text('• Name / nickname / username that you provide.'),
              Text(
                  '• Account-related settings and preferences (for example theme mode and quality settings).'),
              Text(
                  '• App usage data needed for core functionality (for example favorites, viewing history, and issue reports submitted by you).'),
              Text(
                  'We do not collect phone number, postal address, contacts list, camera photos, or precise GPS location.'),
              SizedBox(height: 12),
              Text('2. How We Use Your Data',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('• To create and manage your account.'),
              Text(
                  '• To provide core app features such as favorites sync and profile settings.'),
              Text(
                  '• To provide account security flows such as password reset and email verification.'),
              Text('• To respond to support/issue reports sent from within the app.'),
              SizedBox(height: 12),
              Text('3. Legal Basis (PDPA)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('• Performance of contract: to provide the service you requested.'),
              Text('• Consent: where consent is required by applicable law.'),
              Text('• Legitimate interest: to maintain app security and service reliability.'),
              SizedBox(height: 12),
              Text('4. Data Sharing', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                  'We do not sell your personal data. We use service providers only as necessary to operate the app (for example Firebase services for authentication, database, and hosting).'),
              SizedBox(height: 12),
              Text('5. Data Retention',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                  'We keep personal data only for as long as necessary to provide the service and comply with legal obligations. If you delete your account, associated account data is deleted from active systems subject to technical and legal limits.'),
              SizedBox(height: 12),
              Text('6. Security', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                  'We apply reasonable technical and organizational safeguards to protect personal data, including encrypted transport (HTTPS) and platform-provided secure storage mechanisms where applicable.'),
              SizedBox(height: 12),
              Text("7. Children's Privacy",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                  'This app is not intentionally directed to children under 13 years of age, and we do not knowingly collect personal data from children under 13.'),
              SizedBox(height: 12),
              Text('8. Your Rights Under PDPA',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                  'Subject to PDPA conditions, you may request access, correction, deletion, restriction, objection, or data portability. You may also withdraw consent where processing is based on consent.'),
              SizedBox(height: 12),
              Text('9. Contact', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('For privacy questions or data rights requests, contact:'),
              Text('6631503124@lamduan.mfu.ac.th'),
              SizedBox(height: 12),
              Text('10. Policy Updates',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                  'We may update this policy from time to time. Material changes will be reflected on this page with an updated effective date.'),
              SizedBox(height: 12),
              Text(
                  'This policy is intended for transparency and compliance with Thailand PDPA requirements for the RenaArt application.'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }
}
