import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../models/span_attribute.dart';
//import '../models/text_span_model.dart';

/// `DocumentModel`을 화면에 렌더링하는 읽기 전용 뷰 위젯입니다.
class DocumentView extends StatelessWidget {
  const DocumentView({
    super.key,
    required this.document,
    this.applyScale = 1.0,
  });

  /// 화면에 표시할 문서 데이터입니다.
  final DocumentModel document;
  final double applyScale;

  @override
  Widget build(BuildContext context) {
    // 문서에 내용이 없으면 빈 컨테이너를 반환합니다.
    if (document.spans.isEmpty) {
      return Container();
    }

    return RichText(
      textAlign: document.textAlign,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style, // 기본 스타일 적용
        children: _buildTextSpans(),
      ),
    );
  }

  /// `DocumentModel`의 `spans` 리스트를 Flutter의 `TextSpan` 위젯 리스트로 변환합니다.
  List<TextSpan> _buildTextSpans() {
    return document.spans.map((spanModel) {
      return spanModel.toTextSpan(applyScale: applyScale);
    }).toList();
  }
}
