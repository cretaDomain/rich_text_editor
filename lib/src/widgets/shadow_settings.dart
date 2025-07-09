import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// 텍스트 그림자 속성을 설정하는 UI를 제공하는 위젯입니다.
class ShadowSettings extends StatefulWidget {
  const ShadowSettings({
    super.key,
    this.value,
    required this.onChanged,
  });

  /// 현재 그림자 값입니다.
  final Shadow? value;

  /// 그림자 값이 변경되었을 때 호출될 콜백 함수입니다.
  final ValueChanged<Shadow?> onChanged;

  @override
  State<ShadowSettings> createState() => _ShadowSettingsState();
}

class _ShadowSettingsState extends State<ShadowSettings> {
  late TextEditingController _blurController;
  late TextEditingController _offsetXController;
  late TextEditingController _offsetYController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _blurController =
        TextEditingController(text: widget.value?.blurRadius.toInt().toString() ?? '0');
    _offsetXController =
        TextEditingController(text: widget.value?.offset.dx.toInt().toString() ?? '0');
    _offsetYController =
        TextEditingController(text: widget.value?.offset.dy.toInt().toString() ?? '0');
    _color = widget.value?.color ?? Colors.black;
  }

  @override
  void didUpdateWidget(ShadowSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    _blurController.text = widget.value?.blurRadius.toInt().toString() ?? '0';
    _offsetXController.text = widget.value?.offset.dx.toInt().toString() ?? '0';
    _offsetYController.text = widget.value?.offset.dy.toInt().toString() ?? '0';
    _color = widget.value?.color ?? Colors.black;
    setState(() {});
  }

  @override
  void dispose() {
    _blurController.dispose();
    _offsetXController.dispose();
    _offsetYController.dispose();
    super.dispose();
  }

  void _onChanged() {
    final blur = double.tryParse(_blurController.text) ?? 0.0;
    final offsetX = double.tryParse(_offsetXController.text) ?? 0.0;
    final offsetY = double.tryParse(_offsetYController.text) ?? 0.0;
    widget.onChanged(
      Shadow(
        color: _color,
        blurRadius: blur,
        offset: Offset(offsetX, offsetY),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('그림자 색상 선택'),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child:
                SizedBox(height: 24, child: const Text('Shadow:', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 4),
          // 색상 선택 버튼
          InkWell(
            onTap: _showColorPicker,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
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
          ),
          const SizedBox(width: 8),
          // 블러 텍스트 필드
          _buildTextField(
            label: 'blur',
            controller: _blurController,
            onChanged: (v) => _onChanged(),
          ),
          const SizedBox(width: 8),
          // X-오프셋 텍스트 필드
          _buildTextField(
            label: 'X',
            controller: _offsetXController,
            onChanged: (v) => _onChanged(),
          ),
          const SizedBox(width: 8),
          // Y-오프셋 텍스트 필드
          _buildTextField(
            label: 'Y',
            controller: _offsetYController,
            onChanged: (v) => _onChanged(),
          ),
          const SizedBox(width: 8),
          // 그림자 제거 버튼
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => widget.onChanged(null),
            tooltip: '그림자 제거',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 텍스트 필드 UI를 생성하는 헬퍼 위젯입니다.
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
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*'))],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
