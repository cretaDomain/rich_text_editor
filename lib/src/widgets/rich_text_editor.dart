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

  @override
  void initState() {
    super.initState();
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

  /// 텍스트 필드의 내용이 변경될 때 호출됩니다.
  void _onTextChanged() {
    // 편집 중에는 DocumentModel을 직접 업데이트하지 않습니다.
    // 스타일 정보가 유실되는 것을 방지하기 위함입니다.
    // 뷰 모드로 전환될 때 한 번에 반영합니다.
  }

  void _update() {
    if (mounted) {
      // 뷰 -> 편집 모드로 전환 시, 최신 문서 내용으로 텍스트 필드를 업데이트합니다.
      if (widget.controller.mode == EditorMode.edit) {
        if (widget.width != null && widget.width! < 800) {
          _currentWidth = 800;
        }
        final newText = widget.controller.document.toPlainText();
        if (_textEditingController.text != newText) {
          // 리스너의 무한 호출을 방지하기 위해 잠시 리스너를 제거하고 텍스트를 설정합니다.
          _textEditingController.removeListener(_onTextChanged);
          _textEditingController.text = newText;
          _textEditingController.addListener(_onTextChanged);
        }
      }
      // 편집 -> 뷰 모드로 전환 시, 텍스트 필드의 내용을 DocumentModel에 반영합니다.
      else if (widget.controller.mode == EditorMode.view) {
        _currentWidth = widget.width;
        // 편집 모드에서 수정한 최종 텍스트를 컨트롤러에 적용합니다.
        // 텍스트가 실제로 변경되었을 때만 업데이트를 적용하여 불필요한 재빌드와 스타일 유실을 방지합니다.
        final originalText = widget.controller.document.toPlainText();
        if (_textEditingController.text != originalText) {
          widget.controller.applyTextUpdate(_textEditingController.text);
        }
      }
      setState(() {});
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
            onDoubleTap: () {
              widget.controller.setMode(EditorMode.edit);
              // Future.delayed를 사용하여 브라우저가 상태를 동기화할 시간을 줍니다.
              Future.delayed(const Duration(milliseconds: 50), () {
                if (mounted) {
                  _focusNode.requestFocus();
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
            ),
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _currentWidth,
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

                      if (newMode == EditorMode.edit) {
                        // Future.delayed를 사용하여 브라우저가 상태를 동기화할 시간을 줍니다.
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (mounted) {
                            _focusNode.requestFocus();
                          }
                        });
                      } else {
                        _focusNode.unfocus();
                      }
                    },
                    tooltip: widget.controller.mode == EditorMode.edit ? 'View Mode' : 'Edit Mode',
                  ),
                ],
              ),
            ),

          // 편집 모드일 때만 툴바를 표시합니다.
          if (widget.controller.mode == EditorMode.edit)
            Toolbar(
              controller: widget.controller,
              fontList: widget.fontList,
              onBold: () => widget.controller
                  .toggleBold(_textEditingController.text, _textEditingController.selection),
              onItalic: () => widget.controller
                  .toggleItalic(_textEditingController.text, _textEditingController.selection),
              onUnderline: () => widget.controller
                  .toggleUnderline(_textEditingController.text, _textEditingController.selection),
              onChangeAlign: (align) =>
                  widget.controller.changeTextAlign(_textEditingController.text, align),
              onChangeLetterSpacing: (value) => widget.controller.changeLetterSpacing(
                  _textEditingController.text, _textEditingController.selection, value),
              onChangeLineHeight: (value) => widget.controller.changeLineHeight(
                  _textEditingController.text, _textEditingController.selection, value),
              onFontFamilyChanged: (value) => widget.controller.changeFontFamily(
                  _textEditingController.text, _textEditingController.selection, value),
              onFontSizeChanged: (value) => widget.controller.changeFontSize(
                  _textEditingController.text, _textEditingController.selection, value),
              onFontColorChanged: (value) => widget.controller.changeFontColor(
                  _textEditingController.text, _textEditingController.selection, value),
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
