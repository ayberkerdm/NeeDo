import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';

class CreateRequestWizard extends StatefulWidget {
  const CreateRequestWizard({super.key});

  @override
  State<CreateRequestWizard> createState() => _CreateRequestWizardState();
}

class _CreateRequestWizardState extends State<CreateRequestWizard> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talep Oluştur'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Talebiniz başarıyla oluşturuldu! Uygun ustalar listeleniyor...'))
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) context.push('/proposals');
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isLastStep = _currentStep == 3;
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.p24),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: isLastStep ? 'Ücretsiz Teklif Al' : 'Devam Et',
                    onPressed: details.onStepContinue,
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Geri',
                      isSecondary: true,
                      onPressed: details.onStepCancel,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Hizmet'),
            isActive: _currentStep >= 0,
            content: _buildServiceStep(),
          ),
          Step(
            title: const Text('Zaman'),
            isActive: _currentStep >= 1,
            content: _buildTimeStep(),
          ),
          Step(
            title: const Text('Konum'),
            isActive: _currentStep >= 2,
            content: _buildLocationStep(),
          ),
          Step(
            title: const Text('Detay'),
            isActive: _currentStep >= 3,
            content: _buildDetailStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hangi hizmete ihtiyacınız var?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Örn: Ev Temizliği',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hizmetin ne zaman yapılmasını istersiniz?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text('Belirli Bir Tarihte'),
          trailing: const Icon(Icons.calendar_month),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text('Esneğim (Tarih fark etmez)'),
          trailing: const Icon(Icons.all_inclusive),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hizmet nerede verilecek?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'İlçe, Mahalle veya Adres arayın',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ek detaylar ve açıklama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ustaların bilmesi gereken ekstra bir detay var mı?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
           children: [
             Icon(Icons.camera_alt, color: AppColors.primary),
             SizedBox(width: 8),
             Text('Fotoğraf Ekle (Opsiyonel)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
           ]
        ),
      ],
    );
  }
}
