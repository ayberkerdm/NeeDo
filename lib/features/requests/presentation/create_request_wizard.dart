import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../data/providers/requests_provider.dart';
import '../../auth/data/providers/auth_provider.dart';

class CreateRequestWizard extends ConsumerStatefulWidget {
  const CreateRequestWizard({super.key});

  @override
  ConsumerState<CreateRequestWizard> createState() => _CreateRequestWizardState();
}

class _CreateRequestWizardState extends ConsumerState<CreateRequestWizard> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen hizmet başlığı (örn: Ev Temizliği) girin.')));
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(requestServiceProvider).createRequest(
        customerId: user.id,
        title: title,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        // timeframe / time could be saved into another column or appended to description
      );

      // Invalidate the requests provider so the list refreshes
      ref.invalidate(myRequestsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Talebiniz başarıyla oluşturuldu! Uygun ustalar listeleniyor...'))
        );
        // Navigate back to the home or requests screen. We go back to home for now.
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talep Oluştur'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  _submitRequest();
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
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Örn: Ev Temizliği, Boya Badana',
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
            side: BorderSide(color: _selectedTime == 'Tarih' ? AppColors.primary : AppColors.border),
          ),
          title: const Text('Belirli Bir Tarihte'),
          trailing: const Icon(Icons.calendar_month),
          onTap: () {
            setState(() { _selectedTime = 'Tarih'; });
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: _selectedTime == 'Esnek' ? AppColors.primary : AppColors.border),
          ),
          title: const Text('Esneğim (Tarih fark etmez)'),
          trailing: const Icon(Icons.all_inclusive),
          onTap: () {
            setState(() { _selectedTime = 'Esnek'; });
          },
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
          controller: _locationController,
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
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ustaların bilmesi gereken ekstra bir detay var mı?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }
}
