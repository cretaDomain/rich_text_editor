import 'package:flutter/material.dart';
import 'span_attribute.dart';

/// 텍스트 내용과 그에 해당하는 스타일 속성을 함께 가지는 모델 클래스입니다.
///
/// 리치 텍스트 문서를 구성하는 가장 기본적인 단위입니다.
/// 이 클래스는 불변(immutable) 객체입니다.
@immutable
class TextSpanModel {
  const TextSpanModel({
    required this.text,
    this.attribute = const SpanAttribute(),
  });

  /// 실제 텍스트 내용
  final String text;

  /// 이 텍스트에 적용될 스타일 속성
  final SpanAttribute attribute;

  /// JSON 맵으로부터 `TextSpanModel` 인스턴스를 생성합니다.
  factory TextSpanModel.fromJson(Map<String, dynamic> json) {
    return TextSpanModel(
      text: json['text'],
      attribute: SpanAttribute.fromJson(json['attribute']),
    );
  }

  /// `TextSpanModel` 인스턴스를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'attribute': attribute.toJson(),
    };
  }

  /// 현재 인스턴스를 복사하여 새로운 인스턴스를 생성합니다.
  TextSpanModel copyWith({
    String? text,
    SpanAttribute? attribute,
  }) {
    return TextSpanModel(
      text: text ?? this.text,
      attribute: attribute ?? this.attribute,
    );
  }
}
