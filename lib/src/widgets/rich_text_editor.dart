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
  EdgeInsets _padding = const EdgeInsets.all(16.0);

  @override
  void initState() {
    super.initState();
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
        // 이 메소드는 컨트롤러의 mode 변경 시 UI를 다시 그리도록 합니다.
        // 더 이상 복잡한 로직이 필요 없습니다.
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
      width: widget.width,
      height: widget.height,
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
          // TODO: 아래 콜백들은 Step 4-2에서 수정될 예정입니다.
          // 현재는 이전 방식 그대로라 정상 동작하지 않습니다.
          onShadowChanged: (shadow) {
            // widget.controller.changeShadows(shadow == null ? null : [shadow]);
          },
          onOutlineChanged: (outline, color) {
            // widget.controller.changeOutline(outline, color);
          },
          strokeWidth: widget.controller.currentStyle.strokeWidth,
          strokeColor: widget.controller.currentStyle.strokeColor,
          onBold: () {
            // widget.controller.toggleBold();
          },
          onItalic: () {
            // widget.controller.toggleItalic();
          },
          onUnderline: () {
            // widget.controller.toggleUnderline();
          },
          onChangeLetterSpacing: (spacing) {
            // widget.controller.changeLetterSpacing(spacing);
          },
          onChangeLineHeight: (height) {
            // widget.controller.changeLineHeight(height);
          },
          onChangeAlign: (align) {
            // widget.controller.changeTextAlign(align);
          },
          onFontFamilyChanged: (value) {
            // widget.controller.changeFontFamily(value);
          },
          onFontSizeChanged: (value) {
            // widget.controller.changeFontSize(value);
          },
          onFontColorChanged: (value) {
            // widget.controller.changeFontColor(value);
          },
          onToggleMode: _toggleMode,
        ),
        Expanded(
          child: Padding(
            padding: _padding,
            child: RawEditor(
              controller: widget.controller,
            ),
          ),
        ),
      ],
    );
  }
}
