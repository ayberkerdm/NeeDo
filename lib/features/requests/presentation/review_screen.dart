import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../data/services/review_service.dart';
import '../../auth/data/providers/auth_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String serviceName;

  const ReviewScreen({
    super.key,
    required this.requestId,
    required this.serviceName,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _provider;

  @override
  void initState() {
    super.initState();
    _fetchProviderDetails();
  }

  Future<void> _fetchProviderDetails() async {
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('offers')
        .select('*, profiles(*)')
        .eq('request_id', widget.requestId)
        .eq('status', 'accepted')
        .maybeSingle();

    if (res != null && mounted) {
      setState(() {
        _provider = res['profiles'];
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _provider == null) return;
    
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(reviewServiceProvider).submitReview(
        providerId: _provider!['id'],
        customerId: user.id,
        requestId: widget.requestId,
        rating: _rating,
        comment: _commentController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değerlendirmeniz başarıyla gönderildi!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmeti Değerlendir'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.border,
              backgroundImage: _provider?['avatar_url'] != null ? NetworkImage(_provider!['avatar_url']) : null,
              child: _provider?['avatar_url'] == null ? const Icon(Icons.person, color: AppColors.textSecondary, size: 40) : null,
            ),
            const SizedBox(height: AppSizes.p16),
            Text(_provider?['full_name'] ?? 'Yükleniyor...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.serviceName, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.p48),
            Text('Hizmet deneyimini nasıl değerlendirirsin?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.p24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: AppSizes.p32),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Yorumunu buraya yazabilirsin...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: AppSizes.p32),
            PrimaryButton(
              text: 'Değerlendirmeyi Gönder',
              isLoading: _isLoading,
              onPressed: _rating > 0 && _provider != null ? _submitReview : null,
            )
          ],
        ),
      ),
    );
  }
}
