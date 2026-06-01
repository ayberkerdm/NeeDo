import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_sizes.dart';
import '../data/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen e-posta ve şifrenizi girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(
        email: email,
        password: password,
      );

      final role = await authService.getUserRole();

      if (mounted) {
        if (role == 'provider') {
          context.go('/provider-home');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarısız: $e')),
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
        title: const Text('NeeDo\'ya Giriş Yap'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _emailController,
              label: 'Telefon Veya E-Posta',
              hint: '05xx xxx xx xx / mail@example.com',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: AppSizes.p16),
            CustomTextField(
              controller: _passwordController,
              label: 'Şifre',
              hint: '••••••••',
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: const Icon(Icons.visibility_off_outlined),
            ),
            const SizedBox(height: AppSizes.p8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Şifremi Unuttum',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: 'Giriş Yap',
                    onPressed: _handleLogin,
                  ),
            const SizedBox(height: AppSizes.p24),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  child: Text('veya'),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: AppSizes.p24),
            PrimaryButton(
              text: 'Google ile Devam Et',
              isSecondary: true,
              onPressed: () {},
            ),
            const SizedBox(height: AppSizes.p16),
            PrimaryButton(
              text: 'Apple ile Devam Et',
              isSecondary: true,
              onPressed: () {},
            ),
            const SizedBox(height: AppSizes.p32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hesabın yok mu?'),
                TextButton(
                  onPressed: () {
                    context.push('/register');
                  },
                  child: const Text(
                    'Kayıt Ol',
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
