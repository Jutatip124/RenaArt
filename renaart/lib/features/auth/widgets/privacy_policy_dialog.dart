import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy Policy'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Data We Collect',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Email address (for authentication)\n'
                '• Username and display name\n'
                '• App preferences (theme, settings)\n'
                '• Favorite artworks and viewing history (stored locally)'),
            SizedBox(height: 16),
            Text('How We Use Your Data',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Your data is used solely to provide app functionality. '
                'We do not share your personal information with third parties.'),
            SizedBox(height: 16),
            Text('Data Storage', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Account data is stored securely in Firebase\n'
                '• Local preferences use encrypted storage\n'
                '• Viewing history is stored only on your device'),
            SizedBox(height: 16),
            Text('Your Rights', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Access: View your data in Profile settings\n'
                '• Deletion: Delete your account and all data anytime\n'
                '• Portability: Export your data from Profile settings'),
            SizedBox(height: 16),
            Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'For privacy concerns, contact us via the app\'s Help section.'),
          ],
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
