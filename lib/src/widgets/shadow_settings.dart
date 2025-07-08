import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 텍스트 그림자 속성을 설정하는 UI를 제공하는 위젯입니다.
class ShadowSettings extends StatelessWidget {
  const ShadowSettings({
    super.key,
    // TODO: 실제 그림자 값과 콜백 함수를 연결해야 합니다.
  });

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
          SizedBox(height: 24, child: const Text('Shadow:', style: TextStyle(fontSize: 14))),
          const SizedBox(width: 4),
          // 색상 선택 버튼 (임시)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          // 블러 텍스트 필드
          _buildTextField(
            label: 'blur',
            value: '0',
            onChanged: (v) {},
          ),
          const SizedBox(width: 8),
          // X-오프셋 텍스트 필드
          _buildTextField(
            label: 'X',
            value: '0',
            onChanged: (v) {},
          ),
          const SizedBox(width: 8),
          // Y-오프셋 텍스트 필드
          _buildTextField(
            label: 'Y',
            value: '0',
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }

  /// 텍스트 필드 UI를 생성하는 헬퍼 위젯입니다.
  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: 48,
      height: 24,
      child: TextField(
        controller: TextEditingController(text: value),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          //contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*'))],
        onChanged: onChanged,
      ),
    );
  }
}
