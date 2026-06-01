import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_sizes.dart';
import '../data/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedRole = 'customer'; // customer or provider

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signUp(
        email: email,
        password: password,
        fullName: name,
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı! Yönlendiriliyorsunuz...')),
        );
        // İlgili ana sayfaya yönlendir
        if (_selectedRole == 'customer') {
          context.go('/home');
        } else {
          context.go('/provider-home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeeDo\'ya Kayıt Ol'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Ad Soyad',
              hint: 'Ahmet Yılmaz',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: AppSizes.p16),
            CustomTextField(
              controller: _emailController,
              label: 'E-Posta',
              hint: 'mail@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: AppSizes.p16),
            CustomTextField(
              controller: _passwordController,
              label: 'Şifre',
              hint: '••••••••',
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            const SizedBox(height: AppSizes.p24),
            const Text(
              'Hesap Türü',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppSizes.p8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Hizmet Alan'),
                    value: 'customer',
                    groupValue: _selectedRole,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() => _selectedRole = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Hizmet Veren'),
                    value: 'provider',
                    groupValue: _selectedRole,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() => _selectedRole = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: 'Kayıt Ol',
                    onPressed: _handleRegister,
                  ),
            const SizedBox(height: AppSizes.p32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Zaten hesabın var mı?'),
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
