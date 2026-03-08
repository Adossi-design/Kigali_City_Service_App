import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProfileProvider);
    final locationNotifs = ref.watch(locationNotificationsProvider);
    final listingNotifs = ref.watch(listingUpdatesNotificationsProvider);
    final authUser = ref.watch(authStateProvider).value;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // profile header with avatar, name, email, and verified badge
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.navyCard, AppTheme.navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(color: AppTheme.navyBorder),
                  ),
                ),
                child: Column(
                  children: [
                    // user avatar circle
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.gold, Color(0xFFE8912A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: AppTheme.navy, width: 3),
                      ),
                      child: const Center(
                        child: Text('👤', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // shows name and email from Firestore user profile
                    userProfile.when(
                      loading: () => const AppLoader(),
                      error: (_, __) => Text(
                        authUser?.email ?? 'User',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                      ),
                      data: (profile) => Column(
                        children: [
                          Text(
                            profile?.name ?? authUser?.email ?? 'User',
                            style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.email ?? authUser?.email ?? '',
                            style: GoogleFonts.dmSans(
                                color: AppTheme.muted, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          // email verified badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified,
                                    color: AppTheme.green, size: 14),
                                const SizedBox(width: 5),
                                Text('Email Verified',
                                    style: GoogleFonts.dmSans(
                                      color: AppTheme.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // notification toggle switches
                    const SectionHeader(title: 'Notifications'),
                    _settingsToggle(
                      context: context,
                      emoji: '🔔',
                      title: 'Location Notifications',
                      subtitle: 'Alerts for nearby services',
                      value: locationNotifs,
                      onChanged: (v) => ref
                          .read(locationNotificationsProvider.notifier)
                          .state = v,
                    ),
                    _settingsToggle(
                      context: context,
                      emoji: '📢',
                      title: 'Listing Updates',
                      subtitle: 'Notify when listings change',
                      value: listingNotifs,
                      onChanged: (v) => ref
                          .read(listingUpdatesNotificationsProvider.notifier)
                          .state = v,
                    ),

                    const SizedBox(height: 20),

                    // account options (edit profile and change password)
                    const SectionHeader(title: 'Account'),
                    _settingsItem(
                      emoji: '✏️',
                      title: 'Edit Profile',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile editor coming soon',
                              style: GoogleFonts.dmSans()),
                          backgroundColor: AppTheme.navyCard,
                        ),
                      ),
                    ),
                    _settingsItem(
                      emoji: '🔑',
                      title: 'Change Password',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Password reset email sent!',
                              style: GoogleFonts.dmSans()),
                          backgroundColor: AppTheme.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // sign out button
                    GestureDetector(
                      onTap: () async {
                        await ref.read(authServiceProvider).signOut();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppTheme.red.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Text('🚪', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Sign Out',
                                  style: GoogleFonts.dmSans(
                                    color: AppTheme.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  )),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: AppTheme.red, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // reusable toggle row widget for notification settings
  Widget _settingsToggle({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.navyBorder),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        color: AppTheme.muted, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.gold,
            inactiveThumbColor: AppTheme.muted,
            inactiveTrackColor: AppTheme.navyBorder,
          ),
        ],
      ),
    );
  }

  // reusable tappable row widget for account options
  Widget _settingsItem({
    required String emoji,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.navyCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.navyBorder),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.dmSans(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppTheme.muted, size: 14),
          ],
        ),
      ),
    );
  }
}
