import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../data/services/export_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/widgets/bottom_padding.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeProvider);
    final reminderEnabled = ref.watch(reminderProvider);
    final biometricState = ref.watch(biometricProvider);
    final currentStreak = ref.watch(streakProvider);
    final entriesThisMonth = ref.watch(currentMonthTxnCountProvider);

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: context.isDesktop ? 720 : double.infinity),
          child: CustomScrollView(
            slivers: [
              // ── Sliver Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profile',
                            style: context.textStyles.heading
                                .copyWith(fontSize: 24)),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/profile');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: context.colors.divider),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 14,
                                    color: context.colors.textSecondary),
                                const SizedBox(width: 6),
                                Text('Edit',
                                    style: context.textStyles.label.copyWith(
                                        color: context.colors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Profile Hero Card ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary,
                          context.colors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: context.colors.primaryGlow,
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withAlpha(80), width: 2),
                            image: user?.profileImagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(user!.profileImagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: user?.profileImagePath == null
                              ? Text(
                                  user?.initials ?? 'U',
                                  style: context.textStyles.heading.copyWith(
                                      fontSize: 28, color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 18),
                        // Name & meta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'User',
                                style: context.textStyles.heading.copyWith(
                                    fontSize: 20, color: Colors.white),
                              ),
                              if (user?.profession != null && user!.profession!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user.profession!,
                                  style: context.textStyles.caption.copyWith(
                                    fontSize: 13, color: Colors.white.withAlpha(200),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _PillBadge(
                                    icon: Icons.local_fire_department_rounded,
                                    label: '$currentStreak day streak',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Stats Row ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: '🔥',
                          value: '$currentStreak',
                          label: 'Day Streak',
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: '📋',
                          value: '$entriesThisMonth',
                          label: 'This Month',
                          color: context.colors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Preferences Section ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Preferences',
                      style: context.textStyles.sectionHeader
                          .copyWith(letterSpacing: 0.8)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(
                    children: [
                      // Theme Switcher
                      _ThemeRow(themeMode: themeMode, ref: ref),
                      Divider(
                          height: 0.5,
                          indent: 60,
                          color: context.colors.divider),
                      // Notifications
                      _ToggleRow(
                        icon: Icons.notifications_none_rounded,
                        iconBg: const Color(0xFF3B82F6),
                        title: 'Notifications',
                        value: reminderEnabled,
                        onChanged: (_) =>
                            ref.read(reminderProvider.notifier).toggle(),
                      ),
                      Divider(
                          height: 0.5,
                          indent: 60,
                          color: context.colors.divider),
                      // Biometric
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Data Section ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Data & Account',
                      style: context.textStyles.sectionHeader
                          .copyWith(letterSpacing: 0.8)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(
                    children: [
                      _ActionRow(
                        icon: Icons.person_outline_rounded,
                        iconBg: context.colors.primary,
                        title: 'Personal Summary',
                        onTap: () => context.push('/profile'),
                      ),
                      Divider(
                          height: 0.5,
                          indent: 60,
                          color: context.colors.divider),
                      _ActionRow(
                        icon: Icons.download_outlined,
                        iconBg: const Color(0xFF0CA75B),
                        title: 'Export Data (CSV)',
                        onTap: () async {
                          final txns =
                              ref.read(transactionNotifierProvider);
                          if (txns.isEmpty) return;
                          await ExportService.exportTransactionsCsv(txns);
                        },
                      ),
                      Divider(
                          height: 0.5,
                          indent: 60,
                          color: context.colors.divider),
                      _ActionRow(
                        icon: Icons.logout_rounded,
                        iconBg: context.colors.expenseRed,
                        title: 'Log Out',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: context.colors.surface,
                              title: Text('Log Out', style: context.textStyles.heading),
                              content: Text('Are you sure you want to log out? This will clear your local profile data.', style: context.textStyles.body),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Cancel', style: context.textStyles.bodyMedium),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref.read(localProfileProvider.notifier).clearProfile();
                                  },
                                  child: Text('Log Out', style: context.textStyles.bodyMedium.copyWith(color: context.colors.expenseRed)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Support Section ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Support',
                      style: context.textStyles.sectionHeader
                          .copyWith(letterSpacing: 0.8)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(
                    children: [
                      _ActionRow(
                        icon: Icons.help_outline_rounded,
                        iconBg: const Color(0xFF8B5CF6),
                        title: 'Help & Support',
                        onTap: () async {
                          final uri = Uri.parse('https://deepanshux.tech');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                      ),
                      Divider(
                          height: 0.5,
                          indent: 60,
                          color: context.colors.divider),
                      _ActionRow(
                        icon: Icons.info_outline_rounded,
                        iconBg: const Color(0xFF64748B),
                        title: 'About FinTrack',
                        onTap: () async {
                          final uri = Uri.parse('https://github.com/Deepanshu-ui-dev/Fintracker');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        trailingIcon: Icons.open_in_new_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: BottomPadding(minimum: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withAlpha(220)),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.textStyles.label.copyWith(
              color: Colors.white.withAlpha(220),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final String icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.colors.subtleShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style:
                    context.textStyles.heading.copyWith(fontSize: 22),
              ),
              Text(
                label,
                style: context.textStyles.caption.copyWith(
                    fontSize: 11, color: context.colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.colors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.themeMode, required this.ref});
  final ThemeMode themeMode;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.palette_outlined,
                    size: 18, color: Color(0xFFEC4899)),
              ),
              const SizedBox(width: 14),
              Text('Theme', style: context.textStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          CupertinoSlidingSegmentedControl<ThemeMode>(
            groupValue: themeMode,
            children: const {
              ThemeMode.system: Text('System'),
              ThemeMode.light: Text('Light'),
              ThemeMode.dark: Text('Dark'),
            },
            onValueChanged: (val) {
              if (val != null) {
                ref.read(themeProvider.notifier).setTheme(val);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconBg;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconBg),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(title, style: context.textStyles.bodyMedium)),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.onTap,
    this.trailingIcon,
  });
  final IconData icon;
  final Color iconBg;
  final String title;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconBg),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title, style: context.textStyles.bodyMedium)),
            Icon(trailingIcon ?? Icons.chevron_right_rounded,
                color: context.colors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
