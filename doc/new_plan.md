# WYSIWYG Rich Text Editor 리팩토링 계획

이 문서는 기존의 분리된 View/Edit 영역을 통합하여, 스타일이 즉시 적용되는 WYSIWYG 방식의 커스텀 에디터를 구현하기 위한 리팩토링 계획을 정의합니다.

---

### Phase 1: `RawEditor` 위젯의 기본 구조 및 렌더링 구현

- [ ] **Step 1-1: `RawEditor` 위젯 파일 생성 및 기본 구조 설정**
  - `lib/src/widgets/raw_editor.dart` 파일을 생성합니다.
  - `StatefulWidget`으로 기본 `RawEditor` 위젯을 구현합니다.
  - `RichTextEditorController`를 파라미터로 받도록 설정합니다.
  - `CustomPaint` 위젯을 사용하여 렌더링 영역의 기초를 마련합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 1-2: `DocumentPainter` 클래스 생성**
  - `CustomPainter`를 상속받는 `DocumentPainter` 클래스를 `raw_editor.dart` 내부에 구현합니다.
  - `DocumentModel`을 파라미터로 받아 `paint` 메소드 내에서 렌더링을 준비합니다.
  - `RawEditor`의 `CustomPaint` 위젯이 `DocumentPainter`를 사용하도록 연결합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 1-3: `TextPainter`를 이용한 텍스트 렌더링 구현**
  - `DocumentPainter`의 `paint` 메소드에서 `document.spans`를 순회합니다.
  - 각 `TextSpanModel`을 `TextSpan`으로 변환하고 `TextPainter`를 사용하여 캔버스에 그립니다.
  - 줄 바꿈을 포함한 기본적인 텍스트 레이아웃을 처리합니다.
  - **(완료 후 사용자 확인 및 커밋)**

### Phase 2: 키보드 입력 및 커서/선택 구현

- [ ] **Step 2-1: 포커스 및 키보드 리스너 추가**
  - `RawEditor` 위젯에 `FocusNode`를 추가하여 포커스를 관리할 수 있도록 합니다.
  - `Focusable`과 `RawKeyboardListener` 위젯으로 `CustomPaint`를 감싸 키보드 이벤트를 수신할 준비를 합니다. (아직 실제 입력 처리는 하지 않음)
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 2-2: 커서(Caret) 렌더링 구현**
  - `DocumentPainter`에 현재 커서 위치(offset) 정보를 전달합니다.
  - `TextPainter.getOffsetForCaret`를 사용하여 커서의 정확한 `x, y` 좌표를 계산합니다.
  - 계산된 위치에 `canvas.drawRect` 등을 사용하여 커서를 그립니다.
  - 커서가 주기적으로 깜빡이도록 `AnimationController`를 사용합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 2-3: 마우스 클릭으로 커서 위치 이동 구현**
  - `GestureDetector`를 `RawEditor`에 추가하여 `onTapUp` 이벤트를 감지합니다.
  - 탭된 위치의 로컬 `x, y` 좌표를 `TextPainter.getPositionForOffset`을 사용하여 텍스트 offset으로 변환합니다.
  - 변환된 offset으로 컨트롤러의 커서 위치를 업데이트하고 화면을 다시 그리도록 요청합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 2-4: 마우스 드래그로 텍스트 선택 기능 구현**
  - `GestureDetector`에 `onPanStart`, `onPanUpdate`, `onPanEnd` 콜백을 구현합니다.
  - 드래그 시작점과 현재 위치를 기반으로 텍스트 선택 영역(`TextSelection`)을 계산합니다.
  - `DocumentPainter`가 `TextSelection` 정보를 받아, 선택된 영역의 배경에 색상을 칠하도록 구현합니다.
  - **(완료 후 사용자 확인 및 커밋)**

### Phase 3: `TextInputClient`를 이용한 고급 입력 처리 (한글 입력 포함)

- [ ] **Step 3-1: `TextInputClient` 인터페이스 구현**
  - `RawEditor`의 `State` 클래스가 `TextInputClient`를 `with` 키워드로 구현하도록 선언합니다.
  - `currentTextEditingValue`, `updateEditingValue` 등 `TextInputClient`의 필수 메소드들을 기본 형태로 구현합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 3-2: IME 연결 및 해제 로직 구현**
  - `RawEditor`의 `State`에 `TextInputConnection` 변수를 추가합니다.
  - 에디터가 포커스를 받을 때 `TextInput.attach`를 호출하여 IME와 연결하고, 포커스를 잃을 때 `connection.close()`를 호출하여 연결을 해제하는 로직을 구현합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 3-3: IME 입력을 `DocumentModel`에 반영**
  - `updateEditingValue` 콜백 내에서, IME로부터 받은 새로운 `TextEditingValue`를 분석합니다.
  - 변경된 텍스트, 커서 위치, 조합 중인 글자 범위(`composing`)를 `RichTextEditorController`와 `DocumentModel`에 반영하는 로직을 구현합니다.
  - 모든 텍스트 입력을 `TextInputClient`를 통해 처리하도록 통합합니다.
  - **(완료 후 사용자 확인 및 커밋)**

### Phase 4: `RichTextEditor` 통합 및 컨트롤러 리팩토링

- [ ] **Step 4-1: `RichTextEditor` 위젯 리팩토링**
  - `lib/src/widgets/rich_text_editor.dart` 파일에서 기존의 View Area와 Edit Area(`TextFormField`)를 모두 제거합니다.
  - 제거된 위치에 우리가 만든 `RawEditor` 위젯을 배치합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 4-2: 컨트롤러와 툴바 연동**
  - `RichTextEditorController`의 스타일 변경 메소드들이 `RawEditor`의 현재 선택 영역에 직접 스타일을 적용하고 즉시 화면에 반영하도록 수정합니다.
  - 선택 영역의 스타일에 따라 툴바의 버튼 상태가 업데이트되도록 `updateStyleAtSelection` 로직을 `RawEditor`의 선택 변경과 연동합니다.
  - **(완료 후 사용자 확인 및 커밋)**

- [ ] **Step 4-3: 불필요한 코드 제거 및 최종 정리**
  - `TextFormField`와 관련된 기존의 복잡한 텍스트 동기화 로직 (`applyTextUpdate` 등)을 컨트롤러에서 제거합니다.
  - 전체적인 코드 리뷰 및 정리를 진행합니다.
  - **(완료 후 사용자 확인 및 커밋)** 