import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';
import '../models/document_model.dart';
import '../models/span_attribute.dart';
import '../models/text_span_model.dart';

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

  /// 현재 커서 위치 또는 선택된 텍스트 영역입니다.
  TextSelection _selection = const TextSelection.collapsed(offset: 0);

  /// 에디터의 여백 값을 관리하고, 변경 시 UI에 알립니다.
  final ValueNotifier<EdgeInsets> paddingNotifier = ValueNotifier(const EdgeInsets.all(16.0));

  @override
  void dispose() {
    paddingNotifier.dispose();
    super.dispose();
  }

  /// 현재 모드를 반환합니다.
  EditorMode get mode => _mode;

  /// 현재 문서를 반환합니다.
  DocumentModel get document => _document;

  /// 현재 스타일 속성을 반환합니다.
  SpanAttribute get currentStyle => _currentStyle;

  /// 현재 선택 영역을 반환합니다.
  TextSelection get selection => _selection;

  /// 현재 커서 위치 또는 선택 영역의 스타일을 감지하여 `currentStyle`을 업데이트합니다.
  ///
  /// 이 메소드는 더 이상 리스너에게 변경을 통지하지 않습니다.
  /// `updateSelection`을 통해 호출되어야 합니다.
  void _updateCurrentStyle(TextSelection selection) {
    // 선택 영역이든 커서든 시작점을 기준으로 스타일을 결정합니다.
    final attr = _document.getSpanAttributeAt(selection.start);
    if (_currentStyle != attr) {
      _currentStyle = attr;
    }
  }

  /// 에디터의 선택 영역을 업데이트하고 UI에 변경을 알립니다.
  void updateSelection(TextSelection newSelection) {
    if (_selection == newSelection) return;

    _selection = newSelection;
    _updateCurrentStyle(newSelection);
    notifyListeners();
  }

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

  /// JSON 문자열로부터 문서를 설정합니다.
  ///
  /// 잘못된 형식의 JSON이 입력될 경우 에러를 로깅하고 현재 문서를 비웁니다.
  void setDocumentFromJsonString(String jsonString, {List<String> fontList = const []}) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // document 파싱
      if (json.containsKey('document')) {
        _document = DocumentModel.fromJson(json['document'], fontList: fontList);
      } else {
        // 이전 버전과의 호환성을 위해 document 키가 없는 경우도 처리
        _document = DocumentModel.fromJson(json, fontList: fontList);
      }

      // padding 파싱
      if (json.containsKey('padding')) {
        final paddingJson = json['padding'] as Map<String, dynamic>;
        paddingNotifier.value = EdgeInsets.fromLTRB(
          (paddingJson['left'] as num).toDouble(),
          (paddingJson['top'] as num).toDouble(),
          (paddingJson['right'] as num).toDouble(),
          (paddingJson['bottom'] as num).toDouble(),
        );
      }
    } catch (e) {
      // JSON 파싱 또는 모델 변환 중 에러 발생 시 처리
      debugPrint('Error parsing JSON string: $e');
      _document = const DocumentModel(); // 안전을 위해 문서를 비웁니다.
    }
    notifyListeners();
  }

  /// 현재 문서와 에디터 관련 설정을 JSON 문자열로 직렬화합니다.
  String toJson() {
    // Create a new map to hold both document and padding data
    final padding = paddingNotifier.value;
    final data = {
      'document': document.toJson(),
      'padding': {
        'left': padding.left,
        'top': padding.top,
        'right': padding.right,
        'bottom': padding.bottom
      },
    };
    final jsonString = jsonEncode(data);
    return jsonString;
  }

  /// 일반 텍스트로부터 문서를 업데이트합니다.
  ///
  /// 현재는 모든 텍스트를 기본 스타일의 단일 스팬으로 만듭니다.
  /// 향후 스타일 병합 로직이 추가될 예정입니다.
  void updateDocumentFromText(String text) {
    _document = DocumentModel(
      spans: [
        TextSpanModel.defaultSpan(text, initialSize: _currentStyle.fontSize ?? 30.0),
      ],
    );
    // 이 메서드는 주로 내부 텍스트 필드에서 호출되므로,
    // 무한 루프를 방지하기 위해 notifyListeners()를 호출하지 않을 수 있습니다.
    // 하지만 외부에서 직접 호출할 경우를 대비해 유지할 수 있습니다.
    // 여기서는 UI의 즉각적인 반응을 위해 호출합니다.
    notifyListeners();
  }

  /// 편집 모드에서 변경된 텍스트를 문서 모델에 최종적으로 적용합니다.
  void applyTextUpdate(String newText) {
    _applyTextUpdateInternal(newText);
    notifyListeners();
  }

  /// 텍스트 업데이트의 핵심 로직을 처리하지만, UI에는 알리지 않는 내부 메서드입니다.
  void _applyTextUpdateInternal(String newText) {
    final oldText = _document.toPlainText();
    if (oldText == newText) return; // 변경 사항이 없으면 아무것도 하지 않음

    if (_document.spans.isEmpty) {
      if (newText.isNotEmpty) {
        _document = DocumentModel(spans: [
          TextSpanModel.defaultSpan(newText, initialSize: _currentStyle.fontSize ?? 30.0)
        ]);
      }
      return;
    }

    if (newText.isEmpty) {
      _document = const DocumentModel(); // 텍스트가 모두 지워졌으면 문서를 비움
      return;
    }

    // 1. Prefix 비교: 앞에서부터 다른 문자가 나올 때까지의 길이 계산
    int prefixLength = 0;
    while (prefixLength < oldText.length &&
        prefixLength < newText.length &&
        oldText[prefixLength] == newText[prefixLength]) {
      prefixLength++;
    }

    // 2. Suffix 비교: 뒤에서부터 다른 문자가 나올 때까지의 길이 계산
    int suffixLength = 0;
    while (suffixLength < oldText.length - prefixLength &&
        suffixLength < newText.length - prefixLength &&
        oldText[oldText.length - 1 - suffixLength] == newText[newText.length - 1 - suffixLength]) {
      suffixLength++;
    }

    final newSpans = <TextSpanModel>[];
    int currentPos = 0;
    SpanAttribute styleForNewSpan = const SpanAttribute();

    // 3. 변경되지 않은 Prefix 부분의 스팬들을 그대로 추가
    for (final span in _document.spans) {
      final spanEnd = currentPos + span.text.length;
      if (spanEnd <= prefixLength) {
        // 이 스팬은 prefix에 완전히 포함됨
        newSpans.add(span);
        currentPos = spanEnd;
        styleForNewSpan = span.attribute; // 마지막 스타일을 기억
      } else {
        // prefix가 이 스팬 중간에서 끝남
        if (currentPos < prefixLength) {
          final prefixPart = span.text.substring(0, prefixLength - currentPos);
          newSpans.add(span.copyWith(text: prefixPart));
          styleForNewSpan = span.attribute; // 스타일을 기억
        }
        break;
      }
    }

    // 4. 변경된 중간 부분을 새로운 스팬으로 추가
    final newMiddleText = newText.substring(prefixLength, newText.length - suffixLength);
    if (newMiddleText.isNotEmpty) {
      newSpans.add(TextSpanModel(text: newMiddleText, attribute: styleForNewSpan));
    }

    // 5. 변경되지 않은 Suffix 부분의 스팬들을 추가
    currentPos = 0;
    final suffixStart = oldText.length - suffixLength;
    final tempSuffixSpans = <TextSpanModel>[];

    for (int i = _document.spans.length - 1; i >= 0; i--) {
      final span = _document.spans[i];
      final spanStart = oldText.length -
          tempSuffixSpans.fold<int>(0, (p, e) => p + e.text.length) -
          span.text.length;

      if (spanStart >= suffixStart) {
        // 이 스팬은 suffix에 완전히 포함됨
        tempSuffixSpans.insert(0, span);
      } else {
        // suffix가 이 스팬 중간에서 시작됨
        if (spanStart + span.text.length > suffixStart) {
          final suffixPart = span.text.substring(suffixStart - spanStart);
          tempSuffixSpans.insert(0, span.copyWith(text: suffixPart));
        }
        break;
      }
    }
    newSpans.addAll(tempSuffixSpans);

    // 6. 최종적으로 스팬 리스트를 병합하고 문서 업데이트
    _document = _document.copyWith(spans: _mergeSpans(newSpans));
  }

  /// 인접한 스팬이 동일한 속성을 가질 경우 하나로 병합합니다.
  List<TextSpanModel> _mergeSpans(List<TextSpanModel> spans) {
    if (spans.isEmpty) return [];
    final mergedSpans = <TextSpanModel>[];
    mergedSpans.add(spans.first);
    for (int i = 1; i < spans.length; i++) {
      final last = mergedSpans.last;
      final current = spans[i];
      if (last.attribute == current.attribute) {
        mergedSpans[mergedSpans.length - 1] = last.copyWith(text: last.text + current.text);
      } else {
        mergedSpans.add(current);
      }
    }
    return mergedSpans;
  }

  /// 텍스트 필드의 변경 사항을 문서 모델에 반영합니다.
  ///
  /// 이 메서드는 사용자의 단순 텍스트 입력/삭제를 처리하며,
  /// 현재 커서 위치의 스타일을 최대한 유지하려고 시도합니다.
  void updateText(String newText, TextSelection newSelection) {
    // 이 부분은 매우 복잡한 로직이 필요합니다.
    // 사용자의 입력(한 글자 추가/삭제, 붙여넣기 등)을 분석하여
    // 기존 spans를 최소한으로 수정해야 합니다.
    // 현재는 이전과 동일하게 단순화된 로직을 유지하지만,
    // 이것이 버그의 근본 원인임을 인지하고 있어야 합니다.
    _document = DocumentModel(
      spans: [
        TextSpanModel.defaultSpan(newText, initialSize: _currentStyle.fontSize ?? 30.0),
      ],
      textAlign: _document.textAlign, // 정렬 상태는 유지합니다.
    );
    notifyListeners();
  }

  /// 폰트 패밀리를 변경하고, 변경 사항을 알립니다.
  void changeFontFamily(String fontFamily) {
    _toggleStyle(_selection, (attr) => attr.copyWith(fontFamily: fontFamily));
    notifyListeners();
  }

  /// 선택된 영역의 폰트 크기를 변경합니다.
  void changeFontSize(double fontSize) {
    _toggleStyle(_selection, (attr) => attr.copyWith(fontSize: fontSize));
    notifyListeners();
  }

  /// 선택된 영역의 자간을 변경합니다.
  void changeLetterSpacing(double letterSpacing) {
    _toggleStyle(_selection, (attr) => attr.copyWith(letterSpacing: letterSpacing));
    notifyListeners();
  }

  /// 선택된 영역의 행간을 변경합니다.
  void changeLineHeight(double lineHeight) {
    _toggleStyle(_selection, (attr) => attr.copyWith(height: lineHeight));
    notifyListeners();
  }

  /// 선택된 영역의 폰트 색상을 변경합니다.
  void changeFontColor(Color color) {
    _toggleStyle(_selection, (attr) => attr.copyWith(color: color));
    notifyListeners();
  }

  /// 현재 선택 영역의 모든 스팬이 주어진 조건을 만족하는지 확인합니다.
  bool _isAttributeActive(bool Function(SpanAttribute) predicate) {
    if (_selection.isCollapsed) {
      return predicate(_currentStyle);
    }
    return _document.isAttributeAppliedToSelection(predicate, _selection);
  }

  /// 선택된 영역의 Bold 스타일을 토글합니다.
  void toggleBold() {
    final isBold = _isAttributeActive((attr) => attr.fontWeight == FontWeight.bold);
    _toggleStyle(_selection,
        (attr) => attr.copyWith(fontWeight: isBold ? FontWeight.normal : FontWeight.bold));
    notifyListeners();
  }

  /// 선택된 영역의 Italic 스타일을 토글합니다.
  void toggleItalic() {
    final isItalic = _isAttributeActive((attr) => attr.fontStyle == FontStyle.italic);
    _toggleStyle(_selection,
        (attr) => attr.copyWith(fontStyle: isItalic ? FontStyle.normal : FontStyle.italic));
    notifyListeners();
  }

  /// 선택된 영역의 Underline 스타일을 토글합니다.
  void toggleUnderline() {
    final isUnderlined = _isAttributeActive((attr) => attr.decoration == TextDecoration.underline);
    _toggleStyle(
        _selection,
        (attr) => attr.copyWith(
            decoration: isUnderlined ? TextDecoration.none : TextDecoration.underline));
    notifyListeners();
  }

  /// 문서의 텍스트 정렬을 변경합니다.
  void changeTextAlign(TextAlign align) {
    _document = _document.copyWith(textAlign: align);
    notifyListeners();
  }

  /// 문서의 수직 텍스트 정렬을 변경합니다.
  void changeVerticalAlign(TextAlignVertical align) {
    _document = _document.copyWith(textAlignVertical: align);
    notifyListeners();
  }

  /// 문서의 패딩(여백)을 변경합니다.
  void changePadding(EdgeInsets padding) {
    paddingNotifier.value = padding;
  }

  /// 선택된 영역의 그림자 속성을 변경합니다.
  void changeShadows(List<Shadow>? shadows) {
    if (shadows == null) {
      // 그림자를 제거합니다.
      _toggleStyle(_selection, (attr) => attr.removeAttribute('shadows'));
    } else {
      // 그림자를 적용합니다.
      _toggleStyle(_selection, (attr) => attr.copyWith(shadows: shadows));
    }
    notifyListeners();
  }

  /// 선택된 영역의 외곽선 속성을 변경합니다.
  void changeOutline(double? strokeWidth, Color? color) {
    _toggleStyle(_selection, (attr) => attr.copyWith(strokeWidth: strokeWidth, strokeColor: color));
    notifyListeners();
  }

  /// `TextInputClient`로부터 받은 변경사항으로 문서와 선택 영역을 업데이트합니다.
  void updateFromTextInput(TextEditingValue value) {
    _applyTextUpdateInternal(value.text);
    updateSelection(value.selection);
    // _applyTextUpdateInternal과 updateSelection이 각각 notifyListeners를
    // 호출할 수 있으므로, 중복 호출을 피하거나 여기서 한 번만 호출하도록 조정이 필요할 수 있습니다.
    // 현재 구조에서는 updateSelection이 notifyListeners를 호출하므로 여기서 추가 호출은 필요 없습니다.
  }

  /// 선택 영역에 특정 스타일 변경을 적용하는 비공개 헬퍼 메서드입니다.
  void _toggleStyle(TextSelection selection, SpanAttribute Function(SpanAttribute) update) {
    if (selection.isCollapsed) {
      _currentStyle = update(_currentStyle);
      // notifyListeners()는 이 메서드를 호출한 상위 메서드에서 처리하므로 여기서 중복 호출하지 않습니다.
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
        newSpans.add(span.copyWith(attribute: update(span.attribute)));
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
            attribute: update(span.attribute),
          ),
        );
        // 3. 선택 영역 뒷부분
        if (spanEnd > selection.end) {
          newSpans.add(span.copyWith(text: span.text.substring(selection.end - currentPos)));
        }
      }
      currentPos = spanEnd;
    }
    _document = _document.copyWith(spans: _mergeSpans(newSpans));
    // 스타일을 적용한 후, 변경된 내용을 _currentStyle에 즉시 반영합니다.
    // 이렇게 해야 툴바의 UI(예: 슬라이더)가 현재 선택 영역의 상태와 동기화됩니다.
    _currentStyle = update(_document.getSpanAttributeAt(selection.start));
  }

  // 개발 단계에 따라 이곳에 에디터의 상태를 관리하는 속성과 메서드가 추가될 예정입니다.
}
