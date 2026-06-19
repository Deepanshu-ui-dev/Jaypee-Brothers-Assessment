import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  String _currency = 'INR';
  String _currencySymbol = '₹';
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _currencies = [
    {'code': 'NGN', 'symbol': '₦', 'name': 'Nigerian Naira'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _professionCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  void _submit() async {
    final name = _nameCtrl.text.trim();
    final profession = _professionCtrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(localProfileProvider.notifier).saveProfile(
          name: name,
          currency: _currency,
          currencySymbol: _currencySymbol,
          profession: profession.isEmpty ? null : profession,
          profileImagePath: _profileImagePath,
        );
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final canSubmit = _nameCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: colors.pageBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 32.0),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo / Avatar ──
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: colors.primary.withAlpha(20),
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.primary.withAlpha(50), width: 2),
                                image: _profileImagePath != null
                                    ? DecorationImage(
                                        image: FileImage(File(_profileImagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _profileImagePath == null
                                  ? _LogoBadge(colors: colors)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.pageBg, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // ── Title ──
                    Text(
                      'Welcome to FinTracke',
                      style: styles.heading.copyWith(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Set up your profile to start tracking smarter.',
                      style: styles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontSize: 15.0,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),

                    // ── Name field ──
                    _FieldLabel(
                      label: 'What should we call you?',
                      colors: colors,
                      styles: styles,
                    ),
                    const SizedBox(height: 8.0),
                    _StyledTextField(
                      controller: _nameCtrl,
                      hintText: 'e.g. John Doe',
                      prefixIcon: Icons.person_outline_rounded,
                      colors: colors,
                      styles: styles,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22.0),

                    // ── Profession field ──
                    _FieldLabel(
                      label: 'Working Profession',
                      colors: colors,
                      styles: styles,
                    ),
                    const SizedBox(height: 8.0),
                    _StyledTextField(
                      controller: _professionCtrl,
                      hintText: 'e.g. Software Engineer',
                      prefixIcon: Icons.work_outline_rounded,
                      colors: colors,
                      styles: styles,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 22.0),

                    // ── Currency picker ──
                    _FieldLabel(
                      label: 'Preferred Currency',
                      colors: colors,
                      styles: styles,
                    ),
                    const SizedBox(height: 8.0),
                    _StyledDropdown(
                      value: _currency,
                      currencies: _currencies,
                      colors: colors,
                      styles: styles,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _currency = val;
                            _currencySymbol = _currencies
                                .firstWhere((c) => c['code'] == val)['symbol']!;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 52.0),

                    // ── CTA ──
                    AnimatedOpacity(
                      opacity: canSubmit ? 1.0 : 0.45,
                      duration: const Duration(milliseconds: 200),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient:
                              canSubmit ? colors.balanceCardGradient : null,
                          color: canSubmit ? null : colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(14.0),
                          boxShadow: canSubmit ? colors.primaryGlow : [],
                        ),
                        child: ElevatedButton(
                          onPressed: canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.transparent,
                            disabledForegroundColor: colors.textMuted,
                            minimumSize: const Size(double.infinity, 54.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            textStyle: styles.body.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Get Started'),
                              SizedBox(width: 8.0),
                              Icon(Icons.arrow_forward_rounded, size: 18.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // ── Footer ──
                    Text(
                      'Your data stays on this device.',
                      style: styles.bodyMedium.copyWith(
                        color: colors.textMuted,
                        fontSize: 13.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo Badge ───────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  final AppColors colors;
  const _LogoBadge({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        // Subtle border ring
      
        // Logo tile
        Container(
          width: 90.0,
          height: 90.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.0),
            color: const Color(0xFF0D0B1E),
            
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.0),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 90.0,
              height: 90.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final AppColors colors;
  final dynamic styles;

  const _FieldLabel({
    required this.label,
    required this.colors,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: styles.label.copyWith(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Styled Text Field ────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final AppColors colors;
  final dynamic styles;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.colors,
    required this.styles,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.divider, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textCapitalization: TextCapitalization.words,
        style: styles.body.copyWith(
          color: colors.textPrimary,
          fontSize: 15.0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: styles.body.copyWith(
            color: colors.textMuted,
            fontSize: 15.0,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: colors.textMuted,
            size: 20.0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 15.0,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

// ── Styled Dropdown ──────────────────────────────────────────────────────────

class _StyledDropdown extends StatelessWidget {
  final String value;
  final List<Map<String, String>> currencies;
  final AppColors colors;
  final dynamic styles;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.currencies,
    required this.colors,
    required this.styles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.currency_exchange_rounded,
            color: colors.textMuted,
            size: 20.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: colors.surface,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.textSecondary,
                ),
                items: currencies.map((c) {
                  return DropdownMenuItem(
                    value: c['code']!,
                    child: Text(
                      '${c['symbol']}  ${c['code']} — ${c['name']}',
                      style: styles.body.copyWith(
                        color: colors.textPrimary,
                        fontSize: 14.0,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}