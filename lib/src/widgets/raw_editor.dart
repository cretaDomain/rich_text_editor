import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _RawEditorState extends State<RawEditor>
    with SingleTickerProviderStateMixin, TextInputClient {
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _cursorBlink;
  TextInputConnection? _connection;

  @override
  void initState() {
    super.initState();
    // 컨트롤러와 포커스 노드에 리스너를 추가하여 UI를 갱신합니다.
    widget.controller.addListener(() => setState(() {}));
    _focusNode.addListener(_onFocusChanged);

    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // 애니메이션 컨트롤러가 값을 변경할 때마다 UI를 다시 그리도록 리스너를 추가합니다.
    _cursorBlink.addListener(() => setState(() {}));
    _cursorBlink.repeat();

    if (_focusNode.hasFocus) {
      _openConnection();
    }
  }

  @override
  void dispose() {
    // 등록된 리스너들을 모두 제거합니다.
    widget.controller.removeListener(() => setState(() {}));
    _focusNode.removeListener(_onFocusChanged);
    _closeConnection();
    _cursorBlink.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      if (_focusNode.hasFocus) {
        _openConnection();
      } else {
        _closeConnection();
      }
    });
  }

  void _openConnection() {
    if (_connection?.attached != true) {
      _connection = TextInput.attach(
        this,
        const TextInputConfiguration(
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline, // Explicitly set the action
        ),
      );
      _connection!.setEditingState(currentTextEditingValue);
      _connection!.show();
    }
  }

  @override
  void connectionClosed() {
    // 연결이 닫혔을 때의 처리 (필요시 구현)
  }

  void _closeConnection() {
    if (_connection?.attached == true) {
      _connection!.close();
      _connection = null;
    }
  }

  // -- TextInputClient implementation --

  @override
  TextEditingValue get currentTextEditingValue {
    return TextEditingValue(
      text: widget.controller.document.toPlainText(),
      selection: widget.controller.selection,
    );
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    // 컨트롤러에 모든 변경사항을 위임합니다.
    // 컨트롤러는 텍스트 변경(diffing), 선택 영역 변경, 스타일 업데이트,
    // 그리고 UI 갱신까지 모두 처리합니다.
    widget.controller.updateFromTextInput(value);
  }

  @override
  void performAction(TextInputAction action) {
    if (action == TextInputAction.newline) {
      // When the 'newline' action is received, insert a newline character.
      final oldValue = currentTextEditingValue;
      final newText = oldValue.text.replaceRange(
        oldValue.selection.start,
        oldValue.selection.end,
        '\n',
      );
      final newValue = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: oldValue.selection.start + 1),
      );
      updateEditingValue(newValue);
    } else {
      // For other actions like 'done', unfocus the editor.
      _focusNode.unfocus();
    }
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    // 개인적인 명령 처리 (필요시 구현)
  }

  @override
  void showAutocorrectionPromptRect(int start, int end) {
    // 자동 수정 프롬프트 표시 (필요시 구현)
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    // 플로팅 커서 업데이트 (필요시 구현)
  }

  @override
  AutofillScope? get currentAutofillScope => null;

  // -- End of TextInputClient implementation --

  TextPainter _createTextPainter(Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        children: widget.controller.document.spans.map((s) => s.toTextSpan()).toList(),
      ),
      textDirection: TextDirection.ltr,
      textAlign: widget.controller.document.textAlign,
    );
    textPainter.layout(maxWidth: size.width);
    return textPainter;
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
    // _openConnection();  <-- This call is redundant and is removed.
    // The connection should only be managed by the _onFocusChanged listener.

    final textPainter = _createTextPainter(context.size!);
    final position = textPainter.getPositionForOffset(details.localPosition);
    widget.controller.updateSelection(
      TextSelection.collapsed(offset: position.offset),
    );

    // 중요: 변경된 선택 영역을 시스템 IME에 즉시 알려 상태를 동기화합니다.
    _connection?.setEditingState(currentTextEditingValue);
  }

  void _handlePanStart(DragStartDetails details) {
    // 탭으로 시작하므로, 커서 위치를 먼저 잡습니다.
    final textPainter = _createTextPainter(context.size!);
    final position = textPainter.getPositionForOffset(details.localPosition);
    widget.controller.updateSelection(
      TextSelection.collapsed(offset: position.offset),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final textPainter = _createTextPainter(context.size!);
    final position = textPainter.getPositionForOffset(details.localPosition);
    widget.controller.updateSelection(
      widget.controller.selection.copyWith(
        extentOffset: position.offset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
            // Intercept the Tab key event to insert a tab character.
            final oldValue = currentTextEditingValue;
            final newText = oldValue.text.replaceRange(
              oldValue.selection.start,
              oldValue.selection.end,
              '\t',
            );
            final newValue = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: oldValue.selection.start + 1),
            );
            updateEditingValue(newValue);
            return KeyEventResult.handled; // Mark the event as handled.
          }
          // For all other keys, let the system and TextInputClient handle them.
          return KeyEventResult.ignored;
        },
        child: CustomPaint(
          painter: DocumentPainter(
            document: widget.controller.document,
            selection: widget.controller.selection,
            isFocused: _focusNode.hasFocus,
            cursorOpacity: _cursorBlink.value,
          ),
          size: Size.infinite,
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

    // 선택 영역 그리기 (텍스트보다 먼저)
    if (!selection.isCollapsed) {
      final selectionColor = Colors.blue.withValues(alpha: 0.3);
      final selectionBoxes = textPainter.getBoxesForSelection(selection);
      for (final box in selectionBoxes) {
        canvas.drawRect(box.toRect(), Paint()..color = selectionColor);
      }
    }

    // 텍스트 그리기
    textPainter.paint(canvas, Offset.zero);

    // 커서 그리기 (텍스트보다 나중에)
    if (isFocused && selection.isCollapsed && cursorOpacity > 0.5) {
      final textPosition = TextPosition(offset: selection.baseOffset);
      final cursorOffset = textPainter.getOffsetForCaret(textPosition, Rect.zero);
      final cursorHeight = textPainter.getFullHeightForCaret(textPosition, Rect.zero);
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
