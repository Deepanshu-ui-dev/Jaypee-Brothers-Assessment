import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/bottom_padding.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  String _currency = 'INR';
  String _currencySymbol = '₹';
  String? _profileImagePath;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  final _currencies = [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'NGN', 'symbol': '₦', 'name': 'Nigerian Naira'},
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameCtrl.text = user.name;
      _currency = user.currency;
      _currencySymbol = user.currencySymbol;
      _professionCtrl.text = user.profession ?? '';
      _profileImagePath = user.profileImagePath;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _professionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _profileImagePath = image.path);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await ref.read(localProfileProvider.notifier).saveProfile(
          name: name,
          currency: _currency,
          currencySymbol: _currencySymbol,
          profession: _professionCtrl.text.trim().isEmpty
              ? null
              : _professionCtrl.text.trim(),
          profileImagePath: _profileImagePath,
        );
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated ✓')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = ref.watch(currentUserProvider)?.initials ?? 'U';

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Text('Edit Profile', style: context.textStyles.appBarTitle),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: (_nameCtrl.text.trim().isNotEmpty && !_loading) ? _save : null,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save',
                    style: context.textStyles.bodyMedium
                        .copyWith(color: context.colors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Avatar Picker ──
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: _profileImagePath == null
                            ? context.colors.balanceCardGradient
                            : null,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.colors.primary.withAlpha(50), width: 2),
                        image: _profileImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_profileImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: _profileImagePath == null
                          ? Text(
                              initials,
                              style: context.textStyles.heading
                                  .copyWith(fontSize: 32, color: Colors.white),
                            )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.pageBg, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to change photo',
                style: context.textStyles.caption
                    .copyWith(color: context.colors.textMuted),
              ),
            ),
            const SizedBox(height: 32),

            // ── Name ──
            Text('Full Name', style: context.textStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: context.textStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Your name',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: context.colors.textSecondary, size: 20),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // ── Profession ──
            Text('Working Profession', style: context.textStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _professionCtrl,
              textCapitalization: TextCapitalization.words,
              style: context.textStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'e.g. Software Engineer',
                prefixIcon: Icon(Icons.work_outline_rounded,
                    color: context.colors.textSecondary, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // ── Currency ──
            Text('Currency', style: context.textStyles.label),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.divider, width: 0.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currency,
                  isExpanded: true,
                  dropdownColor: context.colors.surface,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: context.colors.textSecondary),
                  items: _currencies.map((c) {
                    return DropdownMenuItem(
                      value: c['code']!,
                      child: Text(
                        '${c['symbol']} - ${c['code']} (${c['name']})',
                        style: context.textStyles.body,
                      ),
                    );
                  }).toList(),
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
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: (_nameCtrl.text.trim().isNotEmpty && !_loading)
                  ? _save
                  : null,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes'),
            ),
            const BottomPadding(minimum: 40),
          ],
        ),
      ),
    );
  }
}
