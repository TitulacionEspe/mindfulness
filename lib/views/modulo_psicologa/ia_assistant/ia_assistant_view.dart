import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/viewmodels_psicologa/ia_chat_viewmodel.dart';

class IAAssistantView extends StatefulWidget {
  const IAAssistantView({super.key});

  @override
  State<IAAssistantView> createState() => _IAAssistantViewState();
}

class _IAAssistantViewState extends State<IAAssistantView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profId = context.read<AuthViewModel>().currentUser?.id;
      if (profId != null) {
        context.read<IAChatViewModel>().init(profId);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _focusNode.requestFocus();

    await context.read<IAChatViewModel>().sendMessage(text);
    _scrollToBottom();
  }

  // ── Confirmación: limpiar chat actual ───────────────────────────────────

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Limpiar chat',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Borrar la conversación actual?\nEl historial se conserva.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<IAChatViewModel>().clearCurrentChat();
              Navigator.pop(ctx);
            },
            child: Text(
              'Limpiar',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirmación: eliminar grupo del historial ──────────────────────────

  void _confirmDeleteMessages(List<String> ids) {
    if (ids.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar conversación',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Eliminar esta conversación del historial?\nEsta acción no se puede deshacer.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<IAChatViewModel>().deleteHistoryMessages(ids);
              Navigator.pop(ctx);
            },
            child: Text(
              'Eliminar',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Agrupar mensajes del historial por fecha ────────────────────────────

  List<_DateGroup> _groupByDate(List<dynamic> messages) {
    if (messages.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<dynamic>>{};

    for (final msg in messages) {
      final date = msg.createdAt ?? now;
      final day = DateTime(date.year, date.month, date.day);

      String label;
      if (day == today) {
        label = 'Hoy';
      } else if (day == yesterday) {
        label = 'Ayer';
      } else if (day.isAfter(weekAgo)) {
        label = 'Esta semana';
      } else {
        label = 'Anteriores';
      }

      groups.putIfAbsent(label, () => []).add(msg);
    }

    return groups.entries
        .map((e) => _DateGroup(label: e.key, messages: e.value))
        .toList();
  }

  // ── AppBar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(IAChatViewModel vm) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Asistente IA',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        if (vm.chatMessages.isNotEmpty)
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Limpiar chat',
            onPressed: _confirmClearChat,
          ),
        IconButton(
          icon: Icon(Icons.menu_rounded, color: AppColors.textSecondary),
          tooltip: 'Historial',
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  // ── Drawer (Historial) ──────────────────────────────────────────────────

  Widget _buildDrawer(IAChatViewModel vm) {
    final groups = _groupByDate(vm.historyMessages);

    return Drawer(
      backgroundColor: AppColors.surfaceLowest,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (vm.historyMessages.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                      tooltip: 'Vaciar todo',
                      onPressed: () => _confirmDeleteAll(vm),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    vm.clearCurrentChat();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.add_rounded,
                    color: AppColors.mint,
                    size: 20,
                  ),
                  label: Text(
                    'Nuevo chat',
                    style: TextStyle(
                      color: AppColors.mint,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppColors.successBg,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: AppColors.outlineVariant,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: groups.isEmpty
                  ? Center(
                      child: Text(
                        'Sin conversaciones previas',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: groups.length,
                      itemBuilder: (_, i) => _buildDateGroup(groups[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(IAChatViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Vaciar historial',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Eliminar TODO el historial?\nEsta acción no se puede deshacer.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              vm.deleteAllHistory();
              Navigator.pop(ctx);
            },
            child: Text(
              'Eliminar todo',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(_DateGroup group) {
    // Cada mensaje del usuario es una conversación independiente
    final userMessages = group.messages.where((m) => m.role == 'user').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            group.label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (userMessages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'Sin mensajes',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          )
        else
          ...userMessages.map((userMsg) {
            final preview = userMsg.content.length > 40
                ? '${userMsg.content.substring(0, 40)}...'
                : userMsg.content;
            final idsToDelete = <String>[];
            if (userMsg.id != null) idsToDelete.add(userMsg.id as String);
            final userIndex = group.messages.indexOf(userMsg);
            if (userIndex != -1 && userIndex + 1 < group.messages.length) {
              final next = group.messages[userIndex + 1];
              if (next.role == 'assistant' && next.id != null) {
                idsToDelete.add(next.id as String);
              }
            }
            return _buildHistoryItem(preview, userMsg, idsToDelete);
          }),
      ],
    );
  }

  Widget _buildHistoryItem(
    String preview,
    dynamic userMsg,
    List<String> idsToDelete,
  ) {
    final key = userMsg.id ?? preview;
    return Dismissible(
      key: Key('$key'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
      ),
      confirmDismiss: (_) async {
        if (idsToDelete.isNotEmpty) {
          _confirmDeleteMessages(idsToDelete);
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      preview,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Lista de mensajes del chat ──────────────────────────────────────────

  Widget _buildMessageList(IAChatViewModel vm) {
    if (vm.chatMessages.isEmpty && !vm.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 32,
                color: AppColors.mint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '¿En qué puedo ayudarte?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Genera guías, visualizaciones,\nresúmenes y contenido terapéutico.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: vm.chatMessages.length + (vm.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == vm.chatMessages.length) {
            return _buildTypingBubble();
          }
          final msg = vm.chatMessages[index];
          return _ChatBubble(text: msg.content, isUser: msg.role == 'user');
        },
      ),
    );
  }

  // ── Indicador "escribiendo..." ──────────────────────────────────────────

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: _TypingDots(),
      ),
    );
  }

  // ── Input ───────────────────────────────────────────────────────────────

  Widget _buildInputArea(bool loading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !loading,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: loading ? AppColors.surfaceHigh : AppColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: loading
                    ? AppColors.textSecondary
                    : AppColors.buttonPrimaryText,
                size: 20,
              ),
              onPressed: loading ? null : _sendMessage,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<IAChatViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(viewModel),
      endDrawer: _buildDrawer(viewModel),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(viewModel)),
          _buildInputArea(viewModel.isLoading),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Burbuja de chat
// ═══════════════════════════════════════════════════════════════════════════

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.successBg : AppColors.surfaceHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 22),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Indicador de "escribiendo..." con puntos animados
// ═══════════════════════════════════════════════════════════════════════════

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * (t < 0.5 ? t * 2 : (1 - t) * 2);
            final opacity = 0.3 + 0.7 * scale;
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Modelo auxiliar
// ═══════════════════════════════════════════════════════════════════════════

class _DateGroup {
  final String label;
  final List<dynamic> messages;
  const _DateGroup({required this.label, required this.messages});
}
