import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  String _currency = 'NGN';
  String _currencySymbol = '₦';

  final _currencies = [
    {'code': 'NGN', 'symbol': '₦', 'name': 'Nigerian Naira'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    await ref.read(localProfileProvider.notifier).saveProfile(
          name: name,
          currency: _currency,
          currencySymbol: _currencySymbol,
        );
    
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    size: 64, color: context.colors.primary),
                const SizedBox(height: 24),
                Text(
                  'Welcome to FinTrack',
                  style: context.textStyles.heading.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s set up your profile to get started.',
                  style: context.textStyles.bodyMedium.copyWith(
                      color: context.colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Name field
                Text('What should we call you?', style: context.textStyles.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: context.textStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'e.g. John Doe',
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),

                // Currency picker
                Text('Preferred Currency', style: context.textStyles.label),
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
                  onPressed: _nameCtrl.text.trim().isNotEmpty ? _submit : null,
                  child: const Text('Get Started'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
