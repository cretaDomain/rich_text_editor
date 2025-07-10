import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';
import '../views/document_view.dart';
import 'raw_editor.dart';
import 'toolbar.dart';

/// 실제 UI를 렌더링하는 Rich Text Editor 위젯입니다.
///
/// 이 위젯은 `controller`를 통해 제공되는 데이터에 따라
/// 뷰(View) 모드 또는 편집(Edit) 모드의 UI를 표시합니다.
class RichTextEditor extends StatefulWidget {
  const RichTextEditor({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
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
  final double width;

  /// 위젯의 세로 크기입니다.
  final double height;

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
  EdgeInsets _padding = const EdgeInsets.all(16.0);
  double? _currentWidth;
  double? _currentHeight;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.width;
    _currentHeight = widget.height;
    // 위젯 생성 시 전달된 초기 모드를 컨트롤러에 설정합니다.
    widget.controller.setMode(widget.initialMode);
    // 컨트롤러의 변경사항을 구독하여 UI를 업데이트합니다.
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    // 컨트롤러 리스너를 정리합니다.
    widget.controller.removeListener(_update);
    super.dispose();
  }

  /// 여백이 변경될 때 호출됩니다.
  void _onPaddingChanged(EdgeInsets newPadding) {
    setState(() {
      _padding = newPadding;
    });
  }

  void _update() {
    if (mounted) {
      setState(() {
        // 모드 변경에 따라 에디터 사이즈를 동적으로 조절하는 로직
        const double estimatedToolbarHeight = 160.0;
        final double originalHeight = widget.height;

        if (widget.controller.mode == EditorMode.edit) {
          if (widget.width < 800) {
            _currentWidth = 800;
          } else {
            _currentWidth = widget.width;
          }
          _currentHeight = originalHeight + estimatedToolbarHeight;
        } else {
          _currentWidth = widget.width;
          _currentHeight = originalHeight;
        }
      });
    }
  }

  /// 에디터의 모드를 토글하는 내부 메서드입니다.
  void _toggleMode() {
    final currentMode = widget.controller.mode;
    widget.controller.setMode(
      currentMode == EditorMode.edit ? EditorMode.view : EditorMode.edit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _currentWidth,
      height: _currentHeight,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.controller.mode == EditorMode.view) {
      // 보기 모드: DocumentView만 표시
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _toggleMode,
        child: Padding(
          padding: _padding,
          child: DocumentView(document: widget.controller.document),
        ),
      );
    }

    // 편집 모드: 툴바와 RawEditor 표시
    return Column(
      children: [
        Toolbar(
          controller: widget.controller,
          fontList: widget.fontList,
          padding: _padding,
          onPaddingChanged: _onPaddingChanged,
          shadow: widget.controller.currentStyle.shadows?.firstOrNull,
          onShadowChanged: (shadow) {
            // `shadow`가 null이면 null을, 아니면 리스트에 담아 전달합니다.
            widget.controller.changeShadows(shadow == null ? null : [shadow]);
          },
          onOutlineChanged: (outline, color) {
            widget.controller.changeOutline(outline, color);
          },
          strokeWidth: widget.controller.currentStyle.strokeWidth,
          strokeColor: widget.controller.currentStyle.strokeColor,
          onBold: widget.controller.toggleBold,
          onItalic: widget.controller.toggleItalic,
          onUnderline: widget.controller.toggleUnderline,
          onChangeLetterSpacing: widget.controller.changeLetterSpacing,
          onChangeLineHeight: widget.controller.changeLineHeight,
          onChangeAlign: widget.controller.changeTextAlign,
          onFontFamilyChanged: widget.controller.changeFontFamily,
          onFontSizeChanged: widget.controller.changeFontSize,
          onFontColorChanged: widget.controller.changeFontColor,
          onToggleMode: _toggleMode,
        ),
        Expanded(
          child: Center(
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: _padding,
                child: RawEditor(
                  controller: widget.controller,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
