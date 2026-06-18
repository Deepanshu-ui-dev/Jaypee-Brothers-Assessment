import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  String _currency = 'NGN';
  String _currencySymbol = '₦';
  bool _loading = false;

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
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameCtrl.text = user.name;
      _currency = user.currency;
      _currencySymbol = user.currencySymbol;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);
    await ref.read(localProfileProvider.notifier).saveProfile(
          name: name,
          currency: _currency,
          currencySymbol: _currencySymbol,
        );
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Text('Edit Profile', style: context.textStyles.appBarTitle),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Full Name', style: context.textStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: context.textStyles.bodyMedium,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            
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
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: (_nameCtrl.text.trim().isNotEmpty && !_loading) ? _save : null,
              child: _loading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes'),
            ),
            const BottomPadding(minimum: 40),
          ],
        ),
      ),
    );
  }
}
