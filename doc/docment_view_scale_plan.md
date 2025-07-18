### `DocumentView`에 `applyScale` 적용 계획

**목표:** `DocumentView`에 표시되는 텍스트 및 관련 UI 요소들의 크기를 `applyScale` 계수를 사용하여 동적으로 조절합니다. `span_attribute.dart`와 `text_span_model.dart`에 이미 구현된 스케일링 로직을 재사용하며, 기존 코드 구조는 변경하지 않습니다.

---

**1단계: `DocumentView` 위젯에 `applyScale` 적용**

*   **파일:** `lib/src/views/document_view.dart`
    *   **작업 1:** `DocumentView` 위젯에 `final double applyScale;` 속성을 추가하고, 생성자에서 `this.applyScale = 1.0`과 같이 기본값을 설정하여 초기화합니다. (이전 `revert`된 커밋에서 이미 작업되었을 수 있으므로 확인 후 반영합니다.)
    *   **작업 2:** `DocumentView`의 `build` 메서드 또는 관련 헬퍼 메서드(`_buildTextSpan` 등) 내부에서 `span.toTextSpan()`을 호출하는 부분을 찾습니다.
    *   **작업 3:** 해당 호출을 `span.toTextSpan(applyScale: applyScale)`로 수정하여, `DocumentView`가 속성으로 가지고 있는 `applyScale` 값을 `toTextSpan` 메서드에 전달합니다.

**2단계: `RichTextEditor` 위젯에서 `applyScale` 값 전달**

*   **파일:** `lib/src/widgets/rich_text_editor.dart`
    *   **작업 1:** `_buildContent()` 메서드에서 `_controller!.mode == EditorMode.view` 분기 안에 있는 `DocumentView` 생성 코드를 찾습니다.
    *   **작업 2:** `DocumentView(...)`에 `applyScale: widget.applyScale` 속성을 추가하여 `RichTextEditor`의 `applyScale` 값을 전달합니다.
    *   **작업 3:** `DocumentView`를 감싸는 `Padding` 위젯에, `padding` 값으로 `_padding` 대신 `_padding * widget.applyScale`을 적용하여 패딩 또한 스케일링되도록 합니다. 