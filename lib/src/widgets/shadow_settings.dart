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
        TextEditingController(text: widget.value?.blurRadius.toStringAsFixed(1) ?? '0.0');
    _offsetXController =
        TextEditingController(text: widget.value?.offset.dx.toStringAsFixed(1) ?? '0.0');
    _offsetYController =
        TextEditingController(text: widget.value?.offset.dy.toStringAsFixed(1) ?? '0.0');
    _color = widget.value?.color ?? Colors.black;
  }

  @override
  void didUpdateWidget(ShadowSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateValues();
    }
  }

  void _updateValues() {
    setState(() {
      _blurController.text = widget.value?.blurRadius.toStringAsFixed(1) ?? '0.0';
      _offsetXController.text = widget.value?.offset.dx.toStringAsFixed(1) ?? '0.0';
      _offsetYController.text = widget.value?.offset.dy.toStringAsFixed(1) ?? '0.0';
      _color = widget.value?.color ?? Colors.black;
    });
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

    if (widget.value == null && (blur == 0.0 && offsetX == 0.0 && offsetY == 0.0)) {
      // If there was no shadow and all values are zero, do nothing.
      return;
    }

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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽 컬럼 (레이블, 색상, 삭제 버튼)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shadow:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => widget.onChanged(null),
                    tooltip: 'cancel',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          // 오른쪽 컬럼 (슬라이더 컨트롤)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildValueEditor(
                label: 'B',
                controller: _blurController,
                min: 0,
                max: 50,
              ),
              //const SizedBox(height: 4),
              // X-오프셋 컨트롤
              _buildValueEditor(
                label: 'X',
                controller: _offsetXController,
                min: -50,
                max: 50,
              ),
              //const SizedBox(height: 4),
              // Y-오프셋 컨트롤
              _buildValueEditor(
                label: 'Y',
                controller: _offsetYController,
                min: -50,
                max: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 텍스트필드, 버튼을 포함하는 컨트롤 UI를 생성합니다.
  Widget _buildValueEditor({
    required String label,
    required TextEditingController controller,
    required double min,
    required double max,
  }) {
    return SizedBox(
      height: 20, // 컨트롤의 높이를 지정
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 12, child: Text(label, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 4),
          // Minus Button
          _buildIconButton(
            icon: Icons.remove,
            onPressed: () {
              var value = double.tryParse(controller.text) ?? 0.0;
              value = (value - 1).clamp(min, max);
              controller.text = value.toStringAsFixed(1);
              _onChanged();
            },
          ),
          const SizedBox(width: 4),
          // TextField
          SizedBox(
            width: 40,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(4),
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              onChanged: (v) => _onChanged(),
            ),
          ),
          const SizedBox(width: 4),
          // Plus Button
          _buildIconButton(
            icon: Icons.add,
            onPressed: () {
              var value = double.tryParse(controller.text) ?? 0.0;
              value = (value + 1).clamp(min, max);
              controller.text = value.toStringAsFixed(1);
              _onChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 10,
      ),
    );
  }
}
