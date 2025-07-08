import 'package:flutter/foundation.dart';
import 'package:rich_text_editor/src/models/document_model.dart';

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

  /// 현재 모드를 반환합니다.
  EditorMode get mode => _mode;

  /// 현재 문서를 반환합니다.
  DocumentModel get document => _document;

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

  // 개발 단계에 따라 이곳에 에디터의 상태를 관리하는 속성과 메서드가 추가될 예정입니다.
}
