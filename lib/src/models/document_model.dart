import 'package:flutter/material.dart';
import 'package:rich_text_editor/src/models/span_attribute.dart';
import 'text_span_model.dart';

/// 전체 Rich Text 문서를 나타내는 모델 클래스입니다.
///
/// 여러 `TextSpanModel` 객체의 리스트와 전체 문서의 정렬 상태를 관리합니다.
/// 이 클래스는 불변(immutable) 객체입니다.
@immutable
class DocumentModel {
  const DocumentModel({
    this.spans = const [],
    this.textAlign = TextAlign.start,
  });

  /// 문서를 구성하는 텍스트 조각(span)들의 리스트
  final List<TextSpanModel> spans;

  /// 문서 전체의 텍스트 정렬 상태
  final TextAlign textAlign;

  /// JSON 맵으로부터 `DocumentModel` 인스턴스를 생성합니다.
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    try {
      // 'spans' 필드가 리스트 형태인지 확인합니다.
      final spansList = json['spans'] as List?;
      if (spansList == null) {
        throw const FormatException('Required "spans" field is missing or not a List.');
      }
      return DocumentModel(
        spans: spansList.map((spanJson) => TextSpanModel.fromJson(spanJson)).toList(),
        textAlign: TextAlign.values[json['textAlign'] ?? TextAlign.start.index],
      );
    } catch (e) {
      debugPrint('Failed to parse DocumentModel from JSON: $e. Source: $json');
      // 오류 발생 시, 비어있는 DocumentModel을 반환하여 앱의 비정상 종료를 방지합니다.
      return const DocumentModel();
    }
  }

  /// `DocumentModel` 인스턴스를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'spans': spans.map((span) => span.toJson()).toList(),
      'textAlign': textAlign.index,
    };
  }

  /// 문서를 일반 텍스트 문자열로 변환합니다.
  String toPlainText() {
    return spans.map((span) => span.text).join('');
  }

  /// 현재 인스턴스를 복사하여 새로운 인스턴스를 생성합니다.
  DocumentModel copyWith({
    List<TextSpanModel>? spans,
    TextAlign? textAlign,
  }) {
    return DocumentModel(
      spans: spans ?? this.spans,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  /// 특정 위치(offset)에 있는 텍스트의 `SpanAttribute`를 반환합니다.
  SpanAttribute getSpanAttributeAt(int offset) {
    if (spans.isEmpty) {
      return const SpanAttribute(); // 문서가 비어있으면 기본 속성 반환
    }

    int currentPos = 0;
    for (final span in spans) {
      final spanEnd = currentPos + span.text.length;

      // 커서가 스팬 내부에 있거나, 스팬의 끝(다음 글자 앞)에 위치할 경우
      if (offset >= currentPos && offset <= spanEnd) {
        // 커서가 정확히 스팬의 시작점에 있고, 이전 스팬이 있다면
        // 보통 커서는 다음 글자에 대한 입력을 의미하므로, 현재 스팬의 스타일을 반환하는 것이 맞습니다.
        // 하지만 커서가 텍스트 맨 앞에 있는 경우(offset=0)도 이 조건에 포함됩니다.
        // 또한, 사용자가 왼쪽 글자의 스타일을 따라가길 원할 수 있습니다.
        // 현재 로직: 커서 위치가 포함된 스팬의 스타일을 반환
        return span.attribute;
      }
      currentPos = spanEnd;
    }

    // offset이 모든 스팬의 범위를 벗어난 경우 (보통 텍스트 맨 끝)
    // 마지막 스팬의 속성을 반환합니다.
    return spans.last.attribute;
  }
}
