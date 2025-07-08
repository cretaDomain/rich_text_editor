import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../controllers/rich_text_editor_controller.dart';

/// 텍스트 스타일링을 위한 도구 모음(Toolbar) 위젯입니다.
class Toolbar extends StatefulWidget {
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
    required this.padding,
    required this.onPaddingChanged,
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

  /// 현재 에디터의 여백 값입니다.
  final EdgeInsets padding;

  /// 여백 값이 변경되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<EdgeInsets> onPaddingChanged;

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  late final TextEditingController _fontSizeController;

  @override
  void initState() {
    super.initState();
    // 초기 폰트 크기는 14로 설정합니다. 이 값은 외부 상태와 동기화되지 않습니다.
    _fontSizeController = TextEditingController(text: '14');
  }

  @override
  void dispose() {
    _fontSizeController.dispose();
    super.dispose();
  }

  void _changeFontSize(double newSize) {
    // 폰트 크기를 10-256 사이로 제한합니다.
    final clampedSize = newSize.clamp(10.0, 256.0);
    // 변경된 값을 외부로 알립니다.
    widget.onFontSizeChanged(clampedSize);
    // 내부 텍스트 필드의 값도 갱신합니다.
    _fontSizeController.text = clampedSize.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = widget.controller.currentStyle;
    final doc = widget.controller.document;

    return Container(
      height: 56,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 폰트 종류
            if (widget.fontList.isNotEmpty)
              DropdownButton<String>(
                value: currentStyle.fontFamily ?? widget.fontList.first,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.onFontFamilyChanged(newValue);
                  }
                },
                items: widget.fontList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontFamily: value, fontSize: 14)),
                  );
                }).toList(),
                underline: Container(),
              ),
            const SizedBox(width: 8),
            const VerticalDivider(),
            const SizedBox(width: 8),

            // 폰트 크기
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                final currentSize = double.tryParse(_fontSizeController.text) ?? 14.0;
                _changeFontSize(currentSize - 1);
              },
            ),
            SizedBox(
              width: 40,
              child: TextFormField(
                controller: _fontSizeController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(border: InputBorder.none),
                onFieldSubmitted: (value) {
                  final size = double.tryParse(value);
                  if (size != null) {
                    _changeFontSize(size);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final currentSize = double.tryParse(_fontSizeController.text) ?? 14.0;
                _changeFontSize(currentSize + 1);
              },
            ),
            const SizedBox(width: 8),
            const VerticalDivider(),
            const SizedBox(width: 8),

            // 색상 선택
            IconButton(
              icon: Icon(Icons.color_lens, color: currentStyle.color ?? Colors.black),
              onPressed: () => _showColorPicker(context),
            ),

            const VerticalDivider(),

            // 스타일 버튼들
            IconButton(
              icon: const Icon(Icons.format_bold),
              style: _getButtonStyle(currentStyle.fontWeight == FontWeight.bold),
              onPressed: widget.onBold,
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              style: _getButtonStyle(currentStyle.fontStyle == FontStyle.italic),
              onPressed: widget.onItalic,
            ),
            IconButton(
              icon: const Icon(Icons.format_underline),
              style: _getButtonStyle(
                  currentStyle.decoration?.contains(TextDecoration.underline) ?? false),
              onPressed: widget.onUnderline,
            ),

            const VerticalDivider(),

            // 정렬 버튼들
            IconButton(
              icon: const Icon(Icons.format_align_left),
              style: _getButtonStyle(
                  doc.textAlign == TextAlign.left || doc.textAlign == TextAlign.start),
              onPressed: () => widget.onChangeAlign(TextAlign.left),
            ),
            IconButton(
              icon: const Icon(Icons.format_align_center),
              style: _getButtonStyle(doc.textAlign == TextAlign.center),
              onPressed: () => widget.onChangeAlign(TextAlign.center),
            ),
            IconButton(
              icon: const Icon(Icons.format_align_right),
              style: _getButtonStyle(
                  doc.textAlign == TextAlign.right || doc.textAlign == TextAlign.end),
              onPressed: () => widget.onChangeAlign(TextAlign.right),
            ),
            const VerticalDivider(),
            _buildPaddingControls(),
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
              pickerColor: widget.controller.currentStyle.color ?? Colors.black,
              onColorChanged: widget.onFontColorChanged,
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

  Widget _buildPaddingControls() {
    final currentPadding = widget.padding;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPaddingInput('좌', currentPadding.left, (v) {
          widget.onPaddingChanged(currentPadding.copyWith(left: v));
        }),
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaddingInput('상', currentPadding.top, (v) {
              widget.onPaddingChanged(currentPadding.copyWith(top: v));
            }),
            const SizedBox(height: 2),
            _buildPaddingInput('하', currentPadding.bottom, (v) {
              widget.onPaddingChanged(currentPadding.copyWith(bottom: v));
            }),
          ],
        ),
        const SizedBox(width: 4),
        _buildPaddingInput('우', currentPadding.right, (v) {
          widget.onPaddingChanged(currentPadding.copyWith(right: v));
        }),
      ],
    );
  }

  Widget _buildPaddingInput(String hint, double value, ValueChanged<double> onChanged) {
    final controller = TextEditingController(text: value.toInt().toString());
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    return SizedBox(
      width: 25,
      height: 25,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.zero,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (text) {
          final newValue = double.tryParse(text) ?? 0.0;
          onChanged(newValue);
        },
      ),
    );
  }
}
