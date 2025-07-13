import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/rich_text_editor_controller.dart';
import '../models/document_model.dart';
//import '../models/text_span_model.dart';

/// A raw text editor that displays rich text content and handles user input.
///
/// This widget is responsible for painting the text and managing input
/// directly, without relying on a `TextFormField`.
class RawEditor extends StatefulWidget {
  const RawEditor({
    super.key,
    required this.controller,
    required this.scrollController,
    this.onFocusLost,
    required this.width,
    required this.height,
  });

  /// The controller that manages the document and selection.
  final RichTextEditorController controller;
  final ScrollController scrollController;

  final VoidCallback? onFocusLost;
  final double width;
  final double height;

  @override
  State<RawEditor> createState() => _RawEditorState();
}

class _RawEditorState extends State<RawEditor>
    with SingleTickerProviderStateMixin, TextInputClient {
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _cursorBlink;
  TextInputConnection? _connection;
  DateTime _lastTapTime = DateTime.now();
  int _tapCount = 0;
  final GlobalKey _editorKey = GlobalKey();

  //int? _scrollOffset;

  // final int _previousLineNumber = -1;
  // final double _upVias = 1.0;
  // final double _downVias = 1.0;

  // A listener function to trigger rebuilds when the controller changes.
  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Add the listener.
    widget.controller.addListener(_rebuild);
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
    // Make sure to remove the listener using the exact same function object.
    widget.controller.removeListener(_rebuild);
    _focusNode.removeListener(_onFocusChanged);
    _closeConnection();
    _cursorBlink.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    //setState(() {
    //debugPrint(
    //    '[RawEditor] _onFocusChanged: hasFocus=${_focusNode.hasFocus}, selection=${widget.controller.selection}');
    if (_focusNode.hasFocus) {
      _openConnection();
    } else {
      _closeConnection();
      widget.onFocusLost?.call();
    }
    //});
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
      //debugPrint(
      //    '[RawEditor] _openConnection: setEditingState with ${currentTextEditingValue.selection}');
      _connection!.setEditingState(currentTextEditingValue);
      _connection!.show();
      _updateSizeAndTransform();
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

  void _updateSizeAndTransform() {
    if (_connection == null || _editorKey.currentContext == null) {
      return;
    }
    final RenderBox? renderBox = _editorKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;

      //print('******** size: $size');
      final transform = renderBox.getTransformTo(null);
      _connection!.setEditableSizeAndTransform(
        size,
        //Size(widget.width, widget.height),
        transform,
      );
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

  void _selectWordAt(TextPosition position, TextPainter textPainter) {
    // Get the word boundary at the given position.
    final TextRange word = textPainter.getWordBoundary(position);
    // Update the selection to encompass the word.
    widget.controller.updateSelection(
      TextSelection(baseOffset: word.start, extentOffset: word.end),
    );
  }

  void _selectParagraphAt(TextPosition position, TextPainter textPainter) {
    final String plainText = widget.controller.document.toPlainText();
    final int offset = position.offset;

    // Find the start of the paragraph (previous newline).
    int start = plainText.lastIndexOf('\n', offset - 1);
    if (start == -1) {
      start = 0; // Beginning of the document
    } else {
      start += 1; // Move after the newline character
    }

    // Find the end of the paragraph (next newline).
    int end = plainText.indexOf('\n', offset);
    if (end == -1) {
      end = plainText.length; // End of the document
    }

    widget.controller.updateSelection(
      TextSelection(baseOffset: start, extentOffset: end),
    );
  }

  void _handleTapDown(TapDownDetails details, TextPainter textPainter) {
    final RenderBox renderBox = _editorKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPositionInSizedBox = renderBox.globalToLocal(details.globalPosition);

    final parentSize = renderBox.size;
    final childSize = textPainter.size;
    final alignment = _calculateAlignment(
        widget.controller.document.textAlign, widget.controller.document.textAlignVertical);
    final double dx = (parentSize.width - childSize.width) * (alignment.x + 1) / 2;
    final double dy = (parentSize.height - childSize.height) * (alignment.y + 1) / 2;
    final offset = Offset(dx, dy);

    final localPosition = localPositionInSizedBox - offset;

    final position = textPainter.getPositionForOffset(localPosition);

    // --- Tap counting logic ---
    final now = DateTime.now();
    if (now.difference(_lastTapTime) < const Duration(milliseconds: 300)) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }
    _lastTapTime = now;

    switch (_tapCount) {
      case 1:
        // Single tap: move cursor
        //print('******** position: $position, ${position.offset}');
        //_scrollOffset = position.offset;
        widget.controller.updateSelection(
          TextSelection.collapsed(offset: position.offset),
        );
        break;
      case 2:
        // Double tap: select word
        _selectWordAt(position, textPainter);
        break;
      case 3:
        // Triple tap: select paragraph and reset count
        _selectParagraphAt(position, textPainter);
        _tapCount = 0; // Reset after triple tap
        break;
    }

    // 2. selection 업데이트 후 포커스 및 IME 상태를 처리합니다.
    if (_focusNode.hasFocus) {
      // 이미 포커스가 있다면, 변경된 selection을 즉시 IME에 알립니다.
      _connection?.setEditingState(currentTextEditingValue);
    } else {
      // 포커스가 없다면, 요청만 합니다.
      // _onFocusChanged 리스너가 (이미 업데이트된) selection으로 IME 상태를 설정할 것입니다.
      _focusNode.requestFocus();
    }
  }
/*
  void _handlePanStart(DragStartDetails details) {
    // 탭으로 시작하므로, 커서 위치를 먼저 잡습니다.
    final RenderBox renderBox = _editorKey.currentContext!.findRenderObject() as RenderBox;

    final textPainter = _createTextPainter(context.size!);
    // if (textPainter.computeLineMetrics().length > 1) {
    //   return; // 2줄 이상이면 드래그 비활성화
    // }

    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    final Offset correctedPosition = Offset(
      localPosition.dx,
      localPosition.dy + 0, //_scrollOffset, //widget.scrollController.offset,
    );

    final position = textPainter.getPositionForOffset(correctedPosition);
    widget.controller.updateSelection(
      TextSelection.collapsed(offset: position.offset),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = _editorKey.currentContext!.findRenderObject() as RenderBox;

    final textPainter = _createTextPainter(context.size!);
    // if (textPainter.computeLineMetrics().length > 1) {
    //   return; // 2줄 이상이면 드래그 비활성화
    // }

    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    final position = textPainter.getPositionForOffset(localPosition);
    widget.controller.updateSelection(
      widget.controller.selection.copyWith(
        extentOffset: position.offset,
      ),
    );
  }
  */

  void _handlePanEnd(DragEndDetails details, TextPainter textPainter) {
    final RenderBox renderBox = _editorKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPositionInSizedBox = renderBox.globalToLocal(details.globalPosition);

    final parentSize = renderBox.size;
    final childSize = textPainter.size;
    final alignment = _calculateAlignment(
        widget.controller.document.textAlign, widget.controller.document.textAlignVertical);
    final double dx = (parentSize.width - childSize.width) * (alignment.x + 1) / 2;
    final double dy = (parentSize.height - childSize.height) * (alignment.y + 1) / 2;
    final offset = Offset(dx, dy);

    final localPosition = localPositionInSizedBox - offset;

    final position = textPainter.getPositionForOffset(localPosition);
    widget.controller.updateSelection(
      widget.controller.selection.copyWith(
        extentOffset: position.offset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build가 끝난 후 프레임이 렌더링되고 나면 사이즈와 위치를 업데이트합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // final textPainter = _createTextPainter(context.size!);
        // print('******** textPainter.size: ${textPainter.size}');
        _updateSizeAndTransform();
      }
    });

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        // For all other keys, let the system and TextInputClient handle them.
        return KeyEventResult.ignored;
      },
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          key: _editorKey,
          child: LayoutBuilder(builder: (context, constraints) {
            final textPainter = _createTextPainter(constraints.biggest);

            final painter = CustomPaint(
              painter: DocumentPainter(
                document: widget.controller.document,
                selection: widget.controller.selection,
                isFocused: _focusNode.hasFocus,
                cursorOpacity: _cursorBlink.value,
                textPainter: textPainter,
              ),
              size: textPainter.size,
            );

            final gestureHandler = GestureDetector(
              onTapDown: (details) => _handleTapDown(details, textPainter),
              // onPanStart: _handlePanStart, //<-- 절대로 하면 안됨됨
              // onPanUpdate: _handlePanUpdate, //<-- 절대로 하면 안됨
              onPanEnd: (details) => _handlePanEnd(details, textPainter),
              child: painter,
            );

            // 항상 Align 위젯으로 감싸서 정렬을 처리합니다.
            return Align(
              alignment: _calculateAlignment(widget.controller.document.textAlign,
                  widget.controller.document.textAlignVertical),
              child: gestureHandler,
            );
          }),
        ),
      ),
    );
  }
}

Alignment _calculateAlignment(TextAlign horizontal, TextAlignVertical vertical) {
  final double x;
  switch (horizontal) {
    case TextAlign.left:
    case TextAlign.start:
      x = -1.0;
      break;
    case TextAlign.right:
    case TextAlign.end:
      x = 1.0;
      break;
    case TextAlign.center:
    case TextAlign.justify: // Justify는 가로로 꽉 채우지만, Align에서는 중앙으로 처리
    // ignore: unreachable_switch_default
    default:
      x = 0.0;
      break;
  }

  final double y;
  switch (vertical) {
    case TextAlignVertical.top:
      y = -1.0;
      break;
    case TextAlignVertical.center:
      y = 0.0;
      break;
    case TextAlignVertical.bottom:
      y = 1.0;
      break;
    default:
      y = -1.0;
      break;
  }

  return Alignment(x, y);
}

// DocumentPainter 클래스를 아래 코드로 교체해주세요.
class DocumentPainter extends CustomPainter {
  const DocumentPainter({
    required this.document,
    required this.selection,
    required this.isFocused,
    required this.cursorOpacity,
    this.textPainter,
  });

  final DocumentModel document;
  final TextSelection selection;
  final bool isFocused;
  final double cursorOpacity;
  final TextPainter? textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    final effectivePainter = textPainter ?? _createLocalTextPainter(size);

    // 선택 영역 그리기 (텍스트보다 먼저)
    if (!selection.isCollapsed) {
      final selectionColor = Colors.blue.withValues(alpha: 0.3);
      final selectionBoxes = effectivePainter.getBoxesForSelection(selection);
      for (final box in selectionBoxes) {
        canvas.drawRect(box.toRect(), Paint()..color = selectionColor);
      }
    }

    // 텍스트 그리기
    effectivePainter.paint(canvas, Offset.zero);

    // 커서 그리기 (텍스트보다 나중에)
    if (isFocused && selection.isCollapsed && cursorOpacity > 0.5) {
      final textPosition = TextPosition(offset: selection.baseOffset);
      final cursorOffset = effectivePainter.getOffsetForCaret(textPosition, Rect.zero);
      final cursorHeight = effectivePainter.getFullHeightForCaret(textPosition, Rect.zero);
      final cursorRect = Rect.fromLTWH(cursorOffset.dx, cursorOffset.dy, 2, cursorHeight);
      canvas.drawRect(cursorRect, Paint()..color = Colors.black);
    }
  }

  TextPainter _createLocalTextPainter(Size size) {
    final text = TextSpan(
      children: document.spans.map((s) => s.toTextSpan()).toList(),
    );

    final painter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      textAlign: document.textAlign,
    );

    painter.layout(maxWidth: size.width);
    return painter;
  }

  @override
  bool shouldRepaint(covariant DocumentPainter oldDelegate) {
    // 모든 속성이 변경될 때 다시 그리도록 합니다.
    return oldDelegate.document != document ||
        oldDelegate.selection != selection ||
        oldDelegate.isFocused != isFocused ||
        oldDelegate.cursorOpacity != cursorOpacity ||
        oldDelegate.textPainter != textPainter;
  }
}
