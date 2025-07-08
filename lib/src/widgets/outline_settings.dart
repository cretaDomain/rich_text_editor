import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// 텍스트 외곽선 속성을 설정하는 UI를 제공하는 위젯입니다.
class OutlineSettings extends StatefulWidget {
  const OutlineSettings({
    super.key,
    this.strokeWidth,
    this.color,
    required this.onChanged,
  });

  /// 현재 외곽선 두께입니다.
  final double? strokeWidth;

  /// 현재 외곽선 색상입니다.
  final Color? color;

  /// 외곽선 값이 변경되었을 때 호출될 콜백 함수입니다.
  final void Function(double? strokeWidth, Color? color) onChanged;

  @override
  State<OutlineSettings> createState() => _OutlineSettingsState();
}

class _OutlineSettingsState extends State<OutlineSettings> {
  late TextEditingController _strokeWidthController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _strokeWidthController = TextEditingController(text: widget.strokeWidth?.toString() ?? '0');
    _color = widget.color ?? Colors.black;
  }

  @override
  void didUpdateWidget(OutlineSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.strokeWidth != oldWidget.strokeWidth || widget.color != oldWidget.color) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    _strokeWidthController.text = widget.strokeWidth?.toString() ?? '0';
    _color = widget.color ?? Colors.black;
    setState(() {});
  }

  @override
  void dispose() {
    _strokeWidthController.dispose();
    super.dispose();
  }

  void _onChanged() {
    final strokeWidth = double.tryParse(_strokeWidthController.text);
    if (strokeWidth == null || strokeWidth == 0) {
      widget.onChanged(null, null);
    } else {
      widget.onChanged(strokeWidth, _color);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('외곽선 색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _color,
              onColorChanged: (color) => setState(() => _color = color),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onChanged();
              },
              child: const Text('적용'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 24, child: const Text('Outline:', style: TextStyle(fontSize: 14))),
          const SizedBox(width: 4),
          // 색상 선택 버튼
          InkWell(
            onTap: _showColorPicker,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 두께 텍스트 필드
          _buildTextField(
            label: 'width',
            controller: _strokeWidthController,
            onChanged: (v) => _onChanged(),
          ),
          const SizedBox(width: 8),
          // 외곽선 제거 버튼
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => widget.onChanged(null, null),
            tooltip: '외곽선 제거',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: SizedBox(
        width: 48,
        height: 24,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
