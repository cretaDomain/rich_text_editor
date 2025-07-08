import 'package:flutter/material.dart';
import '../controllers/rich_text_editor_controller.dart';
import '../views/document_view.dart';

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
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    // 편집 모드에서 사용할 텍스트 컨트롤러를 초기화합니다.
    _textEditingController = TextEditingController(
      text: widget.controller.document.spans.map((s) => s.text).join(''),
    )..addListener(_onTextChanged); // 텍스트 변경 리스너 추가

    // 위젯 생성 시 전달된 초기 모드를 컨트롤러에 설정합니다.
    widget.controller.setMode(widget.initialMode);
    // 컨트롤러의 변경사항을 구독하여 UI를 업데이트합니다.
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    // 컨트롤러들을 정리하여 메모리 누수를 방지합니다.
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    widget.controller.removeListener(_update);
    super.dispose();
  }

  /// 텍스트 필드의 내용이 변경될 때 호출됩니다.
  void _onTextChanged() {
    // 텍스트 필드의 변경 내용을 RichTextEditorController의 document에 반영합니다.
    // 스타일 정보가 유실되는 것을 방지하기 위해, 현재 커서 위치 등을 고려한
    // 정교한 로직이 필요하지만, 현재 단계에서는 전체 텍스트를 업데이트합니다.
    if (widget.controller.mode == EditorMode.edit) {
      widget.controller.updateDocumentFromText(_textEditingController.text);
    }
  }

  void _update() {
    // 컨트롤러에서 변경이 발생하면 위젯을 다시 빌드하도록 요청합니다.
    if (mounted) {
      // 뷰 -> 편집 모드로 전환 시, 최신 문서 내용으로 텍스트 필드를 업데이트합니다.
      if (widget.controller.mode == EditorMode.edit) {
        final newText = widget.controller.document.spans.map((s) => s.text).join('');
        if (_textEditingController.text != newText) {
          // 리스너의 무한 호출을 방지하기 위해 잠시 리스너를 제거하고 텍스트를 설정합니다.
          _textEditingController.removeListener(_onTextChanged);
          _textEditingController.text = newText;
          _textEditingController.addListener(_onTextChanged);
        }
      }
      setState(() {});
    }
  }

  /// 에디터의 본문 영역을 현재 모드에 따라 빌드합니다.
  Widget _buildEditorBody() {
    if (widget.controller.mode == EditorMode.view) {
      return GestureDetector(
        onDoubleTap: () {
          widget.controller.setMode(EditorMode.edit);
        },
        child: DocumentView(document: widget.controller.document),
      );
    } else {
      // 편집 모드일 경우, 텍스트 입력 필드를 표시합니다.
      return TextFormField(
        controller: _textEditingController,
        maxLines: null, // 여러 줄 입력 가능
        expands: true, // 사용 가능한 공간을 모두 채움
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.0),
        ),
        textAlignVertical: TextAlignVertical.top,
      );
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  // 편집/뷰 모드 전환 버튼
                  IconButton(
                    icon: Icon(
                      widget.controller.mode == EditorMode.edit ? Icons.visibility : Icons.edit,
                    ),
                    onPressed: () {
                      final newMode = widget.controller.mode == EditorMode.edit
                          ? EditorMode.view
                          : EditorMode.edit;
                      widget.controller.setMode(newMode);
                    },
                    tooltip: widget.controller.mode == EditorMode.edit ? 'View Mode' : 'Edit Mode',
                  ),
                ],
              ),
            ),

          // 에디터 본문 영역
          Expanded(
            child: _buildEditorBody(),
          ),
        ],
      ),
    );
  }
}
