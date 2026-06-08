import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/chat_message_model.dart';
import '../../viewmodels/chat_viewmodel.dart';
import 'solicitar_cita_view.dart';

/// Chatbot de acompanamiento emocional "Calma".
/// No diagnostica: escucha, comprende y alienta. Ante senales de riesgo
/// sugiere agendar una cita con un psicologo.
class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatViewModel>().loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<ChatViewModel>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Calma · Acompañamiento',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          const _ChatDisclaimer(),
          if (vm.suggestAppointment) const _AppointmentSuggestion(),
          Expanded(
            child: vm.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.mint),
                  )
                : !vm.hasMessages
                ? const _EmptyChatState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: vm.messages.length,
                    itemBuilder: (context, index) {
                      return _MessageBubble(message: vm.messages[index]);
                    },
                  ),
          ),
          if (vm.isSending) const _TypingIndicator(),
          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                vm.errorMessage!,
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          _ChatComposer(
            controller: _controller,
            isSending: vm.isSending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ChatDisclaimer extends StatelessWidget {
  const _ChatDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_border, color: AppColors.lavender, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Soy un asistente de acompañamiento, no reemplazo a un '
              'profesional. Estoy aquí para escucharte.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentSuggestion extends StatelessWidget {
  const _AppointmentSuggestion();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Te gustaría hablarlo con alguien preparado?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pedir ayuda es un acto de valentía. Puedes agendar una cita con un '
            'psicólogo desde el módulo de Citas. Si es una emergencia, llama al '
            '911 o a la línea de ayuda emocional 171 (opción 6).',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SolicitarCitaView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('Agendar una cita'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => context
                    .read<ChatViewModel>()
                    .dismissAppointmentSuggestion(),
                child: Text(
                  'Ahora no',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: AppColors.lavender,
            ),
            const SizedBox(height: 16),
            Text(
              'Hola, soy Calma',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuéntame cómo te sientes hoy. Estoy aquí para escucharte sin '
              'juzgarte, a tu ritmo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bgColor = isUser
        ? AppColors.secondaryContainer
        : AppColors.surfaceHigh;
    final textColor = AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
        ),
      ),
    );
  }
}

class _BouncingDotsIndicator extends StatefulWidget {
  const _BouncingDotsIndicator();

  @override
  State<_BouncingDotsIndicator> createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<_BouncingDotsIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!mounted) return;
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const _BouncingDotsIndicator(),
          ),
          const SizedBox(width: 10),
          Text(
            'Calma está escribiendo...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Escribe cómo te sientes…',
                  filled: true,
                  fillColor: AppColors.surfaceLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => isSending ? null : onSend(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: Material(
                color: AppColors.buttonPrimary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isSending ? null : onSend,
                  child: Icon(
                    Icons.send_rounded,
                    color: AppColors.buttonPrimaryText,
                    size: 22,
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
