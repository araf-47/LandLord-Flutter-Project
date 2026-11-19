import 'package:flutter/material.dart';
import '../../core/ai/offline_ai_assistant.dart';
import '../../ui/theme/app_theme.dart';

class AiChatMessage {
  final String text;
  final bool isUser;
  AiChatMessage({required this.text, required this.isUser});
}

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<AiChatMessage> _messages = [
    AiChatMessage(
      text: "👋 Hello! I am your LandLord AI Advisor.\n\nAsk me about rental yields, lease agreements, Bangladeshi tenant law, rent adjustments, or maintenance strategies.",
      isUser: false,
    ),
  ];

  void _send() {
    final query = _inputCtrl.text.trim();
    if (query.isEmpty) return;
    _inputCtrl.clear();

    setState(() {
      _messages.add(AiChatMessage(text: query, isUser: true));
    });

    final reply = OfflineAiAssistant.getResponse(query);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _messages.add(AiChatMessage(text: reply, isUser: false));
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('LandLord AI Advisor'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return Align(
                    alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      decoration: BoxDecoration(
                        color: m.isUser
                            ? AppColors.primary
                            : (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: m.isUser ? null : Border.all(color: const Color(0xFF334155), width: 0.5),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          color: m.isUser
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                          fontSize: 14,
                          height: 1.4,
                        ),
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
                      controller: _inputCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ask about rent, yields, maintenance...',
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
