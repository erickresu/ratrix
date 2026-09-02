import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../rates_colors.dart';

class _ChatMsg {
  const _ChatMsg({required this.fromUser, required this.text});

  final bool fromUser;
  final String text;
}

/// UI-only preview of an AI assistant — no backend wired up yet. Replies
/// are canned locally so the shape of the feature is visible without
/// promising a working model behind it.
class RatrixAiChatWidget extends StatefulWidget {
  const RatrixAiChatWidget({super.key});

  @override
  State<RatrixAiChatWidget> createState() => _RatrixAiChatWidgetState();
}

class _RatrixAiChatWidgetState extends State<RatrixAiChatWidget> {
  bool _open = false;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMsg>[
    const _ChatMsg(
      fromUser: false,
      text:
          "Hi, I'm Ratrix AI! I can help you find rates, calculate "
          'freight, and more — ask me anything.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(fromUser: true, text: text));
      _messages.add(
        const _ChatMsg(
          fromUser: false,
          text: "I'm still learning — full answers are coming soon!",
        ),
      );
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void openPanel() => setState(() => _open = true);
  void closePanel() => setState(() => _open = false);

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _ChatBubble(state: this),
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: closePanel,
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _ChatPanel(state: this),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.state});

  final _RatrixAiChatWidgetState state;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.primary,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: state.openPanel,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Icon(CupertinoIcons.sparkles, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({required this.state});

  final _RatrixAiChatWidgetState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 440,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadowCard,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _PanelHeader(state: state),
          Expanded(
            child: ListView.builder(
              controller: state._scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state._messages.length,
              itemBuilder: (context, i) =>
                  _MessageBubble(msg: state._messages[i]),
            ),
          ),
          _PanelInput(state: state),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.state});

  final _RatrixAiChatWidgetState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: RatesColors.dark.sidebarBg,
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Ratrix AI',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Preview',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: state.closePanel,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.xmark,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg});

  final _ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: msg.fromUser
              ? context.colors.primary
              : context.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: msg.fromUser ? Colors.white : context.colors.textBody,
          ),
        ),
      ),
    );
  }
}

class _PanelInput extends StatelessWidget {
  const _PanelInput({required this.state});

  final _RatrixAiChatWidgetState state;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: state._controller,
                onSubmitted: (_) => state._send(),
                style: TextStyle(fontSize: 13, color: context.colors.textBody),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Ask Ratrix AI...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: context.colors.textFaint,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.borderStrong),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: state._send,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    CupertinoIcons.arrow_up,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
