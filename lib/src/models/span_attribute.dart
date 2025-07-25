//import 'dart:ui';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

class SpanAttribute {
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final Color? color;
  final Paint? foreground;
  final double? letterSpacing;
  final double? height;
  final String? fontFamily;
  final TextDecoration? decoration;
  final List<Shadow>? shadows;
  final double? strokeWidth;
  final Color? strokeColor;

  const SpanAttribute({
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.color,
    this.foreground,
    this.letterSpacing,
    this.height,
    this.fontFamily,
    this.decoration,
    this.shadows,
    this.strokeWidth,
    this.strokeColor,
  });

  SpanAttribute copyWith({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    Paint? foreground,
    double? letterSpacing,
    double? height,
    String? fontFamily,
    TextDecoration? decoration,
    List<Shadow>? shadows,
    double? strokeWidth,
    Color? strokeColor,
  }) {
    return SpanAttribute(
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      color: color ?? this.color,
      foreground: foreground ?? this.foreground,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      height: height ?? this.height,
      fontFamily: fontFamily ?? this.fontFamily,
      decoration: decoration ?? this.decoration,
      shadows: shadows ?? this.shadows,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
    );
  }

  /// 특정 속성을 제거(null로 설정)한 새로운 인스턴스를 반환합니다.
  SpanAttribute removeAttribute(String attributeName) {
    return SpanAttribute(
      fontSize: attributeName == 'fontSize' ? null : fontSize,
      fontWeight: attributeName == 'fontWeight' ? null : fontWeight,
      fontStyle: attributeName == 'fontStyle' ? null : fontStyle,
      color: attributeName == 'color' ? null : color,
      foreground: attributeName == 'foreground' ? null : foreground,
      letterSpacing: attributeName == 'letterSpacing' ? null : letterSpacing,
      height: attributeName == 'height' ? null : height,
      fontFamily: attributeName == 'fontFamily' ? null : fontFamily,
      decoration: attributeName == 'decoration' ? null : decoration,
      shadows: attributeName == 'shadows' ? null : shadows,
      strokeWidth: attributeName == 'strokeWidth' ? null : strokeWidth,
      strokeColor: attributeName == 'strokeColor' ? null : strokeColor,
    );
  }

  /// 이 속성을 Flutter의 `TextStyle` 객체로 변환합니다.
  TextStyle toTextStyle({double applyScale = 1.0}) {
    return TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontSize: fontSize != null ? fontSize! * applyScale : 48.0 * applyScale,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing != null ? letterSpacing! * applyScale : 2.0 * applyScale,
      height: height ??
          2.0, // Line height is a multiplier, not a pixel value, so it should not be scaled.
      shadows: shadows
          ?.map((s) => Shadow(
                color: s.color,
                offset: s.offset * applyScale,
                blurRadius: s.blurRadius * applyScale,
              ))
          .toList(),
      foreground: strokeWidth != null && strokeColor != null
          ? (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth! * applyScale
            ..color = strokeColor!)
          : null,
    );
  }

  /// `SpanAttribute` 인스턴스를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson({List<String>? fontList}) {
    final json = <String, dynamic>{};
    json['fontSize'] = fontSize ?? 48.0;
    if (fontWeight != null) json['fontWeight'] = fontWeight.toString();
    if (fontStyle != null) json['fontStyle'] = fontStyle.toString();
    // ignore: deprecated_member_use
    json['color'] = (color ?? Colors.black).value;
    if (letterSpacing != null) json['letterSpacing'] = letterSpacing;
    json['height'] = height ?? 2.0;
    json['fontFamily'] =
        fontFamily ?? (fontList != null && fontList.isNotEmpty ? fontList.first : 'HDHarmony');
    if (decoration != null) json['decoration'] = decoration.toString();
    if (shadows != null) {
      json['shadows'] = shadows!
          .map((s) => {
                // ignore: deprecated_member_use
                'color': s.color.value,
                'offsetX': s.offset.dx,
                'offsetY': s.offset.dy,
                'blurRadius': s.blurRadius
              })
          .toList();
    }
    if (strokeWidth != null) json['strokeWidth'] = strokeWidth;
    // ignore: deprecated_member_use
    if (strokeColor != null) json['strokeColor'] = strokeColor!.value;
    return json;
  }

  /*
  FontWeight 을 toString() 한 값이 
  디버그 모드와 릴리즈 모드가 다른 문제 발견되어 _fontWeightFromJson 함수 만듬 아래 fromJson의 fontWeight 지정 부분에 사용함
  디버그 e.toString() = FontWeight.w100
  릴리즈 e.toString() = Instance of 'FontWeight'
  */

  static FontWeight? _fontWeightFromJson(String? value) {
    if (value == null) return null;

    final cleaned = value.replaceAll('FontWeight.', '');

    const fontWeightMap = {
      'w100': FontWeight.w100,
      'w200': FontWeight.w200,
      'w300': FontWeight.w300,
      'w400': FontWeight.w400,
      'w500': FontWeight.w500,
      'w600': FontWeight.w600,
      'w700': FontWeight.w700,
      'w800': FontWeight.w800,
      'w900': FontWeight.w900,
    };

    return fontWeightMap[cleaned];
  }

  factory SpanAttribute.fromJson(Map<String, dynamic> json, {List<String>? fontList}) {
    return SpanAttribute(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 48.0,
      //기존 코드
      /*
      fontWeight: json['fontWeight'] != null
          ? FontWeight.values.firstWhere((e) => e.toString() == json['fontWeight'])
          : null,
      */
      fontWeight: _fontWeightFromJson(json['fontWeight']),
      fontStyle: json['fontStyle'] != null
          ? FontStyle.values.firstWhere((e) => e.toString() == json['fontStyle'])
          : null,
      color: json['color'] != null ? Color(json['color']) : Colors.black,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble() ?? 2.0,
      fontFamily: json['fontFamily'] ??
          (fontList != null && fontList.isNotEmpty ? fontList.first : 'HDHarmony'),
      decoration: json['decoration'] != null ? _decorationFromString(json['decoration']) : null,
      shadows: json['shadows'] != null
          ? (json['shadows'] as List)
              .map((s) => Shadow(
                    color: Color(s['color']),
                    offset:
                        Offset((s['offsetX'] as num).toDouble(), (s['offsetY'] as num).toDouble()),
                    blurRadius: (s['blurRadius'] as num).toDouble(),
                  ))
              .toList()
          : null,
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble(),
      strokeColor: json['strokeColor'] != null ? Color(json['strokeColor']) : null,
    );
  }

  static TextDecoration? _decorationFromString(String value) {
    switch (value) {
      case 'TextDecoration.underline':
        return TextDecoration.underline;
      case 'TextDecoration.overline':
        return TextDecoration.overline;
      case 'TextDecoration.lineThrough':
        return TextDecoration.lineThrough;
      case 'TextDecoration.none':
        return TextDecoration.none;
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SpanAttribute) return false;
    return other.fontSize == fontSize &&
        other.fontWeight == fontWeight &&
        other.fontStyle == fontStyle &&
        other.color == color &&
        other.foreground == foreground &&
        other.letterSpacing == letterSpacing &&
        other.height == height &&
        other.fontFamily == fontFamily &&
        other.decoration == decoration &&
        listEquals(other.shadows, shadows) &&
        other.strokeWidth == strokeWidth &&
        other.strokeColor == strokeColor;
  }

  @override
  int get hashCode => Object.hash(
        fontSize,
        fontWeight,
        fontStyle,
        color,
        foreground,
        letterSpacing,
        height,
        fontFamily,
        decoration,
        Object.hashAll(shadows ?? []),
        strokeWidth,
        strokeColor,
      );
}
