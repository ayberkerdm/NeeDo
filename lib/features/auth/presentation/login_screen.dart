import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_sizes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            const CustomTextField(
              label: 'Telefon Veya E-Posta',
              hint: '05xx xxx xx xx / mail@example.com',
              prefixIcon: Icon(Icons.person_outline),
            ),
            const SizedBox(height: AppSizes.p16),
            const CustomTextField(
              label: 'Şifre',
              hint: '••••••••',
              obscureText: true,
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: Icon(Icons.visibility_off_outlined),
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
            PrimaryButton(
              text: 'Giriş Yap',
              onPressed: () {
                context.go('/home'); // To be implemented
              },
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
                  onPressed: () {},
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
