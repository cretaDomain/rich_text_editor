import 'dart:ui';
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

  TextStyle toTextStyle() {
    Paint? foregroundPaint;
    if ((strokeWidth ?? 0) > 0 && strokeColor != null) {
      foregroundPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth!
        ..color = strokeColor!;
    } else {
      foregroundPaint = foreground;
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: foregroundPaint == null ? color : null,
      foreground: foregroundPaint,
      letterSpacing: letterSpacing, // 이 줄이 추가되었습니다.
      height: height, // 이 줄이 추가되었습니다.
      fontFamily: fontFamily,
      decoration: decoration,
      shadows: shadows,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (fontSize != null) json['fontSize'] = fontSize;
    if (fontWeight != null) json['fontWeight'] = fontWeight.toString();
    if (fontStyle != null) json['fontStyle'] = fontStyle.toString();
    if (color != null) json['color'] = color!.value;
    if (letterSpacing != null) json['letterSpacing'] = letterSpacing;
    if (height != null) json['height'] = height;
    if (fontFamily != null) json['fontFamily'] = fontFamily;
    if (decoration != null) json['decoration'] = decoration.toString();
    if (strokeWidth != null) json['strokeWidth'] = strokeWidth;
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
        other.shadows == shadows &&
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
        shadows,
        strokeWidth,
        strokeColor,
      );
}
