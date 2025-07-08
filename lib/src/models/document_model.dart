import 'package:flutter/material.dart';
import 'text_span_model.dart';

/// 전체 Rich Text 문서를 나타내는 모델 클래스입니다.
///
/// 여러 `TextSpanModel` 객체의 리스트를 관리합니다.
/// 이 클래스는 불변(immutable) 객체입니다.
@immutable
class DocumentModel {
  const DocumentModel({
    this.spans = const [],
  });

  /// 문서를 구성하는 텍스트 조각(span)들의 리스트
  final List<TextSpanModel> spans;

  /// JSON 맵으로부터 `DocumentModel` 인스턴스를 생성합니다.
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      spans: (json['spans'] as List).map((spanJson) => TextSpanModel.fromJson(spanJson)).toList(),
    );
  }

  /// `DocumentModel` 인스턴스를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'spans': spans.map((span) => span.toJson()).toList(),
    };
  }

  /// 현재 인스턴스를 복사하여 새로운 인스턴스를 생성합니다.
  DocumentModel copyWith({
    List<TextSpanModel>? spans,
  }) {
    return DocumentModel(
      spans: spans ?? this.spans,
    );
  }
}
