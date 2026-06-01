import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../auth/data/providers/auth_provider.dart';
import '../data/services/message_service.dart';
import '../data/models/message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        ref.read(messageServiceProvider).markMessagesAsRead(user.id, widget.otherUserId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    _messageController.clear();

    try {
      await ref.read(messageServiceProvider).sendMessage(
        senderId: user.id,
        receiverId: widget.otherUserId,
        content: text,
      );
      // Auto scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100, // Roughly scroll down
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Giriş yapınız.')));
    }

    final messageService = ref.read(messageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person, size: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName, style: const TextStyle(fontSize: 16)),
                const Text('Çevrimiçi', style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: messageService.getChatMessages(user.id, widget.otherUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                
                // Keep marked as read
                if (messages.any((m) => m.receiverId == user.id && !m.isRead)) {
                  messageService.markMessagesAsRead(user.id, widget.otherUserId);
                }

                if (messages.isEmpty) {
                  return const Center(child: Text('Henüz mesaj yok', style: TextStyle(color: AppColors.textHint)));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == user.id;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildChatInputRow(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.content,
                    style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}', 
                  style: const TextStyle(fontSize: 10, color: AppColors.textHint)
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.check,
                    size: 14,
                    color: msg.isRead ? AppColors.primary : AppColors.textHint,
                  ),
                ]
              ],
            ),
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
            Expanded(
              child: TextField(
                controller: _messageController,
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
                onSubmitted: (_) => _sendMessage(),
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
                onPressed: _sendMessage,
              ),
            )
          ],
        ),
      ),
    );
  }
}
