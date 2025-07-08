import 'package:flutter/material.dart';
import 'span_attribute.dart';

/// 편집 가능한 텍스트 문서의 한 조각(span)을 나타내는 데이터 모델입니다.
///
/// 각 `TextSpanModel`은 텍스트 내용(`text`)과 해당 텍스트에 적용될
/// 스타일 속성(`attribute`)을 가집니다.
@immutable
class TextSpanModel {
  /// 이 `TextSpanModel`에 대한 기본 생성자입니다.
  const TextSpanModel({
    required this.text,
    required this.attribute,
  });

  /// 텍스트 내용
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
  Map<String, dynamic> toJson() => {
        'text': text,
        'attribute': attribute.toJson(),
      };

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

  /// 주어진 텍스트에 대한 기본 스타일을 가진 `TextSpanModel`을 생성합니다.
  factory TextSpanModel.defaultSpan(String text) {
    return TextSpanModel(
      text: text,
      attribute: const SpanAttribute(
        fontSize: 14.0,
        color: Colors.black,
      ),
    );
  }
}
