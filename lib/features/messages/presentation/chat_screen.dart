import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person, size: 16, color: AppColors.textSecondary),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmet Usta', style: TextStyle(fontSize: 16)),
                Text('Çevrimiçi', style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProposalSummary(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.p16),
              children: [
                _buildSystemMessage('Dün, 14:30'),
                _buildMessageBubble('Merhaba, fiyat teklifimi ilettim incelerseniz sevinirim.', false, '14:35'),
                _buildMessageBubble('Evet gördüm, temizlenecek alan 120 metrekare, sorun olmaz değil mi?', true, '14:40'),
                _buildMessageBubble('Hiç problem değil, kendi malzemelerimizle geliyoruz ekstra bir şeye gerek yok.', false, '14:42'),
                _buildSystemMessage('Bugün, 10:40'),
                _buildMessageBubble('Konum bilgisi atabilir misiniz?', false, '10:42'),
              ],
            ),
          ),
          _buildChatInputRow(),
        ],
      ),
    );
  }

  Widget _buildProposalSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      margin: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.p12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Teklif Özeti: Ev Temizliği', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Teklif edilen fiyat: 1200 TL', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                border: isMe ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                text,
                style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInputRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textHint),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
