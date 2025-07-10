import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';
import '../models/document_model.dart';

/// A raw text editor that displays rich text content and handles user input.
///
/// This widget is responsible for painting the text and managing input
/// directly, without relying on a `TextFormField`.
class RawEditor extends StatefulWidget {
  const RawEditor({
    super.key,
    required this.controller,
  });

  /// The controller that manages the document and selection.
  final RichTextEditorController controller;

  @override
  State<RawEditor> createState() => _RawEditorState();
}

class _RawEditorState extends State<RawEditor> with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _cursorBlink;

  @override
  void initState() {
    super.initState();
    // 컨트롤러와 포커스 노드에 리스너를 추가하여 UI를 갱신합니다.
    widget.controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));

    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // 애니메이션 컨트롤러가 값을 변경할 때마다 UI를 다시 그리도록 리스너를 추가합니다.
    _cursorBlink.addListener(() => setState(() {}));
    _cursorBlink.repeat();
  }

  @override
  void dispose() {
    // 등록된 리스너들을 모두 제거합니다.
    widget.controller.removeListener(() => setState(() {}));
    _focusNode.removeListener(() => setState(() {}));
    _cursorBlink.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final textPainter = TextPainter(
      text: TextSpan(
        children: widget.controller.document.spans.map((s) => s.toTextSpan()).toList(),
      ),
      textDirection: TextDirection.ltr,
      textAlign: widget.controller.document.textAlign,
    );
    textPainter.layout(maxWidth: renderBox.size.width);

    final position = textPainter.getPositionForOffset(details.localPosition);

    widget.controller.updateSelection(
      TextSelection.collapsed(offset: position.offset),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      child: Focus(
        focusNode: _focusNode,
        child: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (RawKeyEvent event) {
            // Key handling logic will be implemented in a later step.
          },
          child: CustomPaint(
            painter: DocumentPainter(
              document: widget.controller.document,
              selection: widget.controller.selection,
              isFocused: _focusNode.hasFocus,
              // 애니메이션의 현재 값을 painter에게 전달합니다.
              cursorOpacity: _cursorBlink.value,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

// DocumentPainter 클래스를 아래 코드로 교체해주세요.
class DocumentPainter extends CustomPainter {
  const DocumentPainter({
    required this.document,
    required this.selection,
    required this.isFocused,
    required this.cursorOpacity,
  });

  final DocumentModel document;
  final TextSelection selection;
  final bool isFocused;
  final double cursorOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final text = TextSpan(
      children: document.spans.map((s) => s.toTextSpan()).toList(),
    );

    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      textAlign: document.textAlign,
    );

    textPainter.layout(maxWidth: size.width);

    // 텍스트를 먼저 그립니다.
    textPainter.paint(canvas, Offset.zero);

    // 커서 그리기
    if (isFocused && selection.isCollapsed && cursorOpacity > 0.5) {
      final textPosition = TextPosition(offset: selection.baseOffset);
      final cursorOffset = textPainter.getOffsetForCaret(textPosition, Rect.zero);
      final cursorHeight = textPainter.getFullHeightForCaret(textPosition, Rect.zero) ?? 14.0;
      final cursorRect = Rect.fromLTWH(cursorOffset.dx, cursorOffset.dy, 2, cursorHeight);
      canvas.drawRect(cursorRect, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant DocumentPainter oldDelegate) {
    // 모든 속성이 변경될 때 다시 그리도록 합니다.
    return oldDelegate.document != document ||
        oldDelegate.selection != selection ||
        oldDelegate.isFocused != isFocused ||
        oldDelegate.cursorOpacity != cursorOpacity;
  }
}
