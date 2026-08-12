import 'package:flutter/material.dart';
import '../data/admin_store.dart';
import '../theme/app_theme.dart';
import '../widgets/dashed_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: adminStore,
          builder: (context, _) {
            return DashedContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SECURITY',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Require 2FA after login', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            SizedBox(height: 3),
                            Text('Admins must enter a 6-digit code after signing in.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: adminStore.twoFactorRequired,
                        activeColor: AppColors.accentMagenta,
                        onChanged: (v) => adminStore.setTwoFactorRequired(v),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        DashedContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('APP SETTINGS',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 18),
              _row('Minimum age', '18'),
              _row('Max match radius', '80 km'),
              _row('Auto-flag threshold', '3 reports'),
              _row('Support email', 'support@rightone.app'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DashedContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ADMIN TEAM',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 18),
              _row('You', 'Owner'),
              _row('moderator@rightone.app', 'Moderator'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textPrimary,
                ),
                child: const Text('+ Invite Admin'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ),
          Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
