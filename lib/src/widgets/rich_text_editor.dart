import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';

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

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
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
    // 위젯이 제거될 때 리스너를 해제하여 메모리 누수를 방지합니다.
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    // 컨트롤러에서 변경이 발생하면 위젯을 다시 빌드하도록 요청합니다.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          // 타이틀 바 표시가 활성화되어 있고, 타이틀이 지정된 경우에만 타이틀 바를 표시합니다.
          if (widget.showTitleBar && widget.title != null)
            Container(
              height: widget.titleBarHeight,
              color: widget.titleBarColor ?? Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),

          // 에디터 본문 영역
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {
                // 뷰 모드에서 더블 클릭 시 편집 모드로 전환합니다.
                if (widget.controller.mode == EditorMode.view) {
                  widget.controller.setMode(EditorMode.edit);
                }
              },
              child: Center(
                // 현재는 모드 상태를 텍스트로 보여주는 플레이스홀더입니다.
                child: Text('Current Mode: ${widget.controller.mode.name}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
