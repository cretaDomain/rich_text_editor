//import 'dart:convert';

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
    this.controller,
    this.initialText,
    required this.width,
    required this.height,
    this.maxSize,
    this.onEditCompleted,
    this.backgroundColor = Colors.transparent,
    this.title,
    this.showTitleBar = true,
    this.titleBarColor,
    this.titleBarHeight = 48.0,
    this.initialMode = EditorMode.edit,
    this.fontList = const [],
    this.showToolbar = true,
    this.autoResize = true,
    this.applyScale = 1.0,
    this.toolbarHeight = 76 * 2 + 8 * 3,
    this.minToolbarWidth = 812,
  });

  /// 위젯의 상태를 관리하는 컨트롤러입니다.
  final RichTextEditorController? controller;

  final String? initialText;

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
  final ValueChanged<String>? onEditCompleted;

  final bool showToolbar;

  final bool autoResize;

  final double applyScale;

  final double toolbarHeight;

  final double minToolbarWidth;

  final Size? maxSize;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  EdgeInsets _padding = const EdgeInsets.all(16.0);
  double? _currentWidth;
  double? _currentHeight;
  late final ScrollController _scrollController;
  // late final FocusNode _scrollFocusNode;
  RichTextEditorController? _controller;
  bool _isMaximized = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // _scrollFocusNode = FocusNode(debugLabel: 'RichTextEditorScrollView');
    if (widget.maxSize != null) {
      _currentWidth = widget.maxSize!.width;
      _currentHeight = widget.maxSize!.height;
    } else {
      _currentWidth = widget.width;
      _currentHeight = widget.height;
    }

    _controller = widget.controller;

    _controller ??= RichTextEditorController();
    if (widget.controller == null && widget.initialText != null) {
      _controller?.setDocumentFromJsonString(widget.initialText!);
    }

    // 컨트롤러에 설정된 패딩 값으로 위젯의 _padding 상태를 초기화합니다.
    _padding = _controller!.paddingNotifier.value;

    // 위젯 생성 시 전달된 초기 모드를 컨트롤러에 설정합니다.
    _controller?.setMode(widget.initialMode);
    // 컨트롤러의 변경사항을 구독하여 UI를 업데이트합니다.
    // if (widget.showToolbar && widget.autoResize) {
    //   _controller?.addListener(_resize);
    // }
    // 컨트롤러의 패딩 값 변경을 구독합니다.
    _controller?.paddingNotifier.addListener(_onPaddingNotified);

    if (widget.autoResize && widget.initialMode == EditorMode.edit && widget.showToolbar) {
      _resize();
    }
  }

  @override
  void didUpdateWidget(RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width) {
      if (_isMaximized && widget.maxSize != null) {
        _currentWidth = widget.maxSize!.width;
      } else {
        _currentWidth = widget.width;
      }

      if (widget.autoResize && widget.initialMode == EditorMode.edit && widget.showToolbar) {
        _resize();
      }
      setState(() {});
    }
    if (oldWidget.height != widget.height) {
      if (_isMaximized && widget.maxSize != null) {
        _currentHeight = widget.maxSize!.height;
      } else {
        _currentHeight = widget.height;
      }
      if (widget.autoResize && widget.initialMode == EditorMode.edit && widget.showToolbar) {
        _resize();
      }
      setState(() {});
    }

    if (oldWidget.applyScale != widget.applyScale) {
      _currentWidth = widget.width;
      _currentHeight = widget.height;
      if (widget.autoResize && widget.initialMode == EditorMode.edit && widget.showToolbar) {
        _resize();
      }
      setState(() {});
    }
    if (oldWidget.maxSize != widget.maxSize) {
      _isMaximized = true;
      _currentWidth = widget.maxSize!.width;
      _currentHeight = widget.maxSize!.height;
      setState(() {});
    }
    if (oldWidget.initialText != widget.initialText) {
      if (widget.initialText != null) {
        _controller?.setDocumentFromJsonString(widget.initialText!, fontList: widget.fontList);
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    // 컨트롤러 리스너를 정리합니다.
    // if (widget.showToolbar && widget.autoResize) {
    //   _controller?.removeListener(_resize);
    // }
    // _controller?.paddingNotifier.removeListener(_onPaddingNotified);
    _controller?.dispose();

    _scrollController.dispose();
    // _scrollFocusNode.dispose();
    super.dispose();
  }

  /// 컨트롤러의 paddingNotifier로부터 변경 알림을 받았을 때 호출됩니다.
  void _onPaddingNotified() {
    _onPaddingChanged(_controller!.paddingNotifier.value);
  }

  /// 여백이 변경될 때 호출됩니다.
  void _onPaddingChanged(EdgeInsets newPadding) {
    _controller?.changePadding(newPadding);
    setState(() {
      _padding = newPadding;
    });
  }

  // ignore: unused_element
  // void _resize() {
  //   if (mounted) {
  //     setState(() {
  //       // 모드 변경에 따라 에디터 사이즈를 동적으로 조절하는 로직
  //       const double estimatedToolbarHeight = 76 * 2 + 8 * 3;
  //       final double originalHeight = widget.height;

  //       if (_controller!.mode == EditorMode.edit) {
  //         if (widget.width < 900) {
  //           _currentWidth = 900;
  //         } else {
  //           _currentWidth = widget.width;
  //         }
  //         _currentHeight = originalHeight + estimatedToolbarHeight;
  //       } else {
  //         _currentWidth = widget.width;
  //         _currentHeight = originalHeight;
  //       }
  //     });
  //   }
  // }

  void _resize() {
    // 모드 변경에 따라 에디터 사이즈를 동적으로 조절하는 로직
    if (widget.width < widget.minToolbarWidth) {
      _currentWidth = widget.minToolbarWidth;
    }
    if (_isMaximized && widget.maxSize != null) {
      _currentHeight = widget.maxSize!.height;
    } else {
      _currentHeight = widget.height + widget.toolbarHeight;
    }
  }

  void _onEditCompleted() {
    if (widget.onEditCompleted != null) {
      // Create a new map to hold both document and padding data
      // final data = {
      //   'document': _controller!.document.toJson(),
      //   'padding': {
      //     'left': _padding.left,
      //     'top': _padding.top,
      //     'right': _padding.right,
      //     'bottom': _padding.bottom
      //   },
      // };
      // final jsonString = jsonEncode(data);
      final jsonString = _controller?.toJson() ?? '';
      widget.onEditCompleted!(jsonString);
    }
  }

  /// 에디터의 모드를 토글하는 내부 메서드입니다.
  void _toggleMode() {
    final currentMode = _controller!.mode;
    if (currentMode == EditorMode.edit) {
      _onEditCompleted();
    }
    _controller?.setMode(
      currentMode == EditorMode.edit ? EditorMode.view : EditorMode.edit,
    );
  }

  /// 에디터의 크기를 최대/일반 크기로 토글합니다.
  void _toggleSize() {
    setState(() {
      _isMaximized = !_isMaximized;
      if (_isMaximized && widget.maxSize != null) {
        _currentWidth = widget.maxSize!.width;
        _currentHeight = widget.maxSize!.height;
      } else {
        _currentWidth = widget.width;
        _currentHeight = widget.height;
      }
      // autoResize가 활성화된 경우, 일반 크기에서 툴바 높이를 추가합니다.
      if (widget.autoResize && !_isMaximized) {
        if (widget.width < widget.minToolbarWidth) {
          _currentWidth = widget.minToolbarWidth;
        }
        _currentHeight = widget.height + widget.toolbarHeight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _currentWidth,
      height: _currentHeight, // //, + (76 * 2 + 8 * 3),
      child: Container(
        // decoration: BoxDecoration(
        //   //color: widget.backgroundColor,
        //   border: Border.all(color: Colors.grey.shade300),
        // ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller!.mode == EditorMode.view) {
      final scaledPadding = _padding * widget.applyScale;
      Widget view = Padding(
        padding: scaledPadding,
        child: Align(
          alignment: _calculateAlignment(
              _controller!.document.textAlign, _controller!.document.textAlignVertical),
          child: DocumentView(
            document: _controller!.document,
            applyScale: widget.applyScale,
          ),
        ),
      );

      // 보기 모드: DocumentView만 표시
      if (widget.onEditCompleted != null) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _toggleMode,
          onTap: () {
            //_onEditCompleted();
            //print('****** RichTextEditor onTap');
            _controller?.setMode(EditorMode.edit);
          },
          child: view,
        );
      }
      return view;
    }

    Widget toolbar = Toolbar(
      controller: _controller!,
      fontList: widget.fontList,
      padding: _padding,
      onPaddingChanged: _onPaddingChanged,
      shadow: _controller!.currentStyle.shadows?.firstOrNull,
      onShadowChanged: (shadow) {
        // `shadow`가 null이면 null을, 아니면 리스트에 담아 전달합니다.
        _controller?.changeShadows(shadow == null ? null : [shadow]);
      },
      onOutlineChanged: (outline, color) {
        _controller?.changeOutline(outline, color);
      },
      strokeWidth: _controller!.currentStyle.strokeWidth,
      strokeColor: _controller!.currentStyle.strokeColor,
      onBold: _controller!.toggleBold,
      onItalic: _controller!.toggleItalic,
      onUnderline: _controller!.toggleUnderline,
      onChangeLetterSpacing: _controller!.changeLetterSpacing,
      onChangeLineHeight: _controller!.changeLineHeight,
      onChangeAlign: _controller!.changeTextAlign,
      onVerticalAlignChanged: _controller!.changeVerticalAlign,
      onFontFamilyChanged: _controller!.changeFontFamily,
      onFontSizeChanged: _controller!.changeFontSize,
      onFontColorChanged: _controller!.changeFontColor,
      onToggleMode: widget.onEditCompleted != null ? _toggleMode : null,
      isMaximized: _isMaximized,
      onToggleSize: _toggleSize,
    );
    Widget editor = Container(
      width: _isMaximized ? _currentWidth : widget.width,
      height: _isMaximized ? _currentHeight : widget.height,
      decoration: BoxDecoration(
        //border: Border.all(color: Colors.grey.shade400, width: 1.0),
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Scrollbar(
        controller: _scrollController,
        child: RawEditor(
          padding: _padding * widget.applyScale,
          scrollController: _scrollController,
          width: widget.width,
          height: widget.height,
          controller: _controller!,
          onFocusLost: _onEditCompleted,
          applyScale: widget.applyScale,
        ),
      ),
    );

    // 편집 모드: 툴바와 RawEditor 표시
    if (widget.showToolbar) {
      return Column(
        children: [
          toolbar,
          Expanded(
            child: Center(
              child: editor,
            ),
          ),
        ],
      );
    }
    return editor;
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
}
