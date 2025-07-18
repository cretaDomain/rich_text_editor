### `applyScale` 적용 계획

**목표:** `RawEditor`에 표시되는 텍스트 및 관련 UI 요소들의 크기를 `applyScale` 계수를 사용하여 동적으로 조절합니다. 이 과정에서 기존 로직과 코드 구조는 절대 변경하지 않으며, 오직 `applyScale` 값을 필요한 속성에 곱하는 방식으로만 구현합니다. `DocumentView`는 이번 작업에서 제외합니다.

---

**1단계: 데이터 모델 수정 (`applyScale` 값 전달 통로 마련)**

*   **파일:** `lib/src/models/span_attribute.dart`
    *   **작업:** `toTextStyle()` 메서드 시그니처를 `toTextStyle({double applyScale = 1.0})`으로 변경합니다.
    *   **내용:** 메서드 내부에서 `fontSize`, `letterSpacing`, `shadows`의 `offset` 및 `blurRadius`, `strokeWidth` 값에 `applyScale`을 곱하여 `TextStyle` 객체를 생성합니다.
    *   **주의:** `height` 속성은 폰트 크기의 배수이므로 스케일링하지 않습니다.

*   **파일:** `lib/src/models/text_span_model.dart`
    *   **작업:** `toTextSpan()` 메서드 시그니처를 `toTextSpan({double applyScale = 1.0})`으로 변경합니다.
    *   **내용:** 이 메서드 내부에서 `attribute.toTextStyle(applyScale: applyScale)`를 호출하여 `applyScale` 값을 그대로 전달합니다.

**2단계: `RawEditor` 위젯에 `applyScale` 적용**

*   **파일:** `lib/src/widgets/raw_editor.dart`
    *   **작업 1:** `RawEditor` 위젯에 `final double applyScale;` 속성을 추가하고 생성자에서 이를 초기화합니다.
    *   **작업 2:** `RawEditorState`의 `_createTextPainter` 메서드에서 `widget.controller.document.spans.map(...)` 부분을 `s.toTextSpan(applyScale: widget.applyScale)`로 수정하여 `applyScale` 값을 전달합니다.
    *   **작업 3:** `DocumentPainter` 클래스에 `final double applyScale;` 속성을 추가하고 생성자에서 초기화합니다.
    *   **작업 4:** `RawEditorState`의 `build` 메서드에서 `DocumentPainter`를 생성할 때, `applyScale: widget.applyScale`을 전달합니다.
    *   **작업 5:** `DocumentPainter`의 `_createLocalTextPainter` 메서드에서 `document.spans.map(...)` 부분을 `s.toTextSpan(applyScale: applyScale)`로 수정합니다.

**3단계: `RichTextEditor` 위젯에서 `applyScale` 값 전달**

*   **파일:** `lib/src/widgets/rich_text_editor.dart`
    *   **작업 1:** `_buildContent()` 메서드에서 `RawEditor`를 감싸고 있는 `Padding` 위젯을 찾아, `padding` 값에 `widget.applyScale`을 곱한 `scaledPadding`을 적용합니다. (이 부분은 이미 되돌리기 전 커밋에서 반영되었을 수 있으므로 확인 후 적용합니다.)
    *   **작업 2:** `RawEditor` 위젯을 생성하는 부분에 `applyScale: widget.applyScale` 속성을 추가하여 값을 전달합니다. 