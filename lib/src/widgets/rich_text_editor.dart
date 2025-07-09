import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';
import '../views/document_view.dart';
import 'toolbar.dart';

/// 실제 UI를 렌더링하는 Rich Text Editor 위젯입니다.
///
/// 이 위젯은 `controller`를 통해 제공되는 데이터에 따라
/// 뷰(View) 모드 또는 편집(Edit) 모드의 UI를 표시합니다.
class RichTextEditor extends StatefulWidget {
  const RichTextEditor({
    super.key,
    required this.controller,
    this.width,
    this.height,
    this.backgroundColor = Colors.transparent,
    this.title,
    this.showTitleBar = true,
    this.titleBarColor,
    this.titleBarHeight = 48.0,
    this.initialMode = EditorMode.edit,
    this.fontList = const [],
  });

  /// 위젯의 상태를 관리하는 컨트롤러입니다.
  final RichTextEditorController controller;

  /// 위젯의 가로 크기입니다.
  final double? width;

  /// 위젯의 세로 크기입니다.
  final double? height;

  /// 에디터의 배경색입니다. (기본값: 투명)
  final Color backgroundColor;

  /// 에디터 상단에 표시될 타이틀입니다.
  final String? title;

  /// 타이틀 바 표시 여부를 결정합니다. (기본값: true)
  final bool showTitleBar;

  /// 타이틀 바의 배경색입니다.
  final Color? titleBarColor;

  /// 타이틀 바의 높이입니다.
  final double titleBarHeight;

  /// 위젯이 처음 생성될 때의 초기 모드입니다. (기본값: 편집 모드)
  final EditorMode initialMode;

  /// 폰트 드롭다운에 표시될 폰트 리스트입니다.
  final List<String> fontList;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;
  double? _currentWidth;
  double? _currentEditorHeight;
  TextSelection _lastSelection = const TextSelection.collapsed(offset: -1);
  EdgeInsets _padding = const EdgeInsets.all(16.0);
  List<Shadow>? _shadows;

  @override
  void initState() {
    super.initState();
    _currentEditorHeight = widget.height;
    // 포커스 노드를 초기화합니다.
    _focusNode = FocusNode();
    // 편집 모드에서 사용할 텍스트 컨트롤러를 초기화합니다.
    _textEditingController = TextEditingController(
      text: widget.controller.document.toPlainText(),
    )..addListener(_onTextChanged); // 텍스트 변경 리스너 추가

    _currentWidth = widget.width;

    // 위젯 생성 시 전달된 초기 모드를 컨트롤러에 설정합니다.
    widget.controller.setMode(widget.initialMode);
    // 컨트롤러의 변경사항을 구독하여 UI를 업데이트합니다.
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    // 컨트롤러와 포커스 노드를 정리하여 메모리 누수를 방지합니다.
    _focusNode.dispose();
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    widget.controller.removeListener(_update);
    super.dispose();
  }

  /// 여백이 변경될 때 호출됩니다.
  void _onPaddingChanged(EdgeInsets newPadding) {
    setState(() {
      _padding = newPadding;
    });
  }

  // void _onShadowChanged(Shadow? shadow) {
  //   widget.controller.changeShadows(
  //     _textEditingController.text,
  //     _lastSelection,
  //     shadow == null ? null : [shadow],
  //   );
  //   // setState(() {
  //   //   _shadows = shadow == null ? null : [shadow];
  //   // });
  // }

  /// 텍스트 필드의 내용이 변경될 때 호출됩니다.
  void _onTextChanged() {
    final currentSelection = _textEditingController.selection;
    // 텍스트 필드가 포커스를 잃을 때 selection이 유효하지 않은 값(-1)으로 설정될 수 있습니다.
    // 유효한 selection일 때만 마지막 선택 영역을 업데이트합니다.
    if (currentSelection.start > -1 && currentSelection.end > -1) {
      if (_lastSelection != currentSelection) {
        _lastSelection = currentSelection;
        // 선택 영역이 변경될 때마다 컨트롤러에 알려 스타일을 업데이트합니다.
        widget.controller.updateStyleAtSelection(currentSelection);
      }
    }
  }

  void _update() {
    if (mounted) {
      if (widget.controller.mode == EditorMode.edit) {
        final newText = widget.controller.document.toPlainText();
        if (_textEditingController.text != newText) {
          _textEditingController.removeListener(_onTextChanged);
          _textEditingController.text = newText;
          _textEditingController.addListener(_onTextChanged);
        }
      }

      setState(() {
        const double estimatedToolbarHeight = 160.0; // 2-3줄 높이 추정치
        final double originalHeight = widget.height ?? 300.0;

        if (widget.controller.mode == EditorMode.edit) {
          if (widget.width != null && widget.width! < 800) {
            _currentWidth = 800;
          }
          _currentEditorHeight = originalHeight * 2 + estimatedToolbarHeight;
        } else {
          _currentWidth = widget.width;
          _currentEditorHeight = originalHeight;
        }
      });
    }
  }

  /// 에디터의 모드를 토글하는 내부 메서드입니다.
  void _toggleMode() {
    final currentMode = widget.controller.mode;
    if (currentMode == EditorMode.edit) {
      // 편집 -> 뷰 모드로 전환 시, 먼저 텍스트 필드의 내용을 모델에 반영합니다.
      final originalText = widget.controller.document.toPlainText();
      if (_textEditingController.text != originalText) {
        widget.controller.applyTextUpdate(_textEditingController.text);
      }
      // 그런 다음 모드를 변경합니다.
      widget.controller.setMode(EditorMode.view);
      _focusNode.unfocus();
    } else {
      // 뷰 -> 편집 모드로 전환합니다.
      // _update 리스너가 텍스트 필드 내용을 동기화할 것입니다.
      widget.controller.setMode(EditorMode.edit);
      // Future.delayed를 사용하여 브라우저가 상태를 동기화할 시간을 줍니다.
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  /// 에디터의 본문 영역을 현재 모드에 따라 빌드합니다.
  Widget _buildEditorBody() {
    return Stack(
      children: [
        // 뷰 모드 위젯
        Offstage(
          offstage: widget.controller.mode != EditorMode.view,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: _toggleMode,
            child: Padding(
              padding: _padding,
              child: DocumentView(document: widget.controller.document),
            ),
          ),
        ),
        // 편집 모드 위젯
        Offstage(
          offstage: widget.controller.mode != EditorMode.edit,
          child: TextFormField(
            controller: _textEditingController,
            focusNode: _focusNode,
            maxLines: null,
            expands: true,
            textAlign: widget.controller.document.textAlign,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: _padding,
            ),
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _currentWidth,
      height: _currentEditorHeight,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    // 뷰 모드일 경우
    if (widget.controller.mode == EditorMode.view) {
      return Container(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: _buildEditorBody(),
      );
    }

    // 편집 모드일 경우: 상단 뷰 + 하단 에디터
    return Column(
      children: [
        // 상단: 뷰 위젯 (고정 높이)
        Center(
          child: Container(
            width: widget.width,
            height: widget.height ?? 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: _padding,
              child: DocumentView(document: widget.controller.document),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 하단: 에디터 위젯 (나머지 공간 모두 사용)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                if (widget.showTitleBar && widget.title != null)
                  Container(
                    height: widget.titleBarHeight,
                    color: widget.titleBarColor ?? Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title!,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                Toolbar(
                  controller: widget.controller,
                  fontList: widget.fontList,
                  padding: _padding,
                  onPaddingChanged: _onPaddingChanged,
                  shadow: widget.controller.currentStyle.shadows?.firstOrNull,
                  onShadowChanged: (shadow) {
                    widget.controller.changeShadows(
                      _textEditingController.text,
                      _lastSelection,
                      shadow == null ? null : [shadow],
                    );
                  },
                  onOutlineChanged: (outline, color) {
                    widget.controller.changeOutline(
                      _textEditingController.text,
                      _lastSelection,
                      outline,
                      color,
                    );
                  },
                  strokeWidth: widget.controller.currentStyle.strokeWidth,
                  strokeColor: widget.controller.currentStyle.strokeColor,
                  onBold: () => widget.controller.toggleBold(
                    _textEditingController.text,
                    _lastSelection,
                  ),
                  onItalic: () => widget.controller.toggleItalic(
                    _textEditingController.text,
                    _lastSelection,
                  ),
                  onUnderline: () => widget.controller.toggleUnderline(
                    _textEditingController.text,
                    _lastSelection,
                  ),
                  onChangeLetterSpacing: (spacing) => widget.controller.changeLetterSpacing(
                    _textEditingController.text,
                    _lastSelection,
                    spacing,
                  ),
                  onChangeLineHeight: (height) => widget.controller.changeLineHeight(
                    _textEditingController.text,
                    _lastSelection,
                    height,
                  ),
                  onChangeAlign: (align) => widget.controller.changeTextAlign(
                    _textEditingController.text,
                    align,
                  ),
                  onFontFamilyChanged: (value) => widget.controller
                      .changeFontFamily(_textEditingController.text, _lastSelection, value),
                  onFontSizeChanged: (value) => widget.controller
                      .changeFontSize(_textEditingController.text, _lastSelection, value),
                  onFontColorChanged: (value) => widget.controller
                      .changeFontColor(_textEditingController.text, _lastSelection, value),
                  onToggleMode: _toggleMode,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlign: widget.controller.document.textAlign,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: _padding,
                    ),
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
