import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../controllers/rich_text_editor_controller.dart';

/// 텍스트 스타일링을 위한 도구 모음(Toolbar) 위젯입니다.
class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.controller,
    required this.fontList,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onChangeLetterSpacing,
    required this.onChangeLineHeight,
    required this.onChangeAlign,
    required this.onFontFamilyChanged,
    required this.onFontSizeChanged,
    required this.onFontColorChanged,
  });

  /// 위젯의 상태를 관리하는 컨트롤러입니다.
  final RichTextEditorController controller;

  /// 폰트 드롭다운에 표시될 폰트 리스트입니다.
  final List<String> fontList;

  /// Bold 버튼이 눌렸을 때 호출될 콜백 함수입니다.
  final VoidCallback onBold;

  /// Italic 버튼이 눌렸을 때 호출될 콜백 함수입니다.
  final VoidCallback onItalic;

  /// Underline 버튼이 눌렸을 때 호출될 콜백 함수입니다.
  final VoidCallback onUnderline;

  /// Letter Spacing 변경이 요청되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<double> onChangeLetterSpacing;

  /// Line Height 변경이 요청되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<double> onChangeLineHeight;

  /// Text Align 변경이 요청되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<TextAlign> onChangeAlign;

  /// Font Family가 변경되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<String> onFontFamilyChanged;

  /// Font Size가 변경되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<double> onFontSizeChanged;

  /// Font Color가 변경되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<Color> onFontColorChanged;

  @override
  Widget build(BuildContext context) {
    final currentStyle = controller.currentStyle;
    final doc = controller.document;
    const fontSizes = [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 32.0];

    return Container(
      height: 56,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 폰트 리스트가 비어있지 않은 경우에만 드롭다운을 표시합니다.
            if (fontList.isNotEmpty)
              DropdownButton<String>(
                value: currentStyle.fontFamily ?? fontList.first,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onFontFamilyChanged(newValue);
                  }
                },
                items: fontList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontFamily: value, fontSize: 14)),
                  );
                }).toList(),
                underline: Container(), // 기본 밑줄 제거
              ),

            const VerticalDivider(),

            // Font size
            DropdownButton<double>(
              value: fontSizes.contains(currentStyle.fontSize) ? currentStyle.fontSize : 14.0,
              onChanged: (double? newValue) {
                if (newValue != null) {
                  onFontSizeChanged(newValue);
                }
              },
              items: fontSizes.map<DropdownMenuItem<double>>((double value) {
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text(value.toInt().toString()),
                );
              }).toList(),
              underline: Container(),
            ),

            const VerticalDivider(),

            // Color Picker
            IconButton(
              icon: Icon(Icons.color_lens, color: currentStyle.color ?? Colors.black),
              onPressed: () => _showColorPicker(context),
            ),

            const VerticalDivider(),

            // Bold 버튼
            IconButton(
              icon: const Icon(Icons.format_bold),
              style: _getButtonStyle(currentStyle.fontWeight == FontWeight.bold),
              onPressed: onBold,
            ),
            // Italic 버튼
            IconButton(
              icon: const Icon(Icons.format_italic),
              style: _getButtonStyle(currentStyle.fontStyle == FontStyle.italic),
              onPressed: onItalic,
            ),
            // Underline 버튼
            IconButton(
              icon: const Icon(Icons.format_underline),
              style: _getButtonStyle(
                  currentStyle.decoration?.contains(TextDecoration.underline) ?? false),
              onPressed: onUnderline,
            ),

            const VerticalDivider(),

            // Align Left
            IconButton(
              icon: const Icon(Icons.format_align_left),
              style: _getButtonStyle(doc.textAlign == TextAlign.left),
              onPressed: () => onChangeAlign(TextAlign.left),
            ),
            // Align Center
            IconButton(
              icon: const Icon(Icons.format_align_center),
              style: _getButtonStyle(doc.textAlign == TextAlign.center),
              onPressed: () => onChangeAlign(TextAlign.center),
            ),
            // Align Right
            IconButton(
              icon: const Icon(Icons.format_align_right),
              style: _getButtonStyle(doc.textAlign == TextAlign.right),
              onPressed: () => onChangeAlign(TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: controller.currentStyle.color ?? Colors.black,
              onColorChanged: onFontColorChanged,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 버튼의 활성화 상태에 따라 다른 배경색을 적용하는 스타일을 반환합니다.
  ButtonStyle _getButtonStyle(bool isActive) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        isActive ? Colors.grey.shade400 : Colors.transparent,
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
    );
  }
}
