import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../landlord_provider.dart';

class ChatThreadScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatThreadScreen({super.key, required this.conversation});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<MessageItem> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await context.read<LandlordProvider>().getMessages(widget.conversation.id);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();

    await context.read<LandlordProvider>().sendMessage(widget.conversation.id, text);
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.tenantName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index];
                        final isMe = m.senderType == 'landlord';

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : const Color(0xFF334155),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
                                bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              m.content,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: const Border(top: BorderSide(color: Color(0xFF334155), width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a reply to tenant...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
