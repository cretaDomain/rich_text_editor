import 'package:flutter/material.dart';

/// 텍스트의 한 조각(span)에 적용될 스타일 속성을 나타내는 클래스입니다.
///
/// 이 클래스는 불변(immutable) 객체로, 모든 속성은 final로 선언됩니다.
/// 속성을 변경하려면 `copyWith` 메소드를 사용하여 새로운 인스턴스를 생성해야 합니다.
@immutable
class SpanAttribute {
  const SpanAttribute({
    this.fontFamily,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.shadows,
    this.foreground,
    this.letterSpacing,
    this.height,
  });

  /// 폰트 종류
  final String? fontFamily;

  /// 글자 크기
  final double? fontSize;

  /// 글자 색상
  final Color? color;

  /// 글자 굵기 (e.g., FontWeight.bold)
  final FontWeight? fontWeight;

  /// 글자 스타일 (e.g., FontStyle.italic)
  final FontStyle? fontStyle;

  /// 텍스트 꾸미기 (e.g., TextDecoration.underline)
  final TextDecoration? decoration;

  /// 그림자 효과
  final List<Shadow>? shadows;

  /// 외곽선 효과 등을 위한 전경 Paint
  final Paint? foreground;

  /// 글자 간격 (장평)
  final double? letterSpacing;

  /// 줄 간격 (라인 높이)
  final double? height;

  /// JSON 맵으로부터 `SpanAttribute` 인스턴스를 생성합니다.
  factory SpanAttribute.fromJson(Map<String, dynamic> json) {
    // TextDecoration 역직렬화
    TextDecoration? decoration;
    if (json['decoration'] != null) {
      final List<TextDecoration> decorations = [];
      if (json['decoration']['underline'] == true) {
        decorations.add(TextDecoration.underline);
      }
      if (json['decoration']['lineThrough'] == true) {
        decorations.add(TextDecoration.lineThrough);
      }
      if (json['decoration']['overline'] == true) {
        decorations.add(TextDecoration.overline);
      }
      if (decorations.isNotEmpty) {
        decoration = TextDecoration.combine(decorations);
      }
    }

    return SpanAttribute(
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize'],
      color: json['color'] != null ? Color(json['color']) : null,
      fontWeight: json['fontWeight'] != null ? FontWeight.values[json['fontWeight']] : null,
      fontStyle: json['fontStyle'] != null ? FontStyle.values[json['fontStyle']] : null,
      decoration: decoration,
      shadows: (json['shadows'] as List?)
          ?.map((s) => Shadow(
                color: Color(s['color']),
                offset: Offset(s['offset']['dx'], s['offset']['dy']),
                blurRadius: s['blurRadius'],
              ))
          .toList(),
      foreground: json['foreground'] != null
          ? (Paint()
            ..color = Color(json['foreground']['color'])
            ..strokeWidth = json['foreground']['strokeWidth']
            ..style = PaintingStyle.values[json['foreground']['style']])
          : null,
      letterSpacing: json['letterSpacing'],
      height: json['height'],
    );
  }

  /// `SpanAttribute` 인스턴스를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      // ignore: deprecated_member_use
      'color': color?.value,
      'fontWeight': fontWeight?.index,
      'fontStyle': fontStyle?.index,
      // TextDecoration 직렬화
      'decoration': decoration != null
          ? {
              'underline': decoration!.contains(TextDecoration.underline),
              'lineThrough': decoration!.contains(TextDecoration.lineThrough),
              'overline': decoration!.contains(TextDecoration.overline),
            }
          : null,
      'shadows': shadows
          ?.map((s) => {
                // ignore: deprecated_member_use
                'color': s.color.value,
                'offset': {'dx': s.offset.dx, 'dy': s.offset.dy},
                'blurRadius': s.blurRadius,
              })
          .toList(),
      'foreground': foreground != null
          ? {
              // ignore: deprecated_member_use
              'color': foreground!.color.value,
              'strokeWidth': foreground!.strokeWidth,
              'style': foreground!.style.index,
            }
          : null,
      'letterSpacing': letterSpacing,
      'height': height,
    };
  }

  /// 현재 인스턴스를 복사하여 새로운 인스턴스를 생성합니다.
  ///
  /// 주어진 값으로 속성을 갱신하고, 나머지는 기존 값을 유지합니다.
  SpanAttribute copyWith({
    String? fontFamily,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    List<Shadow>? shadows,
    Paint? foreground,
    double? letterSpacing,
    double? height,
  }) {
    return SpanAttribute(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      decoration: decoration ?? this.decoration,
      shadows: shadows ?? this.shadows,
      foreground: foreground ?? this.foreground,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      height: height ?? this.height,
    );
  }
}
