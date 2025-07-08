import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final currentStyle = controller.currentStyle;

    return Container(
      height: 56,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // 폰트 리스트가 비어있지 않은 경우에만 드롭다운을 표시합니다.
          if (fontList.isNotEmpty)
            DropdownButton<String>(
              value: currentStyle.fontFamily ?? fontList.first,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.changeFontFamily(newValue);
                }
              },
              items: fontList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontFamily: value)),
                );
              }).toList(),
              underline: Container(), // 기본 밑줄 제거
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
            style: _getButtonStyle(currentStyle.decoration == TextDecoration.underline),
            onPressed: onUnderline,
          ),
        ],
      ),
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
