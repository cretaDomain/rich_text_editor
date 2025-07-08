# Rich Text Editor 위젯 개발 계획서

## 1. 개요

본 문서는 `doc/requirement.md`에 정의된 요구사항을 기반으로 Rich Text Editor 위젯을 개발하기 위한 상세 계획을 정의합니다.

### **중요 원칙**
- **단계(Step) 정의**: 본 계획에서 "단계"는 `1-1`, `1-2`와 같은 세부 항목을 의미합니다.
- **개발 프로세스**: 각 단계 완료 후에는 **사용자(Product Owner)의 확인(Confirm)을 받고 Git에 커밋(Commit)**한 후 다음 단계를 진행합니다.
- **개발 규칙**: 개발은 사전에 정의된 **사용자 규칙(User Rules)을 반드시 준수**하여 진행합니다.
- **테스트 생략**: 본 개발에서는 요구사항과 달리 **테스트 코드 작성을 생략**합니다.

---

## 2. 개발 단계 (체크리스트)

### Phase 1: 프로젝트 설정 및 기본 구조 수립
- [x] **1-1. Flutter 신규 프로젝트 생성**: `rich_text_editor`라는 이름의 Flutter 프로젝트를 초기화합니다.
- [x] **1-2. 디렉토리 구조 설정**: 기능별로 코드를 분리하기 위해 `lib/src` 내부에 `models`, `controllers`, `widgets`, `views` 디렉토리를 생성합니다.
- [x] **1-3. 기본 위젯 및 컨트롤러 정의**:
    - `RichTextEditor` 위젯의 기본 골격(`StatefulWidget`)을 생성합니다.
    - `RichTextEditorController` 클래스의 기본 골격을 정의합니다. 이 컨트롤러는 `ChangeNotifier`를 상속받아 상태 변경을 알립니다.
- [x] **1-4. UI 와이어프레임 작성**: UI 와이어프레임을 작성하여 `doc/wireframe.svg` 파일로 저장합니다.

### Phase 2: 데이터 모델 구현
- [ ] **2-1. 데이터 모델 클래스 정의**:
    - 텍스트 조각의 속성을 담는 `SpanAttribute` 클래스 정의 (폰트, 색상, 크기 등).
    - 텍스트 내용과 속성을 담는 `TextSpanModel` 클래스 정의.
    - 전체 문서를 표현하는 `DocumentModel` 클래스 정의 (`List<TextSpanModel>`).
- [ ] **2-2. JSON 직렬화/역직렬화 구현**:
    - `SpanAttribute`, `TextSpanModel`, `DocumentModel` 클래스에 `fromJson`, `toJson` 메서드를 구현합니다.

### Phase 3: 뷰 모드(읽기 전용) 기능 구현
- [ ] **3-1. `DocumentModel` 렌더링**: `DocumentModel`을 Flutter의 `RichText` 위젯과 `TextSpan`으로 변환하여 화면에 렌더링하는 뷰(`DocumentView`)를 구현합니다.
- [ ] **3-2. 외부 인수 연동 (View)**:
    - 위젯 생성자를 통해 `RichTextEditorController`를 주입받습니다.
    - 컨트롤러의 `DocumentModel`이 변경될 때마다 화면이 다시 렌더링되도록 구현합니다.
    - 배경색(기본값: 완전 투명) 및 내부 여백(Padding)을 위젯 인수로 받아 뷰에 적용합니다.

### Phase 4: 편집 모드 기능 구현
- [ ] **4-1. 기본 텍스트 필드 추가**: 편집 모드에서 사용할 `TextFormField`를 `RichTextEditor` 위젯에 추가합니다.
- [ ] **4-2. 컨트롤러 연동 (Edit)**: `TextFormField`의 `controller`를 `RichTextEditorController`와 연동하여 기본적인 텍스트 입력, 수정, 삭제(한글 포함), 여러 줄 편집이 가능하도록 구현합니다.
- [ ] **4-3. 편집/뷰 모드 전환**:
    - 모드 상태를 관리할 변수를 컨트롤러에 추가합니다.
    - 모드 전환 토글 버튼 UI를 구현하고, 버튼 클릭 시 편집 모드(`TextFormField`)와 뷰 모드(`DocumentView`)가 전환되도록 로직을 구현합니다.

### Phase 5: 텍스트 스타일링 UI 및 로직 구현
- [ ] **5-1. 스타일링 도구 모음(Toolbar) UI**: 편집 모드에서만 보이는 스타일링 도구 모음의 기본 UI를 구현합니다.
- [ ] **5-2. 폰트 선택 기능**: 위젯 인수로 받은 폰트 리스트를 사용하여 폰트 변경 드롭다운 메뉴를 구현하고, 선택된 폰트를 `Controller`에 반영합니다.
- [ ] **5-3. 텍스트 속성 변경 기능**:
    - 글자 크기, 색상, Bold, Italic, Underline을 변경하는 UI 컨트롤들을 도구 모음에 추가합니다.
    - `TextFormField`에서 선택된 텍스트(Selection)의 속성을 변경하고, 이를 `DocumentModel`에 반영하는 로직을 `Controller`에 구현합니다.
- [ ] **5-4. 단락 속성 변경 기능**:
    - 장평(letter spacing), 줄 간격(line height), 정렬(alignment)을 변경하는 UI 컨트롤을 추가하고 `Controller`에 관련 로직을 구현합니다.
- [ ] **5-5. 고급 속성 변경 기능**:
    - 그림자, 외곽선 효과를 적용하는 UI 및 로직을 구현합니다.

### Phase 6: 최종 점검 및 문서화
- [ ] **6-1. 플랫폼 호환성 점검**: Web, Android, iOS 각 플랫폼에서 위젯이 의도대로 동작하는지 직접 확인하고 발견된 문제를 수정합니다.
- [ ] **6-2. 문서화**: 코드 내에 주석을 추가하고, 위젯 사용법에 대한 간단한 `README.md` 문서를 작성합니다.

--- 