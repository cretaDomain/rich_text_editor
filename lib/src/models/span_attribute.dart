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
  TextStyle toTextStyle() {
    return TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
      foreground: strokeWidth != null && strokeColor != null
          ? (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth!
            ..color = strokeColor!)
          : null,
    );
  }

  /// `SpanAttribute` 인스턴스를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (fontSize != null) json['fontSize'] = fontSize;
    if (fontWeight != null) json['fontWeight'] = fontWeight.toString();
    if (fontStyle != null) json['fontStyle'] = fontStyle.toString();
    // ignore: deprecated_member_use
    if (color != null) json['color'] = color!.value;
    if (letterSpacing != null) json['letterSpacing'] = letterSpacing;
    if (height != null) json['height'] = height;
    if (fontFamily != null) json['fontFamily'] = fontFamily;
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

  factory SpanAttribute.fromJson(Map<String, dynamic> json) {
    return SpanAttribute(
      fontSize: json['fontSize'],
      fontWeight: json['fontWeight'] != null
          ? FontWeight.values.firstWhere((e) => e.toString() == json['fontWeight'])
          : null,
      fontStyle: json['fontStyle'] != null
          ? FontStyle.values.firstWhere((e) => e.toString() == json['fontStyle'])
          : null,
      color: json['color'] != null ? Color(json['color']) : null,
      letterSpacing: json['letterSpacing'],
      height: json['height'],
      fontFamily: json['fontFamily'],
      decoration: json['decoration'] != null ? _decorationFromString(json['decoration']) : null,
      shadows: json['shadows'] != null
          ? (json['shadows'] as List)
              .map((s) => Shadow(
                    color: Color(s['color']),
                    offset: Offset(s['offsetX'], s['offsetY']),
                    blurRadius: s['blurRadius'],
                  ))
              .toList()
          : null,
      strokeWidth: json['strokeWidth'],
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
