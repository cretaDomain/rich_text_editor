import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rich_text_editor/src/models/document_model.dart';
import 'package:rich_text_editor/src/models/span_attribute.dart';
import 'package:rich_text_editor/src/models/text_span_model.dart';

/// 에디터의 모드를 정의합니다. (편집 모드 / 뷰 모드)
enum EditorMode {
  edit,
  view,
}

/// Rich Text Editor의 상태를 관리하고, UI에 변경 사항을 알리는 컨트롤러입니다.
///
/// 이 컨트롤러는 텍스트 내용, 스타일, 편집 모드 등 에디터의 모든 데이터를 소유하고 제어합니다.
class RichTextEditorController extends ChangeNotifier {
  /// 현재 에디터 모드 (기본값: 편집)
  EditorMode _mode = EditorMode.edit;

  /// 에디터가 현재 가지고 있는 문서 데이터입니다.
  DocumentModel _document = const DocumentModel();

  /// 현재 툴바 또는 다음 입력에 적용될 스타일 속성입니다.
  SpanAttribute _currentStyle = const SpanAttribute();

  /// 현재 모드를 반환합니다.
  EditorMode get mode => _mode;

  /// 현재 문서를 반환합니다.
  DocumentModel get document => _document;

  /// 현재 스타일 속성을 반환합니다.
  SpanAttribute get currentStyle => _currentStyle;

  /// 에디터 모드를 변경하고, 변경 사항을 구독자에게 알립니다.
  void setMode(EditorMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  /// 문서를 새로운 내용으로 교체하고, 변경 사항을 구독자에게 알립니다.
  void setDocument(DocumentModel newDocument) {
    _document = newDocument;
    notifyListeners();
  }

  /// 일반 텍스트로부터 문서를 업데이트합니다.
  ///
  /// 현재는 모든 텍스트를 기본 스타일의 단일 스팬으로 만듭니다.
  /// 향후 스타일 병합 로직이 추가될 예정입니다.
  void updateDocumentFromText(String text) {
    _document = DocumentModel(
      spans: [
        TextSpanModel.defaultSpan(text),
      ],
    );
    // 이 메서드는 주로 내부 텍스트 필드에서 호출되므로,
    // 무한 루프를 방지하기 위해 notifyListeners()를 호출하지 않을 수 있습니다.
    // 하지만 외부에서 직접 호출할 경우를 대비해 유지할 수 있습니다.
    // 여기서는 UI의 즉각적인 반응을 위해 호출합니다.
    notifyListeners();
  }

  /// 편집 모드에서 변경된 텍스트를 문서 모델에 최종적으로 적용합니다.
  ///
  /// 현재는 매우 단순화된 방식으로, 전체 텍스트를 첫 번째 스팬에 덮어씁니다.
  /// 이렇게 하면 최소한 단일 스타일의 텍스트는 보존됩니다.
  /// TODO: 향후 diff 알고리즘을 적용하여 정교하게 만들어야 합니다.
  void applyTextUpdate(String text) {
    if (_document.spans.isEmpty) {
      if (text.isNotEmpty) {
        _document = DocumentModel(spans: [TextSpanModel.defaultSpan(text)]);
      }
      // if text is empty, do nothing.
    } else {
      // 기존 스팬들을 유지하되, 전체 텍스트를 가진 새로운 스팬 리스트를 만듭니다.
      // 이는 스타일 유실 문제를 임시로 완화하기 위함입니다.
      if (text.isNotEmpty) {
        final newSpans = [
          _document.spans.first.copyWith(text: text),
        ];
        _document = _document.copyWith(spans: newSpans);
      } else {
        _document = const DocumentModel(); // Clear the document if text is empty
      }
    }
    notifyListeners();
  }

  /// 텍스트 필드의 변경 사항을 문서 모델에 반영합니다.
  ///
  /// 이 메서드는 사용자의 단순 텍스트 입력/삭제를 처리하며,
  /// 현재 커서 위치의 스타일을 최대한 유지하려고 시도합니다.
  void updateText(String newText, TextSelection newSelection) {
    // TODO: 이 부분은 매우 복잡한 로직이 필요합니다.
    // 사용자의 입력(한 글자 추가/삭제, 붙여넣기 등)을 분석하여
    // 기존 spans를 최소한으로 수정해야 합니다.
    // 현재는 이전과 동일하게 단순화된 로직을 유지하지만,
    // 이것이 버그의 근본 원인임을 인지하고 있어야 합니다.
    _document = DocumentModel(
      spans: [
        TextSpanModel.defaultSpan(newText),
      ],
      textAlign: _document.textAlign, // 정렬 상태는 유지합니다.
    );
    notifyListeners();
  }

  /// 폰트 패밀리를 변경하고, 변경 사항을 알립니다.
  void changeFontFamily(String fontFamily) {
    _currentStyle = _currentStyle.copyWith(fontFamily: fontFamily);
    notifyListeners();
  }

  /// 선택된 영역의 Bold 스타일을 토글합니다.
  void toggleBold(TextSelection selection) {
    _toggleStyle(
        selection,
        (attr) =>
            attr.copyWith(fontWeight: attr.fontWeight == FontWeight.bold ? null : FontWeight.bold));
  }

  /// 선택된 영역의 Italic 스타일을 토글합니다.
  void toggleItalic(TextSelection selection) {
    _toggleStyle(
        selection,
        (attr) =>
            attr.copyWith(fontStyle: attr.fontStyle == FontStyle.italic ? null : FontStyle.italic));
  }

  /// 선택된 영역의 Underline 스타일을 토글합니다.
  void toggleUnderline(TextSelection selection) {
    _toggleStyle(
        selection,
        (attr) => attr.copyWith(
            decoration:
                attr.decoration == TextDecoration.underline ? null : TextDecoration.underline));
  }

  /// 문서의 텍스트 정렬을 변경합니다.
  void changeTextAlign(TextAlign align) {
    _document = _document.copyWith(textAlign: align);
    notifyListeners();
  }

  /// 선택된 영역의 글자 간격(letter spacing)을 변경합니다.
  void changeLetterSpacing(TextSelection selection, double spacing) {
    _toggleStyle(selection, (attr) => attr.copyWith(letterSpacing: spacing));
  }

  /// 선택된 영역의 줄 간격(height)을 변경합니다.
  void changeLineHeight(TextSelection selection, double height) {
    _toggleStyle(selection, (attr) => attr.copyWith(height: height));
  }

  /// 선택 영역에 특정 스타일 변경을 적용하는 비공개 헬퍼 메서드입니다.
  void _toggleStyle(TextSelection selection, SpanAttribute Function(SpanAttribute) updateFunc) {
    if (selection.isCollapsed) {
      _currentStyle = updateFunc(_currentStyle);
      notifyListeners();
      return;
    }

    final newSpans = <TextSpanModel>[];
    int currentPos = 0;

    for (final span in _document.spans) {
      final spanEnd = currentPos + span.text.length;

      // 선택 영역과 겹치지 않는 경우
      if (selection.end <= currentPos || selection.start >= spanEnd) {
        newSpans.add(span);
      }
      // 선택 영역이 스팬을 완전히 포함하는 경우
      else if (selection.start <= currentPos && selection.end >= spanEnd) {
        newSpans.add(span.copyWith(attribute: updateFunc(span.attribute)));
      }
      // 그 외 겹치는 모든 경우 (스팬 분할 필요)
      else {
        // 1. 선택 영역 앞부분
        if (currentPos < selection.start) {
          newSpans.add(span.copyWith(text: span.text.substring(0, selection.start - currentPos)));
        }
        // 2. 선택 영역 부분
        final start = selection.start > currentPos ? selection.start - currentPos : 0;
        final end = selection.end < spanEnd ? selection.end - currentPos : span.text.length;
        newSpans.add(
          span.copyWith(
            text: span.text.substring(start, end),
            attribute: updateFunc(span.attribute),
          ),
        );
        // 3. 선택 영역 뒷부분
        if (spanEnd > selection.end) {
          newSpans.add(span.copyWith(text: span.text.substring(selection.end - currentPos)));
        }
      }
      currentPos = spanEnd;
    }
    _document = DocumentModel(spans: newSpans);
    notifyListeners();
  }

  @override
  void dispose() {
    // ... existing code ...
  }

  // 개발 단계에 따라 이곳에 에디터의 상태를 관리하는 속성과 메서드가 추가될 예정입니다.
}
