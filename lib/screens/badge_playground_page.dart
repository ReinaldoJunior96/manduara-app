import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../playground/playground_source_bridge.dart';
import '../theme/triluma_theme.dart';
import '../widgets/playground/playground_badge.dart';

class BadgePlaygroundPage extends StatefulWidget {
  const BadgePlaygroundPage({super.key});

  static const routeName = '/badge-playground';

  @override
  State<BadgePlaygroundPage> createState() => _BadgePlaygroundPageState();
}

class _BadgePlaygroundPageState extends State<BadgePlaygroundPage> {
  static const _sourceAsset = 'lib/widgets/playground/playground_badge.dart';
  final _sourceBridge = const PlaygroundSourceBridge();
  final _codeController = TextEditingController();
  final _editorScrollController = ScrollController();
  final _gutterScrollController = ScrollController();

  String _initialSource = '';
  String _status = 'Carregando o código-fonte compilado…';
  bool _saving = false;
  bool _darkPreview = true;
  double _zoom = 1;
  int _restartToken = 0;

  @override
  void initState() {
    super.initState();
    _editorScrollController.addListener(_syncGutter);
    _loadSource();
  }

  Future<void> _loadSource() async {
    final bundled = await rootBundle.loadString(_sourceAsset);
    final local = await _sourceBridge.loadSource();
    if (!mounted) return;
    final source = local ?? bundled;
    _initialSource = source;
    _codeController.text = source;
    setState(() {
      _status = local == null
          ? 'Fonte incluída no app. Inicie o helper local para habilitar a gravação.'
          : 'Conectado ao arquivo local. Salvar grava o .dart; use Hot Reload para compilar.';
    });
  }

  void _syncGutter() {
    if (!_gutterScrollController.hasClients) return;
    final target = _editorScrollController.offset.clamp(
      0.0,
      _gutterScrollController.position.maxScrollExtent,
    );
    _gutterScrollController.jumpTo(target);
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _codeController.text));
    if (mounted) setState(() => _status = 'Código copiado.');
  }

  void _restoreCode() {
    _codeController
      ..text = _initialSource
      ..selection = TextSelection.collapsed(offset: _initialSource.length);
    setState(() => _status = 'Texto restaurado para a versão carregada.');
  }

  Future<void> _saveCode() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _status = 'Gravando no arquivo local…';
    });
    final result = await _sourceBridge.saveSource(_codeController.text);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _status = result.message;
      if (result.saved) _initialSource = _codeController.text;
    });
  }

  @override
  void dispose() {
    _editorScrollController
      ..removeListener(_syncGutter)
      ..dispose();
    _gutterScrollController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Text(
          'Badge Playground',
          style: TrilumaTheme.editorial.copyWith(fontSize: 28),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: Center(
              child: Text(
                'AMBIENTE LOCAL · HOT RELOAD',
                style: TextStyle(
                  color: TrilumaColors.secondary,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final editor = _EditorPanel(
            controller: _codeController,
            editorScrollController: _editorScrollController,
            gutterScrollController: _gutterScrollController,
            status: _status,
            saving: _saving,
            onCopy: _copyCode,
            onRestore: _restoreCode,
            onSave: _saveCode,
          );
          final preview = _PreviewPanel(
            dark: _darkPreview,
            zoom: _zoom,
            restartToken: _restartToken,
            onDarkChanged: (value) => setState(() => _darkPreview = value),
            onZoomChanged: (value) => setState(() => _zoom = value),
            onRestart: () => setState(() => _restartToken++),
          );
          if (constraints.maxWidth >= 980) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 11, child: editor),
                const VerticalDivider(width: 1),
                Expanded(flex: 9, child: preview),
              ],
            );
          }
          return Column(
            children: [
              Expanded(child: editor),
              const Divider(height: 1),
              Expanded(child: preview),
            ],
          );
        },
      ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.controller,
    required this.editorScrollController,
    required this.gutterScrollController,
    required this.status,
    required this.saving,
    required this.onCopy,
    required this.onRestore,
    required this.onSave,
  });

  final TextEditingController controller;
  final ScrollController editorScrollController;
  final ScrollController gutterScrollController;
  final String status;
  final bool saving;
  final VoidCallback onCopy;
  final VoidCallback onRestore;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111917),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editor Dart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'playground_badge.dart',
                        style: TextStyle(
                          color: Color(0xFF8BA49D),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copiar código',
                  onPressed: onCopy,
                  color: Colors.white,
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: 'Restaurar texto carregado',
                  onPressed: onRestore,
                  color: Colors.white,
                  icon: const Icon(Icons.restore),
                ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Salvar .dart'),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF17231F),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFFEAD7AA)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O preview executa o widget já compilado. Depois de salvar, acione Hot Reload no Flutter.',
                    style: TextStyle(color: Color(0xFFEAD7AA), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final lineCount = '\n'.allMatches(controller.text).length + 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 54,
                      color: const Color(0xFF0D1412),
                      child: SingleChildScrollView(
                        controller: gutterScrollController,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(8, 16, 10, 32),
                        child: Text(
                          List.generate(
                            lineCount,
                            (index) => '${index + 1}',
                          ).join('\n'),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFF587068),
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Scrollbar(
                            controller: editorScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: math.max(constraints.maxWidth, 920),
                                height: constraints.maxHeight,
                                child: TextField(
                                  controller: controller,
                                  scrollController: editorScrollController,
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(
                                    color: Color(0xFFE3ECE8),
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    height: 1.55,
                                  ),
                                  cursorColor: TrilumaColors.teal,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(
                                      14,
                                      16,
                                      24,
                                      32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            color: const Color(0xFF17231F),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 15, color: Color(0xFF8BA49D)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB7CBC5),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.dark,
    required this.zoom,
    required this.restartToken,
    required this.onDarkChanged,
    required this.onZoomChanged,
    required this.onRestart,
  });

  final bool dark;
  final double zoom;
  final int restartToken;
  final ValueChanged<bool> onDarkChanged;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final background = dark
        ? const Color(0xFF052F2A)
        : TrilumaColors.background;
    final foreground = dark ? Colors.white : TrilumaColors.text;
    return ColoredBox(
      color: background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Preview compilado',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? TrilumaColors.text
                          : foreground,
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? TrilumaColors.surface
                          : Colors.transparent,
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: foreground.withValues(alpha: .45)),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Claro'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Escuro'),
                    ),
                  ],
                  selected: {dark},
                  onSelectionChanged: (selection) =>
                      onDarkChanged(selection.first),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Reiniciar animação',
                  onPressed: onRestart,
                  color: foreground,
                  icon: const Icon(Icons.replay),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = math
                    .min(
                      constraints.maxWidth * .68,
                      constraints.maxHeight * .78,
                    )
                    .clamp(220.0, 520.0);
                return ClipRect(
                  child: Center(
                    child: Transform.scale(
                      scale: zoom,
                      child: SizedBox.square(
                        dimension: side,
                        child: PlaygroundBadge(restartToken: restartToken),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Row(
              children: [
                Icon(Icons.zoom_out, color: foreground),
                Expanded(
                  child: Slider(
                    value: zoom,
                    min: .6,
                    max: 1.35,
                    divisions: 15,
                    label: '${(zoom * 100).round()}%',
                    onChanged: onZoomChanged,
                  ),
                ),
                Icon(Icons.zoom_in, color: foreground),
                const SizedBox(width: 12),
                Text(
                  '${(zoom * 100).round()}%',
                  style: TextStyle(
                    color: foreground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
