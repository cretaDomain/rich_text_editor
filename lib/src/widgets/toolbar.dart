import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../controllers/rich_text_editor_controller.dart';
import 'shadow_settings.dart';
//import 'outline_settings.dart';

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
    required this.onVerticalAlignChanged,
    this.shadow,
    required this.onShadowChanged,
    this.strokeWidth,
    this.strokeColor,
    required this.onOutlineChanged,
    required this.onToggleMode,
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

  /// Vertical Text Align 변경이 요청되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<TextAlignVertical> onVerticalAlignChanged;

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

  final Shadow? shadow;
  final ValueChanged<Shadow?> onShadowChanged;
  final double? strokeWidth;
  final Color? strokeColor;
  final void Function(double? strokeWidth, Color? color) onOutlineChanged;
  final VoidCallback onToggleMode;

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
    if (widget.controller.mode == EditorMode.view) {
      return const SizedBox.shrink();
    }

    final currentStyle = widget.controller.currentStyle;
    final doc = widget.controller.document;

    // 각 도구 그룹을 생성하는 헬퍼 메서드
    Widget buildToolGroup({required List<Widget> children}) {
      return Container(
        height: 66.0, // 모든 그룹에 동일한 높이를 적용합니다.
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // 자식 위젯들을 수직으로 중앙 정렬합니다.
          children: children,
        ),
      );
    }

    return Material(
      elevation: 1.0,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // 모드 전환 버튼
            buildToolGroup(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.red.shade700,
                  tooltip: 'View Mode',
                  onPressed: widget.onToggleMode,
                ),
              ],
            ),

            // 폰트 종류 및 크기
            buildToolGroup(
              children: [
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
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
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
              ],
            ),

            // 색상 선택 및 스타일
            buildToolGroup(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: currentStyle.color ?? Colors.black,
                    ),
                  ),
                  tooltip: 'Change color',
                  onPressed: () => _showColorPicker(context),
                ),
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
              ],
            ),

            // 텍스트 정렬
            buildToolGroup(
              children: [
                ToggleButtons(
                  renderBorder: false,
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                  isSelected: [
                    doc.textAlign == TextAlign.left || doc.textAlign == TextAlign.start,
                    doc.textAlign == TextAlign.center,
                    doc.textAlign == TextAlign.right || doc.textAlign == TextAlign.end,
                    doc.textAlign == TextAlign.justify,
                  ],
                  onPressed: (index) {
                    final aligns = [
                      TextAlign.left,
                      TextAlign.center,
                      TextAlign.right,
                      TextAlign.justify
                    ];
                    widget.onChangeAlign(aligns[index]);
                  },
                  children: const [
                    Icon(Icons.format_align_left),
                    Icon(Icons.format_align_center),
                    Icon(Icons.format_align_right),
                    Icon(Icons.format_align_justify),
                  ],
                ),
              ],
            ),
            // 수직 정렬
            buildToolGroup(
              children: [
                ToggleButtons(
                  renderBorder: false,
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                  isSelected: [
                    doc.textAlignVertical == TextAlignVertical.top,
                    doc.textAlignVertical == TextAlignVertical.center,
                    doc.textAlignVertical == TextAlignVertical.bottom,
                  ],
                  onPressed: (index) {
                    final aligns = [
                      TextAlignVertical.top,
                      TextAlignVertical.center,
                      TextAlignVertical.bottom,
                    ];
                    widget.onVerticalAlignChanged(aligns[index]);
                  },
                  children: const [
                    Icon(Icons.vertical_align_top),
                    Icon(Icons.vertical_align_center),
                    Icon(Icons.vertical_align_bottom),
                  ],
                ),
              ],
            ),

            // 패딩
            buildToolGroup(children: [_buildPaddingControls()]),

            // 그림자
            buildToolGroup(
              children: [
                ShadowSettings(
                  value: widget.shadow,
                  onChanged: widget.onShadowChanged,
                ),
              ],
            ),

            // 자간/행간
            buildToolGroup(
              children: [
                _buildSpacingSlider(
                  label: 'letter spacing',
                  value: widget.controller.currentStyle.letterSpacing ?? 0.0,
                  onChanged: widget.onChangeLetterSpacing,
                  min: -5.0,
                  max: 10.0,
                  divisions: 30,
                ),
                const SizedBox(width: 16),
                _buildSpacingSlider(
                  label: 'line height',
                  value: widget.controller.currentStyle.height ?? 1.0,
                  onChanged: widget.onChangeLineHeight,
                  min: 0.1,
                  max: 3.0,
                  divisions: 25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpacingSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required int divisions,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 12),
        ),
        SizedBox(
          width: 150,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
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
    final theme = Theme.of(context);
    return IconButton.styleFrom(
      foregroundColor: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      backgroundColor: isActive ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    );
  }

  Widget _buildPaddingControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top
        _buildTextField(widget.padding.top, (v) {
          widget.onPaddingChanged(widget.padding.copyWith(top: v));
        }),
        //const SizedBox(height: 2),
        // Middle Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left
            _buildTextField(widget.padding.left, (v) {
              widget.onPaddingChanged(widget.padding.copyWith(left: v));
            }),
            const SizedBox(width: 4),
            // +/- Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIconButton(Icons.add, () {
                  final newValue = (widget.padding.left + 1).clamp(0, double.infinity);
                  widget.onPaddingChanged(EdgeInsets.all(newValue.toDouble()));
                }),
                _buildIconButton(Icons.remove, () {
                  final newValue = (widget.padding.left - 1).clamp(0, double.infinity);
                  widget.onPaddingChanged(EdgeInsets.all(newValue.toDouble()));
                }),
              ],
            ),
            const SizedBox(width: 4),
            // Right
            _buildTextField(widget.padding.right, (v) {
              widget.onPaddingChanged(widget.padding.copyWith(right: v));
            }),
          ],
        ),
        //const SizedBox(height: 2),
        // Bottom
        _buildTextField(widget.padding.bottom, (v) {
          widget.onPaddingChanged(widget.padding.copyWith(bottom: v));
        }),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildTextField(double value, ValueChanged<double> onFieldChanged) {
    return SizedBox(
      width: 30,
      height: 21,
      child: TextFormField(
        controller: TextEditingController(text: value.toInt().toString()),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (text) {
          final newValue = double.tryParse(text) ?? 0.0;
          onFieldChanged(newValue);
        },
      ),
    );
  }
}
